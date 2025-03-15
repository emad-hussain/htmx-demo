pipeline {
    agent any
    
    environment {
        IMAGE_NAME = "htmx-demo"
        REGISTRY = "registry.digitalocean.com/kube-app-registry"
        DEPLOYMENT_FILE = "deployment.yaml"
        SECRET_FILE = "do-registry-secret.yaml"
        DO_CLUSTER = "k8s-htmx"
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

        stage('Login to DigitalOcean') {
            steps {
                withCredentials([string(credentialsId: 'DO_ACCESS_TOKEN', variable: 'DO_TOKEN')]) {
                    sh '''
                        export DIGITALOCEAN_ACCESS_TOKEN=$DO_TOKEN
                        doctl auth init --access-token $DO_TOKEN
                        doctl kubernetes cluster kubeconfig save $DO_CLUSTER
                    '''
                }
            }
        }

        stage('Tag and Push to DOCR') {
            steps {
                sh "docker tag ${IMAGE_NAME} ${REGISTRY}/${IMAGE_NAME}:latest"
                sh "docker push ${REGISTRY}/${IMAGE_NAME}:latest"
            }
        }

        stage('Update Kubernetes Secret YAML') {
            steps {
                withCredentials([string(credentialsId: 'DO_ACCESS_TOKEN', variable: 'DO_TOKEN')]) {
                    sh '''
                        # Create the Docker authentication JSON
                        DOCKER_CONFIG_JSON=$(echo -n "{\"auths\":{\"${REGISTRY}\":{\"auth\":\"$(echo -n $DO_TOKEN: | base64)\"}}}")

                        # Encode the JSON to Base64
                        BASE64_CONFIG=$(echo -n "$DOCKER_CONFIG_JSON" | base64 -w 0)

                        # Update the Secret YAML file
                        sed -i "s|<BASE64_ENCODED_CREDENTIALS>|$BASE64_CONFIG|g" $SECRET_FILE
                    '''
                }
            }
        }

        stage('Apply Kubernetes Secret') {
            steps {
                withCredentials([file(credentialsId: 'KUBECONFIG_FILE', variable: 'KUBECONFIG')]) {
                    sh '''
                        export KUBECONFIG=/var/lib/jenkins/.kube/config
                        kubectl apply -f do-registry-secret.yaml
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'KUBECONFIG_FILE', variable: 'KUBECONFIG')]) {
                    sh '''
                        export KUBECONFIG=/var/lib/jenkins/.kube/config
                        kubectl get nodes
                        kubectl apply -f deployment.yaml
                    '''
                }
            }
        }
    }
}
