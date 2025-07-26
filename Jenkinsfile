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
                    sh """
                    echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
                    docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                    docker push ${DOCKER_IMAGE}:latest
                    """
                }
            }
        }

        stage('Prepare EC2 Instance') {
            steps {
                sshagent(credentials: ["${EC2_CREDENTIAL_ID}"]) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_IP} << EOF
                        sudo apt-get update
                        sudo apt-get install -y docker.io
                        sudo systemctl start docker
                        sudo systemctl enable docker
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
                        docker pull ${DOCKER_IMAGE}:latest
                        docker stop ${CONTAINER_NAME} || true
                        docker rm ${CONTAINER_NAME} || true
                        docker run -d --name ${CONTAINER_NAME} -p 80:5000 -e API_KEY=\$(cat ~/.env | grep API_KEY | cut -d '=' -f2) ${DOCKER_IMAGE}:latest
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