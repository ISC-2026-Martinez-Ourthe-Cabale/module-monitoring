## Variable para definir nombre del proyecto.
variable "project_name" {
  description = "Nombre del proyecto para tags y recursos de monitoreo."
  type        = string
  default     = "Obligatorio"
}

## Variable para definir VPC CIDR, utilizada en el módulo de networking.
variable "vpc_id" {
  description = "ID de la VPC donde se despliegan los recursos."
  type        = string
}

## Variable para definir las subnets públicas, utilizadas en el módulo de monitoreo.
variable "public_subnet_ids" {
  description = "IDs de subnets públicas usadas por recursos de monitoreo."
  type        = list(string)
}

## Variable para el ARN del ALB, utilizada en el módulo de monitoreo.
variable "alb_arn" {
  description = "ARN del Application Load Balancer."
  type        = string
}

## Variable para el ARN del Target Group, utilizada en el módulo de monitoreo.
variable "target_group_arn" {
  description = "ARN del Target Group asociado al ALB."
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
}

## Variable para umbral de CPU de RDS, utilizada en el módulo de monitoreo.
variable "alarma_rds_cpu_umbral" {
  description = "Umbral de CPU para alarma de RDS."
  type        = number
  default     = 70
}

## Variable para definir umbral de 5xx en ALB, utilizada en el módulo de monitoreo.
variable "alarma_alb_5xx_umbral" {
  description = "Umbral de errores 5xx en el ALB."
  type        = number
  default     = 10
}

## Variable para definir umbral almacenamiento libre en RDS, utilizada en el módulo de monitoreo.
variable "alarma_rds_free_storage_umbral_gb" {
  description = "Umbral de almacenamiento libre en RDS (GB)."
  type        = number
  default     = 10
}

## Variable para definir período de evaluación para las alarmas, utilizada en el módulo de monitoreo.
variable "alarma_periodo_segundos" {
  description = "Período de evaluación para las alarmas."
  type        = number
  default     = 300
}

variable "alarma_evaluacion_periodos" {
  description = "Cantidad de períodos para evaluar la alarma."
  type        = number
  default     = 2
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