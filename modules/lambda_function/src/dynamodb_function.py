import os
import json
import boto3
from botocore.exceptions import ClientError

# Obtener el nombre de la tabla DynamoDB del entorno
DYNAMODB_TABLE_NAME = os.environ['DYNAMODB_TABLE_NAME']

# Crear un cliente DynamoDB
dynamodb = boto3.client('dynamodb')

def lambda_handler(event, context):
    try:
        # Obtener información de la solicitud
        http_method = event['httpMethod']
        path = event['path']
        headers = event['headers']
        query_string_parameters = event['queryStringParameters']
        body = event['body']

        # Realizar operaciones adicionales según tus necesidades
        # Por ejemplo, puedes procesar los datos de la solicitud, realizar validaciones, etc.

        # Convertir la solicitud a JSON
        request_json = json.dumps(event)

        # Insertar el registro en DynamoDB
        dynamodb.put_item(
            TableName=DYNAMODB_TABLE_NAME,
            Item={
                'RequestId': {'S': context.aws_request_id},
                'RequestData': {'S': request_json},
            }
        )

        print("Registro insertado en DynamoDB")

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
