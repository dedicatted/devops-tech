package main

import (
	"bytes"
	"compress/gzip"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"os"
	"strconv"

	// "runtime"
	"sort"
	"time"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/cloudwatchlogs"
	"github.com/aws/aws-sdk-go/service/kinesis"
)

const BatchSizeInLogStreams = 51

type Event struct {
	ID        string `json:"id"`
	Timestamp int64  `json:"timestamp"`
	Message   string `json:"message"`
}

type Message struct {
	LogGroup  string                          `json:"logGroup"`
	LogStream string                          `json:"logStream"`
	LogEvents []*cloudwatchlogs.InputLogEvent `json:"logEvents"`
}

var LogGroupWhitelist = make(map[string]struct{})
var LogStreamWhitelist = make(map[string]struct{})
var MessageBatch = make(map[string]*Message, BatchSizeInLogStreams)
var stopIterator int = 0

func Handler(ctx context.Context) (string, error) {
	invoke()
	// Your function logic goes here
	return "Success", nil
}

func main() {
	lambda.Start(Handler)

	// For local benchmarking purposes
	// var m1, m2 runtime.MemStats
	// var t1, t2 time.Time
	// runtime.GC()
	// runtime.ReadMemStats(&m1)
	// t1 = time.Now()
	// invoke()
	// t2 = time.Now()
	// fmt.Printf("Time taken: %v\n", t2.Sub(t1))
	// runtime.ReadMemStats(&m2)
	// fmt.Printf("Total Allocated: %fkb\n", float32(m2.TotalAlloc-m1.TotalAlloc)/1000)
	// fmt.Printf("Total mallocs: %d\n", m2.Mallocs-m1.Mallocs)
}

func GetEnv(envName string) string {
	env, ok := os.LookupEnv(envName)
	if !ok {
		log.Panicf("env %s not found\n", envName)
	}
	return env
}

func GetEnvInt(envName string) int64 {
	env, ok := os.LookupEnv(envName)
	if !ok {
		log.Panicf("env %s not found\n", envName)
	}
	x, err := strconv.ParseInt(env, 10, 64)
	if err != nil {
		log.Panicf("cannot parse %s to int", env)
	}
	return x
}

