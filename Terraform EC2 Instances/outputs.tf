output "Time-Date" {
  description = "Date/Time of Execution"
  value       = timestamp()
}

output "aws_instances" {
  description = "Names of the Instances Created"
  value       = aws_instance.my-instance.*.tags.Name
}

output "availability_zone" {
  description = "Output the selected availability zone"
  value       = local.availability_zone
}