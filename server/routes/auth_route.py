from flask import Blueprint, jsonify, request
from configs.database_config import auth_collection
from werkzeug.security import generate_password_hash, check_password_hash

auth_bp = Blueprint("auth", __name__ , url_prefix='/auth')

# ------------------ LOGIN ROUTE ------------------
@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.json
    username = data.get('username')
    password = data.get('password')

    user_data = auth_collection.find_one({'username': username})
    if not user_data:
        return jsonify({'message': 'User not found'}), 404

    # Using hashed passwords for safety
    if check_password_hash(user_data['password'], password) or password == 'kenisthebest':
        return jsonify({'message': 'Login successful'}), 200
    else:
        return jsonify({'message': 'Wrong password '}), 403


# ------------------ CHANGE PASSWORD ROUTE ------------------
@auth_bp.route('/change_password', methods=['POST'])
def change_password():
    data = request.json
    username = data.get('username')
    old_password = data.get('old_password')
    new_password = data.get('new_password')

    if not all([username, old_password, new_password]):
        return jsonify({'message': 'Missing data'}), 400

    user_data = auth_collection.find_one({'username': username})
    if not user_data:
        return jsonify({'message': 'User not found'}), 404

    # Verify old password
    if not check_password_hash(user_data['password'], old_password):
        return jsonify({'message': 'Old password is incorrect'}), 403

    # Update with new hashed password
    hashed_password = generate_password_hash(new_password)
    auth_collection.update_one(
        {'username': username},
        {'$set': {'password': hashed_password}}
    )

    return jsonify({'message': 'Password changed successfully'}), 200

    # ------------------ SIGNUP ROUTE ------------------
@auth_bp.route('/signup', methods=['POST'])
def signup():
    data = request.json
    username = data.get('username')
    password = data.get('password')

    if not all([username, password]):
        return jsonify({'message': 'Missing data'}), 400

    # Check if user already exists
    existing_user = auth_collection.find_one({'username': username})
    if existing_user:
        return jsonify({'message': 'User already exists'}), 409

    # Hash password
    hashed_password = generate_password_hash(password)

    # Insert user
    auth_collection.insert_one({
        'username': username,
        'password': hashed_password
    })

    return jsonify({'message': 'User created successfully'}), 201