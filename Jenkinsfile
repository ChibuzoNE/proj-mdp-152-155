pipeline {
    agent any

    environment {
        IMAGE_NAME = 'calc-app'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        DOCKERHUB_REPO = 'chibuzone/calc-app'
        FULL_IMAGE = "${DOCKERHUB_REPO}:${IMAGE_TAG}"
        LATEST_IMAGE = "${DOCKERHUB_REPO}:latest"
    }

    options {
        timeout(time: 30, unit: 'MINUTES')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'Project-3', url: 'https://github.com/ChibuzoNE/proj-mdp-152-155.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh '''
                        docker build -t $FULL_IMAGE -t $LATEST_IMAGE .
                    '''
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push $FULL_IMAGE
                        docker push $LATEST_IMAGE
                        docker logout
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh '''
                        sed -i "s|image: .*|image: $FULL_IMAGE|g" k8s-deploy/k8s-deployment.yml
                        /usr/local/bin/kubectl apply -f k8s-deploy/k8s-deployment.yml
                    '''
                }
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
