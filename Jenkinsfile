pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "parvezali4953/flask-weather-app"
        DOCKER_CREDENTIALS_ID = "DockerHub"
        EC2_USER = "My_WeatherApp"
        EC2_IP = "65.2.127.119"
        EC2_CREDENTIAL_ID = "EC2-SSH"
        CONTAINER_NAME = "Flask-WeatherApp"
        APP_PORT = "5000"
        PUBLIC_PORT = "80"
        }
    }

    stages {

        stage('Clone Repo') {
            steps {
                git branch: 'master', url: 'https://github.com/Parvezali4953/WeatherApp.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:01 ."
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    docker push ${DOCKER_IMAGE}:01
                    """
                }
            }
        }

        stage('Copy Deployment Files to EC2') {
            steps{
                sshagent(credentials: ["${EC2_CREDENTIAL_ID}"]) {
                    sh """
                        scp docker-compose.yml ${EC2_USER}@${EC2_IP}:/home/${EC2_USER}/
                        scp nginx/default.conf ${EC2_USER}@${EC2_IP}:/home/${EC2_USER}/nginx.conf
                     
                    """
                }
            }
        }

        stage('Deploy on EC2 with Docker Compose') {
            steps {
                sshagent(credentials: ["${EC2_CREDENTIAL_ID}"]) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ec2-user@${EC2_IP} << EOF
                        docker pull ${DOCKER_IMAGE}:01 
                        mkdir -p /home/${EC2_USER}/nginx
                        mv /home/${EC2_USER}/nginx.conf /home/${EC2_USER}/nginx/default.conf
                        cd /home/${EC2_USER}
                        docker-compose down || true
                        docker compose up -d
                    EOF
                    """
                }
            }
        }
    }

    post {
        success {
            echo '✅ CI/CD completed: App is live via Docker Hub image!'
        }
        failure {
            echo '❌ CI/CD failed. Check logs.'
        }
    }
