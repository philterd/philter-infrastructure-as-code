# Philter Terraform AWS Module

This directory contains a Terraform module for deploying a single Philter EC2 instance. A VPC ID, subnet ID, and SSH keyname are required.

```
terraform apply -var 'vpc_id=VPC_ID' -var 'subnet_id=SUBNET_ID' -var 'instance_keyname=KEYPAIR_NAME'
```

For a more complete Philter stack managed by Terraform see the [aws-terraform](https://github.com/mtnfog/philter-infrastructure-as-code/tree/master/aws-terraform) that creates an autoscaling group, load balancer, and cache.