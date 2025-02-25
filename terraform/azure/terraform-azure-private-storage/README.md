## Azure private Blob Storage Account setup public access with Front Door for HITRUST certification using Terraform - Step-by-Step Guide

#### Quick start:
> [!TIP]  
>Detailed article read on [Medium](Set_link_here)

Before start you need edit `./config/main.tfvars` Just follow comments inside file.


> [!NOTE]  
> At next `az` commands set your data in place `<>`

#### Logging to Azure:

```
az login --username <Bohdan.Boiko@dedicatted.com>
az account set --subscription <11223344-1111-2222-3333-c55a52cfbe4c>
```

#### Initialize Terraform:

```
terraform init
terraform plan -var-file=config/main.tfvars
```


#### Apply Terraform Configuration:

```
terraform apply -var-file=config/main.tfvars
```
![image](./images/tf_apply.png)

#### Action after apply:
You need manually approve Private Endpoint in Network settings of Storage account

![image](./images/approve_private_endpoint.png)

Then you can upload file to storage: 

![image](./images/upload_file.png)

It will successfully work with your domain:
![image](./images/result.png)

#### Additional Links:

- [How to import DNS zone to Azure](https://learn.microsoft.com/en-us/azure/dns/dns-delegate-domain-azure-dns)

