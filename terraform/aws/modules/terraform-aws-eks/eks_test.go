package test

import (
    "testing"
	// "fmt"
	// "os"
	// "strings"
	// "io/ioutil"
	// "text/template"

	// "github.com/aws/aws-sdk-go/service/sts"
    // "github.com/aws/aws-sdk-go/aws"
    // "github.com/aws/aws-sdk-go/aws/session"
    // "github.com/aws/aws-sdk-go/service/kms"
	"github.com/gruntwork-io/terratest/modules/terraform"
	// "github.com/aws/aws-sdk-go/service/ec2"
)

// func TestCreateKMSKeyWithPolicy(t *testing.T) {
// 	t.Parallel()

// 	// Create a new AWS session using your AWS credentials and desired region.
// 	sess := session.Must(session.NewSessionWithOptions(session.Options{
// 		SharedConfigState: session.SharedConfigEnable,
// 		Config: aws.Config{
// 			Region: aws.String("us-east-1"), // Replace with your desired region.
// 		},
// 	}))

// 	// Create a KMS client using the AWS session.
// 	svc := kms.New(sess)

// 	// Create an STS (Security Token Service) client using the AWS session.
// 	stsSvc := sts.New(sess)

// 	// Use the STS service to get the AWS account ID.
// getCallerIdentityOutput, err := stsSvc.GetCallerIdentity(&sts.GetCallerIdentityInput{})
// if err != nil {
// 	t.Fatalf("Failed to get AWS account ID: %v", err)
// }
// accountID := aws.StringValue(getCallerIdentityOutput.Account)

// // Construct the policy JSON as a string with the dynamic account ID.
// policy := `{
// 	"Version": "2012-10-17",
// 	"Statement": [
// 		{
// 			"Sid": "Default",
// 			"Effect": "Allow",
// 			"Principal": {
// 				"AWS": "arn:aws:iam::` + accountID + `:root"
// 			},
// 			"Action": "kms:*",
// 			"Resource": "*"
// 		},
// 		{
// 			"Sid": "KeyAdministration",
// 			"Effect": "Allow",
// 			"Principal": {
// 				"AWS": "arn:aws:iam::` + accountID + `:user/terraform-test"
// 			},
// 			"Action": [
// 				"kms:Update*",
// 				"kms:UntagResource",
// 				"kms:TagResource",
// 				"kms:ScheduleKeyDeletion",
// 				"kms:Revoke*",
// 				"kms:Put*",
// 				"kms:List*",
// 				"kms:Get*",
// 				"kms:Enable*",
// 				"kms:Disable*",
// 				"kms:Describe*",
// 				"kms:Delete*",
// 				"kms:Create*",
// 				"kms:CancelKeyDeletion"
// 			],
// 			"Resource": "*"
// 		},
// 		{
// 			"Sid": "KeyServiceRolesASG",
// 			"Effect": "Allow",
// 			"Principal": {
// 				"AWS": "arn:aws:iam::` + accountID + `:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
// 			},
// 			"Action": [
// 				"kms:ReEncrypt*",
// 				"kms:GenerateDataKey*",
// 				"kms:Encrypt",
// 				"kms:DescribeKey",
// 				"kms:Decrypt"
// 			],
// 			"Resource": "*"
// 		},
// 		{
// 			"Sid": "KeyServiceRolesASGPersistentVol",
// 			"Effect": "Allow",
// 			"Principal": {
// 				"AWS": "arn:aws:iam::` + accountID + `:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
// 			},
// 			"Action": "kms:CreateGrant",
// 			"Resource": "*",
// 			"Condition": {
// 				"Bool": {
// 					"kms:GrantIsForAWSResource": "true"
// 				}
// 			}
// 		}
// 	]
// }`

// 	// Create the KMS key with the updated policy.
// 	createKeyInput := &kms.CreateKeyInput{
// 		Description: aws.String("My KMS Key Description"),
// 		Policy:      aws.String(policy),
// 	}
// 	createKeyOutput, err := svc.CreateKey(createKeyInput)
// 	if err != nil {
// 		t.Fatalf("Failed to create KMS key: %v", err)
// 	}

// 	// Get the ARN of the created KMS key.
// 	keyArn := aws.StringValue(createKeyOutput.KeyMetadata.Arn)
// 	fmt.Println("Created KMS Key ARN:", keyArn)

// 	os.Setenv("TF_VAR_kms_key_arn", keyArn)
// }

// func createVPCAndSubnets(t *testing.T, awsRegion string) []string {
// 	t.Parallel()
//     // Create a new AWS session using your AWS credentials and desired region.
//     sess := session.Must(session.NewSessionWithOptions(session.Options{
//         SharedConfigState: session.SharedConfigEnable,
//         Config: aws.Config{
//             Region: aws.String(awsRegion), // Replace with your desired region.
//         },
//     }))

//     // Create an EC2 client using the AWS session.
//     ec2Svc := ec2.New(sess)

//     // Create a VPC.
//     createVpcInput := &ec2.CreateVpcInput{
//         CidrBlock: aws.String("10.0.0.0/16"), // Replace with your desired CIDR block for the VPC.
//     }
//     createVpcOutput, err := ec2Svc.CreateVpc(createVpcInput)
//     if err != nil {
//         t.Fatalf("Failed to create VPC: %v", err)
//     }

//     // Get the ID of the created VPC.
//     vpcID := aws.StringValue(createVpcOutput.Vpc.VpcId)
//     os.Setenv("TF_VAR_vpc_id", vpcID)

//     // Valid us-east-1 availability zones
//     availabilityZones := []string{"us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"}

