config {
	daysToKeep = 21
	cronTrigger = ''
	concurrentBuilds = false
	upstreamProjectsTrigger = 'docker/jboss-base-jdk/jdk8'
}

node() {
	git.checkout { }

	dockerfile.validate { }

	stage("Build") {
		def buildImg = dockerfile.build {
			stage = ""
			name = 'jboss/wildfly-build-environment'
			dockerfile = 'Dockerfile.build'
		}
	
		buildImg.inside {
			sh('sh build.sh')
		}
		
		def img = dockerfile.build {
			stage = ""
			name = 'jboss/wildfly'
			args = '--squash'
		}

		dockerfile.publish {
			image = img
			tags = [ "12.0.0.Final"]
		}
	}
}
