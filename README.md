# Infrastructure-as-Code Resources for Philter

This repository contains a collection of infrastructure-as-code (IaC) resources for deploying [Philter](https://www.mtnfog.com/products/philter/) to identify and remove sensitive information from text.

## Philter IaC Resources in this Repository

You are welcome to use these resources as-is or to customize them to meet your needs.

| Platform | Scripts | Description | Launch |
|----------|--------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| AWS | [CloudFormation Template](https://github.com/mtnfog/philter-infrastructure-as-code/tree/master/aws-cloudformation/) | AWS CloudFormation template for a load-balanced, highly-available Philter deployment. | [![Launch Stack](https://github.com/mtnfog/philter-infrastructure-as-code/blob/master/aws-cloudformation/cloudformation-launch-stack.png?raw=true)](https://console.aws.amazon.com/cloudformation/home?#/stacks/create/review?stackName=philter&templateURL=https://mtnfog-public.s3.amazonaws.com/philter-resources/philter-vpc-load-balanced-with-redis.json) |
| AWS | [Terraform Scripts](https://github.com/mtnfog/philter-infrastructure-as-code/tree/master/aws-terraform/) | Terraform scripts for a load-balanced, highly-available Philter deployment. | |
| AWS | [Terraform Module](https://github.com/mtnfog/philter-infrastructure-as-code/tree/master/aws-terraform-module) | Terraform module that creates a single Philter EC2 instance. | |
## License

This project is licensed under the Apache License, version 2.0.

Copyright 2020 Mountain Fog, Inc.
Philter is a registered trademark of Mountain Fog, Inc.