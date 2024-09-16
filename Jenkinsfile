pipeline {
    agent any

    environment {
        IMAGE_NAME = "datzofgk/nginx-image"
        IMAGE_TAG = "v${BUILD_NUMBER}"
        NEXUS_REPO = "10.10.3.67:1008/docker-hosted/${IMAGE_NAME}"
    }

    stages {
        stage('Build') {
            steps {
                script {
                    echo 'Building Docker image with updated HTML'
                    sh '''
                        docker build --cache-from ${IMAGE_NAME}:latest -t ${IMAGE_NAME}:${IMAGE_TAG} .
                    '''
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    echo 'Pushing Docker image to Docker Hub'
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials-id') {
                        sh 'docker push ${IMAGE_NAME}:${IMAGE_TAG}'
                    }
                }
            }
        }

        stage('Tag and Push to Nexus') {
            steps {
                script {
                    echo 'Tagging and Pushing Docker image to Nexus'
                    docker.withRegistry('http://10.10.3.67:1008/', 'nexus-credentials-id') {
                        sh '''
                            docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${NEXUS_REPO}:${IMAGE_TAG}
                            docker push ${NEXUS_REPO}:${IMAGE_TAG}
                        '''
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    echo 'Deploying Docker container'
                    sh '''
                        ANSIBLE_HOST_KEY_CHECKING=False
                        ansible-playbook deploy.yml --private-key=/var/jenkins_home/id_rsa -i inventory -u vsi -e "image_tag=${IMAGE_TAG}" 
                    '''
                }
            }
        }
    }
}
