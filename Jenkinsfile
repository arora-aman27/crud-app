pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
        ECR_REPO = 'crud-app'
        ECR_REGISTRY = '094417668047.dkr.ecr.ap-south-1.amazonaws.com/crud-app'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        SONARQUBE_SERVER = 'SonarQubeServer'
        PROJECT_KEY = 'crud-app'
        DOCKER_IMAGE = "${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}"
        // KUBE_CONFIG = credentials('eks-kubeconfig')
        CLUSTER_NAME   = 'crud-eks-cluster'
    }

    stages {
        stage('Check or Create S3 Bucket') {
            steps {
                withAWS(region: "${AWS_REGION}", credentials: 'aws-jenkins-credentials-id') {
                    script{
                        def bucket = 'crud-app-bucket-2312'
                        
                        // Check if bucket exists
                        def result = sh(script: "aws s3api head-bucket --bucket ${bucket}", returnStatus: true)

                        if (result !=0) {
                            echo "Bucket '${bucket}' does not exist or is inaccessible. Creating it..."
                            sh """
                                aws s3 mb s3://"${bucket}" --region "${AWS_REGION}"
                                """                       
                            }  else {
                                echo "Bucket '${bucket}' already exists."
                                }  
                            }
                        }
                    }
                }  

        stage('Provision EKS using Terraform') {
            steps {
                dir('terraform-eks') {
                    withAWS(region: "${AWS_REGION}", credentials: 'aws-jenkins-credentials-id') {
                        sh '''
                            aws sts get-caller-identity
                            terraform init -reconfigure
                            terraform validate
                            terraform apply -auto-approve
                            aws eks --region ${AWS_REGION} update-kubeconfig --name ${CLUSTER_NAME}
                        '''
                    }
                }
            }
        }

        stage('Checkout') {
            steps {
                git 'https://github.com/arora-aman27/crud-app.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                dir('backend') {
                    sh 'npm install'
                }
            }
        }

        stage('Run Tests') {
            steps {
                dir('backend') {
                    sh 'npm test || echo "No Tests Defined for now"'
                }
            }
        }

       /*stage('SonarQube Scan') {
       	   steps {
                withSonarqubeEnv("${SONARQUBE_SERVER}")
                dir('backend') {
                    sh '''
                        sonar-scanner \
                        -Dsonar.projectKey=${PROJECT_KEY} \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=$SONAR_HOST_URL \
                        -Dsonar.login=$SONAR_AUTH_TOKEN
                        '''
                }

            }
        }*/


        stage('Docker Build & push to ECR') {
            steps {
                script {
                    sh '''
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}
                        docker build -t ${DOCKER_IMAGE} .
                        docker push ${DOCKER_IMAGE}
                        '''
                }
            }
        }

        stage('Deploy to EKS using Helm') {
            steps {
                script {
                        sh '''
                            helm upgrade --install crud-app ./helm-chart \
                            --set image.repository=${ECR_REGISTRY}/${ECR_REPO} \
                            --set image.tag=${IMAGE_TAG} \
                            --namespace default
                            '''
                        }
                    }
                }
            }

    post {
        success {
            echo 'Deployed successfully to EKS !'
        }

        failure {
            echo 'Pipeline Failed, Please check logs'
        }
    }
}
