# 🌦️ Weather Forecast Web App

A simple Flask app to fetch weather data using the OpenWeatherMap API, enhanced with a DevOps pipeline.

## 🚀 Features
- Search weather by city name.
- Displays temperature, description, humidity, and wind speed.
- Error handling for invalid cities.
- Automated deployment and monitoring.

## 📁 Structure
- `app.py`: Flask app.
- `templates/`: HTML files (`index.html`, `result.html`).
- `static/style.css`: CSS styling.
- `Dockerfile`: Docker configuration.
- `docker-compose.yml`: Docker Compose configuration.
- `requirements.txt`: Python dependencies.
- `playbook.yml`: Ansible configuration.
- `main.tf`: Terraform configuration.
- `.github/workflows/ci.yml`: GitHub Actions workflow.

## 🛠️ DevOps Pipeline
- **CI/CD**: GitHub Actions builds and deploys Docker image.
- **IaC**: Terraform provisions EC2, ELB, CloudWatch, and S3.
- **Configuration Management**: Ansible sets up EC2 with Docker, Nginx, and CloudWatch Logs.
- **Monitoring**: CloudWatch monitors EC2 metrics and logs.
- **Storage**: S3 stores logs via CloudWatch.
- **Scalability**: ELB for load balancing.

## 🔐 Setup
1. Clone: `git clone [invalid url, do not cite]
2. Install dependencies: `pip install -r requirements.txt`
3. Set `.env`: `API_KEY=your_api_key`
4. Run locally: `python app.py`

## 📋 Deployment
- Provision infrastructure with Terraform: `terraform apply`
- Configure EC2 with Ansible: `ansible-playbook -i inventory playbook.yml`
- Deploy with GitHub Actions: Push to main branch

## 📸 Screenshots
- [Homepage]([invalid url, do not cite])
- [Result]([invalid url, do not cite])