func invoke() {
	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))

	kc := kinesis.New(sess)
	logs := cloudwatchlogs.New(sess)
	streamName := aws.String(GetEnv("KINESIS_STREAM_NAME"))
	streams, err := kc.DescribeStream(&kinesis.DescribeStreamInput{StreamName: streamName})
	if err != nil {
		log.Panic(err)
	}
	log.Println("Accessed the stream")
	
	timeFromStart := time.Now().Add(time.Duration(-GetEnvInt("HOURS_FROM_START")) * time.Hour) //.AddDate(0, 0, -1)
	log.Printf("Starting from timestamp: %v\n", timeFromStart)

	// retrieve iterator
	iteratorOutput, err := kc.GetShardIterator(&kinesis.GetShardIteratorInput{
		// Shard Id is provided when making put record(s) request.
		ShardId:           aws.String(*streams.StreamDescription.Shards[0].ShardId),
		Timestamp:         &timeFromStart,
		ShardIteratorType: aws.String("AT_TIMESTAMP"),
		StreamName:        streamName,
	})
	if err != nil {
		log.Panic(err)
	}
	log.Println("Got shard iterator")

	shardIterator := iteratorOutput.ShardIterator
	var a *string

	// get data using infinity looping
	for {
		// get records use shard iterator for making request
		records, err := kc.GetRecords(&kinesis.GetRecordsInput{
			ShardIterator: shardIterator,
		})

		// if error, wait until 1 seconds and continue the looping process
		if err != nil {
			log.Println(err)
			time.Sleep(1 * time.Second)
			stopIterator++
			if stopIterator > 20 {
				return
			}
			continue
		}

		// process the data
		if len(records.Records) > 0 {
			for _, record := range records.Records {
				// Unzip and unmarshal the data
				parsed, err := Unzip(record.Data)
				if err != nil {
					log.Printf("GetRecords ERROR: %v\n", err)
					break
				}
				data := Message{}
				json.Unmarshal(parsed, &data)
				
				// Optional logging for debugging
				// log.Printf("Message: %s %s %v\n", data.LogGroup, data.LogStream, time.Unix(0, *data.LogEvents[0].Timestamp*int64(time.Millisecond)))

				if _, ok := MessageBatch[data.LogStream]; !ok {
					// Add to batch
					MessageBatch[data.LogStream] = &data

					if len(MessageBatch) > 50 {
						// Print the timestamp of the first log event (to validate that the data is fresh)
						log.Printf("Active time at: %v\n", time.Unix(0, *MessageBatch[data.LogStream].LogEvents[0].Timestamp*int64(time.Millisecond)))
						if err := PostBatch(logs); err != nil {
							log.Printf("PutToCloudwatch ERROR: %v\n", err)
							break
						}
					}
				} else {
					MessageBatch[data.LogStream].LogEvents = append(MessageBatch[data.LogStream].LogEvents, data.LogEvents...)
					if len(MessageBatch[data.LogStream].LogEvents) > 120 {
						log.Printf("Active time at: %v\n", time.Unix(0, *MessageBatch[data.LogStream].LogEvents[0].Timestamp*int64(time.Millisecond)))
						if err := PostBatch(logs); err != nil {
							log.Printf("PutToCloudwatch ERROR: %v\n", err)
							break
						}
					}
				}
			}
		} else if records.NextShardIterator == a || shardIterator == records.NextShardIterator || err != nil {
			log.Printf("GetRecords ERROR: %v\n", err)
			break
		}
		log.Println("No new data")
		if err := PostBatch(logs); err != nil {
			log.Printf("PutToCloudwatch ERROR: %v\n", err)
			break
		}
		shardIterator = records.NextShardIterator
		// time.Sleep(1 * time.Second)
		stopIterator++
		if stopIterator > 20 {
			log.Println("All data batches processed.")
			return
		}
	}
}

func PostBatch(logs *cloudwatchlogs.CloudWatchLogs) error {
	if len(MessageBatch) == 0 {
		return nil
	}
	log.Print("Posting batch")
	totalEvents := 0
	for _, msg := range MessageBatch {
		totalEvents += len(msg.LogEvents)
		err := PutToCloudwatch(logs, msg)
		if err != nil {
			log.Printf("PutToCloudwatch ERROR: %v\n", err)
			continue
		}
	}
	log.Printf("Events posted: %d\n", totalEvents)
	
	// Clear batch after posting
	MessageBatch = make(map[string]*Message, BatchSizeInLogStreams)
	return nil
}

func Unzip(data []byte) ([]byte, error) {
	rdata := bytes.NewReader(data)
	r, err := gzip.NewReader(rdata)
	if err != nil {
		return nil, err
	}
	uncompressedData, err := io.ReadAll(r)
	if err != nil {
		return nil, err
	}
	return uncompressedData, nil
}

