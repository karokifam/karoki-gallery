from flask import request, jsonify, Blueprint
from configs.database_config import DatabaseFunctions

chat_bp = Blueprint("chat", __name__, url_prefix="/messages") 

@chat_bp.route('/get/<sender>/<receiver>', methods=['GET'])
def get_chats(sender, receiver):
    chats = DatabaseFunctions.get_chats(sender, receiver)
    return jsonify(chats)
@chat_bp.route('/get_group_chats', methods=['GET'])
def get_group_chats():
    chats = DatabaseFunctions.get_groupChats('group' , 'group')
    return jsonify(chats)

@chat_bp.route('/send', methods=['POST'])
def send_chat():
    data = request.json
    if not data or not all(k in data for k in ("sender", "receiver", "message")):
        return jsonify({'error': 'Missing required fields'}), 400
    
    DatabaseFunctions.add_chat(data)
    return jsonify({'status': 'Message sent'}), 201
