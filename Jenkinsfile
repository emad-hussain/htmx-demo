pipeline {
    agent any
    
    environment {
        IMAGE_NAME = "htmx-demo"
        REGISTRY = "registry.digitalocean.com/kube-app-registry"
        DEPLOYMENT_FILE = "deployment.yaml"
        KUBECONFIG_PATH = ""
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/emad-hussain/htmx-demo.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME .'
            }
        }

        stage('Login to DOCR') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'DOCR_CREDENTIALS', usernameVariable: 'DOCR_USER', passwordVariable: 'DOCR_PASS')]) {
                    sh """
                        echo \$DOCR_PASS | docker login ${REGISTRY} -u \$DOCR_USER --password-stdin
                    """
                }
            }
        }

        stage('Tag and Push to DOCR') {
            steps {
                sh "docker tag ${IMAGE_NAME} ${REGISTRY}/${IMAGE_NAME}:latest"
                sh "docker push ${REGISTRY}/${IMAGE_NAME}:latest"
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'KUBECONFIG_FILE', variable: 'KUBECONFIG')]) {
                    sh '''
                        echo "Using KUBECONFIG: $KUBECONFIG"
                        export KUBECONFIG=$KUBECONFIG
                        kubectl apply -f ${DEPLOYMENT_FILE}
                        kubectl rollout status deployment/htmx-demo
                    '''
                }
            }
        }
    }
}
