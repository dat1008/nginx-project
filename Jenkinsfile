pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/dat1008-zofgk/nginx-project.git'
            }
        }
        stage('Build') {
            steps {
                sh 'docker build -t nginx-image .'
            }
        }
        stage('Deploy') {
            steps {
                sh 'ansible-playbook deploy.yml'
            }
        }
    }
}
