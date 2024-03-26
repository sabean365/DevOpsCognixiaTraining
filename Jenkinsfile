pipeline {
	agent {
  		label 'Sarah-Laptop'
	}
	tools {
    	maven 'MAVEN_3'
	}
	triggers {
  		bitbucketPush buildOnCreatedBranch: false, overrideUrl: ''
	}
	stages {
		stage ('Compile & Build') {
			steps {
    			bat 'mvn clean package'
  			}
			post {
    			success {
			  		archiveArtifacts artifacts: 'target/*.war', followSymlinks: false
    			}
			}	
		}
		stage ('Build Image') {
			steps {
                bat 'docker image build . -f Dockerfile -t sabean365/javawebapp:1.0'
			}
		}
		stage ('Push Image to Docker Hub') {
			steps {
				withCredentials([usernamePassword(credentialsId: 'sarah-bb', passwordVariable: 'DOCKERHUB_PASSWORD', usernameVariable: 'DOCKERHUB_USERNAME')]) {
					bat '''docker login -u %DOCKERHUB_USERNAME% -p %DOCKERHUB_PASSWORD%
                    docker image build . -f Dockerfile -t sabean365/javawebapp:1.0'''
				}			
			}
		}
        stage('Deploy') {
            steps {
                sh 'ls -lrt'
			}
		    agent {
			    label 'built-in'
		    }
	    }
    }
    
}