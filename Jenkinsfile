pipeline {
  agent{
    kubernetes {
      cloud 'k8s'
      label 'jenkins-maven-pipeline'
      defaultContainer 'jnlp' 
        yaml """
            apiVersion: v1
            kind: Pod
            metadata:
              labels:
                name: jenkins-maven-pipeline
            spec:
              containers:
              - name: maven
                image: maven:3.6.0-jdk-11
                command:
                - cat
                tty: true
    """
    }
  }
    stages {
        stage ('Clone') {
            steps {
                git branch: 'pipeline', url: "https://github.com/yairbass/petclinic-docker.git", credentialsId: 'github'
            }
        }
            stage ('SonarQube') {
            environment {
                scannerHome = tool 'SonarQubeScanner'
            }
            steps {
        withSonarQubeEnv('SonarServer') {
            sh "${scannerHome}/bin/sonar-scanner"
                }
                }
            }
        }
      
        stage ('Artifactory configuration') {
            steps {

                rtMavenDeployer (
                    id: "MAVEN_DEPLOYER",
                    serverId: "artifactory",
                    releaseRepo: "maven-virtual",
                    snapshotRepo: "maven-virtual"
                    
                )

                rtMavenResolver (
                    id: "MAVEN_RESOLVER",
                    serverId: "artifactory",
                    releaseRepo: "maven-virtual",
                    snapshotRepo: "maven-virtual"
                   
                )
            }
        }

        stage ('Exec Maven') {
            steps {
                rtMavenRun (
                    tool: 'MAVEN_TOOL', // Tool name from Jenkins configuration
                    pom: 'pom.xml',
                    goals: 'package -Dmaven.test.skip=true ',
                    deployerId: "MAVEN_DEPLOYER",
                    resolverId: "MAVEN_RESOLVER"
                )
            }
        }
        
        stage("Quality Gate") {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    // Parameter indicates whether to set pipeline to UNSTABLE if Quality Gate fails
                    // true = set pipeline to UNSTABLE, false = don't
                    // Requires SonarQube Scanner for Jenkins 2.7+
                    waitForQualityGate abortPipeline: true
                }
            }
}
        stage ('Publish build info') {
            steps {
                rtPublishBuildInfo (
                    serverId: "artifactory"
                )
            }
        }
        
    stage ('Scan Build with xray') {
        steps {
            script {
                server = Artifactory.server "artifactory"
                def scanConfig = [
                    'buildName'      : env.JOB_NAME,
                    'buildNumber'    : env.BUILD_NUMBER,
                    'failBuild'      : false
                  ]
                def scanResult = server.xrayScan scanConfig
                echo scanResult as String
            }
        
        }
      }
    }
}



