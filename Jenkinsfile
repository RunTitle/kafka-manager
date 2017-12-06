node {

  def org = 'runtitle'
  def appName = 'kafka-manager'

  try {
    stage('build'){
      notifyBuild('STARTED')
      checkout scm

      gitCommit = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
      shortCommit = gitCommit.take(6)

      commitTag = "${org}/${appName}:${env.BRANCH_NAME}.${gitCommit}"
      branchTag = "${org}/${appName}:${env.BRANCH_NAME}"

      def app =  docker.build "${commitTag}"
    }

    // stage('test') {
    //   // Replace container names in compose file
    //   sh("sed -i. 's#${appName}.test#${appName}.test.${env.BRANCH_NAME}.${env.BUILD_NUMBER}#' docker-compose-tests.sh")
    //   sh("sed -i. 's#${appName}.test#${appName}.test.${env.BRANCH_NAME}.${env.BUILD_NUMBER}#' docker-compose-tests.yml")
    //   sh("sed -i. 's#${appName}.postgres#${appName}.postgres.${env.BRANCH_NAME}.${env.BUILD_NUMBER}#' docker-compose-tests.yml")
    //   sh("sed -i. 's#${org}/${appName}:latest#${commitTag}#' docker-compose-tests.yml")

    //   // Run tests
    //   sh('./docker-compose-tests.sh')
    // }

    stage('publish'){
      sh("docker tag ${commitTag} ${branchTag}")

      withCredentials([file(credentialsId: 'docker.config.json', variable: 'CONFIGFILE')]){
        sh("mkdir -p ~/.docker")
        sh("cp $CONFIGFILE ~/.docker/config.json")
      }
      sh("docker push ${commitTag}")
      sh("docker push ${branchTag}")
    }

    stage('deploy'){
      switch(env.BRANCH_NAME){
        case 'staging':
          withCredentials([file(credentialsId: 'cluster-staging.runtitle.com-config', variable: 'KUBERNETES_CONFIG')]){
            sh('mkdir -p ~/.kube')
            sh('cp $KUBERNETES_CONFIG ~/.kube/config')
            sh("sed -i.bak 's#${org}/${appName}:latest#${commitTag}#' kube/*.yaml")
            sh("kubectl config current-context")
            // sh("kubectl apply --namespace=default -f kube/payzone.cm.yaml")

            sh("kubectl apply --namespace=default -f kube/kafka-manager.dep.yaml")
            sh("kubectl apply --namespace=default -f kube/kafka-manager.svc.yaml")
          }
          break
        // case 'master':
        //   echo 'master branch'
        //   withCredentials([file(credentialsId: 'cluster-production.runtitle.com-config', variable: 'KUBERNETES_CONFIG')]){
        //     sh('mkdir -p ~/.kube')
        //     sh('cp $KUBERNETES_CONFIG ~/.kube/config')
        //     sh("sed -i.bak 's#${org}/${appName}:latest#${commitTag}#' kube/*.yaml")
        //     sh("kubectl config current-context")
        //     sh("kubectl apply --namespace=default -f kube/payzone.cm.yaml")

        //     sh("kubectl apply --namespace=default -f kube/payzone.dep.api.yaml")
        //     sh("kubectl apply --namespace=default -f kube/payzone.svc.api.yaml")

        //     sh("kubectl apply --namespace=default -f kube/payzone.dep.rabbitmq.yaml")
        //     sh("kubectl apply --namespace=default -f kube/payzone.svc.rabbitmq.yaml")

        //     sh("kubectl apply --namespace=default -f kube/payzone.dep.redis.yaml")
        //     sh("kubectl apply --namespace=default -f kube/payzone.svc.redis.yaml")

        //     sh("kubectl apply --namespace=default -f kube/payzone.dep.grpc.yaml")
        //     sh("kubectl apply --namespace=default -f kube/payzone.svc.grpc.yaml")

        //     sh("kubectl apply --namespace=default -f kube/payzone.dep.flower.yaml")
        //     sh("kubectl apply --namespace=default -f kube/payzone.svc.flower.yaml")

        //     sh("kubectl apply --namespace=default -f kube/payzone.dep.worker.yaml")
        //   }
        //   break
        default:
          // do nothing?
          echo 'no-op'
      }
    }
  } catch(e){
    currentBuild.result = "FAILED"
    throw e
  } finally {
    notifyBuild(currentBuild.result)
  }
}

def notifyBuild(String buildStatus = 'STARTED') {
  // build status of null means successful
  buildStatus =  buildStatus ?: 'SUCCESSFUL'

  // Default values
  def colorName = 'RED'
  def colorCode = '#FF0000'
  def subject = "${buildStatus}: Job '${env.JOB_NAME}'"
  def summary = "${subject}\n${env.BUILD_URL}console"
  def details = """<p>STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
    <p>Check console output at &QUOT;<a href='${env.BUILD_URL}console'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>&QUOT;</p>"""

  // Override default values based on build status
  if (buildStatus == 'STARTED') {
    color = 'YELLOW'
    colorCode = '#FFFF00'
  } else if (buildStatus == 'SUCCESSFUL') {
    color = 'GREEN'
    colorCode = '#00FF00'
  } else {
    color = 'RED'
    colorCode = '#FF0000'
  }

  // Send notifications
  slackSend (color: colorCode, message: summary)
}
