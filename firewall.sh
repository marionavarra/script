#!/bin/bash
sudo iptables -A OUTPUT -p tcp -m owner --gid-owner internet -j ACCEPT
sudo iptables -A OUTPUT -p tcp -d 127.0.0.1 -j ACCEPT
sudo iptables -A OUTPUT -p tcp -j REJECT



