#!/bin/bash

INSTALL_DIR=$HOME/elk
LOGSTASH_PATH=logstash-1.4.1
LOGSTASH_BINARY=$LOGSTASH_PATH.tar.gz
ES_PATH=elasticsearch-1.2.1
ES_BINARY=$ES_PATH.tar.gz
NFL_DATA_FILE_NAME=2012_nfl_pbp_data.csv
NFL_DATA_BINARY=2012_nfl_pbp_data.csv.gz
KIBANA_PATH=kibana-3.1.0
KIBANA_BINARY=$KIBANA_PATH.tar.gz


echo Installing ELK stack into $INSTALL_DIR
mkdir -p $INSTALL_DIR

cp twitter.conf $INSTALL_DIR
cp nfl.conf $INSTALL_DIR
cp week-by-week.json $INSTALL_DIR
cp $NFL_DATA_BINARY $INSTALL_DIR

cd $INSTALL_DIR
if test -s $LOGSTASH_BINARY
then
    echo Logstash already Downloaded
else
	echo Downloading $LOGSTASH_BINARY
	curl -O https://download.elasticsearch.org/logstash/logstash/$LOGSTASH_BINARY
fi

if test -s $ES_BINARY
then
    echo Elasticsearch already Downloaded
else
	echo Downloading $ES_PATH
	curl -O https://download.elasticsearch.org/elasticsearch/elasticsearch/$ES_BINARY
fi

if test -s $KIBANA_BINARY
then
    echo Kibana already Downloaded
else
	echo Downloading $KIBANA_BINARY
	curl -O https://download.elasticsearch.org/kibana/kibana/$KIBANA_BINARY
fi

echo Downloaded... Now installing
echo Unpacking logstash
tar zxf $LOGSTASH_BINARY

echo Unpacking Elasticsearch
tar zxf $ES_BINARY

echo Unpacking nfl dataset
gunzip -f $NFL_DATA_BINARY

cd $ES_PATH
if [ -d "plugins/marvel" ];
then
    echo Marvel already installed
else
	echo Installing Marvel latest
	bin/plugin -i elasticsearch/marvel/latest
fi

if [ -d "plugins/kibana" ];
then
    echo Kibana already installed
else
  echo Installing $KIBANA_BINARY
  mkdir -p plugins/kibana/
  tar zxf ../$KIBANA_BINARY
  mv $KIBANA_PATH plugins/kibana/_site
fi

cp ../week-by-week.json plugins/kibana/_site/app/dashboards/

if [ -d "plugins/kopf" ];
then
    echo kopf already installed
else
	echo Installing kopf latest
	bin/plugin -i lmenezes/elasticsearch-kopf
fi

echo Starting Elasticsearch to run in the background.  
bin/elasticsearch -d --cluster.name=es_demo --network.host=localhost

cd ../$LOGSTASH_PATH
echo loading nfl data using logstash
sh bin/logstash -f ../nfl.conf < ../$NFL_DATA_FILE_NAME

echo Now browse to:
echo  http://localhost:9200/_plugin/marvel
echo or
echo http://localhost:9200/_plugin/kopf
echo or
echo http://localhost:9200/_plugin/kibana
echo or
echo http://localhost:9200/_plugin/kibana/index.html#/dashboard/file/week-by-week.json

exit
