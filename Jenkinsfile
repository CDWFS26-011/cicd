pipeline {
    agent any

    environment {
        REGISTRY = "localhost:5000"
        IMAGE_NAME = "water-app"
    }

    stages {

        stage('Tests') {
            agent {
                docker {
                    image 'python:3.11'
                    reuseNode true
                }
            }
            steps {
                sh 'pip install -r requirements.txt'
                sh 'pytest --cov . --cov-report xml'
            }
        }

        stage('Build Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} -f cicd/Dockerfile ."
                sh "docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:latest"
            }
        }

        stage('Push to Registry') {
            steps {
                sh "docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}"
                sh "docker tag ${IMAGE_NAME}:latest ${REGISTRY}/${IMAGE_NAME}:latest"
                sh "docker push ${REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}"
                sh "docker push ${REGISTRY}/${IMAGE_NAME}:latest"
            }
        }

        stage('Deploy to Host') {
            agent {
                label 'ssh_agent'
            }
            steps {
                sh """
                    docker pull ${REGISTRY}/${IMAGE_NAME}:latest
                    docker stop ${IMAGE_NAME} || true
                    docker rm ${IMAGE_NAME} || true
                    docker run -d \
                        --name ${IMAGE_NAME} \
                        --restart unless-stopped \
                        -p 5000:5000 \
                        ${REGISTRY}/${IMAGE_NAME}:latest
                """
            }
        }

    }

    post {
        always {
            echo 'Pipeline terminé.'
        }
        success {
            echo 'Déploiement réussi.'
        }
        failure {
            echo 'Échec du pipeline.'
        }
    }
}
