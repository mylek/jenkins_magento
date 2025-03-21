pipeline {
    agent any
    
    parameters {
        string(defaultValue: "1.0.0-RC7", description: "Set git Tag", name: "tag")
        string(defaultValue: "https://github.com/mylek/magento245.git", description: "Repo URL", name: "repoURL")
        string(defaultValue: "https://github.com/mylek/m24_env.git", description: "Repo ENV URL", name: "repoEnvURL")
        string(defaultValue: "ubuntu@ec2-52-209-233-16.eu-west-1.compute.amazonaws.com", description: "Server SSH host", name: "sshHost")
        string(defaultValue: "/var/www/spamgwozd.chickenkiller.com", description: "Server dir", name: "serverDir")
        string(defaultValue: "ssh-agent", description: "SSH Agent", name: "sshAgent")
    }
    environment {
        rootDir = "shop"
        TAG = "${params.tag}";
    }
    
    stages {
        stage("Check input") {
            steps {
                script {
                    echo ${TAG}
                    if (params.tag == '') {
                        currentBuild.result = 'ABORTED'
                        error('Tag not set')
                    }
                    if (params.repoURL == '') {
                        currentBuild.result = 'ABORTED'
                        error('Repo URL not set')
                    }
                    if (params.repoEnvURL == '') {
                        currentBuild.result = 'ABORTED'
                        error('Repo ENV URL not set')
                    }
                    if (params.sshHost == '') {
                        currentBuild.result = 'ABORTED'
                        error('SSH host not set')
                    }
                    if (params.serverDir == '') {
                        currentBuild.result = 'ABORTED'
                        error('Server dir not set')
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
                        //sh "rm -rf ${rootDir}"
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
                            //sh "rm -rf var/cache"
                            //sh "rm -rf var/page_cache/*"
                            //sh "rm -rf var/preprocessed/*"
                            sh "rm -rf pub/static/*"
                            sh "rm -rf generated/code/*"

                            // Compilate
                            sh "php bin/magento setup:di:compile"
                            sh "php bin/magento setup:static-content:deploy -f"
                            sh "rm -rf var"
                            sh "rm -rf pub/media"
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
                script {
                    try {
                        echo "Deployment tag: ${params.tag}";
                        sshagent(["${params.sshAgent}"]) {
                            // upload zip file
                            sh "scp -o StrictHostKeyChecking=no shop.tar.gz ${params.sshHost}:${params.serverDir}/tmp/${releaseTimestamp}.tar.gz"
            
                            // create release dir and unzip
                            sh "ssh -tt -o StrictHostKeyChecking=no ${params.sshHost} sudo -u www-data mkdir ${params.serverDir}/releases/${releaseTimestamp}"
                            sh "ssh -tt -o StrictHostKeyChecking=no ${params.sshHost} sudo -u www-data tar -xzf ${params.serverDir}/tmp/${releaseTimestamp}.tar.gz -C ${params.serverDir}/releases/${releaseTimestamp} --strip-components=1"
            
                            // create assets symlinks
                            sh "ssh -tt -o StrictHostKeyChecking=no ${params.sshHost} sudo -u www-data ln -sf ${params.serverDir}/share/var/ ${params.serverDir}/releases/${releaseTimestamp}"
                            sh "ssh -tt -o StrictHostKeyChecking=no ${params.sshHost} sudo -u www-data ln -sf ${params.serverDir}/share/env.php ${params.serverDir}/releases/${releaseTimestamp}/app/etc/env.php"
                            sh "ssh -tt -o StrictHostKeyChecking=no ${params.sshHost} sudo -u www-data ln -sf ${params.serverDir}/share/pub/media ${params.serverDir}/releases/${releaseTimestamp}/pub"
            
                            // komendy magento
                            sh "ssh -tt -o StrictHostKeyChecking=no ${params.sshHost} sudo -u www-data ${params.serverDir}/releases/${releaseTimestamp}/bin/magento setup:upgrade --keep-generated -n"
                            
                            // create core symlink
                            sh "ssh -tt -o StrictHostKeyChecking=no ${params.sshHost} sudo rm -fr ${params.serverDir}/current"
                            sh "ssh -tt -o StrictHostKeyChecking=no ${params.sshHost} sudo -u www-data ln -sf ${params.serverDir}/releases/${releaseTimestamp} ${params.serverDir}/current"
            
                            // restart services
                            sh "ssh -tt -o StrictHostKeyChecking=no ${params.sshHost} sudo /etc/init.d/php8.1-fpm restart"
            
                            // Deletes old releases folders leaving the last 3
                            sh "ssh -tt -o StrictHostKeyChecking=no ${params.sshHost} \"bash -s\" < remove_old_release.sh \"${params.serverDir}\" "
                        }
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                    }
                }
            }
        }
        
        stage("Clear up") {
            steps {
                sshagent(["${params.sshAgent}"]) {
                    // remove archived files
                    sh "ssh -tt -o StrictHostKeyChecking=no ${params.sshHost} rm -rf ${params.serverDir}/tmp/*"
                }
                sh "rm -rf shop.tar.gz"
                sh "rm -rf ${rootDir}"
                sh "rm -rf env"
            }
        }
    }
}
