pipeline {
    agent any
    environment {
        DOCKER_IMAGE_NAME = 'pinteresz/jenkins_docker_image:latest'
    }
    stages {
        stage('Build Docker image') {
            steps {
                sh "docker build -t $DOCKER_IMAGE_NAME ."
            }
        }
        stage('Login to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub_credentials', passwordVariable: 'password', usernameVariable: 'username')]) {
                    sh "docker login -u $username -p $password"
                }
            }
        }
        stage('Push image to Docker Hub') {
            steps {
                sh "docker push $DOCKER_IMAGE_NAME"
            }
        }
         
    }
    post {
        always {
            // Logout from Docker Hub
            sh 'docker logout'
        }
    }
}