# AI Resume Analyzer & ATS Optimizer 🚀

An end-to-end, full-stack AI-powered Resume Analyzer and Applicant Tracking System (ATS) Optimizer. This application enables candidates to upload resumes (PDF/DOCX), compare them against job descriptions, evaluate ATS compatibility scores, identify missing high-priority keywords, and dynamically optimize weak bullet points using an interactive AI "Fix-It" Studio.

---

## 🛠️ Project Architecture & Tech Stack

- **Frontend:** Flutter Web / Mobile / Desktop (Dart)
- **Backend:** FastAPI (Python 3.13)
- **Document Parsing:** `pypdf`, `python-docx`
- **Deployment:** Render (FastAPI Backend) & Vercel / Netlify / Chrome Web (Flutter Frontend)

---

## 📂 Repository & Directory Structure

```text
AI_Resume-Analyzer/
├── backend/
│   ├── main.py              # FastAPI application & endpoint definitions
│   └── requirements.txt     # Python backend dependencies
└── frontend/
    ├── lib/
    │   └── main.dart        # Main Flutter application logic & UI code
    └── pubspec.yaml         # Flutter dependencies & metadata configuration
```

---

## 🚀 Quick Start & Local Development Setup

### 1. Prerequisites
- **Python 3.9+** (Python 3.13 supported)
- **Flutter SDK 3.x+**
- **VS Code** (with Dart & Flutter extensions)

---

### 2. Backend Setup (FastAPI)

1. Open terminal and navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Create and activate a Python virtual environment:
   - **Windows (PowerShell):**
     ```powershell
     python -m venv venv
     .\venv\Scripts\Activate.ps1
     ```
   - **Windows (Command Prompt):**
     ```cmd
     python -m venv venv
     venv\Scripts\activate.bat
     ```
   - **macOS / Linux:**
     ```bash
     python3 -m venv venv
     source venv/bin/activate
     ```
3. Install required packages:
   ```bash
   pip install -r requirements.txt
   ```
4. Start the FastAPI Uvicorn development server:
   ```bash
   uvicorn main:app --reload --port 8000
   ```
   *The backend will be live at `http://127.0.0.1:8000` with interactive API docs available at `http://127.0.0.1:8000/docs`.*

---

### 3. Frontend Setup (Flutter)

1. Open a new terminal tab and navigate to the frontend directory:
   ```bash
   cd frontend
   ```
2. Fetch required dependencies:
   ```bash
   flutter pub get
   ```
3. Run the web client in Google Chrome:
   ```bash
   flutter run -d chrome
   ```

---

## 🔬 Lab Experiments & Outputs Log (CS506PC: UI Design - Flutter)

Below are the key practical implementations and verified experimental outputs corresponding to the **UI DESIGN - FLUTTER** lab syllabus.

---

### Experiment 1: Dart SDK & Language Basics
- **Objective:** Install Flutter and Dart SDK; execute fundamental Dart scripts.
- **Implementation:** Set up SDK paths (`C:\src\flutter\bin`) and initialized Flutter project configurations (`pubspec.yaml`).
- **Output:** Verified Flutter installation using CLI diagnostics:
  ```text
  [✓] Flutter (Channel stable, 3.22.x, on Microsoft Windows)
  [✓] Windows Version (Installed version of Windows is 10 or higher)
  [✓] Chrome - develop for the web
  [✓] VS Code (version 1.90.0)
  [✓] Connected device (2 available)
  ```

---

### Experiment 2: Widgets & Layout Structures
- **Objective:** Explore core widgets (`Text`, `Container`, `Card`, `Icon`) and layouts (`Row`, `Column`, `Stack`).
- **Implementation:** Structured the home page with `Column` views containing ATS Score cards, using `Stack` overlays to build the circular progress indicators and `Row` layouts for keyword tag displays.
- **Output:**
  ```text
  Rendered Layout Hierarchy:
  └── SingleChildScrollView
      └── Column
          ├── Card (Job Description Input)
          ├── Card (Resume Upload Picker)
          ├── Card (Score Banner using Stack + CircularProgressIndicator)
          └── Card (Interactive AI Fix-It List)
  ```

---

