import os
import re
from flask import Blueprint, request, jsonify
from configs.cloudinary_config import initialize_cloudinary
import cloudinary.uploader
from configs.database_config import DatabaseFunctions , binders_collection

upload_bp = Blueprint('upload', __name__)

MEDIA_TYPE_MAP = {
    'png': ('image', 'image'),
    'jpg': ('image', 'image'),
    'jpeg': ('image', 'image'),
    'gif': ('image', 'image'),
    'webp': ('image', 'image'),
    'mp4': ('video', 'video'),
    'mov': ('video', 'video'),
    'avi': ('video', 'video'),
    'mkv': ('video', 'video'),
}

MAX_FILE_SIZE = 100 * 1024 * 1024  # 100MB

initialize_cloudinary()

def sanitize_binder_path(name: str) -> str:
    """Allow only alphanumerics, hyphens, and underscores."""
    return re.sub(r'[^a-zA-Z0-9_-]', '', name)

@upload_bp.route('/upload/<binder_path>/<uploader>', methods=['POST'])
def upload_media(binder_path, uploader):
    binder_path = sanitize_binder_path(binder_path)
    if not binder_path:
        return jsonify({'error': 'Invalid binder name'}), 400

    file = request.files.get('file') or request.files.get('image')
    if not file or file.filename == '':
        return jsonify({'error': 'No file provided'}), 400

    # Guard against missing extension
    parts = file.filename.rsplit('.', 1)
    if len(parts) != 2:
        return jsonify({'error': 'Filename must have an extension'}), 400

    file_ext = parts[1].lower()
    if file_ext not in MEDIA_TYPE_MAP:
        return jsonify({'error': 'Unsupported file type'}), 400

    # Enforce file size limit
    file.seek(0, os.SEEK_END)
    file_size = file.tell()
    file.seek(0)
    if file_size > MAX_FILE_SIZE:
        return jsonify({'error': 'File exceeds 100MB limit'}), 413

    media_type, resource_type = MEDIA_TYPE_MAP[file_ext]

    try:
        upload_fn = cloudinary.uploader.upload_large if media_type == 'video' else cloudinary.uploader.upload
        upload_kwargs = dict(
            folder=f'base/{binder_path}',
            resource_type=resource_type,
            **({"chunk_size": 6_000_000} if media_type == 'video' else {})
        )
        result = upload_fn(file, **upload_kwargs)

        media_doc = {
            'uploader': uploader,
            'url': result['secure_url'],
            'type': media_type,
            'binder': binder_path,
            'public_id': result['public_id'],
        }
        DatabaseFunctions.add_media(media_doc)
        binders_collection.update_one(
            {'path': binder_path},
            {"$set": {"thumbnail": result['secure_url']}}
        )
        
        if '_id' in media_doc:
            media_doc['_id'] = str(media_doc['_id'])

        return jsonify(media_doc), 201

    except Exception as e:
        return jsonify({'error': str(e)}), 500