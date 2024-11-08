pipeline {
    agent {
        dockerfile true
    }
    
    parameters {
        choice(choices: ["develop", "staging"], description: "Set enviroment", name: "enviroment")
        string(defaultValue: "1.0.0-RC1", description: "Set git Tag", name: "tag")
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
                script {
                    echo "Tool Setup";
                    sh "rm -fr shop"
                    if (!fileExists('shop')) {
                        sh "git clone https://github.com/mylek/magento-module-test.git --branch=${params.tag} shop"
                    }
                    sh "ls shop"
                    sh "git fetch origin"
                    sh "git checkout -f ${params.tag}"
                    sh "git reset --hard origin/${params.tag}"
                    sh "ls shop"
                    sh "php -v"
                }
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
        stage("Clear up") {
            steps {
                sh "rm -fr shop"
            }
        }
    }
}
