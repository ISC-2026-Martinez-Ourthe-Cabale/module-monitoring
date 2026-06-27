## Outout sns para el módulo de monitoreo.
output "sns_topic_arn" {
  description = "ARN del topic SNS de monitoreo."
  value       = aws_sns_topic.monitoring.arn
}

## Output dashboard de CloudWatch para el módulo de monitoreo.
output "dashboard_name" {
  description = "Nombre del dashboard de CloudWatch."
  value       = aws_cloudwatch_dashboard.monitoring.dashboard_name
}

## Variable para nombre de las alarmas de CloudWatch creadas, utilizada en el módulo de monitoreo.
output "alarm_names" {
  description = "Nombres de las alarmas de CloudWatch creadas."
  value = [
    aws_cloudwatch_metric_alarm.ec2_cpu_utilization.alarm_name,
    aws_cloudwatch_metric_alarm.ec2_status_check.alarm_name,
    aws_cloudwatch_metric_alarm.alb_5xx.alarm_name,
    aws_cloudwatch_metric_alarm.rds_cpu_utilization.alarm_name,
    aws_cloudwatch_metric_alarm.rds_free_storage.alarm_name,
  ]
}

## Variable para nombre del CloudWatch Log Group creado, utilizada en el módulo de monitoreo.
output "log_group_name" {
  description = "Nombre del CloudWatch Log Group creado si está habilitado."
  value       = var.habilitar_log_group ? aws_cloudwatch_log_group.optional[0].name : ""
}