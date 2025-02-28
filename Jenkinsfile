pipeline {
    agent any
    //agent {
        //dockerfile true
    //}
    environment {
        rootDir = "shop"
    }
    
    parameters {
        choice(choices: ["develop", "staging"], description: "Set enviroment", name: "enviroment")
        string(defaultValue: "1.0.0-RC6", description: "Set git Tag", name: "tag")
        string(defaultValue: "https://github.com/mylek/m24.git", description: "Repo URL", name: "repoURL")
        string(defaultValue: "https://github.com/mylek/m24_env.git", description: "Repo ENV URL", name: "repoEnvURL")
    }
    
    stages {
        stage("Check input") {
            steps {
                script {
                    if (params.tag == '') {
                        currentBuild.result = 'ABORTED'
                        error('Tag not set')
                    }
                }
            }
        }
        stage("Initiation docker contener") {
            phpContainer = docker.build("magento")
            sshagent(['ssh-agent']) {
                sh "ssh -tt -o StrictHostKeyChecking=no ubuntu@ec2-63-32-44-175.eu-west-1.compute.amazonaws.com ls -a"
            }
        }
        stage("Magento Setup") {
            steps {
                script {
                    phpContainer.inside {
                        if (!fileExists("${rootDir}")) {
                            sh "git clone ${params.repoURL} --branch=${params.tag} ${rootDir}"
                        }
    
                        if (!fileExists('env')) {
                            sh "git clone ${params.repoEnvURL} env"
                        }
    
                        if (fileExists('${rootDir}/app/etc/env.php')) {
                            sh "rm -rf ${rootDir}/app/etc/env.php"
                        }
                        sh "cp env/env.php ${rootDir}/app/etc/env.php"
    
                        if (fileExists('${rootDir}/auth.json')) {
                            sh "rm -rf ${rootDir}/auth.json"
                        }
                        sh "cp env/auth.json ${rootDir}/auth.json"
                        
                        dir("${rootDir}") {
                            sh "git fetch origin"
                            sh "git checkout -f ${TAG}"
                            sh "composer install --no-dev"
                            sh "rm -rf var/cache/*"
                            sh "rm -rf var/page_cache/*"
                            sh "rm -rf var/preprocessed/*"
                            sh "rm -rf pub/static/*"
                            sh "rm -rf generated/code/*"
                            //sh "php bin/magento setup:di:compile"
                            //sh "php bin/magento setup:static-content:deploy"
                            //sh "php bin/magento cache:flush"
                            //sh "php bin/magento maintenance:enable"
                            //sh "php bin/magento setup:upgrade --keep-generated"
                            //sh "php bin/magento maintenance:disable"
                            //sh "php bin/magento cache:enable"
                            sh 'pwd'
                            sh 'ls -la'
                        }
                    }
                }
            }
        }
        stage("Asset Generation") {
            steps {
                script {
                    phpContainer.inside {
                        sh "tar -cvf var_di.tar.gz ${rootDir}/var/di"
                        sh "rm -rf ${rootDir}/var/di"
                        sh "tar -cvf var_generation.tar.gz ${rootDir}/generated"
                        sh "rm -rf ${rootDir}/generated"
                        sh "tar -cvf pub_static.tar.gz ${rootDir}/pub/static"
                        sh "rm -rf ${rootDir}/pub/static"
                        sh "tar -cvf shop.tar.gz ${rootDir}"
                        sh "ls"
                    }
                }
            }
        }
        stage("Deployment") {
            steps {
                echo "Deployment enviroment ${params.enviroment} tag: ${params.tag}";
            }
        }
        stage("Clear up") {
            steps {
                sh "rm -rf var_di.tar.gz"
                sh "rm -rf var_generation.tar.gz"
                sh "rm -rf pub_static.tar.gz"
                sh "rm -rf shop.tar.gz"
            }
        }
    }
}
