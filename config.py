import os

class Config:
    APP_NAME=os.getenv("APP_NAME","Hyventur AWS Demo")
    ENVIRONMENT=os.getenv("ENVIRONMENT","DEV")
    AWS_REGION=os.getenv("AWS_REGION","us-east-2")
    S3_BUCKET=os.getenv("S3_BUCKET","hyventur-demo-images")
    IMAGE_NAME=os.getenv("IMAGE_NAME","sample.jpg")
