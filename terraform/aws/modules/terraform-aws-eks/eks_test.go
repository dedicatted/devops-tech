package test

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

// Define a function to create a KMS key using AWS CLI.
func createKMSKey(t *testing.T) string {
	// Create the KMS key with the constructed ARN in the policy.
	createKeyCmd := exec.Command("aws", "kms", "create-key", "--query", "KeyMetadata.KeyId", "--output", "text")
	output, err := createKeyCmd.CombinedOutput()
	if err != nil {
		t.Fatalf("Failed to create KMS key: %v\nOutput:\n%s", err, output)
	}
	keyID := strings.TrimSpace(string(output))

	// Sleep for a few seconds to allow the key to be fully created (optional but recommended).
	time.Sleep(10 * time.Second)

	fmt.Printf("Created KMS key with ID: %s\n", keyID)

	getAccountIDCmd := exec.Command("aws", "sts", "get-caller-identity", "--query", "Account", "--output", "text")
	accountIDOutput, err := getAccountIDCmd.CombinedOutput()
	if err != nil {
		t.Fatalf("Failed to get AWS account ID: %v\nOutput:\n%s", err, accountIDOutput)
	}
	accountID := strings.TrimSpace(string(accountIDOutput))

	// Use the AWS CLI to get the current AWS region from the default profile.
	getRegionCmd := exec.Command("aws", "configure", "get", "region")
	regionOutput, err := getRegionCmd.CombinedOutput()
	if err != nil {
		t.Fatalf("Failed to get AWS region: %v\nOutput:\n%s", err, regionOutput)
	}
	region := strings.TrimSpace(string(regionOutput))

	// Create the KMS key ARN with the dynamically obtained account ID and region.
	kmsKeyARN := fmt.Sprintf("arn:aws:kms:%s:%s:key/%s", region, accountID, keyID)

	// Set the KMS key ARN as an environment variable for Terraform to use.
	err = os.Setenv("KMS_KEY_ARN", kmsKeyARN)
	if err != nil {
		t.Fatalf("Failed to set environment variable: %v", err)
	}

	// Return the KMS key ARN as a string.
	return kmsKeyARN
}

func TestCreateKMSKeyWithDynamicPolicy(t *testing.T) {
	t.Parallel()

	// Call the createKMSKey function to create a KMS key and set its policy.
	// kmsKeyARN := createKMSKey(t)

	// Construct the terraform options with default retryable errors to handle the most common
	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: "../terraform-aws-eks",
		Vars: map[string]interface{}{
			"kms_key_arn": "arn:aws:kms:us-east-1:338096867149:key/00af221b-ae1a-467b-9791-10980b2d0c91", // Pass the KMS key ARN as a Terraform variable.
		},
	})

	// Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	// Clean up resources with "terraform destroy" at the end of the test.
	defer terraform.Destroy(t, terraformOptions)
}
