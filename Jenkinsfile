pipeline {
    agent {
        dockerfile true
    }

    environment {
        phingFile = "/var/jenkins_home/workspace/Magento/phing-latest.phar"
        phingCall = "php ${phingFile}"
    }
    
    parameters {
        choice(choices: ["develop", "staging"], description: "Set enviroment", name: "enviroment")
        string(defaultValue: "1.0.0-RC5", description: "Set git Tag", name: "tag")
        string(defaultValue: "https://github.com/mylek/m24.git", description: "Repo URL", name: "repoURL")
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
                    if (!fileExists("${phingFile}")) {
                        sh "curl -sS https://www.phing.info/get/phing-latest.phar"
                    }
                    sh "${phingCall} -v"
                }
            }
        }
        stage("Magento Setup") {
            steps {
                script {
                    if (!fileExists('shop')) {
                        sh "git clone ${params.repoURL} --branch=${params.tag} shop"
                        //sh "git clone ${params.repoURL} --branch=${params.tag} shop &> /dev/null"
                    }
                    dir('shop') {
                        sh "git fetch origin"
                        sh "git checkout -f ${TAG}"
                        sh "php bin/magento maintenance:enable"
                        sh "rm -rf vendor/*"
                        sh "rm -rf var/cache/*"
                        sh "rm -rf var/page_cache/*"
                        sh "rm -rf var/preprocessed/*"
                        sh "rm -rf pub/static/*"
                        sh "rm -rf generated/code/*"
                        sh "composer install --no-dev"
                        sh "php bin/magento setup:upgrade"
                        sh "php bin/magento setup:di:compile"
                        sh "php bin/magento setup:static-content:deploy"
                        sh "php bin/magento cache:flush"
                        sh "php bin/magento maintenance:disable"
                        sh "php bin/magento cache:enable"
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
