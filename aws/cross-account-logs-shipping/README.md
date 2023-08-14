# Cross-account Log Transfer with Kinesis Data Streams and AWS Lambda

### Introduction
Recently, our project presented an interesting challenge for our team. We were assigned the task of transferring logging entries to separate accounts, 
following the AWS best practice of not retaining them on the main account. This particular requirement motivated us to delve into creating a custom solution that could effectively utilize Kinesis Data Streams, 
helping minimize costs associated with this task.
The decision to leverage Kinesis Data Streams was driven by its ability to efficiently handle the real-time streaming of data, ensuring that our logging entries could be seamlessly and securely transferred to 
the designated separate accounts. By adopting this approach, we aimed not only to adhere to the recommended best practices but also to optimize the overall efficiency of our logging process.

### General Solution and Proposed AWS Services
Kinesis Data Streams is a real-time data streaming serverless service provided by AWS. 
It is designed to handle and process vast amounts of data, making it an excellent solution for transferring logs to separate accounts.

![img.png](img.png)

The general idea is to post Cloudwatch Logs to Kinesis Data stream from the main account, then parse it with Lambda function and put all events (effectively) to Cloudwatch Logs on Logs account. 
The Kinesis Data Streams account location is debatable.

### Implementation

#### 1. Kinesis and IAM roles

Before the deployment of Kinesis several points should be considered:

- Cloud Watch Logs Subscription filters support both same-account and cross-account Kinesis subscription (with Log Destination ARN)
- It is impossible to pass IAM roles across accounts

It was decided to deploy Kinesis Data stream on Logs account, create *log_destination* resource, which will absorb IAM roles/policies and pass the ARN to main account Log groups. 
The detailed scheme is provided below:

![img_1.png](img_1.png)

#### 2. Lambda

For any function deployed on Lambda it is important to be as performance-efficient as possible, that's why Go-lang is a perfect choice for this task. 
Here's a code to parse Log events and put them to Cloud Watch Logs.

```
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
```

Notes:
- AWS-SDK uses permissions that are provided with IAM policies assigned to it
- Lambda function automatically creates the incoming log groups and streams, and minimizes API calls to check them by caching already existing resources names
- The code aggregates all incoming log events in batches to reduce the amount of calls and ensure the performance and minimal runtime

#### 3. Deployment & Operational (Terraform and Terraform Cloud)
As the setup requires configuring both accounts, origin and logs, we need to create separate modules with necessary outputs and data sources. 
Let's declare the main parts of it.

- Logs account module requires the deployment of Kinesis Data stream, Lambda function, additional alerts/dashboards for it and the *aws_cloudwatch_log_destination* resource.

Kinesis deployment:

```
resource "aws_kinesis_stream" "log_stream" {
  name = "kinesis-logging-stream-${var.environment}"

  shard_count      = 2
  retention_period = 24

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
    "IncomingRecords",
    "OutgoingRecords",
    "IteratorAgeMilliseconds"
  ]

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }
}
```

Here you can declare the amount of shards, retention period, and preferred metric with which you want to monitor Kinesis.
A capacity mode, as the official documentation states, determines how the capacity of a data stream is managed and how you are charged for the usage of your data stream.

- *On-demand* - data streams with an on-demand mode require no capacity planning and automatically scale to handle gigabytes of write and read throughput per minute.
- *Provisioned* - for the data streams with a provisioned mode, you must specify the number of shards for the data stream.

- Log destination and IAM roles and policies:

