package test

import (
	"testing"
	"os/exec"
	"fmt"
	"time"
	"strings"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestCreateAndDeletePublicHostedZoneWithAWSCLI(t *testing.T) {
	t.Parallel()

	// Define the domain name for the public hosted zone
	domainName := "dedicatted.info"

	// Generate a unique caller reference based on test name and timestamp
	testName := t.Name()
	uniqueCallerReference := fmt.Sprintf("%s-%d", testName, time.Now().UnixNano())

	// Execute AWS CLI command to create a hosted zone
	cmd := exec.Command("aws", "route53", "create-hosted-zone", "--name", domainName, "--caller-reference", uniqueCallerReference)
	output, err := cmd.CombinedOutput()
	if err != nil {
		t.Fatalf("Failed to create hosted zone: %s\n%s", err, output)
	}

	// Extract the hosted zone ID from the AWS CLI output
	hostedZoneID := parseHostedZoneID(output)

	// Print the value of hostedZoneID for debugging
	t.Logf("Hosted Zone ID: %s", hostedZoneID)

	if hostedZoneID == "" {
		t.Fatalf("Failed to extract Hosted Zone ID from output: %s", output)
	}

	// Set up Terraform options
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: "../terraform-aws-ses",
		EnvVars: map[string]string{
			"TF_VAR_domain": domainName,
		},
	})

	// Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	// Defer the destruction of Terraform resources
	defer func() {
		terraform.Destroy(t, terraformOptions)
		// cleanupHostedZone(t, hostedZoneID)
		deleteCmd := exec.Command("aws", "route53", "delete-hosted-zone", "--id", hostedZoneID)
		deleteOutput, deleteErr := deleteCmd.CombinedOutput()

		if deleteErr != nil {
			t.Fatalf("Failed to delete hosted zone: %s\n%s", deleteErr, deleteOutput)
		} else {
			t.Logf("Hosted zone deletion initiated:\n%s", deleteOutput)
		}
	}()
}

func parseHostedZoneID(output []byte) string {
	lines := strings.Split(string(output), "\n")
	for _, line := range lines {
		if strings.Contains(line, "\"Id\": \"/hostedzone/") {
			// Find the position of the first quote after "/hostedzone/"
			startIndex := strings.Index(line, "\"/hostedzone/") + len("\"/hostedzone/")

			// Find the position of the second quote after "/hostedzone/"
			endIndex := strings.Index(line[startIndex:], "\"") + startIndex

			if startIndex >= len("\"/hostedzone/") && endIndex > startIndex {
				hostedZoneID := strings.TrimSpace(line[startIndex:endIndex])
				return hostedZoneID
			}
		}
	}
	return ""
}