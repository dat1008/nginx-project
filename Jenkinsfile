pipeline {
    agent any

    environment {
        IMAGE_NAME = "datzofgk/nginx-image"
        IMAGE_TAG = "v${BUILD_NUMBER}"
        NEXUS_REPO = "10.10.3.67:1008/docker-hosted/${IMAGE_NAME}"
    }

    stages {
        stage('Cleanup Old Images') {
            steps {
                script {
                    echo 'Cleaning up old Docker images'
                    try {
                        sh '''
                            # Xóa image cũ từ Docker Hub và Nexus (nếu tồn tại)
                            docker rmi ${IMAGE_NAME}:latest || true
                            docker rmi ${NEXUS_REPO}:latest || true
                        '''
                    } catch (Exception e) {
                        echo "Cleanup failed: ${e.message}, but it's okay to proceed."
                    }
                }
            }
        }

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

        stage('Push to Docker Hub') {
            steps {
                script {
                    echo 'Pushing Docker image to Docker Hub'
                    try {
                        docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials-id') {
                            sh '''
                                docker push ${IMAGE_NAME}:${IMAGE_TAG}
                            '''
                        }
                    } catch (Exception e) {
                        error "Push failed: ${e.message}"
                    }
                }
            }
        }

        stage('Tag and Push to Nexus') {
            steps {
                script {
                    echo 'Tagging and Pushing Docker image to Nexus'
                    try {
                        docker.withRegistry('http://10.10.3.67:1008/', 'nexus-credentials-id') {
                            sh '''
                                docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${NEXUS_REPO}:${IMAGE_TAG}
                                docker push ${NEXUS_REPO}:${IMAGE_TAG}
                            '''
                        }
                    } catch (Exception e) {
                        error "Push to Nexus failed: ${e.message}"
                    }
                }
            }
        }

        stage('Cleanup') {
            steps {
                script {
                    echo 'Cleaning up local Docker images'
                    try {
                        sh '''
                            docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true
                            docker rmi ${NEXUS_REPO}:${IMAGE_TAG} || true
                        '''
                    } catch (Exception e) {
                        echo "Cleanup failed: ${e.message}, but it's okay to proceed."
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
