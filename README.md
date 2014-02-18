# ad-code-gen

DFP Third Party Ad Code Generator

The code-generating script is [ad-gen.coffee](ad-gen.coffee)

## To Generate JS
coffee -c ad-gen.coffee

## To Test
0. ./startServer.sh
0. http://localhost:8000/client.2.html

## To Deploy
0. Upload ad-gen.js to aws-frontend-store/PROD/commercial
0. Make script public

## TODO
See https://support.google.com/dfp_premium/answer/2811375 for a better way of doing this
