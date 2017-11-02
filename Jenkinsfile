config {
	daysToKeep = 21
	cronTrigger = ''
	upstreamProjectsTrigger = 'docker/jboss-base-jdk/jdk8'
}

node() {
	git.checkout { }

	dockerfile.validate { }

	def img = dockerfile.build {
		name = 'jboss/wildfly'
		args = '--squash'
	}

	dockerfile.publish {
		image = img
		tags = [ "11.0.0.Final"]
	}
}
