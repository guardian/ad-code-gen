# ad-code-gen

DFP Third Party Ad Code Generator

The code-generating script is [ad-gen.coffee](ad-gen.coffee)

Examples of use are:

* [Page With Single Ad Slot](https://gist.github.com/kelvin-chappell/ab045b1c13c6032c2776)
* [Page With Multiple Ad Slots](https://gist.github.com/kelvin-chappell/d42a83f49e927cf1945d)
* [Page With Out-of-page Ad Slot](https://gist.github.com/kelvin-chappell/7783fcc36ac9886fbf99)

## To Install Coffeescript
sudo npm install -g coffee-script

## To Generate JS
coffee -c ad-gen.coffee

## To Test
0. [Generate JS](#to-generate-js)
0. ./startServer.sh
0. http://localhost:8000/client.html

## To Deploy
0. [Generate JS](#to-generate-js)
0. Upload ad-gen.js to aws-frontend-store/PROD/commercial with:
   Encryption: AES-256 (Amazon S3 server-side encryption, aka Amazon S3 master-key)
   Permission: Public Read,
   Storage Class: Standard,
   Metadata: Content-Type application/x-javascript
0. Make script public

## TODO
See https://support.google.com/dfp_premium/answer/2811375 for a better way of doing this
