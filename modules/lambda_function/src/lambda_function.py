import boto3

def lambda_handler(event, context):
    # Extraer información del evento
    path = event['path']
    http_method = event['httpMethod']
    source_ip = event['requestContext']['identity']['sourceIp']

    # Verificar si la solicitud es para redirigir a api.mercadolibre.com
    if path.startswith('/categories'):
        # Realizar redireccionamiento a api.mercadolibre.com
        response = proxy_request(path, http_method, source_ip)
    else:
        # Devolver una respuesta de error para rutas no compatibles
        response = {
            "statusCode": 404,
            "body": "Route not supported"
        }

    return response

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

    # Devolver la respuesta recibida de api.mercadolibre.com
    return {
        "statusCode": response['StatusCode'],
        "body": response['Body']
    }

def save_request_statistics(source_ip, path, http_method):
    # Implementar la lógica para almacenar las estadísticas de uso de proxy
    # por ejemplo, guardar los datos en una tabla de DynamoDB

    # Registrar información de origen, ruta y método HTTP en la tabla DynamoDB
    # para su posterior análisis y visualización
    pass
