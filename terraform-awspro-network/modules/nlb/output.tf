
output "awspro_nlb_arn" {
  description = "ARN of the AWSPro Network Load Balancer."
  value       = aws_lb.awspro_nlb.arn
}

output "awspro_nlb_dns_name" {
  description = "DNS name of the AWSPro Network Load Balancer."
  value       = aws_lb.awspro_nlb.dns_name
}

output "awspro_nlb_zone_id" {
  description = "Canonical hosted zone ID of the NLB for Route 53 aliases."
  value       = aws_lb.awspro_nlb.zone_id
}

output "awspro_nlb_target_group_arn" {
  description = "ARN of the NLB target group forwarding to the ALB."
  value       = aws_lb_target_group.awspro_alb_tg.arn
}

output "awspro_nlb_listener_arn" {
  description = "ARN of the NLB TCP 443 listener."
  value       = aws_lb_listener.awspro_nlb_tcp_443.arn
}
