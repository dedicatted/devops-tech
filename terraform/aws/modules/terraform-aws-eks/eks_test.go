package test

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/iam"
	"fmt"
	"strings"
	"os"
)
func getRoleArnFromAWS() (string, error) {
	// Create a new AWS session
	sess := session.Must(session.NewSession())

	// Create an IAM client
	iamSvc := iam.New(sess)

	// Specify the AWS service role name
	roleName := "AWSServiceRoleForAutoScaling"

	// Get the ARN for the specified role
	result, err := iamSvc.GetRole(&iam.GetRoleInput{
		RoleName: &roleName,
	})
	if err != nil {
		return "", err
	}

	// Return the ARN
	return *result.Role.Arn, nil
}

func getCurrentUserArn() (string, error) {
	// Create a new AWS session
	sess := session.Must(session.NewSession())

	// Create an IAM client
	iamSvc := iam.New(sess)

	// Get information about the current IAM user
	result, err := iamSvc.GetUser(nil)
	if err != nil {
		return "", err
	}

	// Return the ARN for the current user
	return *result.User.Arn, nil
}

func TestEKSAddons(t *testing.T) {
	awsRegion := "us-east-1"
	// Set the AWS region you want to use for testing
	roleArn, err := getRoleArnFromAWS()
	if err != nil {
		fmt.Println("Error fetching role ARN:", err)
		os.Exit(1)
	}
	userArn, err := getCurrentUserArn()
	if err != nil {
		fmt.Println("Error fetching user ARN:", err)
		os.Exit(1)
	}
	kmsTerraformOptions := &terraform.Options{
		TerraformDir: "../terraform-aws-kms",
		Vars: map[string]interface{}{
			"deletion_window_in_days": "7",
			"key_service_roles_for_autoscaling": []string{roleArn},
			"key_administrators": []string{userArn},
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}
	// Initialize and apply the VPC module
	terraform.InitAndApply(t, kmsTerraformOptions)
	key_arn := terraform.Output(t, kmsTerraformOptions, "key_arn")
	vpcTerraformOptions := &terraform.Options{
		TerraformDir: "../terraform-aws-vpc",
		Vars: map[string]interface{}{
			"name":                              "test-vpc",
			"private_subnets":                   []string{"10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"},
			"public_subnets":                    []string{"10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"},
			"azs":                               fmt.Sprintf(`["%sa", "%sb", "%sc"]`, awsRegion, awsRegion, awsRegion),
			"create_database_subnet_group":      false,
			"create_database_subnet_route_table": false,
			"create_egress_only_igw":            true,
			"enable_nat_gateway":                true,
			"single_nat_gateway":                true,
			"enable_dns_hostnames":              true,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION":                awsRegion,
		},
	}
	// Initialize and apply the VPC module
	defer terraform.Destroy(t, vpcTerraformOptions)

	terraform.InitAndApply(t, vpcTerraformOptions)
	privateSubnetsString := terraform.Output(t, vpcTerraformOptions, "private_subnets")
	vpcID := terraform.Output(t, vpcTerraformOptions, "vpc_id")

	// Remove leading and trailing whitespaces, brackets, and quotes
	privateSubnetsString = strings.Trim(privateSubnetsString, `[]"' `)

	// Split the string into a list of subnets
	privateSubnetsList := strings.Split(privateSubnetsString, " ")

	// Convert the string slice to a list of strings
	var privateSubnets []string
	for _, subnet := range privateSubnetsList {
		privateSubnets = append(privateSubnets, subnet)
	}
	// Configure Terraform options with the path to your Terraform code.
	EksterraformOptions := &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: "../terraform-aws-eks",
		Vars: map[string]interface{}{
			"kms_key_arn": key_arn,
			"private_subnets": privateSubnets,
			"vpc_id": vpcID,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}
	terraform.InitAndApply(t, EksterraformOptions)

	defer terraform.Destroy(t, vpcTerraformOptions)
	defer terraform.Destroy(t, kmsTerraformOptions)
	defer terraform.Destroy(t, EksterraformOptions)
}