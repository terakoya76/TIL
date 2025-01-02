# Configure GPG Key for YubiKey

ref. https://github.com/drduh/YubiKey-Guide

## Create Master Key for Certify
```sh
$ gpg --expert --full-gen-key
gpg (GnuPG) 2.2.27; Copyright (C) 2021 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Please select what kind of key you want:
   (1) RSA and RSA (default)
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
   (7) DSA (set your own capabilities)
   (8) RSA (set your own capabilities)
   (9) ECC and ECC
  (10) ECC (sign only)
  (11) ECC (set your own capabilities)
  (13) Existing key
  (14) Existing key from card
Your selection? 11

Possible actions for a ECDSA/EdDSA key: Sign Certify Authenticate
Current allowed actions: Sign Certify
   (S) Toggle the sign capability
   (A) Toggle the authenticate capability
   (Q) Finished
Your selection? S

Possible actions for a ECDSA/EdDSA key: Sign Certify Authenticate
Current allowed actions: Certify
   (S) Toggle the sign capability
   (A) Toggle the authenticate capability
   (Q) Finished
Your selection? Q

Please select which elliptic curve you want:
   (1) Curve 25519
   (3) NIST P-256
   (4) NIST P-384
   (5) NIST P-521
   (6) Brainpool P-256
   (7) Brainpool P-384
   (8) Brainpool P-512
   (9) secp256k1
Your selection? 1

Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 0

Key does not expire at all
Is this correct? (y/N) y

GnuPG needs to construct a user ID to identify your key.

Real name: <your-name>
Email address: <your-email>
Comment: <any-comment>

# check
$ gpg -K --keyid-format=long
```

## Create Sub Keys for Encrypt/Signing/Auth
Create sub key for Encrypt
```sh
$ keyID="xxx"
$ gpg --expert --edit-key $keyID
gpg> addkey
Please select what kind of key you want:
   (3) DSA (sign only)
   (4) RSA (sign only)
   (5) Elgamal (encrypt only)
   (6) RSA (encrypt only)
   (7) DSA (set your own capabilities)
   (8) RSA (set your own capabilities)
  (10) ECC (sign only)
  (11) ECC (set your own capabilities)
  (12) ECC (encrypt only)
  (13) Existing key
  (14) Existing key from card
Your selection? 12

Please select which elliptic curve you want:
   (1) Curve 25519
   (3) NIST P-256
   (4) NIST P-384
   (5) NIST P-521
   (6) Brainpool P-256
   (7) Brainpool P-384
   (8) Brainpool P-512
   (9) secp256k1
Your selection? 1

Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 0

Key does not expire at all
Is this correct? (y/N) y

Really create? (y/N) y
```

Create sub key for Signing
```sh
$ keyID="xxx"
$ gpg --expert --edit-key $keyID
gpg> addkey
Please select what kind of key you want:
   (3) DSA (sign only)
   (4) RSA (sign only)
   (5) Elgamal (encrypt only)
   (6) RSA (encrypt only)
   (7) DSA (set your own capabilities)
   (8) RSA (set your own capabilities)
  (10) ECC (sign only)
  (11) ECC (set your own capabilities)
  (12) ECC (encrypt only)
  (13) Existing key
  (14) Existing key from card
Your selection? 10

Please select which elliptic curve you want:
   (1) Curve 25519
   (3) NIST P-256
   (4) NIST P-384
   (5) NIST P-521
   (6) Brainpool P-256
   (7) Brainpool P-384
   (8) Brainpool P-512
   (9) secp256k1
Your selection? 1

Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 0

Key does not expire at all
Is this correct? (y/N) y

Really create? (y/N) y
```

