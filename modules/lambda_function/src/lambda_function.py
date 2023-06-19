import json

def lambda_handler(event, context):
    print("Received event: " + json.dumps(event))

    try:
        if event['path'] == '/categories':
            print("Lambda function executed for /categories")
            return {
                'statusCode': 200,
                'body': 'I have reached the Lambda function for /categories.',
                'headers': {
                    'Content-Type': 'text/plain'
                }
            }
        else:
            # Your code logic here
            print("Lambda function executed successfully")
            return {
                'statusCode': 200,
                'body': 'I have reached the Lambda function.',
                'headers': {
                    'Content-Type': 'text/plain'
                }
            }
    except Exception as e:
        print("Error:", str(e))
        return {
            'statusCode': 500,
            'body': 'An error occurred'
        }
