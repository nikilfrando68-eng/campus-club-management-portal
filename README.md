# Campus Club Management Portal

An enterprise-grade, serverless web application designed for collegiate institutions. Students authenticate using their university **Register Number**, explore campus clubs, and undergo real-time automated verification of academic eligibility prerequisites before submitting club membership applications.

Built with a dual-mode architecture:
1. **Local Mode**: Runs instantly in any modern browser using an in-memory & `localStorage` simulation of AWS DynamoDB, Lambda, and Cognito without needing an active AWS account.
2. **AWS Cloud Production**: Deploys via AWS SAM with Amazon Cognito, Amazon API Gateway, Python 3.11 AWS Lambda functions, Amazon DynamoDB, and Amazon S3 static website hosting.

---

## Architecture Overview

```
                                      +-----------------------------+
                                      |    College Admissions       |
                                      |    Authorized Registry      |
                                      +--------------+--------------+
                                                     |
                                                     v
[ Student / Leader / Dean ] ---> [ Amazon Cognito User Pool ]
(Register No. + Password)             (Register Number validation)
          |
          v
[ Amazon S3 / CloudFront ] -----> [ Amazon API Gateway (REST API) ]
 (Static Web App: HTML/CSS/JS)                 |
                                               v
                                   [ AWS Lambda Functions ]
                                 (Python 3.11 Serverless Core)
                                   * CheckEligibilityFunction
                                   * ApplyClubFunction
                                   * ReviewApplicationFunction
                                   * ManageRulesFunction
                                   * ListClubsFunction
                                               |
                                               v
                                 [ Amazon DynamoDB Tables ]
                                 * CCMP_Students
                                 * CCMP_StudentRegistry
                                 * CCMP_Clubs
                                 * CCMP_EligibilityRules
                                 * CCMP_Applications
                                 * CCMP_Events
                                 * CCMP_Notifications
```

---

## Key Capabilities & Role-Based Access Control

### 1. Student Portal
* **Register Number Authentication**: Validates user identity against official admissions records.
* **Automated Eligibility Engine**: Real-time evaluation of:
  - Minimum CGPA cutoff
  - Minimum Programming Test Score
  - Minimum Aptitude Assessment Score
  - Minimum Attendance Percentage (75% standard)
  - Eligible Departments & Academic Years
  - Required Prerequisite Courses
* **Club Applications**: Automated locking prevents ineligible submissions. Applications record an immutable snapshot of evaluation results and rule version.
* **Campus Events**: 1-click event seat reservations with capacity enforcement.
* **Verified Profile**: Read-only transcript of verified grades and certifications.

### 2. Club Leader Workspace
* **Managed Chapters**: Scoped specifically to clubs assigned to the leader.
* **Applications Queue**: Inspect applicants who have satisfied automated verification; approve or reject with audit notes.
* **Event Publisher**: Schedule campus workshops and hackathons with venue, date, and seat limits.

### 3. Institutional Administrator (Dean of Student Affairs)
* **Admissions Whitelist Registry**: Pre-authorize valid Register Numbers allowed to create student accounts.
* **Academic Score Calibrator**: Calibrate verified CGPAs, attendance rates, and test scores.
* **Rule Engine Configurator**: Dynamically configure club eligibility cutoffs, simulate cohort impact before publishing, and create immutable rule versions.
* **Club Capacity Governance**: Reallocate seat quotas and designate student leaders.

---

## 1-Click Evaluation Credentials

The portal includes 1-click demo login buttons directly on the login page:

| Persona | Name | Register Number | Password | Profile Description |
| :--- | :--- | :--- | :--- | :--- |
| **Student (Eligible)** | Aarav Sharma | `2023CS0101` | `password123` | CGPA 8.65, Prog 92%, Apt 88%. Satisfies all criteria. |
| **Student (Ineligible)** | Kavya Sundaram | `2024CS0110` | `password123` | CGPA 6.80, Attendance 74.5%. Demonstrates locked criteria. |
| **Club Leader** | Arjun Reddy | `2022CS0001` | `password123` | Leader of ACM CLUB & ROBOTICS CLUB. |
| **Administrator** | Dr. K. S. Ramanathan | `ADMIN001` | `admin123` | Dean of Student Affairs. Full executive access. |

---

## Local Development & Quick Start

The application runs locally without any dependencies or builds:

1. Clone or open the repository folder:
   ```bash
   cd "campus club management portal"
   ```
2. Start any local HTTP server (or open `index.html` in Chrome/Edge/Firefox):
   ```powershell
   # Using Python:
   python -m http.server 8000

   # Or using Node.js npx:
   npx serve .
   ```
3. Open `http://localhost:8000/index.html` in your browser.
4. Click any of the **Demo 1-Click Role Logins** to explore the student, leader, or administrator workflows.

---

