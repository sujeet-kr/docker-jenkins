#Creating an image for Jenkins server with predefined jobs
#Also plugins are installed automatically

FROM jenkins/jenkins:lts
MAINTAINER Sujeet Kumar <sujeet.kr@hotmail.com>

USER root

RUN apt-get update
RUN apt-get install -y rpm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    curl libunwind8 gettext apt-transport-https && \
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
    mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg && \
    sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-stretch-prod stretch main" > /etc/apt/sources.list.d/dotnetdev.list' && \
    apt-get update

# Install the .Net Core framework, set the path, and show the version of core installed.
RUN apt-get install -y dotnet-sdk-2.1.103 && \
    export PATH=$PATH:$HOME/dotnet && \
    dotnet --version

USER jenkins

# Install plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

#initialize environment variables
ENV JENKINS_USER jenkins
ENV JENKINS_PASS jenkins
ENV GITLAB_ACCESS_TOKEN ""

#All the job names that needs to be created in jenkins
COPY automation_test_poc_job_config.xml /automation_test_poc_job_config.xml

# Copy the scripts to be executed
COPY start_sshd.groovy /usr/share/jenkins/ref/init.groovy.d/1_start_sshd.groovy
COPY default_user.groovy /usr/share/jenkins/ref/init.groovy.d/2_default_user.groovy
COPY add_gitlab_token.groovy /usr/share/jenkins/ref/init.groovy.d/3_add_gitlab_token.groovy
COPY automation_test_poc_job_config.groovy /usr/share/jenkins/ref/init.groovy.d/5_automation_test_poc_job_config.groovy