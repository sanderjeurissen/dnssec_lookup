# dnssec_lookup



## Description

Simple bash script to fetch the DNS-SEC records from your nameserver, to copy/paste them to the domain registrar.

## Usage

```bash
dnssec_lookup.sh <domain>
```

The script assumes the first parameter supplied is the domainname. When no parameter is supplied, it will show a prompt to enter one.

## Config

By default the script will run the dnslookup to localhost. An alternative server can be used by changing the **NS** variable:

```
NS=127.0.0.1
```

## Limitations

The script is currently unable to supply the DNSSEC records when there are 2 or more ZSK/KSK records. When this is the case, it will exit and give an error-message.

## Copyright

This project is licensed under the terms of the MIT license.