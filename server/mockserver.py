from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# -------------------------------
# Mock data for binders (folders)
# -------------------------------
mock_binders = [
    {"name": "Vacation 2023", "path": "vacation_2023"},
    {"name": "Family Events", "path": "family_events"},
    {"name": "School Memories", "path": "school_memories"},
    {"name": "work_projects", "path": "work_projects"},
]

# -------------------------------
# Mock data for media inside binders
# -------------------------------
mock_media = {
    "vacation_2023": [
        {"url": "https://placekitten.com/400/400", "type": "image"},
        {"url": "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4", "type": "video"},
        {"url": "https://placekitten.com/401/400", "type": "image"},
    ],
    "family_events": [
        {"url": "https://placekitten.com/402/400", "type": "image"},
        {"url": "https://placekitten.com/403/400", "type": "image"},
    ],
    "school_memories": [
        {"url": "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4", "type": "video"},
        {"url": "https://placekitten.com/404/400", "type": "image"},
    ],
    "work_projects": [
        {"url": "https://placekitten.com/405/400", "type": "image"},
        {"url": "https://picsum.photos/seed/42/405/400", "type": "image"},
        {"url": "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4", "type": "video"},
    ],
}

# -------------------------------
# Routes
# -------------------------------

@app.route("/folders", methods=["GET"])
def get_folders():
    return jsonify(mock_binders)


@app.route("/media/<binder_name>", methods=["GET"])
def get_media(binder_name):
    print(jsonify(mock_media.get(binder_name, [])))
    return jsonify(mock_media.get(binder_name, []))


# -------------------------------
# Run server
# -------------------------------
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)