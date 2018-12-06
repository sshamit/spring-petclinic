#!/bin/bash
java -jar *.jar &      # You send it in background
MyPID=$!                        # You sign it's PID
echo $MyPID                     # You print to terminal
chmod +x stop.sh
echo "kill -9 $MyPID" > stop.sh  # Write the the command kill pid in MyStop.sh
