terraform {
  backend "s3" {
    bucket         = "nombre-del-bucket-s3"
    key            = "ruta-dentro-del-bucket/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "nombre-de-la-tabla-dynamodb"
    profile        = "nombre-del-perfil-de-credenciales"
  }
}
