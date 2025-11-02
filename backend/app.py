from flask import Flask, request, jsonify, redirect, url_for
from flask_cors import CORS
import json, os, logging

app = Flask(__name__)
CORS(app)  # Allow frontend to connect during development

logging.basicConfig(level=logging.INFO)

DATA_PATH = os.path.join(os.path.dirname(__file__), "data", "brands.json")

def load_data():
    try:
        with open(DATA_PATH, "r", encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        app.logger.error(f"Data file not found: {DATA_PATH}")
        return {}
    except json.JSONDecodeError:
        app.logger.error("Invalid JSON in data file")
        return {}

@app.route("/api/brands", methods=["GET"])
def get_brands():
    data = load_data()
    return jsonify(list(data.keys()))

@app.route("/api/appliances", methods=["GET"])
def get_appliances():
    brand = request.args.get("brand")
    if not brand:
        return jsonify({"error": "Missing 'brand' query parameter"}), 400
    data = load_data()
    if brand not in data:
        return jsonify({"error": "Brand not found"}), 404
    return jsonify(list(data[brand].keys()))

@app.route("/api/issues", methods=["GET"])
def get_issues():
    brand = request.args.get("brand")
    appliance = request.args.get("appliance")
    if not brand or not appliance:
        return jsonify({"error": "Missing 'brand' or 'appliance' query parameter"}), 400
    data = load_data()
    try:
        return jsonify(list(data[brand][appliance]["common_issues"].keys()))
    except KeyError:
        return jsonify({"error": "Not found"}), 404

@app.route("/api/solution", methods=["POST"])
def get_solution():
    data = load_data()
    body = request.get_json(silent=True)
    if not body:
        return jsonify({"error": "Invalid or missing JSON body"}), 400

    brand = body.get("brand")
    appliance = body.get("appliance")
    issue = body.get("issue")

    if not brand or not appliance or not issue:
        return jsonify({"error": "Missing 'brand', 'appliance', or 'issue' in body"}), 400

    try:
        solution = data[brand][appliance]["common_issues"][issue]
        brand_page = data[brand][appliance]["brand_page"]
        return jsonify({"solution": solution, "brand_page": brand_page})
    except KeyError:
        return jsonify({"error": "Data not found"}), 404

@app.route("/")
def index():
    # simple redirect to the brands endpoint or return a short JSON message
    return redirect(url_for("get_brands"))

if __name__ == "__main__":
    app.run(port=5000, debug=True)
