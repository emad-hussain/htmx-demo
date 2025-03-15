pipeline {
    agent any

    environment {
        IMAGE_NAME = "htmx-demo"
        REGISTRY = "registry.digitalocean.com/kube-app-registry"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/emad-hussain/htmx-demo.git'
            }
        }

        stage('Build and Push Image') {
            steps {
                sh """
                    docker build -t ${REGISTRY}/${IMAGE_NAME}:latest .
                    docker push ${REGISTRY}/${IMAGE_NAME}:latest
                """
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'KUBECONFIG', variable: 'KUBECONFIG')]) {
                    sh """
                        kubectl apply -f deployment.yaml --kubeconfig=\$KUBECONFIG
                        kubectl apply -f service.yaml --kubeconfig=\$KUBECONFIG
                    """
                }
            }
        }
    }
}
