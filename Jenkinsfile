pipeline {
    agent any

    environment {
        ROOT_DIR = "shop"
    }
    
    parameters {
        string(defaultValue: "1.0.0-RC7", description: "Set git Tag", name: "tag")
        string(defaultValue: "https://github.com/mylek/magento245.git", description: "Repo URL", name: "repoURL")
        string(defaultValue: "https://github.com/mylek/m24_env.git", description: "Repo ENV URL", name: "repoEnvURL")
        string(defaultValue: "ubuntu@ec2-52-209-233-16.eu-west-1.compute.amazonaws.com", description: "Server SSH host", name: "sshHost")
        string(defaultValue: "/var/www/spamgwozd.chickenkiller.com", description: "Server dir", name: "serverDir")
        string(defaultValue: "ssh-agent", description: "SSH Agent", name: "sshAgent")
    }
    
    stages {
        stage("Init") {
        steps {
                script {
                    phpContainer = docker.build("magento")
                    releaseTimestamp = sh(script: "echo `date +%s`", returnStdout: true).trim()
                    TAG = "${params.tag}"
                    REPO_URL = "${params.repoURL}"
                    REPO_ENV_URL = "${params.repoEnvURL}"
                    SSH_HOST = "${params.sshHost}"
                    SERVER_DIR = "${params.serverDir}"
                    SSH_AGENT = "${params.sshAgent}"
                }
            }
        }
        
        stage("Check input") {
            steps {
                script {
                    if (TAG == '') {
                        currentBuild.result = 'ABORTED'
                        error('Tag not set')
                    }
                    if (REPO_URL == '') {
                        currentBuild.result = 'ABORTED'
                        error('Repo URL not set')
                    }
                    if (REPO_ENV_URL == '') {
                        currentBuild.result = 'ABORTED'
                        error('Repo ENV URL not set')
                    }
                    if (SSH_HOST == '') {
                        currentBuild.result = 'ABORTED'
                        error('SSH host not set')
                    }
                    if (SERVER_DIR == '') {
                        currentBuild.result = 'ABORTED'
                        error('Server dir not set')
                    }
                }
            }
        }
        
        stage("Magento Setup") {
            steps {
                script {
                    phpContainer.inside {
                        //sh "rm -rf ${ROOT_DIR}"
                        if (sh(script: "#!/bin/sh \n test -e ${ROOT_DIR}", returnStatus: true) == 1) {
                            sh "git clone ${REPO_URL} --branch=${TAG} ${ROOT_DIR}"
                        }
    
                        if (sh(script: "#!/bin/sh \n test -e env", returnStatus: true) == 1) {
                            sh "git clone ${REPO_ENV_URL} env"
                        }

                        // Remove env.php if exists
                        if (sh(script: "#!/bin/sh \n test -e ${ROOT_DIR}/app/etc/env.php", returnStatus: true) == 0) {
                            sh "rm -rf ${ROOT_DIR}/app/etc/env.php"
                        }
    
                        if (sh(script: "#!/bin/sh \n test -e ${ROOT_DIR}/auth.json", returnStatus: true) == 0) {
                            sh "rm -rf ${ROOT_DIR}/auth.json"
                        }
                        sh "cp env/auth.json ${ROOT_DIR}/auth.json"
                        
                        dir("${ROOT_DIR}") {
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
                        sh "tar -czf shop.tar.gz ${ROOT_DIR}/*"
                    }
                }
            }
        }
        
        stage("Deployment") {
            steps {
                script {
                    try {
                        echo "Deployment tag: ${params.tag}";
                        sshagent(["${SSH_AGENT}"]) {
                            // upload zip file
                            sh "scp -o StrictHostKeyChecking=no shop.tar.gz ${SSH_HOST}:${SERVER_DIR}/tmp/${releaseTimestamp}.tar.gz"
            
                            // create release dir and unzip
                            sh "ssh -tt -o StrictHostKeyChecking=no ${SSH_HOST} sudo -u www-data mkdir ${SERVER_DIR}/releases/${releaseTimestamp}"
                            sh "ssh -tt -o StrictHostKeyChecking=no ${SSH_HOST} sudo -u www-data tar -xzf ${SERVER_DIR}/tmp/${releaseTimestamp}.tar.gz -C ${SERVER_DIR}/releases/${releaseTimestamp} --strip-components=1"
            
                            // create assets symlinks
                            sh "ssh -tt -o StrictHostKeyChecking=no ${SSH_HOST} sudo -u www-data ln -sf ${SERVER_DIR}/share/var/ ${SERVER_DIR}/releases/${releaseTimestamp}"
                            sh "ssh -tt -o StrictHostKeyChecking=no ${SSH_HOST} sudo -u www-data ln -sf ${SERVER_DIR}/share/env.php ${SERVER_DIR}/releases/${releaseTimestamp}/app/etc/env.php"
                            sh "ssh -tt -o StrictHostKeyChecking=no ${SSH_HOST} sudo -u www-data ln -sf ${SERVER_DIR}/share/pub/media ${SERVER_DIR}/releases/${releaseTimestamp}/pub"
            
                            // komendy magento
                            sh "ssh -tt -o StrictHostKeyChecking=no ${SSH_HOST} sudo -u www-data ${SERVER_DIR}/releases/${releaseTimestamp}/bin/magento setup:upgrade --keep-generated -n"
                            
                            // create core symlink
                            sh "ssh -tt -o StrictHostKeyChecking=no ${SSH_HOST} sudo rm -fr ${SERVER_DIR}/current"
                            sh "ssh -tt -o StrictHostKeyChecking=no ${SSH_HOST} sudo -u www-data ln -sf ${SERVER_DIR}/releases/${releaseTimestamp} ${SERVER_DIR}/current"
            
                            // restart services
                            sh "ssh -tt -o StrictHostKeyChecking=no ${SSH_HOST} sudo /etc/init.d/php8.1-fpm restart"
            
                            // Deletes old releases folders leaving the last 3
                            sh "ssh -tt -o StrictHostKeyChecking=no ${SSH_HOST} \"bash -s\" < remove_old_release.sh \"${SERVER_DIR}\" "
                        }
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                    }
                }
            }
        }
        
        stage("Clear up") {
            steps {
                sshagent(["${SSH_AGENT}"]) {
                    // remove archived files
                    sh "ssh -tt -o StrictHostKeyChecking=no ${SSH_HOST} rm -rf ${SERVER_DIR}/tmp/*"
                }
                sh "rm -rf shop.tar.gz"
                sh "rm -rf ${ROOT_DIR}"
                sh "rm -rf env"
            }
        }
    }
}
