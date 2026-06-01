pipeline {
    agent any

    environment {
        // Replace with your actual Docker Hub username and desired repository name
        DOCKER_USER     = 'your_dockerhub_username'
        IMAGE_NAME      = 'spring-boot-app'
        IMAGE_TAG       = "${BUILD_NUMBER}"
        CONTAINER_NAME  = 'my-running-app'
    }

    stages {
        stage('Checkout') {
            steps {
                // Pull code from your repository (implicitly handled if using a Multibranch Pipeline)
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Multi-stage Docker Image...'
                // Builds the image using the multi-stage Dockerfile present in your repository root
                sh "docker build -t ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG} ."
                sh "docker tag ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_USER}/${IMAGE_NAME}:latest"
            }
        }

        stage('Push to DockerHub') {
            steps {
                echo 'Logging into DockerHub and pushing image...'
                // Securely binds Docker Hub credentials using Jenkins Credentials Provider
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER_ID')]) {
                    sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER_ID --password-stdin"
                    sh "docker push ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker push ${DOCKER_USER}/${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Deploy & Run Container') {
            steps {
                echo 'Deploying application container locally on port 3000...'
                script {
                    // Stop and remove existing container if it is already running
                    sh "docker stop ${CONTAINER_NAME} || true"
                    sh "docker rm ${CONTAINER_NAME} || true"
                    
                    // Launch the newly built container
                    sh "docker run -d -p 3000:3000 --name ${CONTAINER_NAME} ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('Sanity Check') {
            steps {
                echo 'Verifying application status...'
                // Give the Spring Boot app 10 seconds to fully initialize before curling
                sleep time: 10, unit: 'SECONDS'
                sh "curl -I http://localhost:3000/index.html"
            }
        }
    }

    post {
        always {
            echo 'Cleaning up dangling local Docker images...'
            // Cleans up unused build images to save disk space on the Jenkins host
            sh "docker image prune -f"
        }
        success {
            echo 'Pipeline completed successfully! Application is live at http://localhost:3000/index.html'
        }
        failure {
            echo 'Pipeline failed. Please inspect the stage logs above for error details.'
        }
    }
}

