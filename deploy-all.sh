#!/bin/bash 

set -euo pipefail 

echo "Starting full deployment...."

bash scripts/01-resource-group.sh
bash scripts/02-networking.sh 
bash scripts/03-compute.sh 
bash scripts/04-storage.sh
bash scripts/05-iam.sh
bash scripts/06-monitoring.sh 
bash scripts/07-backup.sh 


echo "deployment competed" 