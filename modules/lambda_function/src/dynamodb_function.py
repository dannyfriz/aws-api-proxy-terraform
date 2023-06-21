import os
import json
import boto3
from botocore.exceptions import ClientError

# Obtener el nombre de la tabla DynamoDB del entorno
DYNAMODB_TABLE_NAME = os.environ['DYNAMODB_TABLE_NAME']

# Crear un cliente DynamoDB
dynamodb = boto3.client('dynamodb')

def write_items_to_dynamodb(items):
    # Escribe una lista de elementos en DynamoDB utilizando operaciones de escritura por lotes.
    request_items = {
        DYNAMODB_TABLE_NAME: items
    }
    dynamodb.batch_write_item(RequestItems=request_items)

def lambda_handler(event, context):
    try:
        # Obtener la IP y el host de la solicitud
        ip_address = event['requestContext']['identity']['sourceIp']
        host = event['headers']['Host']

        # Crear una lista de elementos para insertar en DynamoDB
        items = []
        request_json = json.dumps(event)
        item = {
            'PutRequest': {
                'Item': {
                    'RequestId': {'S': context.aws_request_id},
                    'RequestData': {'S': request_json},
                    'IPAddress': {'S': ip_address},
                    'Host': {'S': host}
                }
            }
        }
        items.append(item)

        # Escribir los elementos en DynamoDB utilizando operaciones de escritura por lotes
        write_items_to_dynamodb(items)

        print("Registros insertados en DynamoDB")

        return {
            'statusCode': 200,
            'body': json.dumps('Hello from Lambda!')
        }
    except ClientError as e:
        error_message = e.response['Error']['Message']
        print(f"Error al insertar el registro en DynamoDB: {error_message}")

        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {error_message}')
        }
    except Exception as e:
        error_message = str(e)
        print(f"Error en la función Lambda: {error_message}")

        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {error_message}')
        }
