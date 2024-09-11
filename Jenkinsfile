pipeline {
    agent any

    environment {
        IMAGE_NAME = "datzofgk/nginx-image"
        IMAGE_TAG = "v${BUILD_NUMBER}"
    }

    stages {
        stage('Build') {
            steps {
                script {
                    echo 'Building Docker image'
                    try {
                        sh '''
                            docker build --cache-from ${IMAGE_NAME}:latest -t ${IMAGE_NAME}:${IMAGE_TAG} .
                        '''
                    } catch (Exception e) {
                        error "Build failed: ${e.message}"
                    }
                }
            }
        }
        stage('Tag and Push to Nexus') {
            steps {
                script {
                    echo 'Tagging and Pushing Docker image to Nexus'
                    try {
                        sh '''
                            docker tag ${IMAGE_NAME}:${IMAGE_TAG} 10.10.3.67:1008/docker-hosted/${IMAGE_NAME}:${IMAGE_TAG}
                            docker push 10.10.3.67:1008/docker-hosted/${IMAGE_NAME}:${IMAGE_TAG}
                        '''
                    } catch (Exception e) {
                        error "Tagging or Push failed: ${e.message}"
                    }
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    echo 'Deploying Docker container'
                    try {
                        sh '''
                            ANSIBLE_HOST_KEY_CHECKING=False
                            ansible-playbook deploy.yml --private-key=/var/jenkins_home/id_rsa -i inventory -u vsi -e "image_tag=${IMAGE_TAG}" 
                        '''
                    } catch (Exception e) {
                        error "Deployment failed: ${e.message}"
                    }
                }
            }
        }
    }
}
