pipeline {
    agent any

    stages {
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
                            ANSIBLE_HOST_KEY_CHECKING=False
                            ansible-playbook deploy.yml --private-key=/var/jenkins_home/id_rsa -i inventory -u vsi
                        '''
                    } catch (Exception e) {
                        error "Deployment failed: ${e.message}"
                    }
                }
            }
        }
    }
}