```
resource "aws_cloudwatch_log_destination" "kinesis_log_destination" {
  name       = "kinesis-log-destination"
  role_arn   = aws_iam_role.logs_kinesis_role.arn
  target_arn = aws_kinesis_stream.log_stream.arn
}

resource "aws_cloudwatch_log_destination_policy" "kinesis_log_destination_policy" {
  destination_name = aws_cloudwatch_log_destination.kinesis_log_destination.name
  access_policy    = <<EOF
{
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Sid" : "",
      "Effect" : "Allow",
      "Principal" : {
        "AWS" : "${var.source_account_id}"
      },
      "Action" : "logs:PutSubscriptionFilter",
      "Resource" : "${aws_cloudwatch_log_destination.kinesis_log_destination.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role" "logs_kinesis_role" {
  name               = "kinesis-cloudwatch-logs-producer-role"
  assume_role_policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "logs.amazonaws.com"
            },
            "Action": "sts:AssumeRole",
            "Condition": {
                "StringLike": {
                    "aws:SourceArn": [
                        "arn:aws:logs:us-west-2:${var.source_account_id}:*",
"arn:aws:logs:us-west-2:${var.this_account_id}:*"
                    ]
                }
            }
        }
    ]
}
EOF
}

resource "aws_iam_policy" "logs_kinesis_policy" {
  name        = "kinesis-cloudwatch-logs-producer-policy"
  path        = "/"
  description = "IAM policy for CloudWatch Logs to put records to Kinesis on another account."

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kinesis:PutRecord",
        "kinesis:PutRecords"
      ],
      "Resource": "${aws_kinesis_stream.log_stream.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "kinesis_role_policy_attachment" {
  role       = aws_iam_role.logs_kinesis_role.name
  policy_arn = aws_iam_policy.logs_kinesis_policy.arn
}
Lambda function and alert deployment (we'll use the alert for duration > than 15 minutes):

locals {
  archive_path = "${path.module}/lambda_code/code.zip"
  // Provide the time in hours from where you need to start picking up logs (e.g Lambda runs every 6 hours and picks up all the incoming logs from 6 hours to the past)
  hours_from_start = 6
}

resource "aws_lambda_function" "kinesis_lambda" {
  function_name = "kinesis-data-lambda"
  description   = "Lambda for retrieving logs from Kinesis Data Stream"
  handler       = "main"
  filename      = local.archive_path
  role          = aws_iam_role.kinesis_lambda_role.arn
  runtime       = "go1.x"
  timeout       = 900

  environment {
    variables = {
      KINESIS_STREAM_NAME = "kinesis-logging-stream-${var.environment}"
      HOURS_FROM_START    = local.hours_from_start
    }
  }
}

resource "aws_iam_role" "kinesis_lambda_role" {
  name = "kinesis-data-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "kinesis_lambda_policy_attachment_cloudwatch" {
  name       = "kinesis-data-lambda-policy-attachment-cloudwatch"
  roles      = [aws_iam_role.kinesis_lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
}

resource "aws_iam_policy_attachment" "kinesis_lambda_policy_attachment_get_records" {
  name       = "kinesis-data-lambda-policy-kinesis-get-records"
  roles      = [aws_iam_role.kinesis_lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaKinesisExecutionRole"
}

resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name                = "kinesis-data-lambda-schedule-rule"
  description         = "Rule to trigger Kinesis Lambda every ${local.hours_from_start} hours"
  schedule_expression = "rate(${local.hours_from_start} hours)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule.name
  target_id = "lambda-target"
  arn       = aws_lambda_function.kinesis_lambda.arn
}

resource "aws_lambda_permission" "eventbridge_lambda_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.kinesis_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule.arn}

resource "aws_cloudwatch_metric_alarm" "kinesis_lambda_alarm" {
  alarm_name          = "kinesis-lambda-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 600000
  alarm_description   = "Kinesis Lambda function Duration exceeded 10 minutes"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts_notifications_topic.arn]
  dimensions = {
    FunctionName = aws_lambda_function.kinesis_lambda.function_name
  }
}

resource "aws_sns_topic" "alerts_notifications_topic" {
  name = "alerts-notifications"
}

resource "aws_sns_topic_subscription" "alerts_notifications_sub" {
  topic_arn = aws_sns_topic.alerts_notifications_topic.arn
  protocol  = "https"
  // We are using AWS Chatbot for sending messages to Slack, choose your own approach here
  endpoint  = var.aws_chatbot_url
}
```

