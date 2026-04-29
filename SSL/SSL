# SSL Certificates How To Guide by Hexnub

## Self-Signed Certificates


### How to generate a Root Certificate and setup your Private Certificate Authority
1. Install OpenSSL on Ubuntu
```bash
sudo apt install -y openssl
```
2. Generate a private key which is used to generate a root certificate and encrypt this private key by using AES256 and providing a passphrase. 
```bash
openssl genrsa -aes256 -out rootKey.key 4096
```
Alteratively you can create and encrypt the root private key by using DES3 and providing a passphrase
```bash
openssl genrsa -des3 -out rootKey.key 4096
```

3. Generate a root certificate by using the key you created earlier and providing the passphrase
The root certificate is the CA's public key - when this certificate expires, all clients need to be updated
```bash
openssl req -new -x509 -sha256 -days 1825 -key rootKey.key -out privateCA.pem
```

4. Install the certificates package on Ubuntu
```bash
sudo apt install -y ca-certificates
```
5. Copy the root certificate to the ca-certificates directory
```bash
sudo cp ~/privateCA.pem /usr/local/share/ca-certificates
```
6. Update the certificate store
```bash
sudo update-ca-certificates
```

### Generate Certificates for your private sites that need HTTPS 
1. Generate a private key for your private site and name the key using the domain name of the site
```bash
openssl genrsa -out myPrivateSite.local.key 4096
```
2. Create a Certificate Signing Request (CSR)
```bash
openssl req -new -sha256 -subj "/CN=serverName" -key myPrivateSite.local.key -out myPrivateSite.csr
```
3. Create a x509 v3 certificate extension config file. This is used to define the subject alternative name or SAN for the certificate
```bash
echo "subjectAltName=DNS:my-server.home,IP:10.0.0.12" >> myPrivatesite.home.ext
```
```bash
# optional
echo extendedKeyUsage = serverAuth >> myPrivatesite.home.ext
```
Alternatively you can create the x509 v3 certificate extension config file and edit it, click the link below for more info.
```
https://www.openssl.org/docs/manmaster/man5/x509v3_config.html
```
```
authorityKeyIdentifier = keyid, issuer
basicConstraints = CA:False
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS = my-server.home
IP = 10.0.0.12
```
4. Create the certificate using the CSR, CA private key and the CA certificate and the config file
```bash
openssl x509 -req -sha256 -days 825 -in myPrivateSite.csr -CA privateCA.pem -CAkey rootKey.key -out myPrivateSite.crt -extfile myPrivateSite.home.ext -CAcreateserial
```

We now have 3 files, you can configure local web servers to use HTTPS with the private key and signed certificate
myPrivateSite.local.key | the private key
myPrivateSite.csr | the certificate signing request or CSR file 
myPrivateSite.crt | the signed certificate


### Installing Certificates on your server

Verify your certificate
```bash
openssl verify -CAfile privateCA.pem -verbose myPrivateSite.crt
```
Since the clients validate the certificate through the certificate chain, you can combine the CA public key 'privateCA.pem' and the signed certificate 'myPrivateSite.crt' into a single file.

```bash 
cat privateCA.pem >> myPrivateSite.pem
```
```bash
cat myPrivateSite.crt >> myPrivateSite.pem
```

Now finally you can upload the server's private key and the new combined file to your server.
1. upload the server's private by copying the output of this command
```bash
cat  myPrivateSite.local.key
```
2. upload the combined file containing the CA public key and the signed certificate
```bash
cat myPrivateSite.pem
```


## Install the CA Cert as a trusted root CA on your clients

### MacOS Monterey Keychain
```bash

sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" privateCA.pem
```

### Debian Ubuntu
- Move the CA certificate (`privateCA.pem`) into `/usr/local/share/ca-certificates/privateCA.pem`.
- Update the Cert Store with:
```bash
sudo update-ca-certificates
```

Refer the documentation [here](https://wiki.debian.org/Self-Signed_Certificate) and [here.](https://manpages.debian.org/buster/ca-certificates/update-ca-certificates.8.en.html)

### Fedora
- Move the CA certificate (`privateCA.pem`) to `/etc/pki/ca-trust/source/anchors/privateCA.pem` or `/usr/share/pki/ca-trust-source/anchors/privateCA.pem`
- Now run (with sudo if necessary):
```bash
update-ca-trust
```

### Adding the Root Certificate to Windows 10
1. Open the “Microsoft Management Console” by using the Windows + R keyboard combination, typing mmc and clicking Open
2. Go to File > Add/Remove Snap-in
3. Click Certificates and Add
4. Select Computer Account and click Next
5. Select Local Computer then click Finish
6. Click OK to go back to the MMC window
7. Double-click Certificates (local computer) to expand the view
8. Select Trusted Root Certification Authorities, right-click on Certificates in the middle column under “Object Type” and select All Tasks then Import
9. Click Next then Browse. Change the certificate extension dropdown next to the filename field to All Files (*.*) and locate the myCA.pem file, click Open, then Next
10. Select Place all certificates in the following store. “Trusted Root Certification Authorities store” is the default. Click Next then click Finish to complete the wizard.

### Windows via PowerShell 
Assuming the path to your generated CA certificate as `C:\privateCA.pem`, run:
```powershell
Import-Certificate -FilePath "C:\privateCA.pem" -CertStoreLocation Cert:\LocalMachine\Root
```
- Set `-CertStoreLocation` to `Cert:\CurrentUser\Root` in case you want to trust certificates only for the logged in user.

OR

In Command Prompt, run:
```sh
certutil.exe -addstore root C:\privateCA.pem
```

- `certutil.exe` is a built-in tool (classic `System32` one) and adds a system-wide trust anchor.