func PutToCloudwatch(logs *cloudwatchlogs.CloudWatchLogs, data *Message) error {
	if _, ok := LogGroupWhitelist[data.LogGroup]; !ok {
		exists, err := logGroupExists(logs, data.LogGroup)
		if err != nil {
			return fmt.Errorf("error checking log group existence: %v", err)
		}

		// If the log group does not exist, create it
		if !exists {
			_, err = logs.CreateLogGroup(&cloudwatchlogs.CreateLogGroupInput{
				LogGroupName: aws.String(data.LogGroup),
			})
			if err != nil {
				return fmt.Errorf("failed to create log group: %v", err)
			}

			retentionDays := int64(30) // Set the desired retention period in days

			// Set the retention period for the log group
			putRetentionPolicyInput := &cloudwatchlogs.PutRetentionPolicyInput{
				LogGroupName:    aws.String(data.LogGroup),
				RetentionInDays: aws.Int64(retentionDays),
			}

			_, err := logs.PutRetentionPolicy(putRetentionPolicyInput)
			if err != nil {
				return fmt.Errorf("failed to set log group retention: %v", err)
			}
		}
		// Add to whitelist to avoid checks
		LogGroupWhitelist[data.LogGroup] = struct{}{}
	}

	if _, ok := LogStreamWhitelist[data.LogStream]; !ok {
		exists, err := logStreamExists(logs, data.LogGroup, data.LogStream)
		if err != nil {
			return fmt.Errorf("frror checking log stream existence: %v", err)
		}

		// If the log stream does not exist, create it
		if !exists {
			_, err = logs.CreateLogStream(&cloudwatchlogs.CreateLogStreamInput{
				LogGroupName:  aws.String(data.LogGroup),
				LogStreamName: aws.String(data.LogStream),
			})
			if err != nil {
				return fmt.Errorf("failed to create log stream: %v", err)
			}
		}
		// Add to whitelist to avoid checks
		LogStreamWhitelist[data.LogStream] = struct{}{}
	}

	logEventInput := &cloudwatchlogs.PutLogEventsInput{
		LogGroupName:  aws.String(data.LogGroup),
		LogStreamName: aws.String(data.LogStream),
		LogEvents:     data.LogEvents,
	}

	// Sort the resulting batch (sometimes log events can be out of order by date, which will result in an error)
	sort.Slice(logEventInput.LogEvents, func(i, j int) bool {
		a := *data.LogEvents[i]
		b := *data.LogEvents[j]
		return *a.Timestamp < *b.Timestamp
	})

	_, err := logs.PutLogEvents(logEventInput)
	if err != nil {
		aerr, ok := err.(awserr.Error)
		if !ok {
			return logEventError(err)
		}
		// Avoid breaching the PutLogEvents batch size limit of 1,048,576 bytes by splitting batch on 2 halves
		switch aerr.Code() {
		case cloudwatchlogs.ErrCodeInvalidParameterException:
			totalLength := len(data.LogEvents)
			if _, err := logs.PutLogEvents(&cloudwatchlogs.PutLogEventsInput{
				LogGroupName:  aws.String(data.LogGroup),
				LogStreamName: aws.String(data.LogStream),
				LogEvents:     data.LogEvents[:totalLength/2],
			}); err != nil {
				return logEventError(fmt.Errorf("left batch half: %v", err))
			}

			if _, err := logs.PutLogEvents(&cloudwatchlogs.PutLogEventsInput{
				LogGroupName:  aws.String(data.LogGroup),
				LogStreamName: aws.String(data.LogStream),
				LogEvents:     data.LogEvents[totalLength/2:],
			}); err != nil {
				return logEventError(fmt.Errorf("right batch half: %v", err))
			}
		default:
			return logEventError(err)
		}
	}

	return nil
}

func logEventError(err error) error {
	return fmt.Errorf("failed to post log events: %v", err)
}

func logGroupExists(svc *cloudwatchlogs.CloudWatchLogs, logGroupName string) (bool, error) {
	describeLogGroupsInput := &cloudwatchlogs.DescribeLogGroupsInput{
		LogGroupNamePrefix: aws.String(logGroupName),
	}

	describeLogGroupsOutput, err := svc.DescribeLogGroups(describeLogGroupsInput)
	if err != nil {
		return false, err
	}

	for _, group := range describeLogGroupsOutput.LogGroups {
		if aws.StringValue(group.LogGroupName) == logGroupName {
			return true, nil
		}
	}

	return false, nil
}

func logStreamExists(svc *cloudwatchlogs.CloudWatchLogs, logGroupName, logStreamName string) (bool, error) {
	describeLogStreamsInput := &cloudwatchlogs.DescribeLogStreamsInput{
		LogGroupName:        aws.String(logGroupName),
		LogStreamNamePrefix: aws.String(logStreamName),
	}

	describeLogStreamsOutput, err := svc.DescribeLogStreams(describeLogStreamsInput)
	if err != nil {
		return false, err
	}

	for _, stream := range describeLogStreamsOutput.LogStreams {
		if aws.StringValue(stream.LogStreamName) == logStreamName {
			return true, nil
		}
	}

	return false, nil
}
