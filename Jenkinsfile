pipeline {
    agent any
    
    environment {
        IMAGE_NAME = "htmx-demo"
        REGISTRY = "registry.digitalocean.com/kube-app-registry"
        DEPLOYMENT_FILE = "deployment.yaml"
        SECRET_FILE = "do-registry-secret.yaml"  // Path to the secret file in repo
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
                withCredentials([string(credentialsId: 'DO_ACCESS_TOKEN', variable: 'DO_TOKEN'),
                                 string(credentialsId: 'DO_USERNAME', variable: 'DO_USER')]) {
                    script {
                        // Generate the Base64 encoded config JSON
                        def dockerConfigJson = """{
                            "auths": {
                                "${env.REGISTRY}": {
                                    "username": "${env.DO_USER}",
                                    "password": "${env.DO_TOKEN}"
                                }
                            }
                        }""".trim()

                        def base64Config = dockerConfigJson.bytes.encodeBase64().toString()

                        // Read the existing YAML file from the repo
                        def secretYaml = readFile(file: env.SECRET_FILE)

                        // Replace placeholder with actual Base64-encoded secret
                        secretYaml = secretYaml.replace("<BASE64_ENCODED_CREDENTIALS>", base64Config)

                        // Write updated YAML back to the file
                        writeFile(file: env.SECRET_FILE, text: secretYaml)
                    }
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
