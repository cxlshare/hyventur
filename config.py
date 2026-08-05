import json
import os

import boto3

# Runtime variables — these are the only things that differ between environments
# (dev/staging/prod) sharing the same container image. Everything sensitive
# (bucket name, image key, account-specific values) lives in Secrets Manager,
# not here.
AWS_REGION = os.getenv("AWS_REGION", "us-east-2")
ENVIRONMENT = os.getenv("ENVIRONMENT", "poc")
SECRET_NAME = os.getenv("SECRET_NAME", "hyventur/app-config")


def _load_secret(secret_name: str, region: str) -> dict:
    client = boto3.client("secretsmanager", region_name=region)
    response = client.get_secret_value(SecretId=secret_name)
    return json.loads(response["SecretString"])


_secret = _load_secret(SECRET_NAME, AWS_REGION)


class Config:
    AWS_REGION = AWS_REGION
    ENVIRONMENT = ENVIRONMENT
    SECRET_NAME = SECRET_NAME
    APP_NAME = _secret["APP_NAME"]
    S3_BUCKET = _secret["S3_BUCKET"]
    IMAGE_NAME = _secret["IMAGE_NAME"]
