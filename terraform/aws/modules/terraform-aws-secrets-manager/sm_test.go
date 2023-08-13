package test

import (
	"fmt"
	"os"
	"testing"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/kms"
	"github.com/aws/aws-sdk-go/service/secretsmanager"
	"github.com/stretchr/testify/assert"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func CreateKMSKey(t *testing.T) {
	// Create AWS credentials with environment variables
	creds := credentials.NewStaticCredentials(os.Getenv("AWS_ACCESS_KEY_ID"), os.Getenv("AWS_SECRET_ACCESS_KEY"), "")

	// Initialize an AWS session with custom credentials
	sess, err := session.NewSession(&aws.Config{
		Region:      aws.String("us-east-1"),
		Credentials: creds,
	})
	if err != nil {
		t.Fatalf("Error creating session: %s", err)
	}

	// Create a KMS service client
	svc := kms.New(sess)

	// Create the KMS key
	resp, err := svc.CreateKey(&kms.CreateKeyInput{})
	if err != nil {
		t.Fatalf("Error creating KMS key: %s", err)
	}

	// Ensure the response contains the KeyMetadata
	assert.NotNil(t, resp.KeyMetadata)

	// Export the ARN of the created KMS key to an environment variable
	kmsKeyARN := *resp.KeyMetadata.Arn
	os.Setenv("TF_VAR_kms_key_arn", kmsKeyARN)

	fmt.Println("KMS Key ID:", *resp.KeyMetadata.KeyId)
	fmt.Println("KMS Key ARN:", kmsKeyARN)

}

func TestWAF(t *testing.T) {

	CreateKMSKey(t)
	// Construct the terraform options with default retryable errors to handle the most common
	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: "../terraform-aws-secrets-manager",
	})

	// Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	// Clean up resources with "terraform destroy" at the end of the test.
	defer func() {
		terraform.Destroy(t, terraformOptions)
		// Schedule KMS key deletion after destroying the infrastructure
		err := scheduleKMSKeyDeletion(t)
		if err != nil {
			t.Fatalf("Error scheduling KMS key deletion: %s", err)
		}

		secretIDs := []string{"key1", "key2"} // Add your secret IDs here
		err = removeSecretsAfterDestroy(t, secretIDs)
		if err != nil {
			t.Fatalf("Error removing secrets after destroy: %s", err)
		}
	}()

}

func scheduleKMSKeyDeletion(t *testing.T) error {
	// Create AWS credentials with environment variables
	creds := credentials.NewStaticCredentials(os.Getenv("AWS_ACCESS_KEY_ID"), os.Getenv("AWS_SECRET_ACCESS_KEY"), "")

	// Initialize an AWS session with custom credentials
	sess, err := session.NewSession(&aws.Config{
		Region:      aws.String("us-east-1"),
		Credentials: creds,
	})
	if err != nil {
		return err
	}

	// Create a KMS service client
	svc := kms.New(sess)

	// Retrieve the KMS key ARN from the environment variable
	kmsKeyARN := os.Getenv("TF_VAR_kms_key_arn")

	// Schedule key deletion
	_, err = svc.ScheduleKeyDeletion(&kms.ScheduleKeyDeletionInput{
		KeyId:               aws.String(kmsKeyARN),
		PendingWindowInDays: aws.Int64(7), // Specify the number of days before the key is deleted
	})
	if err != nil {
		return err
	}

	fmt.Println("Scheduled KMS key deletion:", kmsKeyARN)
	return nil
}

func removeSecretsAfterDestroy(t *testing.T, secretIDs []string) error {
	// Create AWS credentials with environment variables
	creds := credentials.NewStaticCredentials(os.Getenv("AWS_ACCESS_KEY_ID"), os.Getenv("AWS_SECRET_ACCESS_KEY"), "")

	// Initialize an AWS session with custom credentials
	sess, err := session.NewSession(&aws.Config{
		Region:      aws.String("us-east-1"),
		Credentials: creds,
	})
	if err != nil {
		return err
	}

	// Create a Secrets Manager service client
	svc := secretsmanager.New(sess)

	// Delete each secret
	for _, secretID := range secretIDs {
		_, err := svc.DeleteSecret(&secretsmanager.DeleteSecretInput{
			SecretId:                  aws.String(secretID),
			ForceDeleteWithoutRecovery: aws.Bool(true),
		})
		if err != nil {
			return err
		}

		fmt.Println("Deleted secrets:", secretID)
	}

	return nil
}