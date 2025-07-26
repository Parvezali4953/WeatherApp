pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "parvezali4953/flask-weather-app"
        DOCKER_CREDENTIALS_ID = "DockerHub"
        EC2_USER = "ubuntu"
        EC2_IP = "65.0.177.39"
        EC2_CREDENTIAL_ID = "EC2-SSH"
        CONTAINER_NAME = "flask-weather-app"
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/Parvezali4953/WeatherApp.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} ."
                sh "docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest"
            }
        }
        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                    echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
                    docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                    docker push ${DOCKER_IMAGE}:latest
                    '''
                }
            }
        }
        stage('Prepare EC2') {
            steps {
                sshagent(credentials: ["${EC2_CREDENTIAL_ID}"]) {
                    sh """
                    echo "Attempting SSH to ${EC2_IP}..."
                    ssh -v -o StrictHostKeyChecking=no -o ConnectTimeout=10 ${EC2_USER}@${EC2_IP} << EOF
echo "SSH connection successful."
uname -a
sudo apt update
sudo apt install -y docker.io || echo "Docker install failed"
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ${EC2_USER}
echo "Docker setup complete. User added to docker group."
EOF
                    """
                }
            }
        }
        stage('Deploy to EC2') {
            steps {
                sshagent(credentials: ["${EC2_CREDENTIAL_ID}"]) {
                    withCredentials([string(credentialsId: 'weather-api-key', variable: 'API_KEY')]) {
                        sh """
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_IP} << EOF
echo "Deploying with API_KEY: \${API_KEY}"  # Debug output
echo "Pulling image..."
sudo docker pull ${DOCKER_IMAGE}:latest || { echo "Pull failed"; exit 1; }
echo "Stopping old container..."
sudo docker stop ${CONTAINER_NAME} 2>/dev/null || true
sudo docker rm ${CONTAINER_NAME} 2>/dev/null || true
echo "Running new container with API_KEY: \${API_KEY}"
sudo docker run -d --name ${CONTAINER_NAME} -p 80:5000 -e API_KEY="\${API_KEY}" ${DOCKER_IMAGE}:latest || { echo "Run failed"; exit 1; }
EOF
                        """
                    }
                }
            }
        }
    }
    post {
        success {
            echo '✅ Deployment successful!'
        }
        failure {
            echo '❌ Deployment failed. Check logs.'
        }
    }
}