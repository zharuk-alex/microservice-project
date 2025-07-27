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

            def repo = sh(script: "terraform output -raw ecr_repository_url", returnStdout: true).trim()

            env.ECR_REGISTRY = repo.split('/')[0]
            env.FULL_REPO    = repo
            echo "✅ Fetched ECR_REPO: ${env.FULL_REPO}"
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
              git clone https://$GIT_USERNAME:$GIT_PAT@github.com/zharuk-alex/microservice-project.git project
              cd project/charts/django-app

              sed -i "s/tag: .*/tag: $IMAGE_TAG/" values.yaml

              git config user.email "$COMMIT_EMAIL"
              git config user.name "$COMMIT_NAME"

              git add values.yaml
              git commit -m "Update image tag to $IMAGE_TAG"
              git push origin django-app
            '''
          }
        }
      }
    }
  }
}
