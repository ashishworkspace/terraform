#!/bin/bash

curl -sfL https://get.k3s.io | sh -
chown ec2-user:root /etc/rancher/k3s/k3s.yaml