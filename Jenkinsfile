pipeline {
agent any

  stages {

    stage('Check-Out') {
     steps {
        checkout([$class: 'GitSCM', branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/Honishmiran/AzureTest.git']]])
        sh '''
        ls -la live/dev/west-europe/resource_group/
        '''
        
     }
    }

  stage('Terragrunt Init') {

      steps {
                echo 'Terragrunt Init'
        sh '''
        terragrunt init"
        '''
                echo 'Terragrunt Init done'
      }
    }

    stage('Terragrunt Plan') {

      steps {
                echo 'Terragrunt Plan'
        sh '''
        terragrunt plan"
        '''
                echo 'TTerragrunt Plan done'
      }
    }

    stage('Terragrunt Apply') {

      steps {
                echo 'Terragrunt Apply'
        sh '''
        terragrunt apply --auto-approve"
        '''
                echo 'Terragrunt Apply done'
      }
    }
  }
  
}