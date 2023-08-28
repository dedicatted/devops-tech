package test

import (
	"testing"
	"os/exec"
	"strings"
	"encoding/json"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

type Subnet struct {
	SubnetID string `json:"SubnetId"`
}

func TestRedis(t *testing.T) {
	// Use AWS CLI to describe subnets and extract their IDs
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

	t.Logf("Extracted Subnet IDs: %v", subnetIDs) // Debug output

	// Use AWS CLI to create a cache subnet group
	cacheSubnetGroupName := "my-cache-subnet-group" // Replace with your desired name

	subnetArgs := make([]string, len(subnetIDs)*2)
	for i, subnetID := range subnetIDs {
		subnetArgs[i*2] = "--subnet-ids"
		subnetArgs[i*2+1] = subnetID
	}

	createCacheSubnetGroupArgs := []string{
		"aws", "elasticache", "create-cache-subnet-group",
		"--cache-subnet-group-name", cacheSubnetGroupName,
		"--cache-subnet-group-description", "My Cache Subnet Group",
	}
	createCacheSubnetGroupArgs = append(createCacheSubnetGroupArgs, subnetArgs...)

	createCacheSubnetGroupCmd := exec.Command(createCacheSubnetGroupArgs[0], createCacheSubnetGroupArgs[1:]...)
	cmdString := strings.Join(createCacheSubnetGroupCmd.Args, " ")
	t.Logf("Executing command: %s", cmdString)

	cmdOutput, err := createCacheSubnetGroupCmd.CombinedOutput()
	if err != nil {
		t.Fatalf("Failed to create cache subnet group. Error: %s\nOutput:\n%s", err, cmdOutput)
	}

	t.Logf("Created Cache Subnet Group: %s", cacheSubnetGroupName)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../terraform-aws-redis",
		EnvVars: map[string]string{
			"TF_VAR_subnet_group_name": cacheSubnetGroupName,
		},
	})

	// Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	// Clean up resources with "terraform destroy" at the end of the test.
	defer func() {
		terraform.Destroy(t, terraformOptions)
		
		
	// Delete the cache subnet group after main resources are deleted
	deleteCacheSubnetGroupCmd := exec.Command("aws", "elasticache", "delete-cache-subnet-group", "--cache-subnet-group-name", cacheSubnetGroupName)
	deleteCacheSubnetGroupOutput, deleteErr := deleteCacheSubnetGroupCmd.CombinedOutput()
	if deleteErr != nil {
		t.Logf("Failed to delete cache subnet group: %s", deleteErr)
	} else {
		t.Logf("Deleted Cache Subnet Group: %s\nOutput:\n%s", cacheSubnetGroupName, deleteCacheSubnetGroupOutput)
	}
	}()
}