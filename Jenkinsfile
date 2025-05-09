pipeline {
    agent any

    tools {
        maven 'Maven3.9.9'
        jdk 'OpenJDK21'
    }

    environment {
        DOCKERHUB_CREDENTIALS_ID = 'dockerhub-credentials'
        GITHUB_CREDENTIALS_ID = 'github-credentials'
        DOCKER_IMAGE_NAME = "vikasvs007/my-ci-cd-app"
        IMAGE_TAG = "latest"
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code from GitHub...'
                cleanWs()
                git branch: 'main',
                    url: 'https://github.com/vikasvs007/my-ci-cd-app.git',
                    credentialsId: env.GITHUB_CREDENTIALS_ID
            }
        }

        stage('Build & Test') {
            steps {
                echo 'Running Maven build and tests...'
                bat 'mvn clean install -e'
            }
            post {
                always {
                    echo 'Archiving test results and artifacts...'
                    junit testResults: 'target/surefire-reports/*.xml', allowEmptyResults: false
                    archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def appVersion = readMavenPom().getVersion()
                    def artifactId = readMavenPom().getArtifactId()
                    def jarFileName = "${artifactId}-${appVersion}.jar"

                    echo "Building Docker image ${env.DOCKER_IMAGE_NAME}:${env.IMAGE_TAG} using ${jarFileName}"

                    docker.withRegistry('https://index.docker.io/v1/', env.DOCKERHUB_CREDENTIALS_ID) {
                        docker.build(
                            "${env.DOCKER_IMAGE_NAME}:${env.IMAGE_TAG}",
                            "--build-arg JAR_FILE=target/${jarFileName} ."
                        )
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    echo "Pushing Docker image to Docker Hub..."
                    docker.withRegistry('https://index.docker.io/v1/', env.DOCKERHUB_CREDENTIALS_ID) {
                        docker.image("${env.DOCKER_IMAGE_NAME}:${env.IMAGE_TAG}").push()
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed. Sending email notification and cleaning workspace.'
            emailext (
                subject: "Build ${currentBuild.currentResult}: Project ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                body: """<p>Project: ${env.JOB_NAME}</p>
                         <p>Build Number: ${env.BUILD_NUMBER}</p>
                         <p>Status: ${currentBuild.currentResult}</p>
                         <p>URL: <a href='${env.BUILD_URL}'>${env.BUILD_URL}</a></p>
                         <hr/>
                         <p>Console Output: <a href='${env.BUILD_URL}console'>${env.BUILD_URL}console</a></p>""",
                to: "vvs634793@gmail.com",
                recipientProviders: [[$class: 'DevelopersRecipientProvider'], [$class: 'RequesterRecipientProvider']],
                mimeType: 'text/html',
                attachLog: true,
                compressLog: true
            )
            cleanWs()
        }
        success {
            echo 'Pipeline SUCCEEDED!'
        }
        failure {
            echo 'Pipeline FAILED.'
        }
        unstable {
            echo 'Pipeline UNSTABLE (e.g., due to test failures or missing test reports).'
        }
    }
}
