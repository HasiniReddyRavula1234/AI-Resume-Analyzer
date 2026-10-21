from fastapi import FastAPI, File, Form, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import io
from pypdf import PdfReader
from docx import Document

from fastapi.middleware.cors import CORISTMiddleware # (or CORSMiddleware)


app = FastAPI(title="AI Resume Analyzer API", version="1.0")

# Enable CORS so your Flutter frontend can communicate with this backend locally
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Or specify your frontend URL for better security
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def extract_text_from_file(file_content: bytes, filename: str) -> str:
    text = ""
    try:
        if filename.endswith(".pdf"):
            reader = PdfReader(io.BytesIO(file_content))
            for page in reader.pages:
                extracted = page.extract_text()
                if extracted:
                    text += extracted + "\n"
        elif filename.endswith(".docx"):
            doc = Document(io.BytesIO(file_content))
            for para in doc.paragraphs:
                text += para.text + "\n"
        else:
            raise HTTPException(status_code=400, detail="Unsupported file format. Please upload PDF or DOCX.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error reading file: {str(e)}")
    return text

@app.get("/")
def read_root():
    return {"message": "AI Resume Analyzer Backend is running successfully!"}

@app.post("/analyze")
async def analyze_resume(
    job_description: str = Form(...),
    file: UploadFile = File(...)
):
    # Read uploaded file bytes
    file_bytes = await file.read()
    resume_text = extract_text_from_file(file_bytes, file.filename)

    # In a production app, you would pass job_description and resume_text to an LLM (like OpenAI/Claude).
    # For this robust backend foundation, we simulate the intelligent analysis results:
    
    ats_score = 78
    missing_keywords = ["Kubernetes", "CI/CD Pipelines", "GraphQL", "Docker", "Unit Testing"]
    weak_bullets = [
        {
            "original": "Managed cloud servers and deployment processes.",
            "improved": "Architected and managed AWS cloud infrastructure using Docker, reducing deployment time by 35%."
        },
        {
            "original": "Wrote code for front-end web applications.",
            "improved": "Developed responsive UI components in Flutter and React, serving over 15,000 active daily users."
        }
    ]

    return {
        "filename": file.filename,
        "ats_score": ats_score,
        "missing_keywords": missing_keywords,
        "weak_bullets": weak_bullets,
        "extracted_resume_snippet": resume_text[:300] + "..." if len(resume_text) > 300 else resume_text
    }