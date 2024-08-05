# Example Voting App

A simple distributed application running across multiple Docker containers.

## Getting started

Download [Docker Desktop](https://www.docker.com/products/docker-desktop) for Mac or Windows. [Docker Compose](https://docs.docker.com/compose) will be automatically installed. On Linux, make sure you have the latest version of [Compose](https://docs.docker.com/compose/install/).

This solution uses Python, Node.js, .NET, with Redis for messaging and Postgres for storage.

Run in this directory to build and run the app:

```shell
docker compose up
```

The `vote` app will be running at [http://localhost:5000](http://localhost:5000), and the `results` will be at [http://localhost:5001](http://localhost:5001).

Alternately, if you want to run it on a [Docker Swarm](https://docs.docker.com/engine/swarm/), first make sure you have a swarm. If you don't, run:

```shell
docker swarm init
```

Once you have your swarm, in this directory run:

```shell
docker stack deploy --compose-file docker-stack.yml vote
```

## Run the app in Kubernetes

The folder k8s-specifications contains the YAML specifications of the Voting App's services.

Run the following command to create the deployments and services. Note it will create these resources in your current namespace (`default` if you haven't changed it.)

```shell
kubectl create -f k8s-specifications/
```

The `vote` web app is then available on port 31000 on each host of the cluster, the `result` web app is available on port 31001.

To remove them, run:

```shell
kubectl delete -f k8s-specifications/
```


## Jenkins Pipeline
* Setting up essential tools for pipeline

*Jenkins

Install and setup jenkins on cloud instance:
```shell
#!/bin/bash
# Install OpenJDK 17 JRE Headless
sudo apt install openjdk-17-jre-headless -y
# Download Jenkins GPG key
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
# Add Jenkins repository to package manager sources
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
/etc/apt/sources.list.d/jenkins.list > /dev/null
# Update package manager repositories
sudo apt-get update
# Install Jenkins
sudo apt-get install jenkins -y
```

Save this script in a file, for example, install_jenkins.sh, and make it executable using:
```shell
chmod +x install_jenkins.sh
```
Then, you can run the script using:
```shell
./install_jenkins.sh
```
This script will automate the installation process of OpenJDK 17 JRE Headless and Jenkins.

Install Trivy on same instance:
```shell
sudo apt-get install wget apt-transport-https gnupg
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy -y
```
Save this script in a file, for example, install_trivy.sh, and make it executable using:
```shell
chmod +x install_trivy.sh
```
Then, you can run the script using:
```shell
./install_trivy.sh
```

*Nexus

Create two more cloud instances for SonarQube and Nexus and install docker on SonarQube and Nexus instances as well by running install_docker.sh. And follow the steps below to setup Nexus.

Create Nexus using docker container on Nexus' cloud instance:

To create a Docker container running Nexus 3 and exposing it on port 8081, you can use the following command:

```shell
docker run -d --name nexus -p 8081:8081 sonatype/nexus3:latest 
```

After running this command, Nexus will be accessible on your host machine at http://IP:8081. 
 
To get Nexus initial password follow this steps:
1. Get Container ID: 
You need to find out the ID of the Nexus container. You can do this by running: 

```shell
docker ps 
```

This command lists all running containers along with their IDs, among other information.

2. Access Container's Bash Shell: 
Once you have the container ID, you can execute the docker exec command to access the container's bash shell: 

```shell
docker exec -it <container_ID> /bin/bash
```

Replace <container_ID> with the actual ID of the Nexus container.
3. Navigate to Nexus Directory: 
Inside the container's bash shell, navigate to the directory where Nexus stores its configuration: 

```shell
cd sonatype-work/nexus3
```

4. View Admin Password: 
Finally, you can view the admin password by displaying the contents of the admin.password file: 

```shell
cat admin.password
```

5. Exit the Container Shell: Once you have retrieved the password, you can exit the container's bash shell: 

```shell
exit 
```

This process allows you to access the Nexus admin password stored within the container. 
Make sure to keep this password secure, as it grants administrative access to your Nexus instance.

*SonarQube

After installing docker to run SonarQube in a Docker container run the command:

```shell
docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
```

This command will download the sonarqube:lts-community Docker image from Docker Hub if it's not already available locally. Then, it will create a container named "sonar"
from this image, running it in detached mode (-d flag) and mapping port 9000 on the host machine to port 9000 in the container (-p 9000:9000 flag).

Access SonarQube by opening a web browser and navigating to http://VmIP:9000


* CI/CD Pipeline

For the pipeline first Install the below Plugins in Jenkins:
1) Eclipse Temurin Installer
2) Pipeline Maven Integration
3) Config File Provider
4) SonarQube Scanner
5) Kubernetes CLI
6) Kubernetes
7) Docker 
8) Docker Pipeline Step

After installing these plugins, you may need to configure them. This typically involves setting up credentials, configuring paths, and specifying options in Jenkins global configuration or individual job configurations. 
Each plugin usually comes with its own set of documentation to guide you through the configuration process.
After configuring the above plugins I will now brief you about pipeline stages: There are 13/14 stages in a production pipeline which will be:
1) Git Checkout:

This stage will pull the repo.

2) Compile:

This stage will compile our source code.

3) Test:

This is will run test cases.

4) File system scan:

This stage is to check if there is any vulnerabilities in the dependencies using 3rd party tool trivy. It will generate a report and export it inside a separate file.

5) SonarQube Analysis:

This stage will perform a SonarQube analysis.

6) Quality Gate:

This stage will perform quality gate.

7) Build:

This stage will build our compiled source code.

8) Publish to Nexus:

This stage will pulish our build artifact to Nexus. 

9) Build and Tag Docker Image:

This stage will Build and tag our applications docker image.

10) Docker Image Scan:

This stage will scan our docker image via trivy.

11) Push Docker Image:

This stage will push the docker image to central image repository such as DockerHub, AWS ECR etc.

12) Deploy to Kubernetes:

This stage will deploy our application on to our cluster.

13) Verify Deployment

## Monitoring and Logging
![Dashboard].(Monitoring and Logging.png)

## Security Measures 
Assigned IAM roles with minimum privileges to cluster instance.
Created a Service account for Jenkins and bonded that Service account with a role with least permissions that are necessary for automated deployment of our application.
Can encrypt the database for data at rest and use tls/ssl certificates for data in transit to secure the application data.


## Architecture

![Architecture diagram](architecture.excalidraw.png)

* A front-end web app in [Python](/vote) which lets you vote between two options
* A [Redis](https://hub.docker.com/_/redis/) which collects new votes
* A [.NET](/worker/) worker which consumes votes and stores them in…
* A [Postgres](https://hub.docker.com/_/postgres/) database backed by a Docker volume
* A [Node.js](/result) web app which shows the results of the voting in real time

## Notes

The voting application only accepts one vote per client browser. It does not register additional votes if a vote has already been submitted from a client.

This isn't an example of a properly architected perfectly designed distributed app... it's just a simple
example of the various types of pieces and languages you might see (queues, persistent data, etc), and how to
deal with them in Docker at a basic level.
