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
            steps {
                script {
                    phpContainer = docker.build("magento")
                    //sshagent(['ssh-agent']) {
                    //    sh "ssh -tt -o StrictHostKeyChecking=no ubuntu@ec2-63-32-44-175.eu-west-1.compute.amazonaws.com ls -a"
                    //}
                }
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

                        sh "cat ${rootDir}/app/etc/env.php"
                        sh "[ -f ${rootDir}/app/etc/env.php ]"
                        // Remove env.php if exists
                        if (fileExists('${rootDir}/app/etc/env.php')) {
                            sh "rm -rf ${rootDir}/app/etc/env.php"
                        }
    
                        if (fileExists('${rootDir}/auth.json')) {
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
                        if (fileExists('${rootDir}/app/etc/env.php')) {
                            sh "rm -rf ${rootDir}/app/etc/env.php"
                        }
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
