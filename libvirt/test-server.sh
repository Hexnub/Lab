virt-install \
--name testvm \
--ram 2048 \
--disk path=/var/lib/libvirt/imagea/u77.qcow2,size=8 \
--vcpus 2 \
--os-type linux \
--os-variant generic \
--console pty,target_type=serial \
--bridge=br0 \
--cdrom /var/lib/libvirt/isos/metal-amd64.iso
