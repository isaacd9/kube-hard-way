#!/bin/bash

export GCE_EMAIL=$(cat ../secrets/project_email)
export GCE_PROJECT=$(cat ../secrets/project_id)
export GCE_CREDENTIALS_FILE_PATH=`pwd`/../secrets/account.json

/usr/bin/env python gce.py $*
