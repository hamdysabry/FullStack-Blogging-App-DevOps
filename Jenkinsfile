pipeline {
    agent any

    tools {
        maven 'maven'
    }

    environment {
        SCANNER_HOME = tool 'sonar-scanar'
        TRIVY_CACHE = "${WORKSPACE}/.trivy-cache"
        DOCKER_IMAGE = 'hamdi2513/bloggingapp'
        DOCKER_TAG = 'latest'
        AWS_REGION = 'us-east-1'
        AWS_CLUSTER = 'blogging-eks'
    }

    stages {

        stage('Clean Workspace') {
            steps {
                script {
                    echo '🧹 Cleaning workspace...'
                    deleteDir()
                }
            }
        }

        stage('Git Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/master']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/hamdysabry/FullStack-Blogging-App-DevOps.git'
                    ]],
                    extensions: [[$class: 'CloneOption', depth: 1, shallow: true]]
                ])
            }
        }

        stage('Compile & Test') {
            steps {
                sh 'mvn clean compile'
                sh 'mvn test'
            }
            post { always { junit '**/target/surefire-reports/*.xml' } }
        }

        stage('SonarQube Analysis') {
            steps {
                withCredentials([string(credentialsId: 'sonar', variable: 'SONAR_TOKEN')]) {
                    sh """
                        ${SCANNER_HOME}/bin/sonar-scanner \
                        -Dsonar.projectName=blogging \
                        -Dsonar.projectKey=blogging \
                        -Dsonar.java.binaries=target/classes \
                        -Dsonar.login=${SONAR_TOKEN}
                    """
                }
            }
        }


        stage('Package') {
            steps {
                sh 'mvn package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo '🐳 Building Docker image...'
                    sh "docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} ."
                    sh "docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:${DOCKER_TAG}"
                }
            }
        }

        stage('Scan Docker Image with Trivy') {
            steps {
                script {
                    sh """
                        mkdir -p ${TRIVY_CACHE}
                        trivy image --cache-dir ${TRIVY_CACHE} \
                        --scanners vuln \
                        --severity HIGH,CRITICAL \
                        --format table \
                        --output trivy-image-report.html \
                        ${DOCKER_IMAGE}:${DOCKER_TAG} || echo '⚠️ Trivy scan completed with warnings'
                    """
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'docker-hub-creds',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )]) {
                        sh '''
                            echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                            docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                            docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                            docker logout
                        '''
                    }
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    script {
                        echo '🚀 Deploying to AWS EKS...'
                        sh "aws eks update-kubeconfig --region ${AWS_REGION} --name ${AWS_CLUSTER}"
                        sh "kubectl apply -f k8s/deployment.yaml"
                         sh "kubectl apply -f k8s/service.yaml"
                        sh "kubectl rollout status deployment/blogging-app"
                    }
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    script {
                        echo '🔍 Verifying deployment...'
                        sh "kubectl get pods -o wide"
                        sh "kubectl get svc -o wide"
                    }
                }
            }
        }
    }

    post {
        always {
            echo '=========================================='
            echo '     Pipeline Execution Completed'
            echo '=========================================='
            archiveArtifacts artifacts: 'trivy-image-report.html', allowEmptyArchive: true
        }
        success {
            echo '✅ SUCCESS: Pipeline completed successfully!'
            echo "✅ Docker images pushed:"
            echo "   - ${DOCKER_IMAGE}:${DOCKER_TAG}"
            echo "   - ${DOCKER_IMAGE}:${BUILD_NUMBER}"
        }
        failure {
            echo '❌ FAILURE: Pipeline failed!'
        }
        // Uncomment the following block to send email notifications on failure
    }
}
