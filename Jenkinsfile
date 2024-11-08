pipeline {
    agent {
        dockerfile true
    }

    environment {
        FOO = "sh"
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
                        sh "curl -sS https://www.phing.info/get/phing-latest.phar --output /run/phing-latest.phar"
                    }
                    sh "ls /run"
                    sh "php /var/jenkins_home/workspace/Magento/phing-latest.phar -v"
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
                    dir('shop') {
                        sh "ls"
                        sh "php /var/jenkins_home/workspace/Magento/phing-latest.phar jenkins:flush-all"
                        sh "php /phing-latest.phar jenkins:setup-project"
                        sh "php /phing-latest.phar jenkins:flush-all"
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
