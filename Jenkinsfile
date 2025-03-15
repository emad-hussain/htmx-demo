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

        stage('Check KUBECONFIG') {
            steps {
                withCredentials([file(credentialsId: 'KUBECONFIG_FILE', variable: 'KUBECONFIG')]) {
                    sh '''
                        echo "Checking if KUBECONFIG exists..."
                        ls -l $KUBECONFIG || echo "KUBECONFIG file not found!"
                        cat $KUBECONFIG || echo "Cannot read KUBECONFIG!"
                        export KUBECONFIG=$KUBECONFIG
                        kubectl get nodes
                    '''
                }
            }
        }
        
    }
}
