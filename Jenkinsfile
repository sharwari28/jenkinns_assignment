pipeline {
    agent any

    environment {
        // Change this to your exact Docker Hub username
        DOCKER_USER     = 'your_dockerhub_username'
        IMAGE_NAME      = 'spring-boot-app'
        IMAGE_TAG       = "${BUILD_NUMBER}"
        CONTAINER_NAME  = 'my-running-app'
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Pulls down the code from your sharwari28/jenkinns_assignment repo
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG} ."
                sh "docker tag ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_USER}/${IMAGE_NAME}:latest"
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER_ID')]) {
                    sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER_ID --password-stdin"
                    sh "docker push ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker push ${DOCKER_USER}/${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Deploy & Run Container') {
            steps {
                script {
                    sh "docker stop ${CONTAINER_NAME} || true"
                    sh "docker rm ${CONTAINER_NAME} || true"
                    sh "docker run -d -p 3000:3000 --name ${CONTAINER_NAME} ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('Sanity Check') {
            steps {
                sleep time: 10, unit: 'SECONDS'
                sh "curl -I http://localhost:3000/index.html"
            }
        }
    }

    post {
        always {
            sh "docker image prune -f"
        }
    }
}
