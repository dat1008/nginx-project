pipeline {
    agent any

    environment {
        IMAGE_NAME = "datzofgk/nginx-image"
        IMAGE_TAG = "v${BUILD_NUMBER}"
        NEXUS_REPO = "10.10.3.67:1008/docker-hosted/${IMAGE_NAME}"
        HASH_FILE = "hash.txt"
    }

    stages {
        stage('Calculate Hash') {
            steps {
                script {
                    echo 'Calculating hash of index.html'
                    sh '''
                        # Compute the hash of index.html
                        md5sum ./src/index.html | awk '{ print $1 }' > ${HASH_FILE}
                    '''
                }
            }
        }

        stage('Check if index.html has changed') {
            steps {
                script {
                    if (fileExists(HASH_FILE)) {
                        def previousHash = readFile(HASH_FILE).trim()
                        def currentHash = sh(script: 'md5sum ./src/index.html | awk \'{ print $1 }\'', returnStdout: true).trim()
                        if (previousHash == currentHash) {
                            echo 'index.html has not changed. Skipping push, tag, and deploy stages.'
                            currentBuild.result = 'SUCCESS'
                            return
                        }
                    }
                }
            }
        }

        stage('Build') {
            steps {
                script {
                    echo 'Building Docker image'
                    sh '''
                        docker build --cache-from ${IMAGE_NAME}:latest -t ${IMAGE_NAME}:${IMAGE_TAG} .
                    '''
                }
            }
        }

        stage('Push to Docker Hub') {
            when {
                expression {
                    fileExists(HASH_FILE) && readFile(HASH_FILE).trim() != sh(script: 'md5sum ./src/index.html | awk \'{ print $1 }\'', returnStdout: true).trim()
                }
            }
            steps {
                script {
                    echo 'Pushing Docker image to Docker Hub'
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials-id') {
                        sh '''
                            docker push ${IMAGE_NAME}:${IMAGE_TAG}
                        '''
                    }
                }
            }
        }

        stage('Tag and Push to Nexus') {
            when {
                expression {
                    fileExists(HASH_FILE) && readFile(HASH_FILE).trim() != sh(script: 'md5sum ./src/index.html | awk \'{ print $1 }\'', returnStdout: true).trim()
                }
            }
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
            when {
                expression {
                    fileExists(HASH_FILE) && readFile(HASH_FILE).trim() != sh(script: 'md5sum ./src/index.html | awk \'{ print $1 }\'', returnStdout: true).trim()
                }
            }
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

        stage('Update Hash') {
            when {
                expression {
                    fileExists(HASH_FILE) && readFile(HASH_FILE).trim() != sh(script: 'md5sum ./src/index.html | awk \'{ print $1 }\'', returnStdout: true).trim()
                }
            }
            steps {
                script {
                    echo 'Updating hash of index.html'
                    sh '''
                        # Save the current hash to the hash file
                        md5sum ./src/index.html | awk '{ print $1 }' > ${HASH_FILE}
                    '''
                }
            }
        }
    }
}
