discourse-sso
=============

Single Sign-On plugin for Discourse forum

Usage
-----

This plugin makes it possible to sign on to a Discourse forum using an URL.

The URL must contain a `sso` parameter which is built up as follows:

`Base64` (`payload` ':' `signature`)

* Where `signature` is `SHA256`(`payload` ':' `secret`)
* Where `payload` is `user` ':' `timestamp` ':' `ipaddress`
* Where `secret` is a secret, only known to Discourse and the application creating the URL.

The secret will be automatically generated and can be found in Admin -> Settings -> SSO Plugin.

`user` can be either:
* Numeric user ID
* Discourse username
* User email address

`timestamp` is the Unix timestamp (seconds since 1-1-1970).

`ipaddress` is the IP address of the user.

When the URL is received by Discourse, the user is looked up and logged in, provided the following criteria are met:
* The signature is valid
* The user exists
* The timestamp does not differ more than 180 seconds from the server time

PHP example code
----------------

    <?php
    
    $secret = "524c48bfdcaa5172a501a6d0db0bc41a90671544c3c1c37c39a2758a66e724ac";
    
    $user = 'kalturian';
    $t = time();
     
    $payload = "{$user}:{$t}:127.0.0.1";
    $hash = hash("sha256", $payload.':'.$secret);
    $value = base64_encode($payload.':'.$hash);
    
    echo "http://discourse.example.com/?sso=".$value."\n";
