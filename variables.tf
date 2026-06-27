## Variable para definir nombre del proyecto.
variable "project_name" {
  description = "Nombre del proyecto para tags y recursos de monitoreo."
  type        = string
  default     = "Obligatorio"
}

## Tags adicionales para los recursos de monitoreo.
variable "tags" {
  description = "Tags adicionales para aplicar a los recursos que admiten etiquetado."
  type        = map(string)
  default     = {}
}

## Variable para el sufijo del ARN del ALB, utilizado como dimensión de CloudWatch.
variable "alb_arn_suffix" {
  description = "Sufijo del ARN del Application Load Balancer."
  type        = string
}

## Variable para el sufijo del ARN del Target Group, utilizado como dimensión de CloudWatch.
variable "target_group_arn_suffix" {
  description = "Sufijo del ARN del Target Group asociado al ALB."
  type        = string
}

## Variable para el ID del Auto Scaling Group, utilizada en el módulo de monitoreo.
variable "asg_name" {
  description = "Nombre del Auto Scaling Group a monitorear."
  type        = string
}

## Variable para el ID de la instancia RDS, utilizada en el módulo de monitoreo.
variable "db_instance_id" {
  description = "ID de la instancia RDS a monitorear."
  type        = string
}

## Variable para definir notificaciones por correo electrónico, utilizada en el módulo de monitoreo.
variable "notificacion_email" {
  description = "Email para recibir alertas del topic SNS. Dejar vacío para no crear suscripción."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for email in var.notificacion_email :
      can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", email))
    ])
    error_message = "Todos los valores de notificacion_email deben tener un formato de correo electrónico válido."
  }
}

## Variable para definir topic SNS, utilizada en el módulo de monitoreo.
variable "sns_topic_name" {
  description = "Nombre del topic SNS para alertas."
  type        = string
  default     = "alertas-monitoreo"
}

## Variable para definir dashboard de CloudWatch, utilizada en el módulo de monitoreo.
variable "dashboard_name" {
  description = "Nombre del dashboard de CloudWatch."
  type        = string
  default     = "dashboard-monitoreo"
}

## Variable para definir alarma CPU de EC2, utilizada en el módulo de monitoreo.
variable "alarma_cpu_umbral" {
  description = "Umbral de CPU para alarma de EC2."
  type        = number
  default     = 80

  validation {
    condition     = var.alarma_cpu_umbral >= 0 && var.alarma_cpu_umbral <= 100
    error_message = "alarma_cpu_umbral debe estar entre 0 y 100."
  }
}

## Variable para umbral de CPU de RDS, utilizada en el módulo de monitoreo.
variable "alarma_rds_cpu_umbral" {
  description = "Umbral de CPU para alarma de RDS."
  type        = number
  default     = 70

  validation {
    condition     = var.alarma_rds_cpu_umbral >= 0 && var.alarma_rds_cpu_umbral <= 100
    error_message = "alarma_rds_cpu_umbral debe estar entre 0 y 100."
  }
}

## Variable para definir umbral de 5xx en ALB, utilizada en el módulo de monitoreo.
variable "alarma_alb_5xx_umbral" {
  description = "Umbral de errores 5xx en el ALB."
  type        = number
  default     = 10

  validation {
    condition     = var.alarma_alb_5xx_umbral >= 0
    error_message = "alarma_alb_5xx_umbral no puede ser negativo."
  }
}

## Variable para definir umbral almacenamiento libre en RDS, utilizada en el módulo de monitoreo.
variable "alarma_rds_free_storage_umbral_gb" {
  description = "Umbral de almacenamiento libre en RDS (GB)."
  type        = number
  default     = 10

  validation {
    condition     = var.alarma_rds_free_storage_umbral_gb > 0
    error_message = "alarma_rds_free_storage_umbral_gb debe ser mayor que cero."
  }
}

## Variable para definir período de evaluación para las alarmas, utilizada en el módulo de monitoreo.
variable "alarma_periodo_segundos" {
  description = "Período de evaluación para las alarmas."
  type        = number
  default     = 300

  validation {
    condition     = var.alarma_periodo_segundos > 0 && var.alarma_periodo_segundos % 60 == 0
    error_message = "alarma_periodo_segundos debe ser positivo y múltiplo de 60."
  }
}

variable "alarma_evaluacion_periodos" {
  description = "Cantidad de períodos para evaluar la alarma."
  type        = number
  default     = 2

  validation {
    condition     = var.alarma_evaluacion_periodos > 0 && floor(var.alarma_evaluacion_periodos) == var.alarma_evaluacion_periodos
    error_message = "alarma_evaluacion_periodos debe ser un número entero mayor que cero."
  }
}

## Variable para habilitar la creación de un CloudWatch Log Group adicional, utilizada en el módulo de monitoreo.
variable "habilitar_log_group" {
  description = "Habilita la creación de un CloudWatch Log Group adicional."
  type        = bool
  default     = false
}

## Variable para definir el nombre del CloudWatch Log Group opcional, utilizada en el módulo de monitoreo.
variable "log_group_name" {
  description = "Nombre del CloudWatch Log Group opcional."
  type        = string
  default     = "/aws/monitoring/app"
}

## Variable para definir la retención del CloudWatch Log Group opcional.
variable "log_retention_in_days" {
  description = "Cantidad de días que se conservarán los logs en CloudWatch."
  type        = number
  default     = 30

  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731,
      1096, 1827, 2192, 2557, 2922, 3288, 3653
    ], var.log_retention_in_days)
    error_message = "log_retention_in_days debe ser un período de retención admitido por CloudWatch Logs."
  }
}
