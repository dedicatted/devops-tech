package test

import (
	"os"
	"testing"
	"os/exec"
	"encoding/json"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/kms"
	"github.com/stretchr/testify/assert"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

type Subnet struct {
	SubnetID string `json:"SubnetId"`
}

func CreateKMSKey(t *testing.T) {
	creds := credentials.NewStaticCredentials(os.Getenv("AWS_ACCESS_KEY_ID"), os.Getenv("AWS_SECRET_ACCESS_KEY"), "")
	sess, err := session.NewSession(&aws.Config{
		Region:      aws.String("us-east-1"),
		Credentials: creds,
	})
	if err != nil {
		t.Fatalf("Error creating session: %s", err)
	}
	svc := kms.New(sess)
	resp, err := svc.CreateKey(&kms.CreateKeyInput{})
	if err != nil {
		t.Fatalf("Error creating KMS key: %s", err)
	}
	assert.NotNil(t, resp.KeyMetadata)
	kmsKeyARN := *resp.KeyMetadata.Arn
	os.Setenv("TF_VAR_kms_key_arn", kmsKeyARN)
}

func scheduleKMSKeyDeletion(t *testing.T) error {
	creds := credentials.NewStaticCredentials(os.Getenv("AWS_ACCESS_KEY_ID"), os.Getenv("AWS_SECRET_ACCESS_KEY"), "")
	sess, err := session.NewSession(&aws.Config{
		Region:      aws.String("us-east-1"),
		Credentials: creds,
	})
	if err != nil {
		return err
	}
	svc := kms.New(sess)
	kmsKeyARN := os.Getenv("TF_VAR_kms_key_arn")
	_, err = svc.ScheduleKeyDeletion(&kms.ScheduleKeyDeletionInput{
		KeyId:               aws.String(kmsKeyARN),
		PendingWindowInDays: aws.Int64(7),
	})
	if err != nil {
		return err
	}
	return nil
}

func TestCreateDBSubnetGroupWithAWSCLI(t *testing.T) {
	describeSubnetsCmd := exec.Command("aws", "ec2", "describe-subnets")
	describeSubnetsOutput, err := describeSubnetsCmd.CombinedOutput()
	if err != nil {
		t.Fatalf("Failed to describe subnets: %s", err)
	}
	var awsSubnets struct {
		Subnets []Subnet `json:"Subnets"`
	}
	err = json.Unmarshal(describeSubnetsOutput, &awsSubnets)
	if err != nil {
		t.Fatalf("Failed to unmarshal JSON: %s", err)
	}
	subnetIDs := make([]string, len(awsSubnets.Subnets))
	for i, subnet := range awsSubnets.Subnets {
		subnetIDs[i] = subnet.SubnetID
	}
	DbSubnetGroupName := "my-subnet-group"
	subnetArgs := []string{"--subnet-ids"}
	subnetArgs = append(subnetArgs, subnetIDs...)
	createDbSubnetGroupArgs := []string{
		"aws", "rds", "create-db-subnet-group",
		"--db-subnet-group-name", DbSubnetGroupName,
		"--db-subnet-group-description", "My Subnet Group",
	}
	createDbSubnetGroupArgs = append(createDbSubnetGroupArgs, subnetArgs...)
	createDbSubnetGroupCmd := exec.Command(createDbSubnetGroupArgs[0], createDbSubnetGroupArgs[1:]...)
	cmdOutput, err := createDbSubnetGroupCmd.CombinedOutput()
	if err != nil {
		t.Fatalf("Failed to create db subnet group. Error: %s\nOutput:\n%s", err, cmdOutput)
	}
}

func TestRDS(t *testing.T) {
	CreateKMSKey(t) // Create KMS Key before running the tests

	DbSubnetGroupName := "my-subnet-group"
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../terraform-aws-rds",
		EnvVars: map[string]string{
			"TF_VAR_db_subnet_group_name": DbSubnetGroupName,
		},
	})
	terraform.InitAndApply(t, terraformOptions)
	defer func() {
		terraform.Destroy(t, terraformOptions)
		err := scheduleKMSKeyDeletion(t)
		if err != nil {
			t.Fatalf("Error scheduling KMS key deletion: %s", err)
		}
		deleteDbSubnetGroupCmd := exec.Command("aws", "rds", "delete-db-subnet-group", "--db-subnet-group-name", DbSubnetGroupName)
		deleteDbSubnetGroupOutput, deleteErr := deleteDbSubnetGroupCmd.CombinedOutput()
		if deleteErr != nil {
			t.Logf("Failed to delete db subnet group: %s", deleteErr)
		} else {
			t.Logf("Deleted DB Subnet Group: %s\nOutput:\n%s", DbSubnetGroupName, deleteDbSubnetGroupOutput)
		}
	}()
}
