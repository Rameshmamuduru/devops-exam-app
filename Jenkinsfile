pipeline {

    agent any

    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['Dev','Stage','Prod'],
            description: 'Select the deployment environment'
        )
    }

    environment {
        IMAGE_NAME = 'ramesh0621/backend-1'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Setting Up Deployment') {
            steps {
                echo "Deployment to Environment: ${params.ENVIRONMENT}"
            }
        }

        stage('Check Out from SCM') {
            steps {
                // git checkout steps here
            }
        }

        stage('SonarQube Analysis') {
            steps {
                // code analysis steps
            }
        }

        stage('Quality Gates') {
            steps {
                // check sonar quality gates
            }
        }

        stage('File System Scan') {
            steps {
                // security scan or static analysis
            }
        }

        stage('Docker Login and Docker Build') {
            steps {
                // docker login and docker build
            }
        }

        stage('Docker Image Scan') {
            steps {
                // scan the image before push
            }
        }

        stage('Docker Tag and Docker Push') {
            steps {
                // tag and push docker image
            }
        }

        stage('Image Updater') {
            steps {
                // update values.yaml for helm chart
            }
        }
    }
}
