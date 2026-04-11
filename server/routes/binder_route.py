from flask import Blueprint, jsonify, request
from configs.database_config import binders_collection
from configs.cloudinary_config import initialize_cloudinary
import cloudinary.api

binder_bp = Blueprint("binder", __name__)

# Initialize cloudinary to use the Admin API
initialize_cloudinary()

@binder_bp.route("/folders", methods=["GET"])
def get_binders():
    # Fetch all binders from MongoDB
    binders = list(binders_collection.find({}, {"_id": 0}))  # hide _id
       
    return jsonify(binders)

@binder_bp.route("/folders", methods=["POST"])
def create_binder():
    data = request.json
    # UI only sends 'name'
    name = data.get("name")
    

    if not name:
        return jsonify({"error": "Missing binder name"}), 400

    # Path used for querying media
    path = name.replace(" ", "")

    # Check if binder already exists in DB
    if binders_collection.find_one({"path": path}):
        return jsonify({"error": "Binder already exists"}), 409

    try:
        # Create folder in Cloudinary under 'base/' root
        # This uses the Cloudinary Admin API
        cloudinary.api.create_folder(f"base/{path}")

        new_binder = {
            "name": name,
            "path": path,
        }

        binders_collection.insert_one(new_binder)

        return jsonify({
            "message": "Binder created successfully", 
            "binder": {
                "name": name,
                "path": path
            }
        }), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500