# Campus Club Management Portal — Deployment Guide

This repository supports flexible deployment options depending on your architectural target:
1. **Instant Static Cloud Deployment (Frontend Portal)**: Vercel, Netlify, or GitHub Pages.
2. **Containerized Production (Django + MySQL)**: Docker Compose, AWS EC2, or DigitalOcean.
3. **PaaS Cloud (Django)**: Render or Railway.
4. **AWS Serverless Stack**: AWS SAM (API Gateway, Lambda, DynamoDB, Cognito, and S3).

---

## ⚡ Quick Deployment via Helper Script

On Windows PowerShell:
```powershell
.\deploy.ps1
```
Follow the interactive prompt to deploy to Vercel, Netlify, Docker, AWS SAM, or S3.

---

## Option 1: Instant Frontend Deployment (Vercel / Netlify / GitHub Pages)

The client portal (`index.html`, `dashboard.html`, `css/`, `js/`) functions out-of-the-box with built-in client-side simulation and role management.

### A. Vercel (Fastest)
1. Install or run Vercel CLI:
   ```bash
   npx vercel --prod
   ```
2. Accept the default project settings.
3. Your portal will be immediately live with HTTPS (e.g., `https://campus-club-portal.vercel.app`).
4. Configuration is pre-wired in [`vercel.json`](file:///c:/Users/nikil/OneDrive/campus%20club%20management%20portal/vercel.json).

### B. Netlify
1. Run Netlify deploy:
   ```bash
   npx netlify-cli deploy --prod --dir=.
   ```
2. Configuration is pre-wired in [`netlify.toml`](file:///c:/Users/nikil/OneDrive/campus%20club%20management%20portal/netlify.toml).

### C. GitHub Pages
1. Push your repository to GitHub.
2. Go to **Settings** > **Pages**.
3. Under **Branch**, select `main` / `root` and click **Save**.

---

## Option 2: Docker & Docker Compose (Django + MySQL)

For running a containerized production environment anywhere:

1. Ensure Docker Desktop is running.
2. Run from the project root:
   ```bash
   docker compose up --build -d
   ```
3. The stack will automatically:
   - Launch MySQL 8.0 on port `3306` with persistent volume storage.
   - Run database migrations (`python manage.py migrate`).
   - Collect static files (`python manage.py collectstatic`).
   - Start the production Gunicorn server on `http://localhost:8000`.
4. Access the portal at [http://localhost:8000](http://localhost:8000).

---

## Option 3: Render (PaaS for Django + SQLite or Postgres)

1. Push this repository to GitHub/GitLab.
2. Log into [Render.com](https://render.com).
3. Click **New +** > **Blueprint**.
4. Select your repository. Render will automatically detect [`render.yaml`](file:///c:/Users/nikil/OneDrive/campus%20club%20management%20portal/render.yaml) and configure:
   - Root Directory: `django_app`
   - Build Command: `pip install -r requirements.txt && python manage.py collectstatic --noinput && python manage.py migrate --noinput && python manage.py seed_portal`
   - Start Command: `gunicorn campus_portal.wsgi:application`
5. Click **Apply** to deploy.
6. Once deployed, sign in with the default administrator account:
   - **Username**: `admin`
   - **Password**: `Admin@12345` (customizable via `DJANGO_SUPERUSER_PASSWORD` env var in Render)

---

## Option 4: AWS Serverless Stack (SAM + Lambda + DynamoDB + S3)

To deploy the full serverless architecture into your AWS account:

### Prerequisites
- AWS CLI configured (`aws configure`)
- AWS SAM CLI installed (`sam --version`)
- Python 3.11

### Steps:
1. Navigate to the `aws` directory:
   ```bash
   cd aws
   ```
2. Build the SAM package:
   ```bash
   sam build
   ```
3. Deploy the CloudFormation stack:
   ```bash
   sam deploy --guided
   ```
4. Note the outputs:
   - `ApiGatewayEndpoint`
   - `FrontendS3Bucket`
5. Connect your frontend:
   - In [`js/config.js`](file:///c:/Users/nikil/OneDrive/campus%20club%20management%20portal/js/config.js), change:
     ```javascript
     APP_CONFIG.mode = "aws";
     APP_CONFIG.aws.apiGatewayUrl = "https://<your-api-id>.execute-api.<region>.amazonaws.com/v1";
     ```
6. Sync static files to the S3 bucket:
   ```bash
   aws s3 sync . s3://<FrontendS3Bucket>/ --exclude "aws/*" --exclude "django_app/*" --exclude "server/*" --exclude ".git/*"
   ```

---

## Verification & Health Check

After deployment:
- Open `/index.html` (or your deployment domain) to access the Portal Login.
- Click any of the **Demo 1-Click Role Logins** (`Student`, `Club Leader`, or `Dean Administrator`) to verify role-based navigation and authentication.
- Access `/dashboard.html` to confirm eligibility calculation engine and event reservations.
