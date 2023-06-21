import json
import urllib.request

def lambda_handler(event, context):
    print('Inicio de la función Lambda')

    # Obtener el parámetro "id" de la ruta
    id = event["pathParameters"]["id"]
    print(f'ID obtenido: {id}')

    # Construir la URL de proxy reemplazando el marcador de posición "{id}"
    url = f"https://api.mercadolibre.com/categories/{id}"
    print(f'URL construida: {url}')

    try:
        print('Realizando la solicitud GET')
        # Realizar la solicitud GET al proxy
        response = urllib.request.urlopen(url)
        
        # Leer la respuesta y decodificarla como JSON
        data = json.loads(response.read().decode())
        print('Respuesta decodificada como JSON')
        
        # Devolver la respuesta como JSON
        return {
            "statusCode": 200,
            "headers": { "Content-Type": "application/json" },
            "body": json.dumps(data)
        }
    except urllib.error.HTTPError as e:
        print(f'Error HTTP: {str(e)}')
        # Capturar errores HTTP
        return {
            "statusCode": e.code,
            "headers": { "Content-Type": "application/json" },
            "body": json.dumps({"message": str(e)})
        }
    except Exception as e:
        print(f'Error: {str(e)}')
        # Capturar otros errores
        return {
            "statusCode": 500,
            "headers": { "Content-Type": "application/json" },
            "body": json.dumps({"message": "Error interno del servidor"})
        }
