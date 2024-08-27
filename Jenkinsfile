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
                        docker.image('datzofgk/nginx-image:v1').pull() 
                    } catch (Exception e) {
                        echo "Image pull failed: ${e.message}. Proceeding to build without cache."
                    }
                    def customImage = docker.build("datzofgk/nginx-image:v1", "--cache-from=datzofgk/nginx-image:v1 .") 
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    echo 'Running tests on Docker container...'
                    try {
                        def customImage = docker.image("datzofgk/nginx-image:v1")
                        customImage.inside {
                            sh 'nginx -t'
                        }
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
                            def customImage = docker.image("datzofgk/nginx-image:v1")
                            customImage.push()
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
                            ansible-playbook -i inventory.ini deploy.yml --private-key=~/.ssh/id_rsa -i 10.10.3.70
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
