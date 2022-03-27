#!/bin/bash

K3S_URL=https://$(curl http://169.254.169.254/latest/meta-data/public-ipv4):6443
K3S_TOKEN=$(cat /var/lib/rancher/k3s/server/node-token) sh -