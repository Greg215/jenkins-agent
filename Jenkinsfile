#!/usr/bin/env groovy

def notify_channel = "#jenkins-notify"
def label = "jenkins-vg-agent"
def aws_region = "ap-southeast-1"
def ecr_repo = "public.ecr.aws/d2n9w0q9"

if(currentBuild.getPreviousBuild()){
    env.PREVIOUS_BUILD_RESULT = currentBuild.getPreviousBuild().getResult()
    echo "PREVIOUS BUILD RESULT: ${env.PREVIOUS_BUILD_RESULT}"
} else {
    env.PREVIOUS_BUILD_RESULT = "NONE"
}

String getChangeSet(String input){
    def var1 = sh(script: "git whatchanged -n 1  | cut -f2 | grep '^${input}' | wc -l", returnStdout: true).trim()
    var1
}

int getChangeSetOnLocalFolder(String input){
    def var1 = sh(script: "find ${input} 2>/dev/null | wc -l", returnStdout: true).trim()
    var1.toInteger()
}

def build_info = "Job: ${env.JOB_NAME}, Build: #${env.BUILD_NUMBER}."

def build_push_image(ecr_repo, aws_region) {
    sh "docker build --network=host -t jenkins-agent:iac-${env.BUILD_NUMBER} ."
    sh 'docker image ls'
//    docker.withRegistry("https://${ecr_repo}/jenkins-agent", "ecr:${aws_region}:aws-secret-key") {

    sh "aws ecr-public get-login-password --region ${aws_region} | docker login --username AWS --password-stdin public.ecr.aws"
    sh "docker tag jenkins-agent:iac-${env.BUILD_NUMBER} ${ecr_repo}/jenkins-agent:iac-${env.BUILD_NUMBER}"
    sh "docker push ${ecr_repo}/jenkins-agent:iac-${env.BUILD_NUMBER}"
//    }
}

podTemplate(label: label, yaml: """
apiVersion: v1
kind: Pod
metadata:
  name: "jenkins-vg-agent"
  labels:
    app: jenkins-vg-agent
spec:
  containers:
  - name: jenkins-agent
    image: greghu/jenkins-agent:latest
    command: ['cat']
    tty: true
    volumeMounts:
    - name: dockersock
      mountPath: /var/run/docker.sock
  nodeSelector:
    beta.kubernetes.io/instance-type: "t3.medium"
  volumes:
  - name: dockersock
    hostPath:
      path: /var/run/docker.sock
"""
) {
    node(label) {
        properties([disableConcurrentBuilds(),
                    buildDiscarder(logRotator(numToKeepStr: '10'))
        ])
        withAWS(credentials: 'aws-secret-key', region: "${aws_region}") {
            stage('Notify Start') {
                slackSend channel: "${notify_channel}", color: "warning", message: "Start jenkins-agent ${build_info} (<${env.BUILD_URL}|see details>)"
            }

            container('jenkins-agent') {
                stage('Checkout') {
                    checkout scm
                }

                stage('Build And Push Image') {
                    build_push_image("${ecr_repo}", "${aws_region}")
                }

            }

            stage('Notify Complete') {
                slackSend channel: "${notify_channel}", color: "good", message: "Finish the new Jenkins agent image."
            }
        }
    }
}