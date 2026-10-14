# 🚀 AgriIntel — Complete Production Deployment Guide

This document provides definitive, end-to-end instructions for deploying both the **FastAPI Backend (AI & Decision Intelligence Engine)** and the **Flutter Client (Web, Android APK, and Windows Desktop)** across modern hosting platforms.

---

## 📑 Table of Contents

1. [Architectural Overview & Deployment Topologies](#1-architectural-overview--deployment-topologies)
2. [Pre-Deployment Readiness Checklist](#2-pre-deployment-readiness-checklist)
3. [Environment Configuration & Variables](#3-environment-configuration--variables)
4. [Deployment Method A: Docker & Docker Compose (Recommended)](#4-deployment-method-a-docker--docker-compose-recommended)
5. [Deployment Method B: Cloud PaaS (Render / Railway / Koyeb)](#5-deployment-method-b-cloud-paas-render--railway--koyeb)
6. [Deployment Method C: Linux Cloud VPS (AWS EC2 / DigitalOcean / Ubuntu)](#6-deployment-method-c-linux-cloud-vps-aws-ec2--digitalocean--ubuntu)
7. [Deployment Method D: Flutter Web Frontend (Vercel / Firebase / Netlify)](#7-deployment-method-d-flutter-web-frontend-vercel--firebase--netlify)
8. [Deployment Method E: Android Mobile App Release (Signed APK & AAB)](#8-deployment-method-e-android-mobile-app-release-signed-apk--aab)
9. [Deployment Method F: Windows Desktop Executable](#9-deployment-method-f-windows-desktop-executable)
10. [Database Management & Migration (SQLite to PostgreSQL)](#10-database-management--migration-sqlite-to-postgresql)
11. [CI/CD Automation with GitHub Actions](#11-cicd-automation-with-github-actions)
12. [Monitoring, Health Checks & Operational Troubleshooting](#12-monitoring-health-checks--operational-troubleshooting)

---

## 1. Architectural Overview & Deployment Topologies

AgriIntel operates on a decoupled client-server architecture:

```
[Flutter Mobile (Android) / Flutter Web / Desktop]
                     │
              HTTPS (TLS 1.3)
                     │
         [Cloudflare / Nginx Proxy]
                     │
         [FastAPI Backend Engine :8000]
         ├── ML Vision (MobileNet/ResNet Calibrated)
         ├── Agromet Weather & Spray Gatekeeper
         ├── AHP Matrix Solver (CR < 0.10)
         ├── OCR Formulation Extractor
         └── Cryptographic SHA-256 Ledger
                     │
     ┌───────────────┴───────────────┐
[Local Data / SQLite]    [Uploads Storage]
(agriintel.db / CSVs)   (/backend/uploads)
```

---

## 2. Pre-Deployment Readiness Checklist

Before initiating any deployment, ensure the following steps are validated:

- [x] **Backend Integration Tests**: Run `python backend/test_api_endpoints.py` (Must yield 100% pass across all 21 test scenarios).
- [x] **ETL Pipeline**: Ensure `data/master_dataset.csv` and `data/crops.csv` are present and populated.
- [x] **Flutter Diagnostics**: Run `cd frontend && flutter analyze` to verify zero static analysis errors.
- [x] **Static Asset Directory**: Verify `/backend/uploads/pesticides` write permissions exist.
- [x] **API Base URL Configuration**: Ensure `frontend/lib/services/api_service.dart` points to your public production domain rather than `localhost` or local LAN IP.

---

## 3. Environment Configuration & Variables

Create a production `.env` file in the project root:

```ini
# Environment Mode
ENVIRONMENT=production
DEMO_MODE=true

# Meteorological Service API Key (Optional: fallbacks to Open-Meteo free agromet proxy)
OPENWEATHER_API_KEY=your_openweather_api_key_here

# Database Configuration
DATABASE_URL=sqlite:///data/agriintel.db
# Or PostgreSQL for distributed production:
# DATABASE_URL=postgresql+psycopg2://user:password@db.provider.com:5432/agriintel

# OCR & Hardware Configuration
OCR_PROVIDER=tesseract
MAX_PESTICIDE_IMAGE_SIZE_MB=10

# Security & Ledger
ENABLE_INVENTORY_BLOCKCHAIN=true
COMPARISON_SCORE_THRESHOLD=5.0
```

---

## 4. Deployment Method A: Docker & Docker Compose (Recommended)

Containerized deployment is the fastest, most reliable method for servers with Docker installed.

### Step 1: Clone Repository & Setup Environment
```bash
git clone https://github.com/TejasGhule77/capstone.git
cd capstone/AgriIntel
cp .env.example .env
```

### Step 2: Build & Start Services
```bash
docker compose up -d --build
```

### Step 3: Verify Container Health
```bash
docker compose ps
docker logs agriintel_backend -f
```
Test health check via curl:
```bash
curl http://localhost:8000/health
```

### Step 4: Graceful Shutdown & Updates
```bash
# Stop containers
docker compose down

# Update and restart with fresh build
git pull
docker compose up -d --build
```

---

## 5. Deployment Method B: Cloud PaaS (Render / Railway / Koyeb)

Ideal for quick, zero-infrastructure cloud deployment.

### Option 1: Render (Web Service)

1. **Sign Up**: Go to [Render.com](https://render.com) and link your GitHub repository.
2. **Create New Web Service**:
   - **Name**: `agriintel-api`
   - **Environment**: `Python 3`
   - **Region**: Singapore or Frankfurt (closest to target users)
   - **Branch**: `main`
   - **Root Directory**: `.` (leave blank or project root)
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `uvicorn backend.app.main:app --host 0.0.0.0 --port $PORT --workers 2`
3. **Add Environment Variables**:
   - `PYTHON_VERSION`: `3.11.9`
   - `DEMO_MODE`: `true`
   - `ENVIRONMENT`: `production`
   - `OPENWEATHER_API_KEY`: *(optional)*
4. **Persistent Disk (Important for SQLite & Uploads)**:
   - Add a Persistent Disk mounted at `/app/data` with size `1 GB`.
5. **Click "Deploy Web Service"**.
   - Your API will be live at `https://agriintel-api.onrender.com`.

---

### Option 2: Railway.app

1. Navigate to [Railway.app](https://railway.app) and create a **New Project**.
2. Select **Deploy from GitHub repo** and choose `capstone`.
3. Railway automatically detects `Dockerfile` in the root.
4. Under **Variables**, add:
   - `PORT`: `8000`
   - `ENVIRONMENT`: `production`
5. Under **Settings**, click **Generate Domain** (e.g., `agriintel.up.railway.app`).

---

## 6. Deployment Method C: Linux Cloud VPS (AWS EC2 / DigitalOcean / Ubuntu)

For maximum performance, complete control, and lowest latency.

### Step 1: Provision Server & Install Prerequisites
Launch an Ubuntu 22.04 LTS instance (2 vCPU, 4GB RAM recommended) and SSH into it:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3-pip python3-venv git nginx certbot python3-certbot-nginx tesseract-ocr
```

### Step 2: Clone Code & Configure Python Virtual Environment
```bash
cd /var/www
sudo git clone https://github.com/TejasGhule77/capstone.git agriintel
sudo chown -R $USER:$USER /var/www/agriintel
cd /var/www/agriintel/AgriIntel

# Create and activate virtualenv
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt
```

### Step 3: Configure Systemd Daemon Service
Create `/etc/systemd/system/agriintel.service`:

```ini
[Unit]
Description=AgriIntel FastAPI Precision Decision Engine
After=network.target

[Service]
User=ubuntu
Group=ubuntu
WorkingDirectory=/var/www/agriintel/AgriIntel
Environment="PATH=/var/www/agriintel/AgriIntel/venv/bin"
EnvironmentFile=/var/www/agriintel/AgriIntel/.env
ExecStart=/var/www/agriintel/AgriIntel/venv/bin/gunicorn backend.app.main:app -w 4 -k uvicorn.workers.UvicornWorker -b 127.0.0.1:8000 --access-logfile /var/log/agriintel.access.log --error-logfile /var/log/agriintel.error.log
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Enable and start the service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable agriintel
sudo systemctl start agriintel
sudo systemctl status agriintel
```

### Step 4: Configure Nginx as Reverse Proxy
Create `/etc/nginx/sites-available/agriintel`:

```nginx
server {
    server_name api.yourdomain.com;

    client_max_body_size 25M;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable site and acquire Free SSL via Let's Encrypt:
```bash
sudo ln -s /etc/nginx/sites-available/agriintel /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Obtain SSL Certificate
sudo certbot --nginx -d api.yourdomain.com
```

---

## 7. Deployment Method D: Flutter Web Frontend (Vercel / Firebase / Netlify)

### Step 1: Update API Endpoint in Flutter
In [frontend/lib/services/api_service.dart](file:///c:/Users/Tejas/Desktop/capstone/Agriintel/frontend/lib/services/api_service.dart), configure your production backend URL:

```dart
// For Production Deployment:
static const String host = "api.yourdomain.com"; // or "agriintel-api.onrender.com"
static const String baseUrl = "https://$host/api";
```

### Step 2: Compile Production Web Build
```bash
cd frontend
flutter clean
flutter pub get
flutter build web --release --web-renderer canvaskit --pwa-strategy offline-first
```
The output files will be generated in `frontend/build/web`.

### Step 3: Deploy to Vercel (CLI)
```bash
npm i -g vercel
cd frontend/build/web
vercel --prod
```

### Step 4: Deploy to Firebase Hosting
```bash
npm i -g firebase-tools
firebase login
firebase init hosting # Set public directory to frontend/build/web
firebase deploy --only hosting
```

---

## 8. Deployment Method E: Android Mobile App Release (Signed APK & AAB)

### Step 1: Generate Release Keystore
Run in terminal:
```bash
keytool -genkey -v -keystore agriintel-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias agriintel
```

### Step 2: Configure Android Keystore Properties
Create `frontend/android/key.properties`:
```ini
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=agriintel
storeFile=../../agriintel-release-key.jks
```

### Step 3: Build Standalone Production APK
```bash
cd frontend
flutter build apk --release --split-per-abi
```
Outputs:
- `frontend/build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk`
- `frontend/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` *(recommended for modern Android phones)*

### Step 4: Build Google Play Store App Bundle (AAB)
```bash
flutter build appbundle --release
```
Output:
- `frontend/build/app/outputs/bundle/release/app-release.aab`

---

## 9. Deployment Method F: Windows Desktop Executable

To generate a standalone Windows desktop executable:

```powershell
cd frontend
flutter build windows --release
```

Output directory:
`frontend/build/windows/x64/runner/Release/`
Distribute the contents of this folder or package with Inno Setup to create a one-click `.exe` installer.

---

## 10. Database Management & Migration (SQLite to PostgreSQL)

When scaling to thousands of concurrent farmers:

1. Create a managed PostgreSQL database (e.g., Supabase, Neon, AWS RDS).
2. Set `.env`:
   ```ini
   DATABASE_URL=postgresql+psycopg2://postgres:YOUR_PASSWORD@db.region.supabase.co:5432/postgres
   ```
3. Install PostgreSQL driver:
   ```bash
   pip install psycopg2-binary
   ```
4. Restart the backend service. SQLAlchemy automatically creates all inventory and comparison tables on startup.

---

## 11. CI/CD Automation with GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: AgriIntel CI/CD Pipeline

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test-backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
      - name: Run Test Suite (21 Tests)
        run: |
          python backend/test_api_endpoints.py

  test-frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.29.0'
      - run: cd frontend && flutter pub get
      - run: cd frontend && flutter analyze
      - run: cd frontend && flutter build web --release
```

---

## 12. Monitoring, Health Checks & Operational Troubleshooting

### 1. Endpoint Health Monitoring
Set up an uptime monitor (e.g., [UptimeRobot](https://uptimerobot.com) or [Better Stack](https://betterstack.com)) pointing to:
`GET https://api.yourdomain.com/health`

Expected response `200 OK`:
```json
{
  "status": "healthy",
  "service": "AgriIntel Precision Agro-Intelligence Engine",
  "version": "2.0.0",
  "demo_mode": true,
  "supported_crops": ["Onion", "Grapes", "Sugarcane", "Wheat"],
  "verification_status": "DEMO"
}
```

### 2. Common Operational Issues & Fixes

| Issue | Root Cause | Solution |
| :--- | :--- | :--- |
| **CORS Policy Error** | Frontend domain not whitelisted | Ensure `CORS_ORIGINS` in `config.py` includes your frontend domain or is set to `["*"]`. |
| **413 Request Entity Too Large** | Nginx or FastAPI blocking large leaf photos | Add `client_max_body_size 25M;` in Nginx configuration. |
| **Android Cleartext HTTP Block** | Android 9+ blocks insecure `http://` calls | Use `https://` with a valid SSL certificate for your production API. |
| **SQLite Locked Error** | High concurrency file write contention | Switch `DATABASE_URL` to PostgreSQL. |
| **RapidOCR/Tesseract Missing** | System lacks OCR binaries | The engine automatically falls back to Heuristic OCR extraction; install `tesseract-ocr` via `apt install` for full computer vision OCR. |

---

*For further operational assistance or bug reports, submit an issue to the project repository.*
