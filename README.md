NIAID Learning Center  
============================

# Table of Contents 
1. [Quick View](#quick-view)  
2. [Staff](#staff)
3. [Clone Repo](#cloning-the-repo)
4. [Work Structure](#work-structure)  
  a. Protected Branches  
  b. Workflow  
  c. Stack Overview  
5. [Dev Environment](#dev-environment)
6. [Monarch QA/Prod](#monarch-environment)
7. [Infrastructure Setup](#infrastructure-setup)


# Log into Artifactory
docker login platform-docker.artifactory.niaid.nih.gov

# run the following to get the docker to run locally
docker build .

# run this instead
sh start.sh