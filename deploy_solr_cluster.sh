#!/bin/bash
# vim: set sw=4 sts=4 et foldmethod=indent :

SOLRCLOUD_HOME=$HOME/solr-cloud-home
NODE1=$SOLRCLOUD_HOME/node1/solr
NODE2=$SOLRCLOUD_HOME/node2/solr
GDB_CONFIGSET=$SOLRCLOUD_HOME/gdb_configset
ZK_HOST=localhost:2181
SOLR=$SOLR_HOME/bin/solr
SOLR_ZK_CLI=$SOLR_HOME/server/scripts/cloud-scripts/zkcli.sh


mkdir -p $NODE1 $NODE2

cp $GDB_CONFIGSET/node_config/* $NODE1
cp $GDB_CONFIGSET/node_config/* $NODE2

#cp -r $GDB_CONFIGSET/conf $NODE1
#cp -r $GDB_CONFIGSET/conf $NODE2

# Start Zookeeper
$ZK_HOME/bin/zkServer.sh start

# Upload GDB Solr Connector schema configuration
$SOLR_ZK_CLI \
    -zkhost $ZK_HOST \
    -cmd upconfig \
    -confname gdb_configset \
    -confdir $GDB_CONFIGSET/conf

# Start the configured nodes
$SOLR start -cloud -s $NODE1 -p 8983 -z $ZK_HOST
$SOLR start -cloud -s $NODE2 -p 8984 -z $ZK_HOST

$SOLR create_collection \
    -c collection1 \
    -n gdb_configset \
    -shards 2 \
    -replicationFactor 2 \
    -p 8983




