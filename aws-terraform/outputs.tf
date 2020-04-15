output "address" {
  value = "${aws_elb.philter_elb.dns_name}"
}
