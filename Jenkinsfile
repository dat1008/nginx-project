pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm  // Thực hiện checkout mã nguồn từ Git
                sh 'ls -lah'
            }
        }
        stage('Build') {
            steps {
                script {
                    try {
                        sh 'docker build --pull -t nginx-image .'  // Sử dụng --pull để đảm bảo lấy image mới nhất
                    } catch (Exception e) {
                        error "Build failed: ${e.message}"
                    }
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    try {
                        sh 'ansible-playbook deploy.yml'
                    } catch (Exception e) {
                        error "Deployment failed: ${e.message}"
                    }
                }
            }
        }
    }

    post {
        always {
            sh 'docker system prune -f'  // Dọn dẹp các docker resources không sử dụng
            cleanWs()  // Xóa workspace để tiết kiệm không gian
        }
        success {
            echo 'Build and deployment succeeded!'
        }
        failure {
            echo 'Build or deployment failed!'
        }
    }
}
