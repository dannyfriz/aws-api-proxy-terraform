# AWS API Proxy - Terraform

Este proyecto muestra un ejemplo de implementación de un API Proxy utilizando Terraform en AWS. El API Proxy se encarga de redirigir las solicitudes a la API de Mercadolibre.

## Estructura del Proyecto

El proyecto sigue la siguiente estructura de directorios:

- `api_gateway`: Módulo de Terraform para configurar la API Gateway.
- `lambda_function`: Módulo de Terraform para configurar la función Lambda.
- `dynamodb`: Módulo de Terraform para configurar la tabla de DynamoDB.
- `tests`: Contiene pruebas automatizadas para la función Lambda.

## Requisitos

- Terraform instalado localmente.
- Credenciales de AWS configuradas en tu entorno.

## Uso

1. Clona este repositorio en tu máquina local.
2. Actualiza los valores de las variables en `main.tf` y otros archivos de configuración según tus necesidades.
3. Ejecuta `terraform init` para inicializar el proyecto.
4. Ejecuta `terraform plan` para ver los cambios que se aplicarán.
5. Ejecuta `terraform apply` para implementar la infraestructura en AWS.
6. Una vez finalizada la implementación, encontrarás la URL de la API Gateway en la salida de Terraform.
7. Puedes ejecutar las pruebas automatizadas en el directorio `tests` utilizando el marco de pruebas de tu elección.

## Contribuciones

Las contribuciones son bienvenidas. Si tienes alguna sugerencia, problema o mejora, por favor crea un issue o envía un pull request.

## Licencia

Este proyecto se distribuye bajo la licencia [MIT](https://opensource.org/licenses/MIT).