This approach proposes building a Golang code into binary and then zipping it by hand for the deployment. 

Here's a little list of commands to do it:

```
These are instructions to build Go binary to deploy new versions of code on Lambda (from https://github.com/aws/aws-lambda-go)

On Linux:
GOOS=linux GOARCH=amd64 go build -ldflags "-s -w" -o main main.go
zip code.zip main
On Windows:

Get the tool
go.exe install github.com/aws/aws-lambda-go/cmd/build-lambda-zip@latest
in Powershell:

$env:GOOS = "linux"
$env:GOARCH = "amd64"
$env:CGO_ENABLED = "0"
go build -ldflags "-s -w" -o main main.go
~\Go\Bin\build-lambda-zip.exe -o code.zip main
```

The full list of variables in this module:

```
variable "environment" {
  description = "What is the environment?"
}

variable "source_account_id" {
  description = "What is the Source Account ID with Cloudwatch Logs to be taken from?"
}

variable "this_account_id" {
  description = "What is this Account's ID?"
}
```

Main account module requires configuring each log group to add a Kinesis destination subscription filter.

```
data "aws_cloudwatch_log_groups" "log_groups" {}

resource "aws_cloudwatch_log_subscription_filter" "kinesis_sub_filter" {
  for_each        = { for index, name in setsubtract(data.aws_cloudwatch_log_groups.log_groups.log_group_names, var.log_group_ignore_list) : index => name }
  name            = "kinesis-logging-sub"
  log_group_name  = each.value
  filter_pattern  = ""
  destination_arn = var.destination_arn
  distribution    = "ByLogStream"
}
```

We're also declaring a variable log_group_ignore_list, in which all the declared Log group names (for example via Terraform Cloud) will be excluded from assignment of a subscription filter.
The full modules code is provided in this GitHub repository.

The configuration of workspaces for each account is as follows:
- Main account

```
data "terraform_remote_state" "log_account" {
  backend = "remote"

  config = {
    // Provide a configuration for your Terraform Cloud workspace from which you will get the destination ARN from output. Otherwise use a variable
    organization = "..."
    workspaces = {
      name = "..."
    }
  }
}

module "kinesis_log_sharing" {
  source = "..."

  environment           = "..."
  destination_arn       = data.terraform_remote_state.log_account.outputs.destination_arn
  log_group_ignore_list = var.log_group_ignore_list
}
```

- Logs account

```
// For these data sources please provide 2 AWS providers with Main and Logs accounts, or declare variables with Account IDs
data "aws_caller_identity" "source" {
  provider = aws.source
}

data "aws_caller_identity" "this" {
  provider = aws
}

module "kinesis_stream" {
  source = "..."

  environment       = "..."
  source_account_id = data.aws_caller_identity.source.account_id
  this_account_id   = data.aws_caller_identity.this.account_id
}

output "destination_arn" {
  description = "Source account Cloudwatch Logs Destination ARN"
  value       = module.kinesis_stream.destination_arn
}
```

#### Conclusion & Costs
To sum up, the resulting configuration transfers logs from source account to the Logging account with minimal cost expenses every N hours (configurable in terraform for Lambda configuration). 
The total cost mostly depends on your preferable operation speed, depending on the amount of Kinesis shards you deploy (each shard provides a capacity of 1 MB/s). 
The amount of data, if reasonable, shouldn't affect the cost too much.

Here's the Pricing Calculator stats:

![img_2.png](img_2.png)

![img_3.png](img_3.png)

Also be sure to review your existing log groups on the main account and change their retention period as preferred.


Lambda Source code could be found here in directory [source-code](cross-account-logs-shipping%2Fsource-code).

#### Authors:
- Oleksandr Yudakov
- George Levytskyy