Create sub key for Auth
```sh
$ keyID="xxx"
$ gpg --expert --edit-key $keyID
gpg> addkey
Please select what kind of key you want:
   (3) DSA (sign only)
   (4) RSA (sign only)
   (5) Elgamal (encrypt only)
   (6) RSA (encrypt only)
   (7) DSA (set your own capabilities)
   (8) RSA (set your own capabilities)
  (10) ECC (sign only)
  (11) ECC (set your own capabilities)
  (12) ECC (encrypt only)
  (13) Existing key
  (14) Existing key from card
Your selection? 11

Possible actions for a ECDSA/EdDSA key: Sign Authenticate
Current allowed actions: Sign
   (S) Toggle the sign capability
   (A) Toggle the authenticate capability
   (Q) Finished
Your selection? S

Possible actions for a ECDSA/EdDSA key: Sign Authenticate
Current allowed actions:
   (S) Toggle the sign capability
   (A) Toggle the authenticate capability
   (Q) Finished
Your selection? A

Possible actions for a ECDSA/EdDSA key: Sign Authenticate
Current allowed actions: Authenticate
   (S) Toggle the sign capability
   (A) Toggle the authenticate capability
   (Q) Finished
Your selection? Q

Please select which elliptic curve you want:
   (1) Curve 25519
   (3) NIST P-256
   (4) NIST P-384
   (5) NIST P-521
   (6) Brainpool P-256
   (7) Brainpool P-384
   (8) Brainpool P-512
   (9) secp256k1
Your selection? 1

Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 0

Key does not expire at all
Is this correct? (y/N) y

Really create? (y/N) y
```

## Export/Import Keys

export keys
```sh
$ gpg -K --keyid-format=long
$ keyID="xxx"

# master key and sub keys
$ gpg -a -o mastersub.key --export-secret-keys $keyID

# sub keys only
$ gpg -a -o sub.key --export-secret-subkeys $keyID

# pub key only
$ gpg -a -o public.asc --export $keyID

# revocation cert
$ gpg -o revoke.asc --gen-revoke $keyID
```

import keys
```sh
# delete keys from machine
$ gpg --delete-secret-keys $keyID

# import
$ gpg --import sub.key

# list
$ gpg -K --keyid-format=long

# register pub key
$ gpg --export $keyID | curl -T - https://keys.openpgp.org
```

## Send Sub key to YubiKey
ref. https://zenn.dev/a24k/articles/20220417-openpgp-yubikey-setupnewkey

```sh
# install ykman
$ sudo apt-add-repository ppa:yubico/stable
$ sudo apt update
$ sudo apt install yubikey-manager

$ ykman info
Device type: YubiKey 5 NFC
Serial number: XXXXXXXX
Firmware version: 5.4.3
Form factor: Keychain (USB-A)
Enabled USB interfaces: OTP, FIDO, CCID
NFC transport is enabled.

Applications	USB    	NFC
FIDO2       	Enabled	Enabled
OTP         	Enabled	Enabled
FIDO U2F    	Enabled	Enabled
OATH        	Enabled	Enabled
YubiHSM Auth	Enabled	Enabled
OpenPGP     	Enabled	Enabled
PIV         	Enabled	Enabled

# send keys to YubiKey
$ gpg --edit-card
gpg: error getting version from 'scdaemon': No SmartCard daemon
gpg: OpenPGP card not available: No SmartCard daemon

# install scdaemon
apt-get install gnupg gpg gpg-agent dirmngr scdaemon

$ gpg --edit-card
gpg/card> admin
# default PIN
PIN: 123456
Admin PIN: 12345678

gpg/card> kdf-setup

# set new PIN
gpg/card> passwd

# set new name
gpg/card> name

# set url
gpg/card> url

# set email
gpg/card> login

gpg/card> q

$ gpg --edit-key $keyID

# choose the key to send
gpg> key 1

gpg> keytocard
Please select where to store the key:
   (2) Encryption key
Your selection? 2

# unchoose the key
gpg> key 1

gpg> save
```

## Setup another machine with YubiKey
ref. https://mitome.in/device/yubikey.html#%E4%BB%96%E3%81%AElinux%E3%81%A6%E3%82%99%E3%81%AE%E7%A7%81%E6%9C%89%E9%8D%B5%E3%81%AE%E5%88%A9%E7%94%A8

```sh
$ gpg --card-edit

# download GPG public key
gpg/card> fetch

gpg/card> quit

# set keyID from fetch result
$ keyID="xxx"
$ gpg --edit-key $keyID

gpg> trust
Please decide how far you trust this user to correctly verify other users' keys
(by looking at passports, checking fingerprints from different sources, etc.)
  1 = I don't know or won't say
  2 = I do NOT trust
  3 = I trust marginally
  4 = I trust fully
  5 = I trust ultimately
  m = back to the main menu
Your decision? 5
Do you really want to set this key to ultimate trust? (y/N) y

gpg> quit
```

## Generate Public Key from GPG Key

```sh
$ gpg -K --keyid-format=long
$ keyID="xxx"
$ gpg -a -o public.asc --export $keyID
```

## Configure git/config
```sh
$ git config --global commit.gpgsign true
$ git config --global user.signingkey $keyID
```
