# Sample Task TOTPGen

## About

This task is an example implementation, how to implement a "Time-based One-Time Password" (TOTP) algorithm as defined in RFC 6238.

## Warning 

Please note that it's not a full-featured implementation and it's not prepared / finished for "download and use".

For security reasons, you have to think additionally about:
* how to share the shared secret between your implenentation and the external TOTP password generator
* how to secure your implementation in the PLC code (for example, not to expose any secret information to process variables readable by online services)
* using TOTP just as a second mechanism (e.g. in combination with user + password authentication + TOTP as 2nd factor)
* ....

## How it works

This TOTP implenentation uses HMAC-SHA1 and the Unix epoch timestamp (seconds since 01.01.1970) as counter, like defined in RFC 6238, producing a 6-digit code.
So it should be compatible with code generators using the same implementation.
As the counter is time-basd, the PLC realtime clock has to be set correct for proper functionality - I used the right timezone settings + NTP client functionality of the PLC to ensure that the base clock value of the external generator and the PLC is the same.

The external generator needs to know the HMAC-SHA1 secret, which is defined in my example as a PLC string.
Most of the generators accept this secret only in Base32 encoding - that's the reason why this example also has a Base32 encoding function inside, even if this is not needed for the code generation itself.
Common external generators (like Google Authenticator) used for 2 factor authentication are producing most often codes with a validitiy time of 30 seconds.

In PLC environment maybe you have different needs, e.g. like a "password of the day" - that's possible by just changing the number of seconds how long the token should be the same.
But then you need to use a external generator which is also able to generate tokens with longer validation time -> the're hundreds of implementations out there, so no doubt about ;-)
For my tests, I used the following online token generator:

https://totp.danhersam.com/

## Example

Just have a look on the following screenshot:

![](mdimages/hash1.png)

On the left side, you see the result of the PLC task after setting "bGenerateCode" to TRUE.
On the right side, you see the setup and the result of the external token generator.
* Yellow: the secret from the PLC as Base32 encoded string which is also used in the external token generator, and the token valid period (in seeconds) matching in both generators
* Green: just for information the usage of the UTC timestamp in the PLC, compared to the local time of my Windows environment
* Blue: the rsult -> the generated token is equal in PLC and in the external generator 