pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
        IMAGE_NAME = 'calc-app'
        DOCKERHUB_REPO = 'chibuzone/calc-app'
    }

    options {
        timeout(time: 30, unit: 'MINUTES')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'project-1', url: 'https://github.com/ChibuzoNE/proj-mdp-152-155.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t $IMAGE_NAME:latest .
                    docker tag $IMAGE_NAME:latest $DOCKERHUB_REPO:latest
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                sh '''
                    echo "$DOCKERHUB_CREDENTIALS_PSW" | docker login -u "$DOCKERHUB_CREDENTIALS_USR" --password-stdin
                    docker push $DOCKERHUB_REPO:latest
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f project-3/Ansible/K8s-deployment.yml'
            }
        }
    }

    post {
        failure {
            echo '❌ Pipeline failed - check logs for details.'
        }
        success {
            echo '✅ Pipeline completed successfully.'
        }
    }
}
