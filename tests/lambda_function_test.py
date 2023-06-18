import unittest

from lambda_function import lambda_handler

class LambdaFunctionTest(unittest.TestCase):

    def test_lambda_handler(self):
        event = {
            "key1": "value1",
            "key2": "value2",
            "key3": "value3"
        }

        context = {}

        response = lambda_handler(event, context)

        # Agrega aquí las aserciones para verificar la respuesta de la función Lambda
        self.assertEqual(response["statusCode"], 200)
        self.assertEqual(response["body"], "Hello, World!")

if __name__ == '__main__':
    unittest.main()
