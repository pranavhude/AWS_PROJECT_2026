
output "launch_template_id" {
  value = aws_launch_template.awspro_ecs_lt.id
}

output "launch_template_latest_version" {
  value = aws_launch_template.awspro_ecs_lt.latest_version
}

output "ecs_ami_id" {
  value = data.aws_ssm_parameter.awspro_ecs_ami.value
}
