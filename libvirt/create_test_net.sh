#!/bin/bash

# Define the network XML
cat <<EOF >/tmp/test-network.xml
<network>
  <name>test</name>
  <bridge name='virbr1' STp='on' delay='0'/>
  <domain name='test'/>
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.156' end='192.168.122.254'/>
    </dhcp>
  </ip>
</network>
EOF

# Define, start, and set to autostart
virsh net-define /tmp/test-network.xml
virsh net-start test
virsh net-autostart test

# Clean up
rm /tmp/test-network.xml

echo "Network 'test' created on virbr1. DHCP range: .156 - .254"
