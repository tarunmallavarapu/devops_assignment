pipeline {
  agent any

  stages {
    stage('Checkout') {
      steps {
        // git checkout ...
      }
    }

    stage('Build Docker Image') {
      steps {
        // docker build -t tarun026/cyware_assigment . 
      }
    }

    stage('Push Docker Image') {
      steps {
        // docker push tarun026/cyware_assigment:<tag>
      }
    }

    stage('Provision Infrastructure') {
      steps {
        // terraform apply -auto-approve
      }
    }

    stage('Deploy') {
      steps {
        // ssh user@ec2-instance 'docker-compose up -d'
      }
    }
  }
}
