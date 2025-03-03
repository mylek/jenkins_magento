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
        string(defaultValue: "1.0.0-RC9", description: "Set git Tag", name: "tag")
        string(defaultValue: "https://github.com/mylek/m24.git", description: "Repo URL", name: "repoURL")
        string(defaultValue: "https://github.com/mylek/m24_env.git", description: "Repo ENV URL", name: "repoEnvURL")
        string(defaultValue: "ubuntu@ec2-63-32-44-175.eu-west-1.compute.amazonaws.com", description: "Server SSH host", name: "sshHost")
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
        stage("Init") {
            steps {
                script {
                    phpContainer = docker.build("magento")
                    release = '${currentBuild.startTimeInMillis}'
                    echo release
                }
            }
        }

        stage("Deployment test") {
            steps {
                echo "Deployment enviroment ${params.enviroment} tag: ${params.tag}";

                script {
                    dockerRun = "whoami && \
                    ls -la && \
                    pwd"
    
                    sshagent(['ssh-agent']) {
                        sh "ssh -tt -o StrictHostKeyChecking=no ${params.sshHost} '${dockerRun}'"
                    }
                }
            }
        }
        
        stage("Magento Setup") {
            steps {
                script {
                    phpContainer.inside {
                        if (sh(script: "#!/bin/sh \n test -e ${rootDir}", returnStatus: true) == 1) {
                            sh "git clone ${params.repoURL} --branch=${params.tag} ${rootDir}"
                        }
    
                        if (sh(script: "#!/bin/sh \n test -e env", returnStatus: true) == 1) {
                            sh "git clone ${params.repoEnvURL} env"
                        }

                        // Remove env.php if exists
                        if (sh(script: "#!/bin/sh \n test -e ${rootDir}/app/etc/env.php", returnStatus: true) == 0) {
                            sh "rm -rf ${rootDir}/app/etc/env.php"
                        }
    
                        if (sh(script: "#!/bin/sh \n test -e ${rootDir}/auth.json", returnStatus: true) == 0) {
                            sh "rm -rf ${rootDir}/auth.json"
                        }
                        sh "cp env/auth.json ${rootDir}/auth.json"
                        
                        dir("${rootDir}") {
                            // Git checkout
                            sh "git fetch origin"
                            sh "git checkout -f ${TAG}"
                            sh "composer install --no-dev"

                            // Clear cache
                            sh "rm -rf var/cache"
                            sh "rm -rf var/page_cache/*"
                            sh "rm -rf var/preprocessed/*"
                            sh "rm -rf pub/static/*"
                            sh "rm -rf generated/code/*"

                            // Compilate
                            sh "php bin/magento setup:di:compile"
                            sh "php bin/magento setup:static-content:deploy -f"
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
                        // Put env.php
                        sh "cp env/env.php ${rootDir}/app/etc/env.php"

                        // Archive store content
                        sh "tar -cf shop.tar.gz ${rootDir}"
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
