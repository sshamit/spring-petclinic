#!groovy
/*
    This is an sample Jenkins file for the Weather App, which is a node.js application that has unit test, code coverage
    and functional verification tests, deploy to staging and production environment and use IBM Cloud DevOps gate.
    We use this as an example to use our plugin in the Jenkinsfile
    Basically, you need to specify required 4 environment variables and then you will be able to use the 4 different methods
    for the build/test/deploy stage and the gate
 */
pipeline {
    agent any
    environment {
        // You need to specify 4 required environment variables first, they are going to be used for the following IBM Cloud DevOps steps
        //IBM_CLOUD_DEVOPS_CREDS = credentials('97afa093-3137-4335-8b08-705a272b23aa')
        //IBM_CLOUD_DEVOPS_ORG = 'CI/CD'
        PYTHON= 'python2.7'
        IBM_CLOUD_DEVOPS_API_KEY=credentials('ibm-cloud-api-key')
        IBM_CLOUD_DEVOPS_APP_NAME = 'ibm-cloud-devops-plugin'
        IBM_CLOUD_DEVOPS_TOOLCHAIN_ID = 'dff42b3d-ecf3-4478-952a-f0ad43e7725d'
        //IBM_CLOUD_DEVOPS_WEBHOOK_URL = 'https://jenkins:ba8298ea-df31-48b2-bfcf-19a3b52d2788:4cdcf732-1057-42a8-84fd-69c10a536925@devops-api.eu-gb.bluemix.net/v1/toolint/messaging/webhook/publish'
        GIT_REPO = 'https://github.com/sshamit/spring-petclinic'
    }
    tools {
        nodejs 'recent' // your nodeJS installation name in Jenkins
    }
    stages {
        stage('SCM') {
            steps {
                deleteDir()
                git "${GIT_REPO}"
            }
        }
        stage('Build') {
            environment {
                // get git commit from Jenkins
                GIT_COMMIT = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
                GIT_BRANCH = 'master'
            }
            steps {
                sh './mvnw package'
            }
            // post build section to use "publishBuildRecord" method to publish build record
            post {
                success {
                    publishBuildRecord gitBranch: "${GIT_BRANCH}", gitCommit: "${GIT_COMMIT}", gitRepo: "${GIT_REPO}", result:"SUCCESS"
                }
                failure {
                    publishBuildRecord gitBranch: "${GIT_BRANCH}", gitCommit: "${GIT_COMMIT}", gitRepo: "${GIT_REPO}", result:"FAIL"
                }
            }
        }
        stage('Unit Test and Code Coverage') {
            steps {
                //sh './mvnw clean test'
            }
            // post build section to use "publishTestResult" method to publish test result
            post {
                always {
                    publishTestResult type:'unittest', fileLocation: './target/surefire-reports/TEST-*.xml'
                    publishTestResult type:'code', fileLocation: './target/site/jacoco/jacoco.xml'
                }
            }
        }
        stage ('SonarQube analysis') {
            steps {
                script {
                    def scannerHome = tool 'Default SQ Scanner';
                    withSonarQubeEnv('Default SQ Server') {

                        env.SQ_HOST_URL = "https://sonarcloud.io";
                        env.SQ_AUTHENTICATION_TOKEN = b1704d62bc11d4a2cff0fc1edee48a7ad9b354d0;
                        env.SQ_PROJECT_KEY = "My Project Key";

                        sh './mvnw sonar:sonar -Dsonar.host.url="https://sonarcloud.io"'
                    }
                }
            }
            post {
                always {
                    publishSQResults SQHostURL: "${SQ_HOST_URL}", SQAuthToken: "${SQ_AUTHENTICATION_TOKEN}", SQProjectKey:"${SQ_PROJECT_KEY}"
                }
            }
        }

        stage('Deploy to Staging') {
            steps {
                // Push the Weather App to Bluemix, staging space
                sh '''
                        echo "Deploying App to Staging"
         
                        ssh root@52.116.3.216 "forever stop /root/temp-deploy/app.js; rm -rf /root/java-temp-deploy/;"
                        scp -pr ./target/*.jar root@52.116.3.216:/root/java-temp-deploy/
                        ssh root@52.116.3.216 "cd /root/java-temp-deploy/ && java -jar target/*.jar"
                        
                    '''
            }
            // post build section to use "publishDeployRecord" method to publish deploy record and notify OTC of stage status
            post {
                success {
                    publishDeployRecord environment: "STAGING", appUrl: "http://staging-${IBM_CLOUD_DEVOPS_APP_NAME}.mybluemix.net", result:"SUCCESS"
                }
                failure {
                    publishDeployRecord environment: "STAGING", appUrl: "http://staging-${IBM_CLOUD_DEVOPS_APP_NAME}.mybluemix.net", result:"FAIL"
                }
            }
        }
        stage('Gate') {
            steps {
                // use "evaluateGate" method to leverage IBM Cloud DevOps gate
                evaluateGate policy: 'POLICY_NAME_PLACEHOLDER', forceDecision: 'true'
            }
        }
        stage('Deploy to Prod') {
            steps {
                // Push the Weather App to Bluemix, production space
                sh '''
                        echo "Deploying to Prod"
                    '''
            }
            // post build section to use "publishDeployRecord" method to publish deploy record and notify OTC of stage status
            post {
                success {
                    publishDeployRecord environment: "PRODUCTION", appUrl: "http://prod-${IBM_CLOUD_DEVOPS_APP_NAME}.mybluemix.net", result:"SUCCESS"
                }
                failure {
                    publishDeployRecord environment: "PRODUCTION", appUrl: "http://prod-${IBM_CLOUD_DEVOPS_APP_NAME}.mybluemix.net", result:"FAIL"
                }
            }
        }
    }
}
