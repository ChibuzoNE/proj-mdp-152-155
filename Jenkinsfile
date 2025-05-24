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
        stage('Build & Run') {
            steps {
                script {
                    docker.build('calc-app:latest').run(
                        '--name calc-app-container -p 8081:8080'
                    )
                }
            }
        }
    }
}
