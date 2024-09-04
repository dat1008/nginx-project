pipeline {
    agent any

    environment {
        IMAGE_NAME = "datzofgk/nginx-image"
        IMAGE_TAG = "v${BUILD_NUMBER}"
    }

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
                    echo "Building Docker image with tag: ${IMAGE_TAG}"
                    sh """
                        docker build --cache-from ${IMAGE_NAME}:latest -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_NAME}:latest .
                    """
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    echo "Running tests on Docker container with tag: ${IMAGE_TAG}"
                    sh "docker run --rm ${IMAGE_NAME}:${IMAGE_TAG} nginx -t"
                }
            }
        }
        stage('Push to Docker Hub') {
            steps {
                script {
                    echo "Pushing Docker image to Docker Hub with tag: ${IMAGE_TAG}"
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials-id') {
                        sh """
                            docker push ${IMAGE_NAME}:${IMAGE_TAG}
                            docker push ${IMAGE_NAME}:latest
                        """
                    }
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    echo "Deploying Docker container with tag: ${IMAGE_TAG}"
                    sh """
                        ANSIBLE_HOST_KEY_CHECKING=False
                        ansible-playbook deploy.yml --private-key=/var/jenkins_home/id_rsa -i inventory -u vsi -e "image_tag=${IMAGE_TAG}"
                    """
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
