import json
import requests
import boto3
from botocore.signers import RequestSigner

def get_api_gateway_url(event):
    region = event['requestContext']['region']
    api_id = event['requestContext']['apiId']
    stage = event['requestContext']['stage']

    url = f"https://{api_id}.execute-api.{region}.amazonaws.com/{stage}"
    return url

def sign_request(url, region, service):
    credentials = boto3.Session().get_credentials()
    signer = RequestSigner(service, region, 'execute-api', 'v4', credentials)

    headers = {}
    signed_url = signer.generate_presigned_url(
        method='GET',
        url=url,
        headers=headers,
        region_name=region,
        expires_in=60
    )

    return signed_url, headers

def lambda_handler(event, context):
    print("Received event: " + json.dumps(event))

    try:
        # Extract the category ID from the path
        category_id = event['pathParameters']['proxy']

        # Create the URL for the API Gateway endpoint
        api_gateway_url = get_api_gateway_url(event)

        # Sign the request for the API Gateway endpoint
        signed_url, headers = sign_request(api_gateway_url, 'us-east-1', 'execute-api')

        # Forward the request to the signed URL
        url = f"{signed_url}/categories/{category_id}"
        response = requests.get(url, headers=headers)

        # Return the response from api.mercadolibre.com
        return {
            'statusCode': response.status_code,
            'body': response.text,
            'headers': {
                'Content-Type': response.headers.get('Content-Type')
            }
        }

    except Exception as e:
        print("Error:", str(e))

        error_response = {
            'statusCode': 500,
            'body': 'An error occurred'
        }

        # Log the error response
        print("Error Response: " + json.dumps(error_response))
        return error_response
