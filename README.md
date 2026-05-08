# RecrutIA

Plateforme web de recrutement avec matching intelligent CV/offres basé sur BERT multilingue (`paraphrase-multilingual-MiniLM-L12-v2`) et FAISS.

## Prérequis

- Docker installé localement
- Au moins 2 Go de RAM disponibles pour le conteneur

## Lancement avec Docker

```bash
# Build de l'image (le premier build prend ~5-10 min, télécharge le modèle BERT)
docker build -t recrutia .

# Lancement du conteneur
docker run -p 5000:5000 recrutia
```

L'application est ensuite disponible sur [http://localhost:5000](http://localhost:5000).

## Lancement local sans Docker

```bash
python -m venv .venv
source .venv/bin/activate          # Linux/macOS
# .venv\Scripts\activate            # Windows

pip install torch==2.4.0+cpu --index-url https://download.pytorch.org/whl/cpu
pip install -r requirements.txt

python app.py
```

## Structure

```
.
├── app.py                  # Point d'entrée Flask, endpoints API
├── matcher.py              # Moteur de matching BERT + FAISS
├── preprocessing.py        # Pipeline NLP (nettoyage, tokenisation)
├── evaluator.py            # Benchmark BERT vs TF-IDF
├── templates/
│   └── index.html          # Page d'accueil (deux espaces)
├── data/
│   ├── cvs_tunisiens.json  # Données CV (à remplacer par vos données)
│   └── job_descriptions.csv
├── Dockerfile
├── requirements.txt
└── .dockerignore
```

## Variables d'environnement

| Variable | Défaut | Description |
|---|---|---|
| `CV_DATA_PATH` | `./data/cvs_tunisiens.json` | Chemin vers le fichier des CV |
| `JOB_DATA_PATH` | `./data/job_descriptions.csv` | Chemin vers le fichier des offres |
| `PORT` | `5000` | Port d'écoute |
| `FLASK_DEBUG` | `0` | Mode debug Flask (0/1) |

## Endpoints API

- `GET  /` — Page d'accueil
- `POST /api/candidate` — Upload d'un CV PDF, retourne les offres adaptées
- `POST /api/recruiter` — Description d'un poste (form `job_description`), retourne les CV adaptés

## Évaluation

```bash
python evaluator.py
```

Compare les performances de RecrutIA (BERT) face à une baseline TF-IDF sur 10 cas de test.
