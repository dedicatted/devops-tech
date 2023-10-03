package test

import (
    "testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestEKS(t *testing.T) {
	t.Parallel()

	// Set the AWS region you want to use for testing.
	awsRegion := "us-east-1"

	// Configure Terraform options with the path to your Terraform code.
	terraformOptions := &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: "../terraform-aws-eks",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	// Run `terraform init` and `terraform apply`. Fail the test if there are any errors.
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

}