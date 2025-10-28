# Ejercicio de Terraform Multicloud: Bot de Chat

## Objetivo: Proporcionar infraestructura en AWS y GCP para que los alumnos identifiquen errores intencionales y malas prácticas en implementaciones multicloud.

> **IMPORTANTE:** el código está diseñado como **material de entrenamiento**: contienen configuraciones inseguras y malas prácticas **intencionales**. Todas las configuraciones son *válidas sintácticamente* y pueden ejecutarse con `terraform plan`
sin conectarse a los proveedores de nube. No desplegar en producción.

---

## Estructura:

```
tf-meli-mod1/
├─ README.md
├─ terraform/
│  ├─ aws/
│  │  ├─ envs/
│  │  │   ├─ dev.tfvars
│  │  │   ├─ test.tfvars
│  │  │   └─ prod.tfvars
│  │  ├─ main.tf
│  │  ├─ variables.tf
│  │  └─ outputs.tf
│  └─ gcp/
│     ├─ envs/
│     │   ├─ dev.tfvars
│     │   ├─ test.tfvars
│     │   └─ prod.tfvars
│     ├─ main.tf
│     ├─ variables.tf
│     └─ outputs.tf
└─ incidents/
   └─ incident_playbook.md
```

- **AWS:** Instancia EC2, Grupos de Seguridad, Elastic IP, credenciales IAM en código
- **GCP:** Instancia Compute, Reglas de Firewall, configuración de red
- **Módulos:** `modules/aws/`, `modules/gcp/`
- **Ambientes:** Configuración mediante variables con soporte para dev/test/prod

---

## Cómo usar:

1. `terraform init`
2. `terraform plan` (usa variables por defecto)
3. Para ambientes específicos: `terraform plan -var-file=terraform.tfvars`

**Notas**:

- El laboratorio contiene reglas de firewall/grupos de seguridad demasiado permisivas
- Hay credenciales hardcodeadas y configuraciones inseguras
- Múltiples inconsistencias entre las implementaciones de AWS y GCP

---

## Explicación rápida de las "fallas intencionales":

Estas configuraciones fueron creadas a propósito para que los alumnos las identifiquen y propongan mejoras:

2. **Configuraciones de seguridad demasiado permisivas**

- Security Group de AWS permite todo el tráfico desde 0.0.0.0/0 en todos los puertos
- Reglas de firewall inconsistentes entre AWS y GCP

3. **Exposición de datos sensibles en outputs**

- Strings de conexión a base de datos con contraseñas expuestas
- Direcciones IP internas y detalles de infraestructura accesibles públicamente

4. **Configuraciones multicloud inconsistentes**

- Regiones diferentes sin consideración de latencia
- Políticas de acceso a red no coincidentes entre nubes
- Posturas de seguridad variables entre proveedores

5. **Controles de seguridad faltantes**

- Sin encriptación de discos en GCP
- Falta configuración de monitoreo
- Service accounts y roles IAM faltantes

6. **Malas prácticas en configuración de recursos**

- AMIs e imágenes de máquina hardcodeadas
- Recursos no utilizados (Elastic IP en AWS)
- Sin configuración de backend para estado remoto

7. **Mala gestión de secretos**

- Contraseñas de base de datos en variables de texto plano
- Credenciales de aplicación en scripts de user_data
- Sin flag sensitive en outputs que contienen secretos

8. **Problemas de disponibilidad y mantenimiento**

- Sin configuraciones de backup o snapshots
- Dependencias circulares entre módulos
- Valores hardcodeados que limitan la flexibilidad

---

## Resultados de aprendizaje esperados:

Después de completar este ejercicio, los estudiantes deberían ser capaces de:

- Identificar vulnerabilidades de seguridad en configuraciones multicloud
- Reconocer inconsistencias entre implementaciones de proveedores de nube
- Aplicar el principio de menor privilegio en configuraciones de seguridad de red
- Implementar prácticas adecuadas de gestión de secretos
- Establecer configuraciones consistentes entre múltiples proveedores de nube
- Aplicar patrones de alta disponibilidad y resiliencia en IaC
- Usar variables y outputs de Terraform de manera segura y efectiva