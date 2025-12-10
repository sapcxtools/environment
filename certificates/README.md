To generate a new CSR for the domain, please use the following command:

```
openssl req -new -newkey rsa:2048 -nodes -keyout local.cxdev.me.key -out local.cxdev.me.csr
````

Fill in the following information (leave blanks):
```
Country Name (2 letter code) [AU]:DE
State or Province Name (full name) [Some-State]:Hessen
Locality Name (eg, city) []:Butzbach
Organization Name (eg, company) [Internet Widgits Pty Ltd]:CX DEV (OPEN SOURCE PROJECT)
Organizational Unit Name (eg, section) []:
Common Name (e.g. server FQDN or YOUR name) []:*.local.cxdev.me
Email Address []:
A challenge password []:
An optional company name []:
```

Attention: The private keyfile must not be committed and stored within the repository directly!

The CSR then needs to be send to the certification authority. In return you will receive a certificate file which then should be stored as file `local.cxdev.me.crt`.

For running the local servers, both the certificate and the private key are necessary. For tomcat server the both files need to be packed into an p12 key store format by running the following command:

```
openssl pkcs12 -export -inkey local.cxdev.me.key -in local.cxdev.me.crt -name local.cxdev.me -out local.cxdev.me.p12
```

For Export Passwort please use: `123456`, which is the default for SAP Commerce Projects.
