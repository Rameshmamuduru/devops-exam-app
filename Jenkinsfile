pipeline {

    agent any

    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['Dev', 'Stage', 'Prod'],
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
                git url: 'https://github.com/Rameshmamuduru/devops-exam-app.git', branch: 'master'
            }
        }

        stage('SonarQube Analysis') {
            environment {
                scannerHome = tool 'sonar-scanner'
            }
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh """
                        ${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=backend-app \
                        -Dsonar.projectName=backend-app \
                        -Dsonar.sources=. \
                        -Dsonar.language=py
                    """
                }
            }
        }

        stage('Quality Gates') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: false
                }
            }
        }

        stage('File System Scan') {
            steps {
                sh '''
                    echo "Running File System Security Scan"
                    trivy fs --severity HIGH,CRITICAL \
                        --format table \
                        -o trivy-fs-report.txt .
                '''

                archiveArtifacts artifacts: 'trivy-fs-report.txt', fingerprint: true
            }
        }

        stage('Docker Login and Docker Build') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-creds') {
                        echo "Building Docker image: ${IMAGE_NAME}:${BUILD_NUMBER}"
                        sh """
                            docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                        """
                    }
                }
            }
        }

        stage('Docker Image Scan') {
            steps {
                script {
                    echo "Scanning Docker image ${IMAGE_NAME}:${BUILD_NUMBER} for vulnerabilities"
                    sh """
                        trivy image --severity HIGH,CRITICAL --exit-code 1 \
                            --format table -o trivy-image-report.txt ${IMAGE_NAME}:${BUILD_NUMBER}
                    """
                    archiveArtifacts artifacts: 'trivy-image-report.txt', fingerprint: true
                }
            }
        }

        stage('Docker Tag and Docker Push') {
            steps {
                script {
                    echo "Tagging and pushing Docker image: ${IMAGE_NAME}:${BUILD_NUMBER}"
                    docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-creds') {
                        sh "docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:latest"
                        sh "docker push ${IMAGE_NAME}:${BUILD_NUMBER}"
                        sh "docker push ${IMAGE_NAME}:latest"
                    }
                }
            }
        }

        stage('Image Tag Updater') {
            steps {
                script {
                    def buildTag = "${BUILD_NUMBER}"
                    def envFile = ""

                    if (params.ENVIRONMENT == 'Dev') {
                        envFile = 'helm/values-dev.yaml'
                    } else if (params.ENVIRONMENT == 'Stage') {
                        envFile = 'helm/values-stage.yaml'
                    } else {
                        envFile = 'helm/values-prod.yaml'
                    }

                    echo "Updating Helm values.yaml for ${params.ENVIRONMENT} environment with tag ${buildTag}"

                    sh """
                        yq e '.images.version = "${buildTag}"' -i ${envFile}
                    """
                    
                    echo "Testing Helm templates for ${params.ENVIRONMENT} environment"

                    sh """
                        helm template myapp1 helm/ -f ${envFile} --namespace ${params.ENVIRONMENT.toLowerCase()}
                     """
                }
            }
        }

        stage('Committing and pushing updated Helm') {
            steps {
                script {

                    input message: "Approve committing and pushing updated Helm values for ${params.ENVIRONMENT}?", ok: "Approve"
                    echo "Approval received. Committing and pushing Helm values..."

                    echo "Committing and pushing updated Helm values for ${params.ENVIRONMENT} with tag ${BUILD_NUMBER}"

                    sh """
                        git config user.email "jenkins@example.com"
                        git config user.name "Jenkins"
                        git add ${envFile}
                        git commit -m "Update ${params.ENVIRONMENT} image tag to ${BUILD_NUMBER}"
                        git push origin master
                    """
                }
            }
        }

    }
}
