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
                            docker pull datzofgk/nginx-image:v1 || true
                            docker build --cache-from datzofgk/nginx-image:v1 -t datzofgk/nginx-image:v1 .
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
                            docker run --rm datzofgk/nginx-image:v1 nginx -t
                        '''
                    } catch (Exception e) {
                        error "Test failed: ${e.message}"
                    }
                }
            }
        }
        stage('Push to Docker Hub') {
            steps {
                script {
                    echo 'Pushing Docker image to Docker Hub...'
                    try {
                        docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials-id') {
                            sh '''
                                docker push datzofgk/nginx-image:v1
                            '''
                        }
                    } catch (Exception e) {
                        error "Push failed: ${e.message}"
                    }
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    echo 'Deploying Docker container with Ansible...'
                    try {
                        sh '''
                            ansible-playbook deploy.yml --private-key=/root/.ssh/id_rsa -i inventory -vvvv
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
