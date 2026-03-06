pipeline {
    agent any

    environment {
        ACR_LOGIN_SERVER = "threetieracr25c33d3d.azurecr.io"
        ACR_REGISTRY = credentials('acr-credentials')
        KUBE_CONFIG = credentials('kubeconfig-prod')
        NAMESPACE = "prod"
        GIT_COMMIT_SHORT = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Push Frontend') {
            steps {
                script {
                    sh '''
                        echo $ACR_REGISTRY_PSW | docker login -u $ACR_REGISTRY_USR --password-stdin $ACR_LOGIN_SERVER
                        docker build -t $ACR_LOGIN_SERVER/frontend:$GIT_COMMIT_SHORT ./frontend
                        docker push $ACR_LOGIN_SERVER/frontend:$GIT_COMMIT_SHORT
                        docker tag $ACR_LOGIN_SERVER/frontend:$GIT_COMMIT_SHORT $ACR_LOGIN_SERVER/frontend:latest
                        docker push $ACR_LOGIN_SERVER/frontend:latest
                    '''
                }
            }
        }

        stage('Build & Push Backend') {
            steps {
                script {
                    sh '''
                        echo $ACR_REGISTRY_PSW | docker login -u $ACR_REGISTRY_USR --password-stdin $ACR_LOGIN_SERVER
                        docker build -t $ACR_LOGIN_SERVER/backend:$GIT_COMMIT_SHORT ./backend
                        docker push $ACR_LOGIN_SERVER/backend:$GIT_COMMIT_SHORT
                        docker tag $ACR_LOGIN_SERVER/backend:$GIT_COMMIT_SHORT $ACR_LOGIN_SERVER/backend:latest
                        docker push $ACR_LOGIN_SERVER/backend:latest
                    '''
                }
            }
        }

        stage('Deploy Frontend') {
            steps {
                script {
                    sh '''
                        export KUBECONFIG=$KUBE_CONFIG
                        helm upgrade frontend ./manifests/helm/frontend -n $NAMESPACE \
                            --set image.tag=$GIT_COMMIT_SHORT \
                            --wait
                    '''
                }
            }
        }

        stage('Deploy Backend') {
            steps {
                script {
                    sh '''
                        export KUBECONFIG=$KUBE_CONFIG
                        helm upgrade backend ./manifests/helm/backend -n $NAMESPACE \
                            --set image.tag=$GIT_COMMIT_SHORT \
                            --wait
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    sh '''
                        export KUBECONFIG=$KUBE_CONFIG
                        kubectl rollout status deployment/frontend -n $NAMESPACE --timeout=5m
                        kubectl rollout status deployment/backend -n $NAMESPACE --timeout=5m
                        kubectl get pods -n $NAMESPACE
                    '''
                }
            }
        }
    }

    post {
        always {
            sh 'docker logout $ACR_LOGIN_SERVER'
        }
        failure {
            echo 'Pipeline failed. Check logs above.'
        }
        success {
            echo 'Pipeline completed successfully!'
        }
    }
}