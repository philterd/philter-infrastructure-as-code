# Infrastructure-as-Code Resources for Philter

This repository contains a collection of infrastructure-as-code (IaC) resources for deploying [Philter](https://www.philterd.io/philter/) to identify and remove sensitive information from text.

You are welcome to use these resources as-is or to customize them to meet your needs. Please contact us if you need assistance with the resources in this repository.

## Templates and Scripts

| Platform | Scripts | Description |
|----------|--------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| AWS | [CloudFormation Template](https://github.com/philterd/philter-infrastructure-as-code/tree/master/aws-cloudformation/) | AWS CloudFormation template for a load-balanced, highly-available Philter deployment. | 
| AWS | [Terraform Scripts](https://github.com/philterd/philter-infrastructure-as-code/tree/master/aws-terraform/) | Terraform scripts for a load-balanced, highly-available Philter deployment. |
| AWS | [Terraform Module](https://github.com/philterd/philter-infrastructure-as-code/tree/master/aws-terraform-module) | Terraform module that creates a single Philter EC2 instance. |

## License

This project is licensed under the Apache License, version 2.0.

Copyright 2024 Philterd, LLC.
Philter is a registered trademark of Philterd, LLC.
