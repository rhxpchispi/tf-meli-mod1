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
