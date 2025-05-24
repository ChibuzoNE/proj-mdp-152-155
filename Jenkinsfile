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
                sh 'docker build -t calc-app:latest .'
            }
        }
        stage('Run Container') {
            steps {
                sh 'docker stop calc-app-container || true'
                sh 'docker rm calc-app-container || true'
                sh 'docker run -d --name calc-app-container -p 8081:8080 calc-app:latest'
            }
        }
    }
}
