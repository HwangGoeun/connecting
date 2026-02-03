import os
os.environ["NUMBA_DISABLE_JIT"] = "1"

from dotenv import load_dotenv
load_dotenv()

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from fastapi.responses import JSONResponse

from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
import umap
import numpy as np

app = FastAPI()

@app.get("/")
def root():
    return {"message": "Server is running!"}

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

model = SentenceTransformer("sentence-transformers/LaBSE")

class WordList(BaseModel):
    words: list[str]

@app.post("/vectorize")
def vectorize(req: WordList):
    words = req.words
    if len(words) < 2:
        return JSONResponse(content={"points": [], "connections": []})

    embeddings = model.encode(words)
    n_neighbors = min(15, len(words) - 1)
    reducer = umap.UMAP(n_components=2, n_neighbors=n_neighbors, random_state=42)
    reduced = reducer.fit_transform(embeddings)

    sim_matrix = cosine_similarity(embeddings)
    threshold = 0.7
    connections = []
    for i in range(len(words)):
        for j in range(i + 1, len(words)):
            sim = sim_matrix[i][j]
            if sim >= threshold:
                connections.append({
                    "from": words[i],
                    "to": words[j],
                    "similarity": round(float(sim), 3)
                })

    points = [
        {"word": word, "x": float(x), "y": float(y)}
        for word, (x, y) in zip(words, reduced)
    ]

    return JSONResponse(
        content={"points": points, "connections": connections},
        media_type="application/json; charset=utf-8"
    )

if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", 7860))
    uvicorn.run("app:app", host="0.0.0.0", port=port)
