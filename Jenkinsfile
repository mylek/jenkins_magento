pipeline {
    agent any
    
    environment {
        rootDir = "shop"
    }
    
    parameters {
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
                    releaseTimestamp = sh(script: "echo `date +%s`", returnStdout: true).trim()
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
                        }
                    }
                }
            }
        }
        stage("Asset Generation") {
            steps {
                script {
                    phpContainer.inside {
                        // Archive store content
                        sh "tar -czf shop.tar.gz ${rootDir}/*"
                    }
                }
            }
        }
        stage("Deployment") {
            steps {
                echo "Deployment tag: ${params.tag}";
                sshagent(['ssh-agent']) {
                    sh "scp -o StrictHostKeyChecking=no shop.tar.gz ${params.sshHost}:/var/www/html/tmp/${releaseTimestamp}.tar.gz"
                    sh "ssh -tt -o StrictHostKeyChecking=no ${params.sshHost} \"bash -s\" < deploy.sh \"${releaseTimestamp}\""
                }
            }
        }
        stage("Clear up") {
            steps {
                sh "rm -rf shop.tar.gz"
                sh "rm -rf ${rootDir}"
                sh "rm -rf env"
            }
        }
    }
}
