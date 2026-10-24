
output "awspro_alb_arn" {
  description = "ARN of the AWSPro Application Load Balancer."
  value       = aws_lb.awspro_alb.arn
}

output "awspro_alb_dns_name" {
  description = "DNS name of the AWSPro ALB."
  value       = aws_lb.awspro_alb.dns_name
}

output "awspro_alb_zone_id" {
  description = "Canonical hosted zone ID for Route 53 alias records."
  value       = aws_lb.awspro_alb.zone_id
}

output "awspro_alb_target_group_arn" {
  description = "ARN of the target group used by the ECS service."
  value       = aws_lb_target_group.awspro_ecs_tg.arn
}

output "awspro_alb_listener_arn" {
  description = "ARN of the ALB HTTPS listener."
  value       = aws_lb_listener.awspro_alb_http.arn
}
