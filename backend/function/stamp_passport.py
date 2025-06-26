import base64
import hashlib
import hmac
import json
import os
from datetime import datetime, timedelta, timezone

import boto3
from botocore.exceptions import ClientError
from utils import generate_http_response

# Inicializar cliente de DynamoDB
dynamodb = boto3.client("dynamodb")

table_name = os.environ.get("DYNAMODB_TABLE_NAME")
index_name = os.environ.get("INDEX_NAME")

# Clave secreta para firmar y verificar el JWT
SECRET_KEY = "my_super_secret_key"


# Función para decodificar el JWT sin librerías externas
def base64url_decode(input: str):
    rem = len(input) % 4
    if rem > 0:
        input += "=" * (4 - rem)
    return base64.urlsafe_b64decode(input)


def verify_jwt(token, secret_key):
    try:
        # Separar el token en sus tres partes (header, payload, signature)
        header_b64, payload_b64, signature_b64 = token.split(".")

        # Verificar la firma
        signing_input = f"{header_b64}.{payload_b64}".encode()
        signature = base64url_decode(signature_b64)
        key = secret_key.encode()
        expected_signature = hmac.new(key, signing_input, hashlib.sha256).digest()

        if not hmac.compare_digest(signature, expected_signature):
            return None

        # Decodificar el payload
        payload_json = base64url_decode(payload_b64).decode("utf-8")
        payload = json.loads(payload_json)

        # Verificar que el token no haya expirado
        if "exp" in payload and datetime.utcnow().timestamp() > payload["exp"]:
            return None

        return payload
    except Exception as e:
        print(f"Error verifying JWT: {e}")
        return None

def can_register(user_id, sponsor_id):
    # Eliminar esta función ya que no necesitamos la regla de 10 minutos
    pass


# Función para guardar o actualizar el sello y los comentarios
def lambda_handler(event, context):
    # Parsear el cuerpo de la solicitud
    try:
        body = json.loads(event["body"])
        short_id = body["short_id"]
        jwt_token = body["jwt"]
    except (KeyError, json.JSONDecodeError) as e:
        return generate_http_response(400, {"error": "Invalid input"})

    # Verificar el JWT y extraer el sponsor_id
    jwt_payload = verify_jwt(jwt_token, SECRET_KEY)
    if jwt_payload is None:
        return generate_http_response(403, {"error": "Invalid or expired JWT"})

    sponsor_id = jwt_payload.get("sponsor_id")
    if not sponsor_id:
        return generate_http_response(403, {"error": "JWT does not contain sponsor_id"})

    notes = body.get("notes", "")  # Notas opcionales

    try:
        # Buscar al usuario por short_id
        response_user = dynamodb.query(
            TableName=table_name,
            IndexName=index_name,
            KeyConditionExpression="short_id = :sid",
            ExpressionAttributeValues={":sid": {"S": short_id}},
        )

        # Verificar si el usuario existe
        if not response_user["Items"]:
            return generate_http_response(404, {"error": "User not found"})

        user_id = response_user["Items"][0]["user_id"]["S"]

        now = datetime.now(timezone.utc).isoformat()

        # Buscar el registro existente para este participante y sponsor
        response_sessions = dynamodb.query(
            TableName=table_name,
            KeyConditionExpression="PK = :user_pk AND begins_with(SK, :sponsor_sk)",
            ExpressionAttributeValues={
                ":user_pk": {"S": f"USER#{user_id}"},
                ":sponsor_sk": {"S": f"SPONSOR#{sponsor_id}"},
            },
        )
        
        items = response_sessions.get('Items', [])
        
        if items:
            # Ya existe un registro
            existing_item = items[0]
            current_visit_count = int(existing_item.get('visit_count', {}).get('N', '0'))
            previous_notes = existing_item.get('notes', {}).get('S', '')
            last_visit = existing_item.get('last_visit', {}).get('S', existing_item.get('created_at', {}).get('S', now))

            if notes and not body.get('register_visit', True):
                # Solo actualizar comentarios, NO sumar visita ni actualizar last_visit
                dynamodb.update_item(
                    TableName=table_name,
                    Key={
                        "PK": {"S": f"USER#{user_id}"},
                        "SK": {"S": f"SPONSOR#{sponsor_id}"}
                    },
                    UpdateExpression="SET notes = :notes",
                    ExpressionAttributeValues={
                        ":notes": {"S": notes}
                    }
                )
                return generate_http_response(200, {
                    "message": "Comments updated",
                    "visit_count": current_visit_count,
                    "last_visit": last_visit,
                    "previous_notes": notes
                })
            else:
                # Registrar visita: sumar visita y actualizar last_visit
                new_visit_count = current_visit_count + 1
                update_expression = "SET visit_count = :visit_count, last_visit = :last_visit"
                expression_values = {
                    ":visit_count": {"N": str(new_visit_count)},
                    ":last_visit": {"S": now}
                }
                if notes:
                    update_expression += ", notes = :notes"
                    expression_values[":notes"] = {"S": notes}
                dynamodb.update_item(
                    TableName=table_name,
                    Key={
                        "PK": {"S": f"USER#{user_id}"},
                        "SK": {"S": f"SPONSOR#{sponsor_id}"}
                    },
                    UpdateExpression=update_expression,
                    ExpressionAttributeValues=expression_values
                )
                return generate_http_response(200, {
                    "message": "Visit updated",
                    "visit_count": new_visit_count,
                    "last_visit": now,
                    "previous_notes": notes if notes else previous_notes
                })
        else:
            # Primera visita, crear nuevo registro
            item_to_save = {
                "PK": {"S": f"USER#{user_id}"},
                "SK": {"S": f"SPONSOR#{sponsor_id}"},
                "created_at": {"S": now},
                "last_visit": {"S": now},
                "visit_count": {"N": "1"}
            }
            
            # Agregar comentarios si existen
            if notes:
                item_to_save["notes"] = {"S": notes}
                
            dynamodb.put_item(TableName=table_name, Item=item_to_save)
            
            return generate_http_response(200, {
                "message": "First visit registered",
                "visit_count": 1,
                "last_visit": now
            })

    except ClientError as e:
        print(f"Error accessing DynamoDB: {e}")
        return generate_http_response(500, {"error": "Error accessing DynamoDB"})
