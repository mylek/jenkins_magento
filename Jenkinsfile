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
                    // Phing
                    if (!fileExists('phing-latest.phar')) {
                        sh "curl -sS -O https://www.phing.info/get/phing-latest.phar -o /usr/bin/phing"
                    }
                    ls /usr/bin/phing
                    sh "/usr/bin/phing -v"
                    sh "printenv"
                }
            }
        }
        stage("Magento Setup") {
            steps {
                script {
                    sh "rm -fr shop"
                    if (!fileExists('shop')) {
                        sh "git clone https://github.com/mylek/magento-module-test.git --branch=${params.tag} shop &> /dev/null"
                    }
                    sh "ls shop"
                    dir('shop') {
                        sh "${phingCall} jenkins:flush-all"
                        sh "${phingCall} jenkins:setup-project"
                        sh "${phingCall} jenkins:flush-all"
                    }
                    sh "ls shop"
                }
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
                echo "Clear up";
            }
        }
    }
}
