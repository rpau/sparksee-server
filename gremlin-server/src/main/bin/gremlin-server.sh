#!/bin/bash

case `uname` in
  CYGWIN*)
    CP="`dirname $0`"/../conf/
    CP="$CP":$( echo `dirname $0`/../lib/*.jar . | sed 's/ /;/g')
    CP="$CP":$( echo `dirname $0`/../ext/*.jar . | sed 's/ /;/g')
    ;;
  *)
    CP="`dirname $0`"/../conf/
    CP="$CP":$( echo `dirname $0`/../lib/*.jar . | sed 's/ /:/g')
    CP="$CP":$( echo `dirname $0`/../ext/*.jar . | sed 's/ /;/g')
esac
#echo $CP

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
CP=$CP:$(find -L $DIR/../ext/ -name "*.jar" | tr '\n' ':')

export CLASSPATH="${CLASSPATH:-}:$CP"

echo $CLASSPATH

# Find Java
if [ "$JAVA_HOME" = "" ] ; then
    JAVA="java -server"
else
    JAVA="$JAVA_HOME/bin/java -server"
fi

# Set Java options
if [ "$JAVA_OPTIONS" = "" ] ; then
    JAVA_OPTIONS="-Xms32m -Xmx512m"
fi

if [ "$GREMLIN_SERVER_HOME" = "" ] ; then
    $GREMLIN_SERVER_HOME=pwd
fi

# Execute the application and return its exit code
if [ "$1" = "-i" ]; then
  shift
  exec $JAVA -Dlog4j.configuration=file:$GREMLIN_SERVER_HOME/conf/log4j-server.properties $JAVA_OPTIONS -javaagent:$GREMLIN_SERVER_HOME/agents/xray-agent-with-dependencies.jar -cp $CP:$CLASSPATH com.tinkerpop.gremlin.server.util.GremlinServerInstall "$@"
else
  exec $JAVA -Dlog4j.configuration=file:$GREMLIN_SERVER_HOME/conf/log4j-server.properties $JAVA_OPTIONS -javaagent:$GREMLIN_SERVER_HOME/agents/xray-agent-with-dependencies.jar -cp $CP:$CLASSPATH com.tinkerpop.gremlin.server.GremlinServer "$@"
fi