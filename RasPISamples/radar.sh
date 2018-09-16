#!/bin/bash
CP=./build/libs/RasPISamples-1.0-all.jar
#
JAVA_OPTIONS=
# JAVA_OPTIONS="$JAVA_OPTIONS -Dverbose=true"
# For remote debugging:
# JAVA_OPTIONS="$JAVA_OPTIONS -client -agentlib:jdwp=transport=dt_socket,server=y,address=4000"
# For remote JVM Monitoring
# JAVA_OPTIONS="$JAVA_OPTIONS -Dcom.sun.management.jmxremote.port=1234 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Djava.rmi.server.hostname=raspberrypi-boat"
#
JAVA_OPTIONS=
#
# Physical pin numbers, delay.
PRMS=
PRMS="$PRMS --servo-port:15"
PRMS="$PRMS --delay:100"
#
echo Running...
sudo java $JAVA_OPTIONS -cp $CP raspiradar.RasPiRadar $PRMS
