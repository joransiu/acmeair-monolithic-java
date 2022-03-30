#!/usr/bin/env bash

ACMEAIR_HOME=`pwd`
cd ..

if [ ! -d acmeair-driver ]; then
    git clone git@github.com:blueperf/acmeair-driver.git
fi
cd acmeair-driver

JMETER_HOME=`pwd`/apache-jmeter-5.4.3
echo "JMETER_HOME: $JMETER_HOME"

if [ ! -d $JMETER_HOME ]; then
    echo "Downloading JMeter..."
    wget -q https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-5.4.3.tgz
    tar xzf apache-jmeter-5.4.3.tgz
    rm apache-jmeter-5.4.3.tgz
    cp $JMETER_HOME/bin/jmeter.properties $JMETER_HOME/bin/jmeter.properties.orig
fi

if [ ! -f $JMETER_HOME/lib/ext/json-simple-1.1.1.jar ]; then
    echo "Downloading json-simple-1.1.1 to $JMETER_HOME/lib/ext"
    wget -q https://repo1.maven.org/maven2/com/googlecode/json-simple/json-simple/1.1.1/json-simple-1.1.1.jar
    mv json-simple-1.1.1.jar $JMETER_HOME/lib/ext
fi

if [ ! -f $JMETER_HOME/lib/ext/acmeair-jmeter-2.0.0-SNAPSHOT.jar ]; then
    cp acmeair-jmeter-2.0.0-SNAPSHOT.jar $JMETER_HOME/lib/ext
fi

if [ ! -f $JMETER_HOME/bin/jmeter.properties.orig ]; then
	echo "Expected setup above to have saved a copy of the original $JMETER_HOME/bin/jmeter.properties file."
	exit 1;
fi
cp $JMETER_HOME/bin/jmeter.properties.orig $JMETER_HOME/bin/jmeter.properties

cat >> $JMETER_HOME/bin/jmeter.properties <<EOF 
#---------------------------------------------------------------------------
# Summariser - Generate Summary Results - configuration (mainly applies to non-GUI mode)
#---------------------------------------------------------------------------
#
log_level.jmeter.reporters.Summariser=INFO
summariser.name=summary
summariser.interval=30
summariser.log=true

# Required for AcmeAir
CookieManager.save.cookies=true
EOF

cd acmeair-jmeter/scripts
EXECUTION_DIR=`pwd`
echo "Execution Directory: $EXECUTION_DIR"
taskset -c 16-23 $JMETER_HOME/bin/jmeter -n -t $ACMEAIR_HOME/AcmeAir-v5.jmx -DusePureIDs=true -JHOST=localhost -JPORT=80 -j logName -JTHREAD=1 -JUSER=999 -JDURATION=300 -JRAMP=0 -JPROTOCOL=https
