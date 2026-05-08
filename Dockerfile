FROM python:3.11-slim

# Bibliothèque runtime requise par faiss (OpenMP)
RUN apt-get update && apt-get install -y --no-install-recommends \
        libgomp1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Étape 1 : installation de PyTorch en version CPU-only depuis le miroir officiel.
# Cela évite les ~2.5 Go de bibliothèques NVIDIA CUDA (cublas, cudnn, etc.)
# qui seraient autrement tirées par le wheel par défaut.
RUN pip install --no-cache-dir \
        torch==2.4.0+cpu \
        --index-url https://download.pytorch.org/whl/cpu

# Étape 2 : installation des autres dépendances Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Étape 3 : pré-téléchargement du modèle BERT pour qu'il soit présent
# dans l'image (sinon il serait téléchargé au premier démarrage).
RUN python -c "from sentence_transformers import SentenceTransformer; \
SentenceTransformer('paraphrase-multilingual-MiniLM-L12-v2')"

# Étape 4 : copie du code applicatif
COPY . .

# Création du dossier d'uploads (au cas où il ne soit pas dans le contexte)
RUN mkdir -p uploads

# Port 8080 : convention utilisée par Hostinger Docker Manager
EXPOSE 8080

# Gunicorn écoute sur 8080 pour matcher le mapping de Hostinger.
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "1", "--timeout", "120", "app:app"]
