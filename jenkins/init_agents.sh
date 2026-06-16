#!/bin/bash
set -e

JENKINS_URL="http://jenkins:8080"
JENKINS_USER="admin"
JENKINS_PASS="admin"

echo "Attente du démarrage Jenkins..."
until curl -sf "$JENKINS_URL/login" > /dev/null; do
  echo "Jenkins pas encore prêt, attente 5s..."
  sleep 5
done

echo "Téléchargement jenkins-cli.jar..."
curl -sf -o /tmp/jenkins-cli.jar "$JENKINS_URL/jnlpJars/jenkins-cli.jar"

for agent in agent1 agent2; do
  echo "Déclaration de l'agent $agent..."
  cat <<XMLEOF | java -jar /tmp/jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_PASS" create-node "$agent" || echo "Agent $agent déjà existant"
<slave>
  <name>${agent}</name>
  <description>Agent JNLP ${agent}</description>
  <remoteFS>/home/jenkins/agent</remoteFS>
  <numExecutors>2</numExecutors>
  <mode>NORMAL</mode>
  <retentionStrategy class="hudson.slaves.RetentionStrategy\$Always"/>
  <launcher class="hudson.slaves.JNLPLauncher">
    <workDirSettings>
      <disabled>false</disabled>
      <internalDir>remoting</internalDir>
      <failIfWorkDirIsMissing>false</failIfWorkDirIsMissing>
    </workDirSettings>
    <websocket>false</websocket>
  </launcher>
  <label>${agent}</label>
  <nodeProperties/>
</slave>
XMLEOF
done

echo "Agents déclarés."
