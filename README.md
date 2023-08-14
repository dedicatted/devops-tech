<p align="left">
  <img src="https://dedicatted.com/images/Logo.svg?imwidth=48" alt="Sublime's custom image"/>
</p>

This repository contain production-ready examples of working solutions to proceed with configuration of: 

- ArgoCD (Application in Application / ApplicationSets / etc);
- Terraform (AWS / Azure / GCP) modules ready to use;
- GitHub Actions / GitLab CI Pipeline examples
- Guides about interesting solution we've had chance to implement 
- and more interesting and useful staff for DevOps Engineers...

#### Guides 
In these directories you are able to find examples and guides of implementation different types of solutions based on cloud type and/or tool:
- [aws](aws)
- [azure](azure)
- [gcp](gcp)
- [argocd](argocd)
- [gitlab-ci](gitlab-ci)
- [github-actions](github-actions)

#### Terraform Modules

We've faced a level when our Engineers already reusing same Terraform code from client to client with minimum amount of modifications to deploy services like VPC, EKS and EKS Addons, RDS, SES, IAM Roles and Policies, SSO, ACM, KMS, operate with
organisation and more, so we've decided to standardize our code, keep it in the one place and share with  anyone who are boring to write same code from time to time. 

Each module what we are sharing also covered by [Terratest](https://terratest.gruntwork.io/) framework and has weekly schedule to assure that it's valid, working and delivery our a needed result.

Current list of modules in our Repository:

AWS (in progress):
- [terraform-aws-vpc](terraform%2Faws%2Fmodules%2Fterraform-aws-vpc)
- [terraform-aws-waf](terraform%2Faws%2Fmodules%2Fterraform-aws-waf)
- [terraform-aws-ses](terraform%2Faws%2Fmodules%2Fterraform-aws-ses)
- [terraform-aws-secrets-manager](terraform%2Faws%2Fmodules%2Fterraform-aws-secrets-manager)
- [terraform-aws-s3](terraform%2Faws%2Fmodules%2Fterraform-aws-s3)
- [terraform-aws-redshift](terraform%2Faws%2Fmodules%2Fterraform-aws-redshift)
- [terraform-aws-redis](terraform%2Faws%2Fmodules%2Fterraform-aws-redis)
- [terraform-aws-rds](terraform%2Faws%2Fmodules%2Fterraform-aws-rds)
- [terraform-aws-kms](terraform%2Faws%2Fmodules%2Fterraform-aws-kms)
- [terraform-aws-guardduty](terraform%2Faws%2Fmodules%2Fterraform-aws-guardduty)
- [terraform-aws-eks](terraform%2Faws%2Fmodules%2Fterraform-aws-eks)
- [terraform-aws-eks-addons](terraform%2Faws%2Fmodules%2Fterraform-aws-eks-addons)
- [terraform-aws-acm](terraform%2Faws%2Fmodules%2Fterraform-aws-acm)
- [terraform-aws-argocd](terraform%2Faws%2Fmodules%2Fterraform-aws-argocd)
- [terraform-argocd-client](terraform%2Faws%2Fmodules%2Fterraform-argocd-client)
- [terraform-aws-cloudtrail](terraform%2Faws%2Fmodules%2Fterraform-aws-cloudtrail)
- [terraform-aws-organizations](terraform%2Faws%2Fmodules%2Fterraform-aws-organizations)

Azure (in progress):
- TBA (coming soon)

GCP (in progress):
- TBA (coming soon)

#### Notes

- Anyone are able to propose to store Terraform Module in our repository, our team are able to help with [Terratest](https://terratest.gruntwork.io/) configuration
- If you found an issue/mistake or any other not working part of code please contact with us via creating a GitHub Issue in this repository

