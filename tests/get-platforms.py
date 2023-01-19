#!/usr/bin/env python3

import yaml
import json

with open("docker-compose.yml", "r") as stream:
    try:
        conf = yaml.safe_load(stream)
        serv = conf.get("services")
        keys = serv.keys()
        skeys = [ str(key) for key in keys ]
        print(json.dumps(skeys))

    except yaml.YAMLError as exc:
        print(exc)
