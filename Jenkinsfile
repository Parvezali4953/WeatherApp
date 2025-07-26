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
                    sh '''
                    echo "Attempting SSH to ${EC2_IP}..."
                    ssh -v -o StrictHostKeyChecking=no -o ConnectTimeout=10 ${EC2_USER}@${EC2_IP} << 'EOF'
                    echo "SSH connection successful."
                    echo "Checking system..."
                    uname -a
                    echo "Updating packages..."
                    sudo apt update
                    echo "Installing Docker..."
                    sudo apt install -y docker.io || { echo "Docker install failed"; exit 1; }
                    echo "Starting Docker..."
                    sudo systemctl start docker
                    sudo systemctl enable docker
                    echo "Docker setup complete."
                    EOF
                    '''
                }
            }
        }
        stage('Deploy to EC2') {
            steps {
                sshagent(credentials: ["${EC2_CREDENTIAL_ID}"]) {
                    withCredentials([string(credentialsId: 'weather-api-key', variable: 'API_KEY')]) {
                        sh '''
                        echo "Deploying to EC2 with API_KEY set..."
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_IP} << 'EOF'
                            echo "Pulling image..."
                            docker pull ${DOCKER_IMAGE}:latest || { echo "Pull failed"; exit 1; }
                            echo "Stopping old container..."
                            docker stop ${CONTAINER_NAME} || true
                            docker rm ${CONTAINER_NAME} || true
                            echo "Running new container with API_KEY: ${API_KEY}"
                            docker run -d --name ${CONTAINER_NAME} -p 80:5000 -e API_KEY=${API_KEY} ${DOCKER_IMAGE}:latest || { echo "Run failed"; exit 1; }
                        EOF
                        '''
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