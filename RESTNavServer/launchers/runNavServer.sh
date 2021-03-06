#!/bin/bash
# Navigation REST server
#
echo -e "----------------------------"
echo -e "Usage is $0 [-p|--proxy] [-m:propertiesfile|--mux:propertiesfile] [--no-date] [--sun-flower]"
echo -e "     -p or --proxy means with a proxy"
echo -e "     -m or --mux points to the properties file to use for the Multiplexer, default is nmea.mux.properties"
echo -e "     -sf or --sun-flower means with Sun Flower option (extra Request Manager)"
echo -e "     --no-date does not put any GPS date or time (replayed or live) in the cache (allows you to use a ZDA generator)"
echo -e "----------------------------"
#
echo -e "⚓ Starting the Navigation Rest Server 🌴"
echo -e "----------------------------------------"
echo -e "Args are $@"
echo -e "----------------------------------------"
#
USE_PROXY=false
NO_DATE=false
SUN_FLOWER=false
PROP_FILE=
#
for ARG in "$@"
do
	echo -e "Managing prm $ARG"
  if [ "$ARG" == "-p" ] || [ "$ARG" == "--proxy" ]
  then
    USE_PROXY=true
  elif [ "$ARG" == "--no-date" ]
  then
    NO_DATE=true
  elif [ "$ARG" == "-sf" ] || [ "$ARG" == "--sun-flower" ]
  then
    SUN_FLOWER=true
    echo -e "SUN_FLOWER is now $SUN_FLOWER"
  elif [[ $ARG == -m:* ]] || [[ $ARG == --mux:* ]] # !! No quotes !!
  then
    PROP_FILE=${ARG#*:}
    echo -e "Detected properties file $PROP_FILE"
  fi
done
#
HTTP_VERBOSE=false
TIDE_VERBOSE=false
ASTRO_VERBOSE=false
IMAGE_VERBOSE=false
GRIB_VERBOSE=false
#
CP=../build/libs/RESTNavServer-1.0-all.jar
JAVA_OPTS=
# For the value of Delta T, see:
# - http://maia.usno.navy.mil/ser7/deltat.data
# - http://maia.usno.navy.mil/
# Delta T predictions: http://maia.usno.navy.mil/ser7/deltat.preds
JAVA_OPTS="$JAVA_OPTS -DdeltaT=68.9677" # 01-Jan-2018
JAVA_OPTS="$JAVA_OPTS -Dhttp.verbose=$HTTP_VERBOSE"
JAVA_OPTS="$JAVA_OPTS -Dtide.verbose=$TIDE_VERBOSE"
JAVA_OPTS="$JAVA_OPTS -Dastro.verbose=$ASTRO_VERBOSE"
JAVA_OPTS="$JAVA_OPTS -Dimage.verbose=$IMAGE_VERBOSE"
JAVA_OPTS="$JAVA_OPTS -Dgrib.verbose=$GRIB_VERBOSE"
#
if [ "$USE_PROXY" == "true" ]
then
  echo -e "Using proxy (hard-coded)"
  JAVA_OPTS="$JAVA_OPTS -Dhttp.proxyHost=www-proxy-hqdc.us.oracle.com -Dhttp.proxyPort=80"
fi
#
# refers to nmea.mux.properties, unless -Dmux.properties is set
WEATHER_STATION=false # Hard coded, for now...
#
if [ "$WEATHER_STATION" == "true" ]
then
	echo -e "+----------------------------------------------------------------+"
	echo -e "| Using nmea.mux.home.properties, TCP input from Weather station |"
	echo -e "+----------------------------------------------------------------+"
	JAVA_OPTS="$JAVA_OPTS -Dmux.properties=nmea.mux.home.properties"
	JAVA_OPTS="$JAVA_OPTS -Ddefault.sf.latitude=37.7489 -Ddefault.sf.longitude=-122.5070" # SF.
else
  JAVA_OPTS="$JAVA_OPTS -Dwith.sun.flower=$SUN_FLOWER"
  if [ "$PROP_FILE" != "" ]
  then
    JAVA_OPTS="$JAVA_OPTS -Dmux.properties=$PROP_FILE"
  fi
fi
#
if [ "$WEATHER_STATION" == "false" ] && [ "$SUN_FLOWER" == "true" ]
then
  JAVA_OPTS="$JAVA_OPTS -Dwith.sun.flower=$SUN_FLOWER"
	JAVA_OPTS="$JAVA_OPTS -Ddefault.sf.latitude=37.7489 -Ddefault.sf.longitude=-122.5070" # SF.
fi
#
# Specific/Temporary
# JAVA_OPTS="$JAVA_OPTS -Dnmea.cache.verbose=true"
if [ "$NO_DATE" == "true" ]
then
	# To use when re-playing GPS data. Those dates will not go in the cache.
	JAVA_OPTS="$JAVA_OPTS -Ddo.not.use.GGA.date.time=true"
	JAVA_OPTS="$JAVA_OPTS -Ddo.not.use.GLL.date.time=true"
fi
# Default position
JAVA_OPTS="$JAVA_OPTS -Ddefault.mux.latitude=37.7489 -Ddefault.mux.longitude=-122.5070" # SF.
#
# Polar file (coeffs)
#
JAVA_OPTS="$JAVA_OPTS -Dpolar.file.location=./sample.data/polars/CheoyLee42.polar-coeff"
#
echo -e "Using properties:$JAVA_OPTS"
#
java -cp $CP $JAVA_OPTS navrest.NavServer
#
echo -e "Bye now ✋"
#
