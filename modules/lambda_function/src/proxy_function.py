import os
import json
import urllib.parse
import urllib.request

# Get the target domain name
API_DOMAIN = os.environ['API_DOMAIN']

def lambda_handler(event, context):
    print('Start of Lambda function')

    # Get the complete URL sent by the client
    url = event["path"]

    try:
        # Ensure that the URL has the complete scheme
        if not url.startswith("https://"):
            url = "https://" + url

        # Parse the URL into its components
        parsed_url = urllib.parse.urlparse(url)

        # Get the path of the URL
        path = parsed_url.path

        # Get the last segment of the path (example: MLM189580)
        category_id = path.split("/")[-1]

        # Build the new URL with the domain and the last segment of the path
        modified_url = f"https://{API_DOMAIN}/categories/{category_id}"

        print(f'Modified URL: {modified_url}')

        print('Making the GET request')
        # Make the GET request to the modified URL
        response = urllib.request.urlopen(modified_url)

        # Read the response and decode it as JSON
        data = json.loads(response.read().decode())
        print('Response decoded as JSON')

        # Return the response as JSON
        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps(data)
        }
    except urllib.error.HTTPError as e:
        print(f'HTTP Error: {str(e)}')
        # Catch HTTP errors
        return {
            "statusCode": e.code,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"message": str(e)})
        }
    except Exception as e:
        print(f'Error: {str(e)}')
        # Catch other errors
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"message": "Internal Server Error"})
        }
