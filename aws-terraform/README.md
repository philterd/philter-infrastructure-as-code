# Philter AWS Terraform Scripts

These Terraform scripts create a VPC, load balancer, [Philter](https://www.mtnfog.com/products/philter/) EC2 instances, a Redis cache, and all required networking and security group configuration.

You are encouraged to use these scripts as a starting point for creating your own Philter deployment. Feel free to fork this repository and customize as needed. We appreciate any contributions you would like to make by pull request.

## Quick Notes

The script looks up the Philter AMI for the latest version of Philter when `terraform apply` is executed.

The stack requires an active subscription to Philter via the [AWS Marketplace](https://aws.amazon.com/marketplace/pp/B07YVB8FFT). The template supports all AWS regions.

## Benefits

The benefits of using these Terraform scripts is that they provide a pre-configured Philter architecture and deployment that is highly-available, scalable, and encrypts all data in-transit and all data at rest. Your API requests to Philter to filter sensitive information from text will have higher throughput since the load balancer will distribute those requests across the Philter instances. And as described below, the stack uses end-to-end encryption of data at-rest and in-transit.

## Architecture

![Philter Architecture](https://github.com/mtnfog/philter-infrastructure-as-code/blob/master/aws-terraform/philter-terraform-redis-arch.png?raw=true)

The deployment creates an elastic load balancer that is attached to an auto-scaled group of Philter EC2 instances. The load balancer spans two public subnets and the Philter EC2 instances are spread across two private subnets. Also in the private subnets is an Amazon Elasticache for Redis replication group. A NAT Gateway located in one of the public subnets provides outgoing internet access by routing the traffic to the VPC’s Internet Gateway.

### Monitoring and Autoscaling

The load balancer will monitor the status of each Philter EC2 instance by periodically checking the /api/status endpoint. If an instance is found to be unhealthy after failing several consecutive health checks the failing instance will be replaced.

The Philter auto-scaling group is set to scale up and down based on the average CPU utilization of the Philter EC2 instances. When the CPU usage hits the high threshold another Philter EC2 instance will be added. When the CPU usage hits the low threshold, the auto-scaling group will begin removing (and terminating) instances from the group. The scaling policy is set to scale up faster rate than scaling down to avoid scaling down too quickly.

### SSH Access

The scripts can optionally create a bastion EC2 instance in the public subnet. The bastion EC2 instance is not created by default and can be enabled by setting the value of the `create_bastion_instance` parameter to `true` when creating the stack. When creating a bastion EC2 instance, it's important to also provide a value for the `instance_keyname` parameter so you are able to SSH into the bastion instance.

### End-to-end Encryption

Incoming traffic to the load balancer is received by a TCP protocol handler on port 8080. These requests are distributed across the available Philter EC2 instances. The encrypted incoming traffic is terminated at the Philter EC2 instances. Network traffic between the Elasticache for Redis nodes is encrypted, and the data at-rest in the cache is also encrypted. The Philter EC2 instances use encrypted EBS volumes.

## Launch the Stack

Clone this repository and create the stack with terraform:

```
git clone https://github.com/mtnfog/philter-infrastructure-as-code.git
cd philter-infrastructure-as-code
terraform init
terraform apply
```

There are some variables in `variables.tf` that can customize the stack.

Once the stack completes Philter will be ready to accept requests. There will be a `philter_elb_endpoint` output. This value is the Philter API URL. (You can see the outputs with `terraform outputs`.)

For example, if the value of `philter_elb_endpoint` is https://philter2-philterlo-5lc0jo7if8g1-586151735.us-east-1.elb.amazonaws.com:8080/, then you can check Philter’s status using the command:

```
curl -k https://philter2-philterlo-5lc0jo7if8g1-586151735.us-east-1.elb.amazonaws.com:8080/api/status
```

You can try a quick sample filter request with:

```
curl -k "https://philter2-philterlo-5lc0jo7if8g1-586151735.us-east-1.elb.amazonaws.com:8080/api/filter" \
  --data "George Washington lives in 90210 and his SSN was 123-45-6789." \
  -H "Content-type: text/plain"
```
