output "philter_elb_endpoint" {
  value = aws_elb.philter_elb.dns_name
}
