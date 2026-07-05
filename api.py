from flask import Flask, request, jsonify
from pymongo import MongoClient, ReturnDocument
from bson import ObjectId
from bson.errors import InvalidId
import os

app = Flask(__name__)

MONGO_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017/")
DB_NAME = os.getenv("DB_NAME", "article_db")

client = MongoClient(MONGO_URI)
db = client[DB_NAME]
articles_collection = db["articles"]


def serialize_article(article):
    return {
        "id": str(article["_id"]),
        "title": article.get("title"),
        "content": article.get("content"),
        "author": article.get("author", "Unknown")
    }


def parse_object_id(article_id):
    try:
        return ObjectId(article_id)
    except InvalidId:
        return None


@app.get("/")
def home():
    return jsonify({
        "message": "Articles API is running",
        "endpoints": [
            "POST /articles",
            "GET /articles",
            "GET /articles/<id>",
            "PUT /articles/<id>",
            "DELETE /articles/<id>"
        ]
    }), 200


@app.get("/health")
def health():
    return jsonify({"status": "ok"}), 200


@app.get("/ready")
def ready():
    try:
        client.admin.command("ping")
        return jsonify({"status": "ready"}), 200
    except Exception:
        return jsonify({"status": "not ready"}), 503


@app.post("/articles")
def create_article():
    data = request.get_json()

    if not data:
        return jsonify({"error": "Request body is required"}), 400

    title = data.get("title")
    content = data.get("content")
    author = data.get("author", "Unknown")

    if not title or not content:
        return jsonify({"error": "title and content are required"}), 400

    article = {
        "title": title,
        "content": content,
        "author": author
    }

    result = articles_collection.insert_one(article)
    article["_id"] = result.inserted_id

    return jsonify(serialize_article(article)), 201


@app.get("/articles")
def list_articles():
    articles = articles_collection.find()
    return jsonify([serialize_article(article) for article in articles]), 200


@app.get("/articles/<article_id>")
def get_article(article_id):
    object_id = parse_object_id(article_id)

    if object_id is None:
        return jsonify({"error": "Invalid article id"}), 400

    article = articles_collection.find_one({"_id": object_id})

    if article is None:
        return jsonify({"error": "Article not found"}), 404

    return jsonify(serialize_article(article)), 200


@app.put("/articles/<article_id>")
def update_article(article_id):
    object_id = parse_object_id(article_id)

    if object_id is None:
        return jsonify({"error": "Invalid article id"}), 400

    data = request.get_json()

    if not data:
        return jsonify({"error": "Request body is required"}), 400

    title = data.get("title")
    content = data.get("content")
    author = data.get("author", "Unknown")

    if not title or not content:
        return jsonify({"error": "title and content are required"}), 400

    updated_article = articles_collection.find_one_and_update(
        {"_id": object_id},
        {
            "$set": {
                "title": title,
                "content": content,
                "author": author
            }
        },
        return_document=ReturnDocument.AFTER
    )

    if updated_article is None:
        return jsonify({"error": "Article not found"}), 404

    return jsonify(serialize_article(updated_article)), 200


@app.delete("/articles/<article_id>")
def delete_article(article_id):
    object_id = parse_object_id(article_id)

    if object_id is None:
        return jsonify({"error": "Invalid article id"}), 400

    result = articles_collection.delete_one({"_id": object_id})

    if result.deleted_count == 0:
        return jsonify({"error": "Article not found"}), 404

    return jsonify({"message": "Article deleted successfully"}), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)