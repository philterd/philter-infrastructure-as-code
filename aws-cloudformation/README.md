# AWS CloudFormation Template

[![Launch Stack](https://github.com/mtnfog/philter-infrastructure-as-code/blob/master/aws/cloudformation-launch-stack.png?raw=true)](https://console.aws.amazon.com/cloudformation/home?#/stacks/create/review?stackName=philter&templateURL=https://mtnfog-public.s3.amazonaws.com/philter-resources/philter-vpc-load-balanced-with-redis.json)

This template creates a VPC, load balancer, Philter instances, a Redis cache, and all required networking and security group configuration. Click the Launch Stack button to begin launching the stack.

The benefits of using this CloudFormation template is that it provides a pre-configured Philter architecture and deployment that is highly-available, scalable, and encrypts all data in-transit and all data at rest. Your API requests to Philter to filter sensitive information from text will have higher throughput since the load balancer will distribute those requests across the Philter instances. And as described below, the stack uses end-to-end encryption of data at-rest and in-transit.

The stack requires an active subscription to Philter via the AWS Marketplace. The template supports us-east-1, us-east-2, us-west-1, and us-west-2 regions.

## Architecture Diagram

![Philter Architecture](https://github.com/mtnfog/philter-infrastructure-as-code/blob/master/aws/philter-cloudformation-redis-arch.png?raw=true)

The deployment creates an elastic load balancer that is attached to an auto-scaled group of Philter EC2 instances. The load balancer spans two public subnets and the Philter EC2 instances are spread across two private subnets. Also in the private subnets is an Amazon Elasticache for Redis replication group. A NAT Gateway located in one of the public subnets provides outgoing internet access by routing the traffic to the VPC’s Internet Gateway.

The load balancer will monitor the status of each Philter EC2 instance by periodically checking the /api/status endpoint. If an instance is found to be unhealthy after failing several consecutive health checks the failing instance will be replaced.

The Philter auto-scaling group is set to scale up and down based on the average CPU utilization of the Philter EC2 instances. When the CPU usage hits the high threshold another Philter EC2 instance will be added. When the CPU usage hits the low threshold, the auto-scaling group will begin removing (and terminating) instances from the group. The scaling policy is set to scale up faster rate than scaling down to avoid scaling down too quickly.

## End-to-end Encryption

Incoming traffic to the load balancer is received by a TCP protocol handler on port 8080. These requests are distributed across the available Philter EC2 instances. The encrypted incoming traffic is terminated at the Philter EC2 instances. Network traffic between the Elasticache for Redis nodes is encrypted, and the data at-rest in the cache is also encrypted. The Philter EC2 instances use encrypted EBS volumes.

## Launch the Stack

Click the Launch Stack button to launch the stack in your AWS account, or get the template here, or launch the stack using the AWS CLI with the command below.

```
aws cloudformation create-stack --stack-name philter --template-url s3://mtnfog-public/philter-resources/philter-vpc-load-balanced-with-redis.json
```

Once the stack completes Philter will be ready to accept requests. There will be an Output value called `PhilterEndpoint`. This value is the Philter API URL.

For example, if the value of `PhilterEndpoint` is https://philter2-philterlo-5lc0jo7if8g1-586151735.us-east-1.elb.amazonaws.com:8080/, then you can check Philter’s status using the command:

```
curl -k https://philter2-philterlo-5lc0jo7if8g1-586151735.us-east-1.elb.amazonaws.com:8080/api/status
```

You can try a quick sample filter request with:

```
curl -k "https://philter2-philterlo-5lc0jo7if8g1-586151735.us-east-1.elb.amazonaws.com:8080/api/filter" \
  --data "George Washington lives in 90210 and his SSN was 123-45-6789." \
  -H "Content-type: text/plain"
```