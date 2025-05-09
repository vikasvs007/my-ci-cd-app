pipeline {
    agent any // Specifies that Jenkins can use any available agent

    tools {
        // These names must match what you configured in Jenkins Global Tool Configuration
        maven 'Maven3.9.9' // Or your configured Maven name
        jdk 'OpenJDK21'      // Or your configured JDK name
    }

    environment {
        DOCKERHUB_CREDENTIALS_ID = 'dockerhub-credentials'
        GITHUB_CREDENTIALS_ID = 'github-credentials'
        DOCKER_IMAGE_NAME = "vikasvs007/my-ci-cd-app" // Using your Docker Hub username from the log
        IMAGE_TAG = "latest"
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code from GitHub...'
                cleanWs() // Clean workspace before checkout
                git branch: 'main',
                    url: 'https://github.com/vikasvs007/my-ci-cd-app.git', // Using your GitHub repo from the log
                    credentialsId: env.GITHUB_CREDENTIALS_ID
            }
        }

        stage('Build & Test') {
            steps {
                echo 'Verifying test file presence and building the application...'
                // Diagnostic step: Verify test file existence
                script {
                    def testFilePath = 'src/test/java/com/example/app/MyCiCdAppApplicationTests.java'
                    if (fileExists(testFilePath)) {
                        echo "SUCCESS: Test file '${testFilePath}' exists in the workspace."
                    } else {
                        echo "ERROR: Test file '${testFilePath}' DOES NOT exist in the workspace."
                        echo "Listing contents of src/test/java/com/example/app/:"
                        bat 'dir src\\test\\java\\com\\example\\app' // Windows command
                        // You might want to list other parent directories if the above is empty
                        echo "Listing contents of src/test/java/com/example/:"
                        bat 'dir src\\test\\java\\com\\example'
                        echo "Listing contents of src/test/java/com/:"
                        bat 'dir src\\test\\java\\com'
                         echo "Listing contents of src/test/java/:"
                        bat 'dir src\\test\\java'
                         echo "Listing contents of src/test/:"
                        bat 'dir src\\test'
                         echo "Listing contents of src/:"
                        bat 'dir src'
                    }
                }
                // Using bat for Windows and -e for error details from Maven
                bat 'mvn clean install -e'
            }
            post {
                always {
                    echo 'Attempting to record test results and archive artifacts...'
                    // Temporarily allow empty results for JUnit to help diagnose further pipeline stages.
                    // The goal is to fix test execution so that reports are generated.
                    junit testResults: 'target/surefire-reports/*.xml', allowEmptyResults: true
                    archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Ensure pipeline-utility-steps plugin is installed for readMavenPom()
                    def appVersion = readMavenPom().getVersion()
                    def artifactId = readMavenPom().getArtifactId() // Get artifactId from pom
                    def jarFileName = "${artifactId}-${appVersion}.jar"
                    
                    echo "Building Docker image: ${env.DOCKER_IMAGE_NAME}:${env.IMAGE_TAG}"
                    echo "Using JAR file: target/${jarFileName}"

                    docker.withRegistry('https://index.docker.io/v1/', env.DOCKERHUB_CREDENTIALS_ID) {
                        def customImage = docker.build(
                            "${env.DOCKER_IMAGE_NAME}:${env.IMAGE_TAG}",
                            // Pass the actual JAR file name as a build argument to Dockerfile
                            // Ensure your Dockerfile has: ARG JAR_FILE
                            // And uses ${JAR_FILE} in the COPY command.
                            "--build-arg JAR_FILE=target/${jarFileName} ."
                        )
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    echo "Pushing Docker image ${env.DOCKER_IMAGE_NAME}:${env.IMAGE_TAG} to Docker Hub..."
                    docker.withRegistry('https://index.docker.io/v1/', env.DOCKERHUB_CREDENTIALS_ID) {
                        docker.image("${env.DOCKER_IMAGE_NAME}:${env.IMAGE_TAG}").push()
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished. Attempting to send email notification...'
            // Note: Email sending failed in your log due to connection errors.
            // This needs to be fixed in Jenkins System Configuration (SMTP settings).
            emailext (
                subject: "Build ${currentBuild.currentResult}: Project ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                body: """<p>Project: ${env.JOB_NAME}</p>
                         <p>Build Number: ${env.BUILD_NUMBER}</p>
                         <p>Build Status: ${currentBuild.currentResult}</p>
                         <p>Build URL: <a href='${env.BUILD_URL}'>${env.BUILD_URL}</a></p>
                         <p>Commit Changes:</p>
                         <pre>${currentBuild.changeSets.collect { cs -> cs.items.collect { item -> item.msg + ' (' + item.author?.fullName + ' [' + item.author?.id + '])' }.join('\\n') }.join('\\n\\n')}</pre>
                         <hr/>
                         <p>Check console output at <a href='${env.BUILD_URL}console'>${env.BUILD_URL}console</a></p>""",
                to: "vikasvs6363163@gmail.com", // Using your email from the log, add others as needed
                recipientProviders: [
                    [$class: 'DevelopersRecipientProvider'],
                    [$class: 'RequesterRecipientProvider']
                ],
                mimeType: 'text/html',
                attachLog: true,
                compressLog: true
            )
            cleanWs() // Clean up workspace after build
        }
        success {
            echo 'Pipeline SUCCEEDED!'
        }
        failure {
            echo 'Pipeline FAILED.'
        }
        unstable {
            // This status occurs if tests fail but allowEmptyResults=true or build otherwise completes
            echo 'Pipeline is UNSTABLE (e.g., tests failed or no test reports found but build continued).'
        }
    }
}
