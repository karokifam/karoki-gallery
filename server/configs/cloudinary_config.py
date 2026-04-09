import cloudinary
import os
from dotenv import load_dotenv

load_dotenv()

def initialize_cloudinary():
    cloudinary.config(
        cloud_name=os.environ.get('CLOUDINARY_CLOUD_NAME'),
        api_key=os.environ.get('CLOUDINARY_API_KEY'),
        api_secret=os.environ.get('CLOUDINARY_API_SECRET'),
        upload_preset=os.environ.get('CLOUDINARY_UPLOAD_PRESET'),
        secure=True
    )