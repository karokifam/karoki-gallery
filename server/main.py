from flask import Flask, request, jsonify
from flask_cors import CORS

### ---------- import routes as blueprints ---------
from routes.binder_route import binder_bp
from routes.media_route import media_bp
from routes.upload_route import upload_bp
from routes.chat_route import chat_bp
from routes.auth_route import auth_bp


app = Flask(__name__)
CORS(app)

app.register_blueprint(binder_bp)
app.register_blueprint(media_bp)
app.register_blueprint(upload_bp)
app.register_blueprint(chat_bp)
app.register_blueprint(auth_bp)

@app.route('/health')
def get_health():
    return jsonify({'message': 'OK'}), 200

if __name__ == '__main__':
    app.run(debug=True, port=8000, host='0.0.0.0')