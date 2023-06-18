import boto3
import json

def lambda_handler(event, context):
    try:
        # Validación de entrada
        validate_input(event)
        
        # Obtener los datos necesarios de la solicitud
        path = event['path']
        http_method = event['httpMethod']
        source_ip = event['requestContext']['identity']['sourceIp']
        
        if path == '/health' and http_method == 'GET':
            print("Request received for /health")
            print({
                "logMessage": "Health Check",
                "sourceIp": source_ip,
                "path": path,
                "httpMethod": http_method
            })
            return {
                "statusCode": 200,
                "body": "Health Check OK. He alcanzado a la lambda."
            }
        
        print(f"Proxy Request: {http_method} {path}")
        
        # Realizar la solicitud a la API de destino
        response = proxy_request(path, http_method, source_ip)
        
        print(f"Proxy Response: {response['statusCode']}")
        
        return {
            "statusCode": response['statusCode'],
            "body": response['body']
        }
    except Exception as e:
        # Manejo de errores específicos
        error_message = str(e)
        print(f"Error: {error_message}")
        
        return {
            "statusCode": 500,
            "body": f"Error: {error_message}"
        }

def validate_input(event):
    # Implementar la validación de los campos requeridos en el evento
    # Por ejemplo, verificar la presencia de 'path', 'httpMethod', etc.
    if 'path' not in event or 'httpMethod' not in event:
        raise Exception("Invalid input. 'path' and 'httpMethod' are required fields.")

def proxy_request(path, http_method, source_ip):
    # Crear una instancia del cliente de API Gateway para realizar la solicitud
    api_gateway_client = boto3.client('apigatewaymanagementapi')

    # Crear una solicitud de redireccionamiento a api.mercadolibre.com
    # utilizando la ruta y el método HTTP proporcionados
    response = api_gateway_client.post_to_connection(
        Data=f'{http_method} {path}',
        ConnectionId='CONNECTION_ID'  # Reemplaza CONNECTION_ID con el ID de la conexión real
    )

    # Registrar la solicitud y guardar estadísticas de uso
    save_request_statistics(source_ip, path, http_method)

    return {
        "statusCode": response['StatusCode'],
        "body": response['Body']
    }

def save_request_statistics(source_ip, path, http_method):
    # Implementar la lógica para almacenar las estadísticas de uso de proxy
    # por ejemplo, guardar los datos en una tabla de DynamoDB

    # Registrar información de origen, ruta y método HTTP en la tabla DynamoDB
    # para su posterior análisis y visualización
    print(f"Request Statistics: {source_ip}, {path}, {http_method}")

# Configuración para imprimir mensajes en formato JSON en CloudWatch
def json_print(message):
    print(json.dumps(message))

# Reemplazar la función print por json_print en la función lambda_handler
print = json_print
