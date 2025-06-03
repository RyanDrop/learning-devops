from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI, HTTPException
import os

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
async def root():
    return {"message": "Container do back-end em Python!!! 🎉"}



