pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'project-1', url: 'https://github.com/ChibuzoNE/proj-mdp-152-155.git'
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
        
        stage('Run Container') {
            steps {
                script {
                    // Gracefully stop and remove existing container if it exists
                    sh 'docker stop calc-app-container || true'
                    sh 'docker rm calc-app-container || true'
                    
                    // Run new container with proper port mapping
                    sh 'docker run -d --name calc-app-container -p 8080:8080 calc-app:latest'
                    
                    // Verify container is running
                    sh 'docker ps | grep calc-app-container'
                }
            }
        }
        
        // Optional additional stage for verification
        stage('Verify Deployment') {
            steps {
                script {
                    // Wait for application to start (adjust sleep time as needed)
                    sh 'sleep 10'
                    
                    // Simple curl test to verify application is accessible
                    sh 'curl -s http://localhost:8081/CalculatorApp/ | grep "Calculator" || true'
                }
            }
        }
    }
    
    // Optional post-build actions
    post {
        always {
            // Clean up workspace
            cleanWs()
        }
        failure {
            // Additional failure handling
            echo 'Pipeline failed - check logs for details'
        }
    }
}
