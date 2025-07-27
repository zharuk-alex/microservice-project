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
      image: gcr.io/kaniko-project/executor:v1.16.0-debug
      imagePullPolicy: Always
      command:
        - sleep
      args:
        - 99d
    - name: git
      image: alpine/git
      command:
        - sleep
      args:
        - 99d
    - name: terraform
      image: hashicorp/terraform:1.8.3
      imagePullPolicy: Always
      command:
        - sleep
      args:
        - 99d
"""
    }
  }

  environment {
      IMAGE_NAME   = "goit-ecr"
      IMAGE_TAG    = "${env.BUILD_NUMBER}"
      COMMIT_NAME  = "Jenkins Bot"
      COMMIT_EMAIL = "jenkins@example.com"
    // ECR_REGISTRY = ""
  }


  stages {
    stage('Get ECR Repo URL') {
      steps {
        container('terraform') {
          script {
            sh 'terraform init -input=false -no-color'
            
            def ECR_REPO = '998698767918.dkr.ecr.eu-central-1.amazonaws.com/goit-ecr'
            
            env.ECR_REGISTRY = ECR_REPO.split('/')[0]
            env.FULL_REPO    = ECR_REPO

            echo "Fetched ECR_REPO: ${env.FULL_REPO}"
          }
        }
      }
    }

    stage('Build & Push Docker Image') {
      steps {
        container('kaniko') {
          sh '''
            /kaniko/executor \
              --context=dir://$(pwd)/charts/django-app \
              --dockerfile=$(pwd)/charts/django-app/Dockerfile \
              --destination=$ECR_REGISTRY/$IMAGE_NAME:$IMAGE_TAG \
              --cache=true \
              --reproducible \
              --single-snapshot \
              --snapshotMode=redo \
              --skip-tls-verify-pull \
              --skip-tls-verify
          '''
        }
      }
    }

    stage('Update Chart Tag in Git') {
      steps {
        container('git') {
          withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PAT')]) {
            sh '''
              git clone --single-branch --branch django-app https://${GIT_USERNAME}:${GIT_PAT}@github.com/zharuk-alex/microservice-project.git
              cd microservice-project/charts/django-app

              sed -i "s/tag: .*/tag: ${BUILD_NUMBER}/" values.yaml

              git config user.email "jenkins@example.com"
              git config user.name "Jenkins CI"

              git add values.yaml
              git commit -m "ci: update image tag to ${BUILD_NUMBER}"
              git push
            '''
          }
        }
      }
    }

  }
}
