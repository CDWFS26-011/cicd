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

    }

    post {
        always {
            echo 'Pipeline terminé.'
        }
    }
}
