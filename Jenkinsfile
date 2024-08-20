pipeline {
    agent any 
    stages {
        stage('Build') {
            steps {
                script {
                    docker.build('nginx-image')
                }
            }
        }
        stage('Deploy') {
            steps {
                ansiblePlaybook(
                    playbook: 'deploy.yml',
                    inventory: 'inventory.ini'
                )
            }
        }
    }
}
