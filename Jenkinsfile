pipeline {
    agent any
    environment {
        AWS_DEFAULT_REGION = 'eu-north-1'
        DOCKER_IMAGE_NAME = 'pinteresz/jenkins_docker_image:latest'
        ELASTIC_BEANSTALK_ENV_NAME = 'esz-app-env'
        S3_BUCKET_NAME = 'elasticbeanstalk-eu-north-1-975007556507'
        GITHUB_REPO_URL = 'https://github.com/pinteresz/Using-Jenkins-to-build-Docker-image-and-deploy-app-on-AWS-Elastic-Beanstalk'
        ZIP_PACKAGE_NAME = 'esz-app.zip'
        APPLICATION_NAME = 'esz-app'
        def timestamp = new Date().format("yyyyMMddHHmmss")
        ELASTIC_BEANSTALK_VERSION_LABEL = "v${timestamp}"  // Timestamp-based version label
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
         stage('Clone GitHub Repository into Jenkins workspace') {
            steps {
                git branch: 'main', url: GITHUB_REPO_URL
            }
        }
        stage('Package Application Files') {
            steps {
                script {
                    // Use Groovy to create a ZIP archive of the application files
                    sh "rm -f $ZIP_PACKAGE_NAME" // Remove if the file exists
                    zip zipFile: "$ZIP_PACKAGE_NAME", archive: false, dir: '.' 
                }
            }
        }
        stage('Login to AWS, upload zip to S3 bucket and deploy on Elastic Beanstalk') {
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws_credentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    // Upload the ZIP archive to S3
                    sh "aws s3 cp $ZIP_PACKAGE_NAME s3://$S3_BUCKET_NAME/"

                    // Create a new Elastic Beanstalk application version
                    sh "aws elasticbeanstalk create-application-version --application-name $APPLICATION_NAME --version-label $ELASTIC_BEANSTALK_VERSION_LABEL --source-bundle S3Bucket=$S3_BUCKET_NAME,S3Key=$ZIP_PACKAGE_NAME"
                   
                    // Update the Elastic Beanstalk environment to use the new application version
                    sh "aws elasticbeanstalk update-environment --environment-name $ELASTIC_BEANSTALK_ENV_NAME --version-label $ELASTIC_BEANSTALK_VERSION_LABEL"
                }
            }
        }
    }
   post {
        always {
            // Logout from Docker Hub
            sh 'docker logout'

            // Logout from AWS
            sh 'aws configure set aws_access_key_id ""'
            sh 'aws configure set aws_secret_access_key ""'
            sh 'aws configure set region ""'            
        }
    }
}
