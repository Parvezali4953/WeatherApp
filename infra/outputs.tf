# Output the ALB's DNS name so the user can access the app
output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

# Output the Task Role ARN for reference (Now references module output)
output "task_role_arn" {
  value = module.iam.task_role_arn
}

# Output the Target Group ARN for reference (Now references module output)
output "target_group_arn" {
  value = module.alb.target_group_arn
}
