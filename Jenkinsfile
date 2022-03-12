pipeline {
agent any

  stages {

    stage('Check-Out') {
     steps {
        
        checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [[$class: 'RelativeTargetDirectory']], userRemoteConfigs: [[credentialsId: 'jenkins_guy', url: 'https://git-codecommit.us-east-1.amazonaws.com/v1/repos/azure1']]])
        
     }
    }

  stage('terragrunt init') {

      steps {
                echo 'terragrunt init'
        sh '''
        cd azure1/codes/Pay-As-You-Go/prod/vm/sabmachine
        ls
        terragrunt init
        '''
                echo 'Terragrunt Init done'
      }
    }

    stage('terragrunt plan') {

      steps {
                echo 'Terragrunt Plan'
        sh '''
        cd azure1/codes/Pay-As-You-Go/prod/vm/sabmachine
        ls
        terragrunt plan -var-file="input.tfvars"
        '''
                echo 'Terragrunt Plan done'
      }
    }

    stage('terragrunt apply') {

      steps {
                echo 'Terragrunt Apply'
        sh '''
        cd azure1/codes/Pay-As-You-Go/prod/vm/sabmachine
        ls
        terragrunt apply -var-file="input.tfvars" --auto-approve
        '''
                echo 'Terragrunt Apply done'
      }
    }

  } 
}
