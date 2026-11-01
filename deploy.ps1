# Campus Club Management Portal - Automated Deployment Helper (PowerShell)
param(
    [string]$Target = ""
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Campus Club Management Portal - Deployment Assistant   " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

if (-not $Target) {
    Write-Host "Select deployment target:" -ForegroundColor Green
    Write-Host "1) Deploy Frontend to Vercel (Instant Cloud URL)"
    Write-Host "2) Deploy Frontend to Netlify (Instant Cloud URL)"
    Write-Host "3) Deploy Full Stack locally with Docker (Django + MySQL)"
    Write-Host "4) Deploy Backend to AWS Serverless (SAM + Lambda + DynamoDB)"
    Write-Host "5) Deploy Frontend to AWS S3 Bucket"
    Write-Host "6) Run Local Test Server (Python HTTP)"
    Write-Host ""
    $choice = Read-Host "Enter option number [1-6]"
} else {
    $choice = $Target
}

switch ($choice) {
    "1" {
        Write-Host "`n--> Deploying Frontend to Vercel..." -ForegroundColor Cyan
        npx --yes vercel --prod
    }
    "2" {
        Write-Host "`n--> Deploying Frontend to Netlify..." -ForegroundColor Cyan
        npx --yes netlify-cli deploy --prod --dir=.
    }
    "3" {
        Write-Host "`n--> Starting Docker Compose Stack..." -ForegroundColor Cyan
        docker compose up --build -d
        Write-Host "`nApplication running at http://localhost:8000" -ForegroundColor Green
    }
    "4" {
        Write-Host "`n--> Building & Deploying AWS SAM Application..." -ForegroundColor Cyan
        Set-Location aws
        sam build
        sam deploy --guided
        Set-Location ..
    }
    "5" {
        $bucket = Read-Host "Enter your S3 Bucket Name (e.g., campus-club-frontend)"
        if ($bucket) {
            Write-Host "`n--> Syncing static assets to s3://$bucket ..." -ForegroundColor Cyan
            aws s3 sync . "s3://$bucket" --exclude "aws/*" --exclude "django_app/*" --exclude "server/*" --exclude ".git/*"
            Write-Host "`nDone! Ensure your S3 bucket has Static Website Hosting enabled." -ForegroundColor Green
        } else {
            Write-Host "Bucket name cannot be empty." -ForegroundColor Red
        }
    }
    "6" {
        Write-Host "`n--> Starting local preview server at http://localhost:8000 ..." -ForegroundColor Cyan
        python -m http.server 8000
    }
    Default {
        Write-Host "Invalid selection. Exiting." -ForegroundColor Red
    }
}
