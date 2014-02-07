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
* (Currently, the IP address parameter is ignored)

Disabling Activation Emails
---------------------------

Usually this SSO strategy goes hand in hand with users being created by an API client, for instance 
https://github.com/discoursehosting/discourse-api-php

Creating users using the API still sends an activation email to the user, even if the user is activated by the API.
To prevent this we have introduced the sso_disable_activationmails setting.

If you enable the sso_disable_activationmails setting you should really disable enable_local_account_create 
and email_editable. If you don't, people will be able to create accounts without email validation, or change to an incorrect email address.


PHP example code
----------------

    <?php
    
    $secret = "524c48bfdcaa5172a501a6d0db0bc41a90671544c3c1c37c39a2758a66e724ac";
    
    $user = 'username';
    $t = time();
     
    $payload = "{$user}:{$t}:127.0.0.1";
    $hash = hash("sha256", $payload.':'.$secret);
    $value = base64_encode($payload.':'.$hash);
    
    echo "http://discourse.example.com/?sso=".$value."\n";

Output:

`http://discourse.example.com/?sso=a2FsdHVyaWFuOjEzOTA5NDI5MTQ6MTI3LjAuMC4xOmM2MDk1MWNkNjkzMWE3YTk2MTBjNDFiMjVmMWNjYjQ1NmRjNmE0YzVkZWE2MDExYTQ2ZTE2MWNlMThkY2NmYzE=`
