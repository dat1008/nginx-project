pipeline {
    agent any

    environment {
        IMAGE_NAME = "datzofgk/nginx-image"
        IMAGE_TAG = "v${BUILD_NUMBER}"
        NEXUS_REPO = "10.10.3.67:1008/docker-hosted/${IMAGE_NAME}"
        SONARQUBE_SERVER = 'sonarqube' 
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

        stage('SonarQube Scan and Quality Gate') {
            steps {
                script {
                    echo 'Running SonarQube Scan and waiting for Quality Gate'
                    withSonarQubeEnv(SONARQUBE_SERVER) {
                        try {
                            sh '''
                                mvn clean verify sonar:sonar -Dsonar.projectKey=nginx -Dsonar.host.url=http://10.10.3.67:9000/ -Dsonar.login=${sonarqube}
                            ''' 
                        } catch (Exception e) {
                            error "SonarQube Scan failed: ${e.message}"
                        }
                    }

                    timeout(time: 1, unit: 'HOURS') {
                        try {
                            waitForQualityGate abortPipeline: true
                        } catch (Exception e) {
                            error "Quality Gate failed: ${e.message}"
                        }
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
