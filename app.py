import boto3
from flask import Flask, render_template

from config import Config

app = Flask(__name__)
s3 = boto3.client(
    "s3",
    region_name=Config.AWS_REGION,
    endpoint_url=f"https://s3.{Config.AWS_REGION}.amazonaws.com",
)


@app.route("/")
def home():
    image_url = s3.generate_presigned_url(
        "get_object",
        Params={"Bucket": Config.S3_BUCKET, "Key": Config.IMAGE_NAME},
        ExpiresIn=300,
    )
    return render_template(
        "index.html",
        app_name=Config.APP_NAME,
        environment=Config.ENVIRONMENT,
        region=Config.AWS_REGION,
        bucket=Config.S3_BUCKET,
        secret_name=Config.SECRET_NAME,
        image_url=image_url,
    )


@app.route("/health")
def health():
    return {"status": "ok"}, 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
