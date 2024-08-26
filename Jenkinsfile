pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
                sh 'ls -lah'
            }
        }
        stage('Build') {
            steps {
                script {
                    echo 'Building Docker image with cache...'
                    try {
                        sh '''
                            docker pull nginx-image:v1 || true
                            docker build --cache-from nginx-image:v1 -t nginx-image:v1 .
                        '''
                    } catch (Exception e) {
                        error "Build failed: ${e.message}"
                    }
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    echo 'Running tests on Docker container...'
                    try {
                        sh '''
                            docker run --rm nginx-image:v1 nginx -t
                        '''
                    } catch (Exception e) {
                        error "Test failed: ${e.message}"
                    }
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    echo 'Deploying Docker container with Ansible...'
                    try {
                        // Sử dụng ansible-playbook với file deploy.yml đã được cập nhật
                        sh '''
                            ansible-playbook deploy.yml --private-key=~/.ssh/id_rsa
                        '''
                    } catch (Exception e) {
                        error "Deployment failed: ${e.message}"
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up Docker system and workspace...'
            sh 'docker system prune -f'
            cleanWs()
        }
        success {
            echo 'Build, test, and deployment succeeded!'
        }
        failure {
            echo 'Build, test, or deployment failed!'
        }
    }
}
