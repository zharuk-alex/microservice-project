pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: jenkins-kaniko
spec:
  serviceAccountName: jenkins-sa
  containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:latest
      imagePullPolicy: Always
      command:
        - cat
      tty: true
    - name: git
      image: alpine/git
      command:
        - cat
      tty: true
"""
    }
  }

  environment {
    AWS_REGION         = "eu-central-1"
    AWS_DEFAULT_REGION = "eu-central-1"
    IMAGE_TAG          = "${env.BUILD_NUMBER}"
  }

  stages {
    stage('Get ECR Repo URL') {
      steps {
        script {
          env.ECR_REPO = sh(
            script: "terraform output -raw module.ecr.ecr_repository_url",
            returnStdout: true
          ).trim()
          env.REGISTRY = env.ECR_REPO.split('/')[0]
        }
      }
    }

    stage('Build & Push Docker Image') {
      steps {
        container('kaniko') {
          withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
            sh '''
              export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
              export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
              export AWS_REGION=$AWS_REGION
              export AWS_DEFAULT_REGION=$AWS_REGION
              aws ecr get-login-password --region $AWS_REGION | \
                docker login --username AWS --password-stdin $REGISTRY
              /kaniko/executor \
                --context ${WORKSPACE}/charts/django-app \
                --dockerfile ${WORKSPACE}/charts/django-app/Dockerfile \
                --destination $REGISTRY/$ECR_REPO:$IMAGE_TAG \
                --cache=true
            '''
          }
        }
      }
    }

    stage('Update Helm values.yaml') {
      steps {
        container('git') {
          sshagent(credentials: ['git-ssh-key']) {
            sh '''
              git clone git@github.com:zharuk-alex/microservice-project.git
              cd microservice-project/charts/django-app
              sed -i "s/^  tag: .*/  tag: '$IMAGE_TAG'/" values.yaml
              git config user.email "jenkins@ci.local"
              git config user.name "Jenkins"
              git add values.yaml
              git commit -m "Update image tag to $IMAGE_TAG [ci skip]"
              git push origin lesson-8
            '''
          }
        }
      }
    }
  }
}