config {
	daysToKeep = 21
	cronTrigger = ''
	upstreamProjectsTrigger = 'docker/jboss-base-jdk/jdk8'
}

node() {
	git.checkout { }

	dockerfile.validate { }
	dockerfile.validate {
		dockerfile = 'Dockerfile.build'
	}

	def buildimg = dockerfile.build {
		name = 'wildflybuild'
		dockerfile = 'Dockerfile.build'
		args = '--tag wildflybuild'
	}

	// TODO

	def img = dockerfile.build {
		name = 'jboss/wildfly'
		args = '--squash'
	}

	dockerfile.publish {
		image = img
		tags = [ "11.0.0.Final.topicus1"]
	}
}
