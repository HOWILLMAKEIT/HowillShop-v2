#!/bin/zsh
set -e
source ~/.zshrc

CATALINA_HOME=~/opt/apache-tomcat-9.0.105

echo ">>> 编译项目..."
mvn -DskipTests compile
mvn -DskipTests dependency:copy-dependencies -DoutputDirectory=target/dependency

echo ">>> 启动 Tomcat..."
$CATALINA_HOME/bin/startup.sh

echo ">>> 启动完成，访问 http://localhost:8080/shop/"
