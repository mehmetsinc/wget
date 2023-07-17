#!/bin/bash

Set the names of the master and slave servers
MASTER_HOST="10.16.0.230"
SLAVE_HOST="10.16.0.229"

Set the username and password for the replication user
USERNAME="replication"
PASSWORD="password"

Stop the replication on the slave server
echo "STOP SLAVE;" | mysql -h $SLAVE_HOST -u $USERNAME -p$PASSWORD

Flush the binary logs on the master server
echo "FLUSH BINARY LOGS;" | mysql -h $MASTER_HOST -u $USERNAME -p$PASSWORD

Get the current master log position
MASTER_LOG_POSITION=$(mysql -h $MASTER_HOST -u $USERNAME -p$PASSWORD -A -e"SHOW MASTER STATUS\G" | awk '{print $12}')

Start the replication on the slave server
echo "START SLAVE;" | mysql -h $SLAVE_HOST -u $USERNAME -p$PASSWORD

Wait for the slave server to catch up to the master server
while [ ! $(mysql -h $SLAVE_HOST -u $USERNAME -p$PASSWORD -A -e"SHOW SLAVE STATUS\G" | awk '{print $10}') -eq $MASTER_LOG_POSITION ]; do
echo "Waiting for the slave server to catch up..."
sleep 1
done

The slave server is now synchronized with the master server
echo "The slave server is now synchronized with the master server."
