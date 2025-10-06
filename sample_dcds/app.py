import os
import sqlite3
import csv
import io
from flask import Flask, jsonify, request, render_template, Response, g
from flask_cors import CORS
from dotenv import load_dotenv
from huggingface_hub import InferenceClient
from uuid import uuid4

# --- Configuration ---
load_dotenv()
app = Flask(__name__, static_folder='.', static_url_path='', template_folder='.')
CORS(app)
DATABASE = 'database.db'

# --- Hugging Face Inference Client Setup ---
HF_TOKEN = os.getenv("HF_TOKEN") or os.getenv("HF_API_TOKEN")
if not HF_TOKEN:
    print("Warning: HF_TOKEN environment variable not set. Chatbot functionality will be disabled.")
    HF_CLIENT_LOADED = False
else:
    try:
        MODEL = "HuggingFaceH4/zephyr-7b-beta"
        client = InferenceClient(model=MODEL, token=HF_TOKEN)
        print(f"Hugging Face client loaded successfully for model: {MODEL}")
        HF_CLIENT_LOADED = True
    except Exception as e:
        print(f"Error initializing Hugging Face client: {e}")
        HF_CLIENT_LOADED = False

conversation_history = {}

# --- Database Setup ---
def get_db():
    if 'db' not in g:
        g.db = sqlite3.connect(DATABASE, detect_types=sqlite3.PARSE_DECLTYPES)
        g.db.row_factory = sqlite3.Row
    return g.db

@app.teardown_appcontext
def close_db(e=None):
    db = g.pop('db', None)
    if db is not None:
        db.close()

def init_db():
    if os.path.exists(DATABASE):
        print("Database already exists. Skipping initialization.")
        return
    with app.app_context():
        db = get_db()
        with app.open_resource('gen.sql', mode='r') as f:
            db.cursor().executescript(f.read())
        db.commit()
    print("Database initialized successfully from gen.sql.")


# --- HTML Serving Routes ---
@app.route('/')
def index():
    return render_template('index.html')

@app.route('/genes')
def genes_page():
    return render_template('genes.html')

@app.route('/traits')
def traits_page():
    return render_template('traits.html')

@app.route('/analytics')
def analytics_page():
    return render_template('analytics.html')

@app.route('/chatbot')
def chatbot_page():
    return render_template('chatbot.html')


# --- API Endpoints (THIS IS THE FIX) ---
@app.route('/api/genes')
def get_genes():
    db = get_db()
    cursor = db.cursor()
    cursor.execute("""
        SELECT g.gene_id, g.gene_symbol, g.gene_name, g.description, COUNT(gta.association_id) AS association_count
        FROM Genes g LEFT JOIN Gene_Trait_Associations gta ON g.gene_id = gta.gene_id
        GROUP BY g.gene_id, g.gene_symbol, g.gene_name, g.description
        ORDER BY g.gene_symbol;
    """)
    genes = [dict(row) for row in cursor.fetchall()]
    return jsonify(genes)

@app.route('/api/traits')
def get_traits():
    db = get_db()
    cursor = db.cursor()
    cursor.execute("""
        SELECT t.trait_id, t.trait_name, t.category, t.inheritance_pattern, COUNT(gta.association_id) AS gene_count
        FROM Traits t LEFT JOIN Gene_Trait_Associations gta ON t.trait_id = gta.trait_id
        GROUP BY t.trait_id, t.trait_name, t.category, t.inheritance_pattern
        ORDER BY t.trait_name;
    """)
    traits = [dict(row) for row in cursor.fetchall()]
    return jsonify(traits)

@app.route('/api/charts/inheritance-patterns')
def get_inheritance_patterns():
    db = get_db()
    cursor = db.cursor()
    cursor.execute("SELECT inheritance_pattern as pattern, COUNT(*) as count FROM Traits GROUP BY inheritance_pattern;")
    data = [dict(row) for row in cursor.fetchall()]
    return jsonify(data)

@app.route('/api/charts/most-studied')
def get_most_studied():
    db = get_db()
    cursor = db.cursor()
    cursor.execute("""
        SELECT g.gene_symbol as gene, COUNT(DISTINCT gta.study_id) as studies
        FROM Gene_Trait_Associations gta JOIN Genes g ON g.gene_id = gta.gene_id
        GROUP BY g.gene_symbol ORDER BY studies DESC LIMIT 10;
    """)
    data = [dict(row) for row in cursor.fetchall()]
    return jsonify(data)

@app.route('/api/chatbot', methods=['POST'])
def chatbot():
    if not HF_CLIENT_LOADED:
        return jsonify({"response": "Sorry, the chatbot model is not available."}), 500

    data = request.json
    user_message = data.get('message')
    session_id = data.get('session_id') or str(uuid4())

    if not user_message:
        return jsonify({"error": "No message provided"}), 400

    if session_id not in conversation_history:
        conversation_history[session_id] = []

    history = conversation_history[session_id]
    history.append({"role": "user", "content": user_message})
    
    if len(history) > 10:
        history = history[-10:]

    try:
        response = client.chat_completion(messages=history, max_tokens=500, stream=False)
        assistant_reply = response.choices[0].message.content
        history.append({"role": "assistant", "content": assistant_reply})
        conversation_history[session_id] = history
        return jsonify({"response": assistant_reply, "session_id": session_id})
    except Exception as e:
        print(f"Error with Hugging Face client: {e}")
        return jsonify({"response": "I'm having trouble processing your request."}), 500

if __name__ == '__main__':
    if not os.path.exists(DATABASE):
        init_db()
    app.run(debug=True, port=5000)