pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')  // Jenkins secret
        IMAGE_NAME = 'calc-app'
        IMAGE_TAG = "${env.BUILD_NUMBER}"  // Unique tag per build
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
                    // Option 1: Run with explicit sudo (requires sudo permissions for Jenkins user)
                    // sh 'sudo docker build -t calc-app:latest .'
                    
                    // Option 2: Better solution - ensure Jenkins user is in docker group
                    sh '''
                        # Add Jenkins user to the docker group if not already
                        sudo usermod -aG docker jenkins || true
                        # Build the image
                        docker build -t calc-app:latest .
                    '''
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    sh '''
                        echo "$DOCKERHUB_CREDENTIALS_PSW" | docker login -u "$DOCKERHUB_CREDENTIALS_USR" --password-stdin
                        docker push $FULL_IMAGE
                        docker push $LATEST_IMAGE
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Update image in K8s deployment YAML dynamically before applying
                    sh '''
                        sed -i "s|image: .*|image: $FULL_IMAGE|g" project-3/k8s-deploy/k8s-deployment.yaml
                        kubectl apply -f project-3/k8s/deployment.yaml
                        kubectl apply -f project-3/k8s/service.yaml
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
