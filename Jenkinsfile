config {
	daysToKeep = 21
	cronTrigger = '@weekend'
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
