podTemplate(label: 'jenkins-maven-pipeline', cloud: 'k8s' , containers:
        [
        containerTemplate(name: 'gradle', image: 'maven:3.3-jdk-8', command: 'cat', ttyEnabled: true , privileged: true)]) {

    node('jenkins-maven-pipeline'){
        def server = Artifactory.server "artifactory"
        def rtMaven = artifactory
        def buildInfo = Artifactory.newBuildInfo()

        rtMavenDeployer (
                id: "MAVEN_DEPLOYER",
                serverId: "ARTIFACTORY_SERVER",
                releaseRepo: "maven-local-repo",
        )

        rtMavenResolver (
                id: "MAVEN_DEPLOYER",
                serverId: "ARTIFACTORY_SERVER",
                releaseRepo: "maven-local-repo",
        )
    }
    stage ('Exec Maven') {
        rtMaven.run pom: 'petclinic-docker/pom.xml', goals: 'clean install', buildInfo: buildInfo
    }

    stage ('Publish build info') {
        server.publishBuildInfo buildInfo
    }
}
