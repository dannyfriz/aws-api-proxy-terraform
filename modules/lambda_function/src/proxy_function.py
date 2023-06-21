import json
import urllib.parse
import urllib.request

def lambda_handler(event, context):
    print('Inicio de la función Lambda')

    # Obtener la URL completa enviada por el cliente
    url = event["path"]

    try:
        # Asegurarse de que la URL tenga el esquema completo
        if not url.startswith("https://"):
            url = "https://" + url

        # Descomponer la URL en sus componentes
        parsed_url = urllib.parse.urlparse(url)

        # Obtener la ruta de la URL
        path = parsed_url.path

        # Obtener el último segmento de la ruta (ejemplo: MLM189580)
        category_id = path.split("/")[-1]

        # Construir la nueva URL con el dominio y el último segmento de la ruta
        new_netloc = "api.mercadolibre.com"
        modified_url = f"https://{new_netloc}/categories/{category_id}"

        print(f'URL modificada: {modified_url}')

        print('Realizando la solicitud GET')
        # Realizar la solicitud GET a la URL modificada
        response = urllib.request.urlopen(modified_url)

        # Leer la respuesta y decodificarla como JSON
        data = json.loads(response.read().decode())
        print('Respuesta decodificada como JSON')

        # Devolver la respuesta como JSON
        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps(data)
        }
    except urllib.error.HTTPError as e:
        print(f'Error HTTP: {str(e)}')
        # Capturar errores HTTP
        return {
            "statusCode": e.code,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"message": str(e)})
        }
    except Exception as e:
        print(f'Error: {str(e)}')
        # Capturar otros errores
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"message": "Error interno del servidor"})
        }
