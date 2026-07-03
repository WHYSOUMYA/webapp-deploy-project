pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
        IMAGE_NAME = 'yourdockerhubuser/webapp'
        IMAGE_TAG = "${BUILD_NUMBER}"
        SSH_CREDENTIALS = credentials('ec2-ssh-key')
        EC2_HOST = credentials('ec2-host')
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/yourusername/your-repo.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube-server') {
                    sh 'sonar-scanner -Dsonar.projectKey=webapp-deploy -Dsonar.sources=./app'
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_NAME}:latest ./app"
            }
        }

        stage('Trivy Scan') {
            steps {
                sh "trivy image --severity HIGH,CRITICAL --exit-code 0 --format table ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                sh "echo ${DOCKERHUB_CREDENTIALS_PSW} | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin"
                sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                sh "docker push ${IMAGE_NAME}:latest"
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent(credentials: ['ec2-ssh-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ec2-user@${EC2_HOST} '
                            docker pull ${IMAGE_NAME}:latest &&
                            docker stop webapp || true &&
                            docker rm webapp || true &&
                            docker run -d --restart unless-stopped -p 80:5000 --name webapp ${IMAGE_NAME}:latest
                        '
                    """
                }
            }
        }
    }

    post {
        always {
            sh 'docker logout'
        }
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed. Check logs for the failing stage.'
        }
    }
}
