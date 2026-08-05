from flask import Flask, render_template
from config import Config

app=Flask(__name__)

@app.route("/")
def home():
    image_url=f"https://{Config.S3_BUCKET}.s3.{Config.AWS_REGION}.amazonaws.com/{Config.IMAGE_NAME}"
    return render_template("index.html",
                           app_name=Config.APP_NAME,
                           environment=Config.ENVIRONMENT,
                           region=Config.AWS_REGION,
                           bucket=Config.S3_BUCKET,
                           image_url=image_url)

if __name__=="__main__":
    app.run(host="0.0.0.0",port=5000)
