pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                sh 'ls -lah'
                git 'https://github.com/DAT1008-ZOFGK/nginx-project'
                
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
