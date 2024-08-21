pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'ls -lah'
            }
        }
        stage('Build') {
            steps {
                script {
                    try {
                        sh '''
                            docker pull nginx-image || true
                            docker build --cache-from nginx-image -t nginx-image .
                        '''
                    } catch (Exception e) {
                        error "Build failed: ${e.message}"
                    }
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    try {
                        sh 'ansible-playbook deploy.yml'
                    } catch (Exception e) {
                        error "Deployment failed: ${e.message}"
                    }
                }
            }
        }
    }

    post {
        always {
            sh 'docker system prune -f'
            cleanWs()
        }
        success {
            echo 'Build and deployment succeeded!'
        }
        failure {
            echo 'Build or deployment failed!'
        }
    }
}