### Experiment 3: Responsive UI Design
- **Objective:** Design responsive UI using breakpoints and fluid layouts.
- **Implementation:** Utilized flexible text wrapping (`Wrap` widget) for keyword chips and auto-resizing containers to adapt cleanly to desktop monitors, tablets, and mobile displays.
- **Output:** Keyword chips automatically wrap onto subsequent lines dynamically based on browser viewport size without pixel overflow warnings.

---

### Experiment 4: Navigation & Named Routes
- **Objective:** Configure navigation and screen routing using `Navigator`.
- **Implementation:** Integrated application routing and snackbar notifications to guide user transitions between file submission states and diagnostic analytical views.
- **Output:** Dynamic navigation feedback toasts displayed upon file upload, processing, and fix application steps.

---

### Experiment 5: Stateful vs. Stateless Widgets & State Management
- **Objective:** Implement application state updates using `StatefulWidget` and `setState`.
- **Implementation:** Maintained asynchronous states (`_isAnalyzing`, `_hasResults`, `_pickedFile`, `_atsScore`) inside `_AnalyzerHomeScreenState` to trigger real-time UI rebuilds upon HTTP payload arrival.
- **Output:**
  ```text
  State Transition Trace:
  [Idle] -> User submits JD & PDF -> [setState: _isAnalyzing = true]
         -> HTTP POST Streamed    -> [setState: _hasResults = true, _isAnalyzing = false]
         -> UI Rebuilt with Score Dashboard
  ```

---

### Experiment 6: Custom Widgets & Styling
- **Objective:** Create styled UI elements using custom themes and borders.
- **Implementation:** Designed styled input boxes, custom elevated primary buttons (`Color(0xFF6366F1)`), and rounded container panels for "Original vs AI Optimized" bullet point comparisons.
- **Output:** Uniform Indigo design theme with dark slate contrast cards (`Color(0xFF1E293B)`) for key metrics presentation.

---

### Experiment 7: Forms, Inputs & Error Handling
- **Objective:** Design input forms with validation and detailed exception handling.
- **Implementation:** Added validation logic on the Job Description text field and file selection picker, displaying warning snackbars if inputs are missing prior to backend request submission.
- **Output:** Catch blocks gracefully intercept lost server connections and render human-readable alert bars to the user.

---

### Experiment 8: Animations in Flutter
- **Objective:** Implement UI animations using standard animation frameworks.
- **Implementation:** Utilized smooth progress ring animations (`CircularProgressIndicator`) and loading state indicators during processing stages.
- **Output:** Animated circular percentage meter animating dynamically from `0%` to `78%` ATS match score.

---

### Experiment 9: REST API Integration
- **Objective:** Fetch data asynchronously from a REST API backend and display it in UI.
- **Implementation:** Executed asynchronous `http.MultipartRequest` POST queries sending file streams and textual form data to FastAPI (`/analyze`), decoding JSON payloads to render missing keyword arrays and bullet point enhancement pairs.
- **Output:**
  ```json
  // Received REST Response (HTTP 200 OK):
  {
    "ats_score": 78,
    "missing_keywords": ["Kubernetes", "CI/CD Pipelines", "GraphQL", "Docker"],
    "weak_bullets": [
      {
        "original": "Managed cloud servers and deployment processes.",
        "improved": "Architected and managed AWS cloud infrastructure using Docker, reducing deployment time by 35%."
      }
    ]
  }
  ```

---

### Experiment 10: Unit Testing & Debugging
- **Objective:** Debug application runtime bugs using Flutter developer tooling.
- **Implementation:** Diagnosed and resolved environment path lookup failures, fixed missing `pubspec.yaml` SDK constraint declarations, updated outdated package binaries for Python 3.13 compatibility, and configured FastAPI `CORSMiddleware`.
- **Output:** Application successfully built and launched on Google Chrome with zero build errors or cross-origin restrictions.

---

## ☁️ Deployment Guide

### Backend (Render.com)
1. Push repository code to GitHub.
2. Select **New Web Service** on Render.
3. Configuration settings:
   - **Root Directory:** `backend`
   - **Runtime:** `Python 3`
   - **Build Command:** `pip install -r requirements.txt`
   - **Start Command:** `uvicorn main:app --host 0.0.0.0 --port $PORT`

### Frontend (Flutter Web)
1. Update `_backendUrl` inside `lib/main.dart` with your deployed Render URL.
2. Build release web assets:
   ```bash
   flutter build web --release
   ```
3. Deploy the compiled assets located in `frontend/build/web` to Vercel, Netlify, or GitHub Pages.