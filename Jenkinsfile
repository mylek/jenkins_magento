pipeline {
    agent {
        dockerfile true
    }
    
    parameters {
        choice(choices: ["develop", "staging"], description: "Set enviroment", name: "enviroment")
        string(defaultValue: "", description: "Set git Tag", name: "tag")
    }
    
    stages {
        stage("Check Input") {
            steps {
                script {
                    if (params.tag == '') {
                        currentBuild.result = 'ABORTED'
                        error('Tag not set')
                    }
                }
            }
        }
        stage("Tool Setup") {
            steps {
                echo "Tool Setup";
                sh "php -v"
            }
        }
        stage("Magento Setup") {
            steps {
                echo "Magento Setup";
            }
        }
        stage("Asset Generation") {
            steps {
                echo "Asset Generation";
            }
        }
        stage("Deployment") {
            steps {
                echo "Deployment enviroment ${params.enviroment} tag: ${params.tag}";
            }
        }
    }
}
