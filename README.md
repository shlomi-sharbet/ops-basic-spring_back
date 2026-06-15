# 🚀 DevOps Mastery Playground: End-to-End AWS & LocalStack Infrastructure

[![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![LocalStack](https://img.shields.io/badge/Local-LocalStack-4c2c92?style=for-the-badge&logo=localstack&logoColor=white)](https://localstack.cloud/)
[![Docker](https://img.shields.io/badge/Container-Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![GitHub Actions](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)](https://github.com/features/actions)
[![AWS](https://img.shields.io/badge/Cloud-AWS-FF9900?style=for-the-badge&logo=amazon-web-services&logoColor=white)](https://aws.amazon.com/)

A professional, production-grade DevOps showcase demonstrating the deployment of a full-stack application (Spring Boot & Angular) on AWS using modern Infrastructure as Code (IaC), automated CI/CD pipelines, containerization, and advanced CDN routing. 

This repository implements a **Local-First development paradigm**, leveraging **LocalStack** to fully simulate AWS environments (VPC, EC2, S3, IAM, Route53, CloudFront) locally before pushing to production AWS Cloud.

---

## 🎯 Project Scope, Philosophy & Mentorship Context

This repository was designed not just as a deployment playground, but as a structured **onboarding and mentorship framework** to guide a junior DevOps engineer through end-to-end infrastructure, automation, and cloud parity practices.

### 💡 Why this Architecture? (Avoiding the Over-Engineering Anti-Pattern)
In professional DevOps, success is measured by delivering the most cost-effective, reliable, and maintainable solution for the business requirements—not by building the most complex system. 
* **Pragmatic Simplicity**: For the scope of this CRUD application, choosing a single EC2 instance behind a global **CloudFront CDN** is a deliberate, professional choice over complex orchestrators (like Kubernetes or ECS/Fargate) or load balancers.
* **Cost & Traffic Optimization**: A single-instance architecture keeps AWS running costs minimal, while CloudFront offloads all static frontend traffic at the edge.
* **Core DevOps Focus**: By keeping the runtime environment simple, the mentorship focus remains entirely on foundational DevOps pillars: Infrastructure as Code (IaC), secure CI/CD pipelines, clean Docker multi-stage builds, zero-trust network configurations, and local-first simulation.

---


## 🗺️ System Architecture

The following diagram illustrates the complete system architecture, demonstrating how frontend and backend services are securely routed, hosted, and deployed:

![EC2 System Architecture](assets/architecture.png)


---

## 🧠 Key Architectural & Engineering Decisions

While this setup may seem straightforward at first glance, the architecture implements several production-grade design patterns that demonstrate industry-standard DevOps and cloud architecture principles:

### 1. Unified Single-Entry Point (CORS & Security Optimization)
* **Problem**: Decoupled full-stack apps (frontend on S3 and API on EC2) usually require configuring Cross-Origin Resource Sharing (CORS) on the backend, introducing additional HTTP `OPTIONS` preflight request latency.
* **Solution**: By routing both the S3 frontend origin (`*`) and backend EC2 API origin (`/api/*`) through a single **AWS CloudFront** distribution, they share the exact same domain name (`ec2-stage.shlomi.com`). This completely eliminates CORS preflight latency and improves security by keeping the actual EC2 instance endpoint hidden from public browsers.

### 2. Edge Caching & Decoupled Static Hosting
* **Strategy**: Serving frontend Angular builds directly from **Amazon S3 website hosting** instead of the EC2 virtual machine.
* **Benefit**: Offloads all static web asset delivery (HTML, JS, CSS, images) to AWS's global edge network (CloudFront). The EC2 instance CPU/Memory is entirely dedicated to processing dynamic database queries and API business logic on port `8080`, vastly improving system scalability and reducing compute costs.

### 3. Database Isolation & Zero-Port Exposure
* **Implementation**: The MySQL database container does not expose or forward port `3306` to the host system or the public internet. 
* **Benefit**: It communicates directly with the Spring Boot container via Docker's high-speed internal bridge DNS, with no ports mapped outside the virtual network. This prevents external database sniffing, credential brute-forcing, and zero-day database port attacks.

### 4. High-Fidelity Local Development (Cloud Parity)
* **Philosophy**: Emulating Route 53 routing, ACM certificates, S3 bucket endpoints, and EC2 provisioning locally using **LocalStack**.
* **Benefit**: Enables testing full cloud infrastructure deployments locally in seconds. This eliminates standard cloud cost overhead during development, supports offline testing, and ensures 100% parity between local test environments and live AWS environments.

### 5. Outbound-Only CI/CD Execution (Zero-Trust Runner Model)
* **Strategy**: The workflows for both frontend and backend repositories run on a **Self-Hosted Runner** (`runs-on: self-hosted`) instead of standard cloud-hosted runners.
* **Benefit**: Standard CI/CD workflows require storing highly sensitive SSH private keys (`SSH_KEY`) on third-party cloud systems and opening inbound SSH port `22` to the public internet. By hosting a local agent, the runner initiates an *outbound-only* connection (HTTPS on port 443) to GitHub to listen for work. This eliminates the need to store sensitive SSH keys on GitHub or open open firewall ports, resulting in a zero-inbound-ports network topology.

### 6. Environment-Agnostic Compilation (Multi-Stage Dockerization)
* **Strategy**: Rewriting the application's `Dockerfile` to implement a two-stage **Multi-Stage Build**.
* **Benefit**: 
  1. *Stage 1 (Builder)*: Uses a Maven-loaded base container to build and package the code. This guarantees that compilation is environment-agnostic; no Java JDK or Maven packages need to be pre-installed on the runner or developer's host machine.
  2. *Stage 2 (Runner)*: Copies only the compiled artifact (`basic.jar`) into a lightweight, hardened `eclipse-temurin:11-jre-alpine` runtime image. This reduces the deployment image size by up to 80% and strips away the compiler, shell tools, and libraries, significantly reducing the attack surface.

### 7. Ordered Bootstrapping & Lifecycle Management (Container Healthchecks)
* **Strategy**: Defining a custom healthcheck command inside `docker-compose.yml` for the MySQL service using `mysqladmin ping` and pairing it with a conditional dependency (`condition: service_healthy`) on the backend service.
* **Benefit**: Spring Boot initializes and attempts database connection within seconds of startup, whereas MySQL takes longer to fully boot and configure its tables. In standard docker configurations, this causes the API container to crash due to database connection failures. Implementing healthchecks ensures the backend container delays its initialization until the database is fully ready to accept connections.

### 8. Enterprise-Grade IaC State Management (S3 Backend & DynamoDB Lock)
* **Strategy**: Utilizing a remote AWS backend configuration for Terraform state storage coupled with state locking.
* **Benefit**: While local testing saves the `.tfstate` locally, production workflows store the state file in a secured **Amazon S3 bucket** (with versioning enabled to roll back accidental state updates) and use a **DynamoDB table** as a state locking mechanism. This prevents race conditions and state corruption when multiple DevOps engineers or CI/CD pipelines attempt to execute infrastructure plans simultaneously.

---

## 🌟 Key DevOps Engineering Pillars Demonstrated

1. **Infrastructure as Code (IaC)**: Fully automated infrastructure provisioning using **Terraform**, managing VPC, Subnets, Internet Gateways, Security Groups, IAM roles, S3 buckets, Route53, EC2, and CloudFront.
2. **Cloud Parity & Emulation**: Utilizes **LocalStack** and `tflocal` to run, test, and debug the entire AWS infrastructure locally, reducing cloud spend and shortening feedback loops.
3. **Containerization & Orchestration**: High-performance multi-container setup running via **Docker Compose**, separating the Java backend API and MySQL database.
4. **Automated CI/CD (GitHub Actions)**:
   - **Backend Pipeline**: Automatic compilation (Maven), Docker image building, publishing to Docker Hub, and zero-downtime deployment to AWS EC2 via SSH.
   - **Frontend Pipeline**: Automated compilation (Angular), deployment to S3 static hosting, and asset invalidation.
5. **Advanced Content Delivery & CDN Routing**: A single-entry point architecture using **AWS CloudFront** mapping:
   - `/api/*` requests dynamically forwarded to the Spring Boot REST API on EC2.
   - All other static assets served instantly via **Amazon S3** edge locations.
   - Custom domains and SSL certificates via **Route 53**, ACM, and GoDaddy nameserver integrations.

---

## 🤖 Built-in Automation Scripts

To streamline local development, infrastructure management, and deployments, the project includes pre-configured automation bash scripts under the `scripts/` directory:

### 1. Infrastructure Management (`scripts/infra.sh`)
Handles the complete lifecycle of your LocalStack environment and Terraform state.
* **Spin up local AWS mock environment**:
  ```bash
  ./scripts/infra.sh start
  ```
* **Teardown local mock environment**:
  ```bash
  ./scripts/infra.sh stop
  ```
* **SSH connection to mock EC2 (as root or testuser)**:
  ```bash
  ./scripts/infra.sh ssh       # Connect as testuser
  ./scripts/infra.sh ssh-root  # Connect as root
  ```
* **Create an encrypted SSH tunnel to forward port 5555**:
  ```bash
  ./scripts/infra.sh tunnel
  ```

### 2. Backend Orchestration (`scripts/build-run.sh`)
Builds the Spring Boot Java API, generates the Docker container image, and spins up the database and backend services using Docker Compose with a single command **inside the EC2 instance**:
```bash
# Run inside the EC2 container/machine after cloning the repo:
./scripts/build-run.sh
```

### 3. Local S3 Frontend Deployment (`scripts/deploy-frontend-local.sh`)
Automates building the Angular frontend and syncing the build artifacts to the local mock S3 bucket inside LocalStack:
```bash
./scripts/deploy-frontend-local.sh
```

---

## 📂 Project Structure

```directory
├── .github/
│   └── workflows/
│       └── build.yml             # GitHub Actions CI/CD for Backend Deployment
├── scripts/
│   ├── infra.sh                  # LocalStack and Terraform management automation
│   ├── build-run.sh              # Compiles, builds Docker image, starts compose
│   └── deploy-frontend-local.sh  # Deploys Angular frontend to S3 locally
├── src/                          # Spring Boot Application source code
├── terraform/                    # Infrastructure as Code (IaC) configuration
│   ├── ec2.tf                    # VPC, Security Groups, EC2 instance, testuser automation
│   ├── s3.tf                     # Static S3 bucket configuration, public read policy
│   ├── iam.tf                    # IAM User and policies for static deployment
│   └── cloudfront.tf             # Route53 zones/records, ACM, CloudFront distribution routing
├── Dockerfile                    # Docker recipe for Java API compilation and execution
├── docker-compose.yml            # Compose file defining server & database services
├── pom.xml                       # Maven project definition
└── README.md                     # This README
```


---

## 💻 Local Emulation & Development (LocalStack)

This project is built to run 100% locally using LocalStack.

### 1. Prerequisites
Ensure you have the following installed and configured on your machine (WSL / Local PC):
* Docker & Docker Compose
* LocalStack CLI (`pip install localstack`)
* Python Virtual Environment with LocalStack helper wrappers (`tflocal` and `awslocal`):
  ```bash
  python3 -m venv ~/venv 
  source ~/venv/bin/activate
  python3 -m pip install terraform-local awscli-local
  ```
* **Verify Local wrappers installation**:
  ```bash
  tflocal --version
  awslocal --version
  ```
* **Host SSH Key (Required for mock EC2 GitHub cloning)**: A valid SSH key pair (preferably `~/.ssh/id_ed25519`) must exist on your host machine and be added to your GitHub account *before* provisioning.

### 2. Generate SSH Key on Host (WSL / Local PC)
Before launching the infrastructure, you must ensure you have an SSH key generated on your host machine so that Terraform can copy it to the container. If you do not have one, run:
```bash
# Generate the key pair on your host machine (WSL or Local PC)
ssh-keygen -t ed25519 -C "[EMAIL_ADDRESS]"

# View and copy the public key
cat ~/.ssh/id_ed25519.pub

# Add the public key to your GitHub account:
# Go to Settings -> SSH and GPG keys -> New SSH key, and paste the output.
```

### 3. Launch LocalStack
Start the local AWS cloud engine in the background:
```bash
localstack start -d
```

### 4. Provision Infrastructure Locally
Navigate to the `terraform/` directory and use `tflocal` to initialize and deploy the infrastructure to your local mock environment:
```bash
cd terraform
tflocal init
tflocal apply -auto-approve
```

> [!NOTE]
> Standard Terraform outputs the generated private SSH key (`ec2_key_pair.pem`) to the `terraform/` directory with `0400` read-only permissions automatically.
> 
> To destroy the local mock environment later, run from the `terraform/` directory:
> ```bash
> tflocal destroy -auto-approve
> ```


### 5. Connect to Local Mock EC2
To log into the simulated Ubuntu machine created inside LocalStack:
```bash
# Secure the key (run from the root directory, copying from the terraform/ folder)
cp terraform/ec2_key_pair.pem ~
chmod 400 ~/ec2_key_pair.pem

# SSH into the containerized machine
ssh -i ~/ec2_key_pair.pem testuser@localhost
# Or as root:
ssh -i ~/ec2_key_pair.pem root@localhost
```

### 6. Verify Tool Installations (Verification)
Run the following commands inside the EC2 instance to ensure all tools have been provisioned correctly:
```bash
docker --version
docker-compose --version
git --version
python3 --version
mvn -version
yq --version
```

### 7. GitHub Authentication & Project Setup (Inside EC2)
Once logged into the EC2 instance and verified, you need to clone your repository to build and deploy the application.

1. **Verify SSH Key and Connection**:
   * **For Local Emulation (LocalStack)**:
     Since the Terraform `copy_ssh_keys` resource automatically copied your host's existing key into the mock EC2 container during step 4, you can verify it and test your connection to GitHub directly:
     ```bash
     ls -la ~/.ssh/
     ssh -T git@github.com
     ```
   * **For Production AWS EC2 (Real Cloud)**:
     If you are deploying on a real AWS cloud instance without automated copy, generate the key pair inside the EC2 instance and register it with GitHub:
     ```bash
     ssh-keygen -t ed25519 -C "shlomi.sharbet@gmail.com"
     cat ~/.ssh/id_ed25519.pub
     # Add the output to GitHub Settings -> SSH and GPG keys.
     ```

2. **Clone and Configure**:
   Clone the repository and set up your git configurations:
   ```bash
   git clone git@github.com:shlomi-sharbet/ops-basic-spring-ec2-back.git
   cd ops-basic-spring-ec2-back
   git config --global user.email "[EMAIL_ADDRESS]"
   ```

---

## 🐳 Application Containerization (Docker Setup)

This phase compiles the Java Backend and orchestrates the containers. You can either use the automated script or run the steps manually inside the EC2 instance.

### Option A: Automated Build & Run (Recommended)
Expose execute permissions and run the orchestration script inside the `ops-basic-spring-ec2-back` directory:
```bash
chmod +x ./scripts/build-run.sh
./scripts/build-run.sh
```

### Option B: Manual Steps
If you prefer running commands individually, follow these steps:

> [!NOTE]
> Thanks to our **Docker Multi-Stage Build**, you do not need to pre-install Maven or compile the Java backend on your host machine before building the Docker image. The `docker build` command handles compilation automatically inside the container.
> If you still want to compile locally on your host for testing, running unit tests, or IDE support, you can compile manually:
> 
> ```bash
> mvn clean install
> # Verifies that basic-0.0.1-SNAPSHOT.jar is generated under /target
> ```


### 2. Manual Docker Build & Publish
```bash
# Login to your registry
# create token: https://app.docker.com/accounts/shlomisharbat/settings/personal-access-tokens
docker login -u <DOCKERHUB_USERNAME>

# Build the API image
docker build . -t backend

# Tag and push
docker tag backend <DOCKERHUB_USERNAME>/backend:latest
docker push <DOCKERHUB_USERNAME>/backend:latest
```

### 3. Run Multi-Container Services
Run the Spring Boot Backend alongside a MySQL database inside the EC2 environment:
```bash
docker-compose up -d
```
* **Swagger API Documentation UI**: Accessible at `http://localhost:8080/swagger-ui.html`
* **MySQL Database**: Running on port `3306` inside the isolated network (Not exposed to the host machine/public internet for security; accessible internally by the backend).


---

## 🐙 CI/CD Pipelines (GitHub Actions)

### 1. Backend CI/CD Workflow (`.github/workflows/build.yml`)
Triggers on every push to the `master` branch:
1. **Build**: Compiles and packages the Java code using Maven with JDK 11.
2. **Dockerize**: Builds the Docker image with a dynamic version tag: `v1.0.${{ github.run_number }}`.
3. **Registry Push**: Uploads the image to Docker Hub.
4. **AWS Deployment (CD)**: Connects securely via SSH to the AWS EC2 instance, updates the image tag in `docker-compose.yml`, pulls the latest build, and performs a graceful container restart (`docker-compose down && docker-compose up -d`).

### 2. Frontend CI/CD Workflow (Angular Deploy to S3)
Triggers on every push to the `main` branch of the frontend repository:
1. **Compilation**: Installs Node dependencies and builds the optimized Angular production bundle (`npm run build --prod`).
2. **S3 Synchronization**: Uses the AWS CLI to sync assets to S3 and purge deleted files:
   ```bash
   aws s3 sync ./dist/webapp s3://${{ env.S3_BUCKET_NAME }} --delete
   ```

### 3. Self-Hosted GitHub Actions Runner
To build and deploy both the backend and frontend applications, the workflows utilize a **Self-Hosted Runner** (`runs-on: self-hosted`). This ensures that the builds execute directly on the target host/runner environment (e.g., your local workspace or deployment server), allowing secure, local build execution and integration.

To start the registered self-hosted runner:
```bash
# Navigate to the runner installation directory and start the agent
cd ~/actions-runner   # (e.g., /home/shlomi/actions-runner)
./run.sh
```

### 4. Configuring Repository Secrets
To run these automated pipelines, configure the following secrets in GitHub under `Settings -> Secrets and variables -> Actions` in their respective repositories:

#### A. Backend Repository Secrets (`ops-basic-spring-ec2-back`)
These secrets are required for compiling, dockerizing, pushing to Docker Hub, and deploying to the EC2 server:

| Secret Name | Description | Example / Mock Value |
| :--- | :--- | :--- |
| `DOCKERHUB_USERNAME` | Your Docker Hub account | `shlomisharbat` |
| `DOCKERHUB_TOKEN` | Personal Access Token from Docker Hub | `dckr_pat_...` |
| `EC2_INSTANCE_PUBLIC_IP` | Public IP of your EC2 Web Server | `13.50.xxx.xxx` (or `localhost` for local testing) |
| `SSH_KEY` | Content of `ec2_key_pair.pem` Private Key | `-----BEGIN RSA PRIVATE KEY----- ...` |

#### B. Frontend Repository Secrets
These secrets are required for building and deploying the static Angular web application to Amazon S3 website hosting:

| Secret Name | Description | Example / Mock Value |
| :--- | :--- | :--- |
| `AWS_ACCESS_KEY_ID` | Access key of deployer IAM user | `AKIA...` |
| `AWS_SECRET_ACCESS_KEY` | Secret key of deployer IAM user | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYzEXAMPLEKEY` |
| `AWS_REGION` | AWS target deployment region | `us-east-1` |
| `S3_BUCKET_NAME` | S3 static hosting bucket name | `shlomi.backend.students` |


---

## ⚡ Professional Tips & Techniques

### Pro-Tip: Secure Local Port Access via SSH Tunneling
When testing endpoints inside a remote EC2 server with closed ports, **do not open ports to the entire internet** in your Security Group! Instead, use **SSH Port Forwarding (Tunneling)**. 

Establish a secure encrypted tunnel that routes local port `5555` directly to port `5555` inside the EC2 instance over port 22:
```bash
ssh -i ~/ec2_key_pair.pem -L 5555:localhost:5555 root@localhost
```
Now, if you launch a test web server on the remote instance (e.g., `python3 -m http.server 5555`), you can access it securely from your local browser at `http://localhost:5555`!

---

## ⚙️ Advanced Production Configuration: Routing & Domain Setup (IaC)

This advanced routing and CDN setup is **fully automated as Infrastructure as Code (IaC)** inside [cloudfront.tf](terraform/cloudfront.tf). When you run `tflocal apply` or `terraform apply`, Terraform provisions and configures the following resources automatically:

1. **Route 53 Hosted Zone** (`aws_route53_zone`): Manages the DNS zone for `shlomi.com` and registers DNS records (e.g., pointing domain registrar nameservers to AWS Route 53).
2. **ACM Certificate** (`aws_acm_certificate`): Automates requesting a wildcard SSL/TLS Certificate (`*.shlomi.com`) to allow secure HTTPS communication.
3. **CloudFront CDN Distribution** (`aws_cloudfront_distribution`): Provisions a global CDN at `ec2-stage.shlomi.com` mapping:
   - **S3 Frontend Origin**: Points to the S3 bucket static website endpoint.
   - **EC2 Backend Origin**: Points to the API Backend CNAME (`api-raw.shlomi.com`) on port `8080`.
   - **Cache Behaviors**:
     - Path pattern `/api/*` routes requests dynamically to the EC2 backend.
     - Default path pattern `*` serves static web assets directly from the S3 bucket.
4. **DNS Records** (`aws_route53_record`): Maps `api-raw.shlomi.com` to the EC2 host and `ec2-stage.shlomi.com` directly to the CloudFront distribution domain.

---

## 🧪 End-to-End Integration Verification (E2E Validation)

To verify that the entire architecture (Frontend on S3, Backend API on EC2, CloudFront CDN Routing, Route 53, and SSL ACM Certificates) is integrated and functioning correctly, follow these verification steps:

### 💡 Verification Pre-requisite: Creating a Test User via Swagger
Before attempting to log into the frontend web application and query/write database records, you must register a user in the database. Since the database is isolated and not exposed to the internet, you can create a user using the Swagger API UI:

1. **Access Swagger UI**:
   Open `http://localhost:8080/swagger-ui.html` or `http://ec2-public-ip:8080/swagger-ui.html` in your browser.
2. **Locate the Auth Controller**:
   Expand the **`jwt-authentication-controller : Jwt Authentication Controller`** section.
3. **Register a User**:
   - Click on the **`POST /api/user`** endpoint.
   - In the request body, define a JSON object with your desired credentials:
     ```json
     {
       "username": "your-username",
       "password": "your-password"
     }
     ```
   - Click **"Try it out"** and verify you receive a success status code (HTTP 200/201).
4. **Test Login**:
   Use these credentials to log in to the frontend application (either locally or on your custom domain) to verify the end-to-end authentication and database flow.

---

### 1. In Local Emulation (LocalStack)
Since LocalStack simulates CloudFront, S3 website hosting, and DNS routing locally, you can verify the integration using local endpoints:

1. **Retrieve the Mock CloudFront URL**:
   Fetch the domain name generated by LocalStack for your CloudFront distribution:
   ```bash
   awslocal cloudfront list-distributions --query "DistributionList.Items[0].DomainName" --output text
   # Or retrieve it via your Terraform output:
   tflocal output cloudfront_domain_name
   ```
2. **Access the Frontend**:
   Open your browser and navigate to the simulated CloudFront distribution URL (e.g., `http://<distribution-id>.cloudfront.localhost.localstack.cloud:4566`). You should see your Angular application load.
3. **Verify API Proxying & Routing**:
   - Open your browser's Developer Tools (`F12`) and navigate to the **Network** tab.
   - Interact with the app (log in using the username/password created in the pre-requisite step, then view or load students data).
   - Verify that requests to the backend API are sent to `http://<distribution-id>.cloudfront.localhost.localstack.cloud:4566/api/students` (which is proxied by CloudFront to the EC2 container on port `8080`) rather than calling port `8080` directly.

### 2. In Production AWS Cloud (Real Infrastructure)
Once deployed to the real AWS cloud, verify the full-stack setup:

1. **Navigate to the Custom Domain**:
   Open `https://ec2-stage.shlomi.com` in your browser.
2. **Verify SSL/TLS Active State**:
   Confirm that the lock icon is visible next to the URL, indicating that the wildcard SSL/TLS Certificate generated by **AWS Certificate Manager (ACM)** is successfully configured on the CloudFront edge network.
3. **Inspect CDN Routing**:
   - Open Browser Developer Tools (`F12`) -> **Network** tab.
   - Trigger a database read or write action (log in using the username/password created in the pre-requisite step).
   - Confirm that the request is routed as a relative path to the same domain (e.g., `https://ec2-stage.shlomi.com/api/...`).
   - If the request is successful (HTTP 200) and displays data, it confirms:
     1. **Route 53** resolved `ec2-stage.shlomi.com` to CloudFront.
     2. **CloudFront** served the static frontend from the **S3 Bucket Website Origin**.
     3. **CloudFront** matched the path `/api/*` and proxied the request to the **EC2 Backend Origin** (`api-raw.shlomi.com`).
     4. The Spring Boot backend running in the **Docker Compose bridge network** successfully queried the isolated **MySQL database** container.


