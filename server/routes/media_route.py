from flask import Blueprint, jsonify , request
from configs.database_config import media_collection , poll_collection , chat_collection
from bson import ObjectId
import cloudinary.uploader

media_bp = Blueprint("media", __name__)

# Helper to convert ObjectId to string
def serialize_media(doc):
    return {
        "id": str(doc.get("_id", "")),
        "uploader": doc.get("uploader"),
        "type": doc.get("type"),
        "url": doc.get("url"),
        "binder": doc.get("binder"),
    }

@media_bp.route("/media/<binder_path>", methods=["GET"])
def get_media(binder_path):
    # Query media by parent binder
    media_docs = list(media_collection.find({"binder": binder_path}))

    # Serialize ObjectId
    media_list = [serialize_media(doc) for doc in media_docs]

    return jsonify(media_list)



@media_bp.route("/media/delete", methods=["POST"])
def delete_media():
    data = request.json
    deleter = data.get('deleter')
    media_url = data.get('memory')
    

    # Find the media document
    media_docs = list(media_collection.find({"url": media_url}))
    if media_docs:
        media_doc = media_docs[0]  # Take the first match
        if media_doc['uploader'] == deleter:
            public_id = media_collection.find_one({'url': media_url})
            try:
                cloudinary.uploader.destroy(public_id, resource_type="image")
            except Exception as e:
                pass
            media_collection.delete_one({'url': media_url})
            return jsonify({"status": "successfully Deleted", "message": "Delete request processed"}), 200
    
    # Insert poll data
    poll_data = {
        "deleter": deleter,
        "memory": media_url,
        "votes_delete": 0,
        "votes_stay": 0,
        "total_voters": [],
        "total_votes": 0,
    }
    poll_collection.insert_one(poll_data)

    # Insert chat message
    poll_db_info = poll_collection.find_one({'memory':media_url})
    chat_collection.insert_one({
        'sender': 'app',
        'receiver': 'group',
        'message': 'pole',
        'memory': media_url,
        'deleter': deleter,
        'poll_id': str(poll_db_info['_id'])
    })

    return jsonify({"status": "Delete poll created", "message": "Delete request processed"}), 201



@media_bp.route("/media/delete_poll", methods=["POST"])
def poll():
    data = request.json

    vote_type = data.get('vote_type')  # "delete" or "stay"
    voter = data.get('voter')
    poll_id = data.get('poll_id')

    if not all([vote_type, voter, poll_id]):
        return jsonify({"error": "Missing data"}), 400

    # Convert string poll_id to ObjectId
    try:
        poll_obj_id = ObjectId(poll_id)
    except Exception:
        return jsonify({"error": "Invalid poll_id"}), 400

    poll_data = poll_collection.find_one({"_id": poll_obj_id})
    if not poll_data:
        return jsonify({"error": "Poll not found"}), 404

    # Check if voter has already voted
    if voter in poll_data.get('total_voters', []):
        return jsonify({"message": "You have already voted"}), 200

    # Decide which field to increment
    update_field = "votes_delete" if vote_type == "delete" else "votes_stay"

    # Update vote counts and total_voters
    poll_collection.update_one(
        {"_id": poll_obj_id},
        {
            "$inc": {update_field: 1, "total_votes": 1},
            "$addToSet": {"total_voters": voter}
        }
    )

    # Refresh poll data after update
    poll_data = poll_collection.find_one({"_id": poll_obj_id})
    status = 'saved from deletion'

    # Check if total votes reached threshold
    if poll_data.get('total_votes', 0) >= 5 or poll_data.get('votes_delete', 0) >= 3:
        if poll_data.get('votes_delete', 0) >= poll_data.get('votes_stay', 0):
            public_id = media_collection.find_one({'url': poll_data.get('memory')})['public_id']
            try:
                cloudinary.uploader.destroy(public_id, resource_type="image")
            except Exception as e:
                pass
            media_collection.delete_one({'url': poll_data.get('memory')})
            status = 'deleted'
            chat_collection.delete_one({'_id':poll_obj_id})
            poll_collection.delete_one({'_id':poll_obj_id})

        # Insert a message into chat collection
        chat_collection.insert_one({
            'sender': 'app',
            'receiver': 'group',
            'message': f"A memory was {status} by {poll_data.get('deleter')} "
                    f"from a poll: {poll_data.get('votes_delete')} wanted it deleted "
                    f"vs {poll_data.get('votes_stay')} wanted it to remain"
        })


    

    return jsonify({"message": "Vote recorded"}), 200