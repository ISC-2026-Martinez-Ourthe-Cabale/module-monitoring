# Módulo de monitoreo

Este módulo crea alertas y visualizaciones de CloudWatch para recursos EC2, Application Load Balancer y RDS.

## Recursos creados

- Topic SNS y suscripciones opcionales por correo electrónico.
- Alarmas para CPU de EC2, hosts no saludables y errores 5xx del ALB.
- Alarmas para CPU y almacenamiento libre de RDS.
- Dashboard de CloudWatch con las métricas monitoreadas.
- Log Group opcional con retención configurable.

## Ejemplo de uso

```hcl
module "monitoring" {
  source = "git::ssh://git@github.com/ISC-2026-Martinez-Ourthe-Cabale/module-monitoring.git"

  project_name            = var.project_name
  asg_name                = module.ec2_asg.asg_name
  db_instance_id           = module.database.db_instance_id
  alb_arn_suffix           = module.alb.alb_arn_suffix
  target_group_arn_suffix  = module.alb.target_group_arn_suffix
  notificacion_email       = ["operaciones@example.com"]

  tags = {
    Environment = "production"
  }
}
```

Las dimensiones de las métricas del ALB requieren los atributos `arn_suffix`, no los ARN completos.

## Variables obligatorias

| Variable | Descripción |
| --- | --- |
| `alb_arn_suffix` | Sufijo del ARN del Application Load Balancer. |
| `target_group_arn_suffix` | Sufijo del ARN del Target Group. |
| `asg_name` | Nombre del Auto Scaling Group. |
| `db_instance_id` | Identificador de la instancia RDS. |

## Variables opcionales

| Variable | Valor predeterminado | Descripción |
| --- | --- | --- |
| `project_name` | `"Obligatorio"` | Nombre utilizado en recursos y tags. |
| `tags` | `{}` | Tags adicionales para los recursos. |
| `notificacion_email` | `[]` | Lista de correos que recibirán alertas. |
| `sns_topic_name` | `"alertas-monitoreo"` | Nombre del topic SNS. |
| `dashboard_name` | `"dashboard-monitoreo"` | Nombre del dashboard. |
| `alarma_cpu_umbral` | `80` | Umbral porcentual de CPU para EC2. |
| `alarma_rds_cpu_umbral` | `70` | Umbral porcentual de CPU para RDS. |
| `alarma_alb_5xx_umbral` | `10` | Umbral de respuestas 5xx. |
| `alarma_rds_free_storage_umbral_gb` | `10` | Umbral de almacenamiento libre en GB. |
| `alarma_periodo_segundos` | `300` | Duración de cada período de evaluación. |
| `alarma_evaluacion_periodos` | `2` | Cantidad de períodos evaluados. |
| `habilitar_log_group` | `false` | Habilita el Log Group opcional. |
| `log_group_name` | `"/aws/monitoring/app"` | Nombre del Log Group opcional. |
| `log_retention_in_days` | `30` | Retención de logs en días. |

## Outputs

| Output | Descripción |
| --- | --- |
| `sns_topic_arn` | ARN del topic SNS. |
| `dashboard_name` | Nombre del dashboard de CloudWatch. |
| `alarm_names` | Lista de nombres de las alarmas. |
| `log_group_name` | Nombre del Log Group, o un string vacío si está deshabilitado. |

## Notificaciones por correo

AWS envía un mensaje de confirmación a cada dirección configurada. La suscripción no comienza a recibir alertas hasta que el destinatario confirma el enlace enviado por SNS.

Cuando `notificacion_email` está vacío no se crean suscripciones ni se asignan acciones SNS a las alarmas.
