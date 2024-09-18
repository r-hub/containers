#!/usr/bin/env python3

import os
import json
import argparse

parser = argparse.ArgumentParser(description="Print containers as JSON.")
parser.add_argument(
    'containers',
    type = str,
    nargs = '?',
    default = 'all',
    help = 'Comma-separated list of containers. Default is "all" to use all containers.'
)
args = parser.parse_args()

conts = os.listdir("containers")
if args.containers != 'all':
    containers = args.containers.split(",")
    conts = [ p for p in containers if p in conts ]

# some hardcoded platforms and secrets
platforms = {
    's390x': 'linux/s390x',
    'rhel8': 'linux/amd64,linux/arm64',
    'rhel9': 'linux/amd64,linux/arm64'
}
secrets = {
    'rhel7': 'REDHAT_ORG_RHEL7,REDHAT_ACTIVATION_KEY_RHEL7',
    'rhel8': 'REDHAT_ORG_RHEL8,REDHAT_ACTIVATION_KEY_RHEL8',
    'rhel9': 'REDHAT_ORG_RHEL9,REDHAT_ACTIVATION_KEY_RHEL9',
}
conf = [ {
    'container': c,
    'platform': platforms[c] if c in platforms else 'linux/amd64',
    'secrets': secrets[c] if c in secrets else ''
} for c in conts ]

print(json.dumps(conf))
