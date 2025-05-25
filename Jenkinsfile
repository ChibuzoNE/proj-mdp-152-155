pipeline {
    agent any

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
                script {
                    sh 'docker build -t calc-app:latest .'
                }
            }
        }

        stage('Run Container') {
            steps {
                script {
                    sh '''
                        # Stop and remove existing container if it exists
                        if [ $(docker ps -aq -f name=calc-app-container) ]; then
                            docker stop calc-app-container || true
                            docker rm calc-app-container || true
                        fi

                        # Run new container
                        docker run -d --name calc-app-container -p 8081:8080 calc-app:latest
                    '''
                }
            }
        }
        stage('Push to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                        sh '''
                            echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin
        
                            # Tag the image
                            docker tag calc-app:latest chibuzone/calc-app:latest
        
                            # Push to Docker Hub
                            docker push chibuzone/calc-app:latest
                        '''
                    }
                }
            }
        }

    }

    post {
        failure {
            echo 'Pipeline failed - check logs for details'
        }
    }
}
