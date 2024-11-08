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
                script {
                    echo "Tool Setup";
                    if (!fileExists('shop')) {
                        git -v
                        sh "git --version"
                        sh "git clone https://github.com/mylek/magento-module-test.git shop"
                    } else {
                        dir('shop') {
                            sh "git fetch origin"
                            sh "git checkout -f ${params.tag}"
                            sh "git reset --hard origin/${params.tag}"
                        }
                    }
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
    }
}