## AWS Cloud Production Deployment

To deploy the backend to AWS using the AWS Serverless Application Model (SAM):

### Prerequisites
* AWS CLI installed and configured with credentials (`aws configure`)
* AWS SAM CLI installed (`sam --version`)
* Python 3.11+

### Build & Deploy
```bash
cd aws

# 1. Build the SAM application
sam build

# 2. Deploy guided stack
sam deploy --guided
```

During `sam deploy`, specify:
* Stack Name: `campus-club-management-portal`
* AWS Region: `us-east-1` (or your preferred region)
* Confirm changeset: `Y`

### Connect Frontend to AWS API Gateway
1. Copy the `ApiGatewayEndpoint` from the SAM deployment outputs.
2. Open `js/config.js` and set:
   ```javascript
   APP_CONFIG.mode = "aws";
   APP_CONFIG.aws.apiGatewayUrl = "https://your-api-id.execute-api.us-east-1.amazonaws.com/v1";
   ```
3. Sync the frontend files to the S3 bucket created by SAM:
   ```bash
   aws s3 sync . s3://campus-club-portal-frontend-<ACCOUNT-ID>/ --exclude "aws/*" --exclude "django_app/*" --exclude "server/*"
   ```

---

## Repository Structure

```
campus club management portal/
├── index.html                          # Public login & registration portal
├── dashboard.html                      # Authenticated SPA shell for all roles
├── assets/
│   └── college_logo.jpg                # Sathyabama Institute of Science and Technology emblem
├── css/
│   ├── main.css                        # Modern design system & color tokens
│   ├── components.css                  # UI component library
│   ├── login.css                       # Split-screen auth layout
│   └── dashboard.css                   # Role-based dashboard styles
├── js/
│   ├── config.js                       # Environment config (AWS vs Local)
│   ├── mockData.js                     # Seed data (10+ students, 9 clubs, rules)
│   ├── mockApi.js                      # Local DynamoDB & Lambda simulation
│   ├── api.js                          # Dual-mode API Gateway client
│   ├── auth.js                         # Register Number authentication
│   ├── router.js                       # Client-side hash router
│   ├── state.js                        # Reactive state store
│   ├── utils.js                        # Toast, alerts, formatters
│   ├── eligibility.js                  # Eligibility UI rendering & modals
│   └── components/
│       ├── loginPage.js                # Login controller
│       ├── registrationPage.js         # Student registration controller
│       ├── forgotPassword.js           # Password reset controller
│       ├── studentDashboard.js         # Student overview dashboard
│       ├── exploreClubs.js             # 9 clubs directory with filters
│       ├── clubDetails.js              # Full club profile & live check
│       ├── eligibilityResults.js       # System-wide eligibility matrix
│       ├── myApplications.js           # Application status tracking
│       ├── myClubs.js                  # Active memberships view
│       ├── eventsPage.js               # Campus events registration
│       ├── studentProfile.js           # Verified student transcript
│       ├── notifications.js            # Notification center
│       ├── clubLeaderDashboard.js      # Club leader workspace
│       ├── adminDashboard.js           # Dean/Admin analytics
│       ├── adminStudentManager.js      # Admissions registry manager
│       ├── adminClubManager.js         # Club operations manager
│       ├── adminEligibilityRules.js    # Rule configurator & simulator
│       └── adminApplicationReview.js   # Global review queue
├── aws/
│   ├── template.yaml                   # AWS SAM infrastructure template
│   ├── samconfig.toml                  # Deployment configuration
│   └── lambda/
│       ├── eligibility/
│       │   ├── check_eligibility.py    # Core automated verification engine
│       │   └── manage_rules.py         # Criteria versioning handler
│       ├── applications/
│       │   ├── apply.py                # Student application processor
│       │   └── review_application.py   # Leader review handler
│       ├── clubs/
│       │   └── list_clubs.py           # Club directory scanner
│       └── shared/
│           └── response.py             # Standard JSON & CORS builder
└── README.md
```

---

## Verification & Validation

The application verifies the following requirements:
* [x] **College Register Number Authentication** with admissions whitelist check.
* [x] **Automated Eligibility Verification Engine** evaluates CGPA, programming score, aptitude, attendance, department, year, and prerequisite courses.
* [x] **Enforced Application Lock**: Students cannot apply if criteria are unmet; full criteria breakdown with shortfall reasons displayed.
* [x] **9 Campus Clubs** spanning Technical, Cultural, Creative, Sports, and Leadership domains.
* [x] **3 Role Dashboards**: Student, Club Leader, and Institutional Administrator.
* [x] **Rule Versioning**: Administrators can adjust cutoffs and publish new immutable rule versions in DynamoDB.
* [x] **AWS SAM Infrastructure**: Ready for 1-command deployment with Cognito, API Gateway, Lambda, DynamoDB, and S3.
