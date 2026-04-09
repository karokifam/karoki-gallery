from pymongo import MongoClient
from  dotenv import load_dotenv
import os

load_dotenv()

Mongo_uri = os.environ.get("MONGO_URI" , "MONGO_URI")
Db_name = os.environ.get("DB_NAME" , "DB_NAME")

client = MongoClient(Mongo_uri)
db = client[Db_name]

### ----------- Collections ------------
binders_collection = db["binders"]
media_collection = db["media"]
chat_collection = db["chats"]
poll_collection = db["poll"]
auth_collection = db["auth"]

class DatabaseFunctions:
    @staticmethod
    def add_media(media_content):
        return media_collection.insert_one(media_content)
    
    @staticmethod
    def update_binder_thumbnail(binder_path, thumbnail_url):
        return binders_collection.update_one(
            {"path": binder_path},
            {"$set": {"thumbnail": thumbnail_url}}
        )
    
    @staticmethod
    def add_chat(message):
        return chat_collection.insert_one(message)

    @staticmethod
    def get_chats(sender, receiver):
        # Use $or to find chats between the two users
        query = {
            "$or": [
                {"sender": sender, "receiver": receiver},
                {"sender": receiver, "receiver": sender}
            ]
        }
        # Sort by timestamp (assuming it exists) or _id if not
        chats = list(chat_collection.find(query).sort("_id", 1))
        
        # Serialize ObjectId
        for chat in chats:
            chat["_id"] = str(chat["_id"])
        return chats
    @staticmethod
    def get_groupChats(sender, receiver):
        # Use $or to find chats between the two users
        query = {
            "$or": [
                {"sender": sender, },
                {"receiver": sender}
            ]
        }
        # Sort by timestamp (assuming it exists) or _id if not
        chats = list(chat_collection.find(query).sort("_id", 1))
        
        # Serialize ObjectId
        for chat in chats:
            chat["_id"] = str(chat["_id"])
        return chats

        