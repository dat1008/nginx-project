pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/DAT1008-ZOFGK/nginx-project'
                sh 'ls -lah'
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
