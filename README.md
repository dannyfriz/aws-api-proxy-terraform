# AWS API Proxy - Terraform

Este proyecto muestra un ejemplo de implementación de un API Proxy utilizando Terraform en AWS. El API Proxy se encarga de redirigir las solicitudes de una API hacia otra.

## Estructura del Proyecto

El proyecto sigue la siguiente estructura de directorios:

```
.
├── backend.tf
├── dev.tfvars
├── errored.tfstate
├── main.tf
├── modules
│   ├── api_gateway
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── cloudwatch
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── dashboard
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── iam
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── lambda_function
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── src
│   │   │   ├── proxy_function.py
│   │   │   ├── proxy_function.zip
│   │   │   └── requirements.txt
│   │   └── variables.tf
│   └── waf
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── outputs.tf
├── README.md
├── template.tfvars
└── variables.tf
```

La estructura del proyecto se organiza en diferentes módulos de Terraform, cada uno con una responsabilidad específica:

- `api_gateway`: Este módulo contiene los archivos de configuración de Terraform relacionados con la API Gateway. Define la configuración de la puerta de enlace, las rutas y las políticas de seguridad.

- `cloudwatch`: Este módulo contiene los archivos de configuración de Terraform para la configuración de CloudWatch. Puede incluir la configuración de alarmas, paneles de control y otras métricas relacionadas con el monitoreo y la observabilidad.

- `dashboard`: Este módulo contiene los archivos de configuración de Terraform para la creación de paneles de control personalizados en CloudWatch. Permite visualizar métricas y datos relevantes para el proyecto en un solo lugar.

- `iam`: Este módulo contiene los archivos de configuración de Terraform para la gestión de roles y políticas de IAM (Identity and Access Management). Puede incluir la configuración de roles de ejecución de Lambda, políticas de permisos y otras configuraciones relacionadas con el acceso y la seguridad.

- `lambda_function`: Este módulo contiene los archivos de configuración de Terraform para la función Lambda. Define la configuración de la función, incluyendo el código fuente, los parámetros de ejecución y las políticas de permisos.

- `waf`: Este módulo contiene los archivos de configuración de Terraform para la configuración del Firewall de Aplicaciones Web (WAF). Define la configuración de las reglas de seguridad, las listas negras de direcciones IP y otras políticas de seguridad relacionadas con la protección de la API.

La estructura modular del proyecto permite una gestión más organizada y modular de los recursos de AWS, facilitando el mantenimiento, la escalabilidad y la reutilización en diferentes proyectos.

## Requisitos

- Terraform 1.5.0 o superior instalado localmente. Puedes descargarlo desde [aquí](https://www.terraform.io/downloads.html).
- Python 3.9 instalado en tu máquina.
- Credenciales de AWS configuradas en tu entorno.
- Un bucket de Amazon S3 creado y configurado con los permisos adecuados para Terraform.

El bucket de Amazon S3 se utiliza como backend de Terraform para almacenar el estado del proyecto de forma remota. Asegúrate de tener un bucket creado previamente en tu cuenta de AWS y configura los permisos de acceso adecuados. Puedes especificar la configuración del backend de Terraform en el archivo `backend.tf` dentro del proyecto.

La configuración adecuada del bucket de S3 es esencial para el correcto funcionamiento de Terraform y el almacenamiento seguro del estado del proyecto. Asegúrate de proporcionar los permisos y credenciales necesarios para que Terraform pueda acceder y gestionar el estado del proyecto en el bucket de S3.

Además, aunque no es obligatorio, se recomienda tener los siguientes recursos adicionales:

- Un dominio personalizado (custom domain) para la API Gateway.
- Un certificado SSL en la región de AWS que deseas utilizar, junto con su correspondiente ARN.

El dominio personalizado y el certificado SSL te permitirán configurar una conexión segura para tu API Gateway.

## Uso

1. Clona este repositorio en tu máquina local.
2. Crea un archivo `dev.tfvars` y otro archivo `prod.tfvars` en la raíz del proyecto. Puedes utilizar el archivo `template.tfvars` como referencia y completar los valores según tus necesidades para cada ambiente.
3. Actualiza los valores de las variables en los archivos `.tfvars` según tus configuraciones específicas para cada ambiente.
4. Antes de ejecutar los comandos `terraform plan` y `terraform apply`, asegúrate de crear el archivo ZIP de la función Lambda. Para ello, sigue los siguientes pasos:
   - Ve al directorio `modules/lambda_function/src` en la raíz del proyecto.
   - Comprime todos los archivos y carpetas en un archivo ZIP.
     - En Linux, puedes utilizar el siguiente comando en la terminal:
       ```
       zip -r proxy_function.zip proxy_function.py
       ```
   - Guarda el archivo ZIP resultante como `proxy_function.zip`.
5. Ejecuta el comando `terraform init` para inicializar el proyecto y descargar los plugins necesarios.
6. Ejecuta el comando `terraform plan -var-file="dev.tfvars"` para ver los cambios que se aplicarán en el ambiente de desarrollo.
7. Ejecuta el comando `terraform apply -var-file="dev.tfvars"` para implementar la infraestructura en AWS para el ambiente de desarrollo.
8. Si deseas implementar la infraestructura en el ambiente de producción, ejecuta los comandos `terraform plan -var-file="prod.tfvars"` y `terraform apply -var-file="prod.tfvars"` respectivamente, utilizando el archivo `prod.tfvars` como variable de entrada.
9. Una vez finalizada la implementación, encontrarás la URL de la API Gateway en la salida de Terraform.
10. Puedes ejecutar las pruebas automatizadas en el directorio `tests` utilizando el marco de pruebas de tu elección.
11. Recuerda que debes asignar el archivo `.tfvars` correspondiente al ambiente que deseas desplegar al utilizar

 los comandos `terraform plan` y `terraform apply`. Esto te permite configurar adecuadamente las variables y opciones para cada ambiente específico.

## Contribuciones

Las contribuciones son bienvenidas. Si tienes alguna sugerencia, problema o mejora, por favor crea un issue o envía un pull request.