//     // Create public and private subnets.
//     subnetCIDRs := []string{"10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"} // Replace with your desired CIDR blocks.
//     subnetIDs := []string{}

//     for i, subnetCIDR := range subnetCIDRs {
//         createSubnetInput := &ec2.CreateSubnetInput{
//             CidrBlock:        aws.String(subnetCIDR),
//             VpcId:            aws.String(vpcID),
//             AvailabilityZone: aws.String(availabilityZones[i]),
//         }
//         createSubnetOutput, err := ec2Svc.CreateSubnet(createSubnetInput)
//         if err != nil {
//             t.Fatalf("Failed to create subnet: %v", err)
//         }
//         subnetIDs = append(subnetIDs, aws.StringValue(createSubnetOutput.Subnet.SubnetId))
//     }

//     return subnetIDs
// }

// func TestCreateVPCAndSubnets(t *testing.T) {
//     // Replace "your_aws_region" with the desired AWS region.
//     awsRegion := "us-east-1"
//     subnetIDs := createVPCAndSubnets(t, awsRegion)

//     // Add your test assertions here if needed.
//     // For example, you can check the length of subnetIDs, etc.
//     if len(subnetIDs) != 3 {
//         t.Errorf("Expected 3 subnets, but got %d", len(subnetIDs))
//     }

// 	// Create terraform.tfvars file.
//     err := createTerraformTFVarsFile(subnetIDs, "terraform.tfvars")
//     if err != nil {
//         t.Errorf("Failed to create terraform.tfvars file: %v", err)
//     }

// }

// func createTerraformTFVarsFile(subnetIDs []string, filename string) error {
//     // Create the content for terraform.tfvars.
//     content := "private_subnets = ["
//     for i, subnetID := range subnetIDs {
//         if i > 0 {
//             content += ", "
//         }
//         content += "\"" + subnetID + "\""
//     }
//     content += "]\n"

//     // Write the content to the file.
//     err := ioutil.WriteFile(filename, []byte(content), 0644)
//     if err != nil {
//         return err
//     }

//     return nil
// }

// Define a custom subtract function for the template.
// func subtract(a, b int) int {
//     return a - b
// }

// func TestOutputPrivateSubnets(t *testing.T) {
//     t.Parallel()

//     // Replace with the desired AWS region.
//     awsRegion := "us-east-1"

//     // Create the VPC and subnets and get the subnetIDs.
//     subnetIDs := createVPCAndSubnets(t, awsRegion)

//     // Define a struct to hold the data for the template.
//     type TerraformVars struct {
//         PrivateSubnets []string
//     }

//     // Populate the struct with your private subnet IDs.
//     terraformVars := TerraformVars{
//         PrivateSubnets: subnetIDs,
//     }

//     // Create a template for the terraform.tfvars file.
//     terraformTemplate := `private_subnets = [{{ range $i, $subnet := .PrivateSubnets }}"{{ $subnet }}"{{ if not (eq $i (subtract (len .PrivateSubnets) 1)) }},{{ end }}{{ end }}]`

//     // Execute the template to generate the content.
//     var contentBuffer strings.Builder
//     tmpl, err := template.New("terraform").Funcs(template.FuncMap{"subtract": subtract}).Parse(terraformTemplate)
//     if err != nil {
//         t.Fatalf("Failed to parse template: %v", err)
//     }
//     if err := tmpl.Execute(&contentBuffer, terraformVars); err != nil {
//         t.Fatalf("Failed to execute template: %v", err)
//     }

//     // Define the path for terraform.tfvars.
//     tfVarsPath := "terraform.tfvars"

//     // Write the content to the terraform.tfvars file.
//     if err := ioutil.WriteFile(tfVarsPath, []byte(contentBuffer.String()), 0644); err != nil {
//         t.Fatalf("Failed to create %s file: %v", tfVarsPath, err)
//     }

//     // Print a message to indicate the file creation.
//     fmt.Printf("Created %s file\n", tfVarsPath)
// }

// func createTerraformTFVars(subnetIDs []string) error {
//     // Open or create the terraform.tfvars file for writing.
//     file, err := os.Create("terraform.tfvars")
//     if err != nil {
//         return err
//     }
//     defer file.Close()

//     // Convert the subnetIDs slice into a string with proper formatting.
//     formattedSubnets := make([]string, len(subnetIDs))
//     for i, subnetID := range subnetIDs {
//         formattedSubnets[i] = fmt.Sprintf("\"%s\"", subnetID)
//     }

//     // Write the formatted subnet IDs to the terraform.tfvars file.
//     content := fmt.Sprintf("private_subnets = [%s]\n", strings.Join(formattedSubnets, ", "))
//     _, err = file.WriteString(content)
//     if err != nil {
//         return err
//     }

//     return nil
// }

func TestEKS(t *testing.T) {
	t.Parallel()

	// Set the AWS region you want to use for testing.
	awsRegion := "us-east-1"

	// Configure Terraform options with the path to your Terraform code.
	terraformOptions := &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: "../terraform-aws-eks",
		// Variables to pass to our Terraform code using TF_VAR_xxx environment variables
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	// Run `terraform init` and `terraform apply`. Fail the test if there are any errors.
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Schedule KMS key deletion using AWS SDK or AWS CLI.
    // keyID := os.Getenv("KMS_KEY_ID")
    // deleteKeyCommand := exec.Command("aws", "kms", "schedule-key-deletion", "--key-id", keyID, "--pending-window-in-days", "7")
    // deleteKeyCommand.Env = append(os.Environ(), "AWS_DEFAULT_REGION="+awsRegion)
    // if err := deleteKeyCommand.Run(); err != nil {
    //     t.Fatalf("Failed to schedule KMS key deletion: %v", err)
    // }
}