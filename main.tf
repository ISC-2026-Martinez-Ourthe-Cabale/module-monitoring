## Data source de la región configurada en el provider, requerida por los widgets del dashboard de CloudWatch.
data "aws_region" "current" {}

## Recursos de monitoreo en AWS utilizando Terraform.
resource "aws_sns_topic" "monitoring" {
  name = var.sns_topic_name

  tags = {
    Project = var.project_name
    Purpose = "monitoring"
  }
}

## Recurso de suscripción al topic SNS para notificaciones por correo electrónico.
resource "aws_sns_topic_subscription" "email" {
  for_each  = toset(var.notificacion_email)
  topic_arn = aws_sns_topic.monitoring.arn
  protocol  = "email"
  endpoint  = each.value
}

## Recursos de alarmas de CloudWatch para monitorear EC2, ALB y RDS.
resource "aws_cloudwatch_metric_alarm" "ec2_cpu_utilizacion" {
  alarm_name          = "${var.project_name}-ec2-cpu-utilizacion"
  alarm_description   = "Alarma cuando el CPU promedio de las instancias en el ASG excede el umbral."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarma_evaluacion_periodos
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.alarma_periodo_segundos
  statistic           = "Average"
  threshold           = var.alarma_cpu_umbral
  dimensions = {
    AutoScalingGroupName = var.asg_name
  }
  alarm_actions = var.notificacion_email != [] ? [aws_sns_topic.monitoring.arn] : []
  ok_actions    = var.notificacion_email != [] ? [aws_sns_topic.monitoring.arn] : []

  tags = {
    Project = var.project_name
    Purpose = "monitoring"
  }
}

## Recurso de alarma de CloudWatch para monitorear el estado de las instancias EC2 en el ASG.
resource "aws_cloudwatch_metric_alarm" "ec2_status_check" {
  alarm_name          = "${var.project_name}-ec2-status-check"
  alarm_description   = "Alarma cuando falla un status check de sistema o instancia."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarma_evaluacion_periodos
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = var.alarma_periodo_segundos
  statistic           = "Maximum"
  threshold           = 0
  dimensions = {
    AutoScalingGroupName = var.asg_name
  }
  alarm_actions = var.notificacion_email != "" ? [aws_sns_topic.monitoring.arn] : []
  ok_actions    = var.notificacion_email != "" ? [aws_sns_topic.monitoring.arn] : []

  tags = {
    Project = var.project_name
    Purpose = "monitoring"
  }
}

## Recursos de alarmas de CloudWatch para monitorear el ALB y RDS.
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.project_name}-alb-5xx"
  alarm_description   = "Alarma cuando hay respuestas 5xx en el ALB."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarma_evaluacion_periodos
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = var.alarma_periodo_segundos
  statistic           = "Sum"
  threshold           = var.alarma_alb_5xx_umbral
  dimensions = {
    TargetGroup = var.target_group_arn
    LoadBalancer = var.alb_arn
  }
  alarm_actions = var.notificacion_email != "" ? [aws_sns_topic.monitoring.arn] : []
  ok_actions    = var.notificacion_email != "" ? [aws_sns_topic.monitoring.arn] : []

  tags = {
    Project = var.project_name
    Purpose = "monitoring"
  }
}

## Recurso de alarma de CloudWatch para monitorear el CPU de RDS.
resource "aws_cloudwatch_metric_alarm" "rds_cpu_utilization" {
  alarm_name          = "${var.project_name}-rds-cpu-utilization"
  alarm_description   = "Alarma cuando el CPU de RDS supera el umbral."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarma_evaluacion_periodos
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = var.alarma_periodo_segundos
  statistic           = "Average"
  threshold           = var.alarma_rds_cpu_umbral
  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
  alarm_actions = var.notificacion_email != "" ? [aws_sns_topic.monitoring.arn] : []
  ok_actions    = var.notificacion_email != "" ? [aws_sns_topic.monitoring.arn] : []

  tags = {
    Project = var.project_name
    Purpose = "monitoring"
  }
}

## Recurso de alarma de CloudWatch para monitorear el almacenamiento libre de RDS.
resource "aws_cloudwatch_metric_alarm" "rds_free_storage" {
  alarm_name          = "${var.project_name}-rds-free-storage"
  alarm_description   = "Alarma cuando el almacenamiento libre de RDS cae por debajo del umbral."
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.alarma_evaluacion_periodos
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = var.alarma_periodo_segundos
  statistic           = "Minimum"
  threshold           = var.alarma_rds_free_storage_umbral_gb * 1024 * 1024 * 1024
  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
  alarm_actions = var.notificacion_email != "" ? [aws_sns_topic.monitoring.arn] : []
  ok_actions    = var.notificacion_email != "" ? [aws_sns_topic.monitoring.arn] : []

  tags = {
    Project = var.project_name
    Purpose = "monitoring"
  }
}

## Recurso de dashboard de CloudWatch para visualizar métricas de EC2, ALB y RDS.
resource "aws_cloudwatch_dashboard" "monitoring" {
  dashboard_name = var.dashboard_name

  dashboard_body = jsonencode({
    widgets = [
      {
        type       = "metric"
        x          = 0
        y          = 0
        width      = 12
        height     = 6
        properties = {
          region  = data.aws_region.current.region
          metrics = [
            [ "AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.asg_name ]
          ]
          title  = "EC2 CPU Utilization"
          period = var.alarma_periodo_segundos
          stat   = "Average"
        }
      },
      {
        type       = "metric"
        x          = 12
        y          = 0
        width      = 12
        height     = 6
        properties = {
          region  = data.aws_region.current.region
          metrics = [
            [ "AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.alb_arn, "TargetGroup", var.target_group_arn ]
          ]
          title  = "ALB Target 5XX Count"
          period = var.alarma_periodo_segundos
          stat   = "Sum"
        }
      },
      {
        type       = "metric"
        x          = 0
        y          = 6
        width      = 12
        height     = 6
        properties = {
          region  = data.aws_region.current.region
          metrics = [
            [ "AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.db_instance_id ]
          ]
          title  = "RDS CPU Utilization"
          period = var.alarma_periodo_segundos
          stat   = "Average"
        }
      },
      {
        type       = "metric"
        x          = 12
        y          = 6
        width      = 12
        height     = 6
        properties = {
          region  = data.aws_region.current.region
          metrics = [
            [ "AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", var.db_instance_id ]
          ]
          title  = "RDS Free Storage Space"
          period = var.alarma_periodo_segundos
          stat   = "Minimum"
        }
      }
    ]
  })
}

## Recurso opcional de CloudWatch Log Group para almacenar logs si está habilitado.
resource "aws_cloudwatch_log_group" "optional" {
  count = var.habilitar_log_group ? 1 : 0

  name              = var.log_group_name
  retention_in_days = 30

  tags = {
    Project = var.project_name
    Purpose = "monitoring"
  }
}