package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestVPC(t *testing.T) {
	// Construct the terraform options with default retryable errors to handle the most common
	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: "../terraform-aws-vpc",
	})

	// Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	// Clean up resources with "terraform destroy" at the end of the test.
	defer terraform.Destroy(t, terraformOptions)

}


// package test

// import (
// 	"testing"
// 	"github.com/aws/aws-sdk-go/aws"
// 	"github.com/aws/aws-sdk-go/service/ec2"
// 	"github.com/stretchr/testify/require"
// 	"github.com/aws/aws-sdk-go/aws/session"
// )

// func TestCreateVPC(t *testing.T) {
// 	t.Parallel()

// 	// Replace "us-west-2" with the desired AWS region
// 	region := "us-east-1"

// 	// Call the createVpc function to create the VPC
// 	createVpc(t, region)
// 	NewEc2Client(t, region)
// 	// Add assertions here to test the VPC properties, if needed.
// 	// For example, you can check if the VPC has the expected CIDR block or other attributes.

// 	// Optionally, you can delete the VPC at the end of the test to clean up resources.
// 	// Note: Implement a deleteVpc function using the AWS SDK to delete the VPC.

// 	// Example of deleting the VPC (uncomment and modify as needed):
// 	// deleteVpc(t, region, *vpc.VpcId)
// }

// func createVpc(t *testing.T, region string) *ec2.Vpc {
// 	ec2Client := NewEc2Client(t, region)

// 	createVpcOutput, err := ec2Client.CreateVpc(&ec2.CreateVpcInput{
// 		CidrBlock: aws.String("10.28.0.0/16"),
// 	})

// 	require.NoError(t, err)
// 	return createVpcOutput.Vpc
// }

// func NewEc2Client(t *testing.T, region string) *ec2.EC2 {
// 	// Create a new AWS session for the specified region
// 	sess, err := session.NewSession(&aws.Config{
// 		Region: aws.String(region),
// 	})
// 	require.NoError(t, err)

// 	// Create the EC2 client using the session
// 	return ec2.New(sess)
// }