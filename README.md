## Using-Jenkins-to-build-Docker-image-and-deploy-app-on-AWS-Elastic-Beanstalk

### :point_right: **In this project, I used Jenkins to build and push a Docker image to Docker Hub and to deploy my application on AWS Elastic Beanstalk (infrastructure created with Terraform).** :point_left:

### **Steps:**

- [x] I **create**d the Node.js **app files** and the **Dockerfile** for my application and this remote repository. (app.js, package.json, package-lock.json, Dockerfile)
    
- [x] I **create**d the **AWS Elastic Beanstalk** infrastructure with **Terraform** and **ran Jenkins** in a Docker container from a **custom Dockerfile** with the following commands: _docker build -t <image_name> ., docker run -it -dp 8080:8080 -p 50000:50000 -v /var/run/docker.sock:/var/run/docker.sock -v jenkins_home:/var/jenkins_home <image_name>_
(These files should reside in a separate repo, but to simplify things, they can be found here.)

- [x] After that I created the  **Dockerrun.aws.json** file that is needed for deploying my app on AWS Elastic Beanstalk.

- [x] In Jenkins, I **install**ed the necessary **plugins** for my project, like AWS Credentials and Pipeline Utility Steps.
I also **create**ed the needed Credentials for logins: for **Docker Hub**, I used the **Token** and for **AWS**, I used **Access Keys** I generated on those platforms earlier.

- [x] I **create**d the **Jenkinsfile** for building and pushing the Docker image to Docker Hub and deploying my application on AWS Elastic Beanstalk. Furthermore, I used the above-mentioned Credentials to keep my login credentials secret.

- [x] After that I triggered my **Jenkins pipeline** with a change in this remote repository.
      
- [x] I could see my newly created Docker image on Docker Hub and could see my **application running** on the **domain** Elastic Beanstalk has provided.