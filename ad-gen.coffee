###
Source: https://github.com/guardian/ad-code-gen/blob/master/ad-gen.coffee
###

# Generates DFP ad code.
#
# Slot parameters:
#   data-ad-unit:           Targeted DFP ad unit name [required]
#   data-ad-size:           Targeted creative size(s), eg. "100x200" or "100x200,200x300" [required for in-page ads]
#                           - if "0x0", an out-of-page ad will be built
#   data-ad-target-<name>:  Custom targeting, eg. data-ad-target-s="culture", data-ad-target-k="music,culture" [optional]

scriptName = "ad-gen.js"

networkId = "59666047"

scripts = document.querySelectorAll("script[src$='#{scriptName}']")
slot = scripts[scripts.length - 1]
slotName = "ad-slot-#{scripts.length}"

buildTargetSize = (size) ->
  formatted = size.replace(/\s*,\s*/g, "],[").replace(/\s*x\s*/g, ",")
  "[[#{formatted}]]"

buildCustomTargeting = ->
  targeting = ""
  for attr in slot.attributes
    match = attr.name.match /^data-ad-target-(.+)$/
    if match?
      key = match[1]
      value = attr.value.replace(/\s*,\s*/g, "','")
      targeting += ".setTargeting('#{key}',['#{value}'])"
  targeting

buildAllThirdPartySegments = ->
  targeting = ""

  kruxSegments = window.localStorage.kxsegs ? []
  if kruxSegments.length > 0
    filling = kruxSegments.split(',').join("','")
    output = "['#{filling}']"

    targeting += ".setTargeting('x', #{output})"

  targeting

buildThirdPartySegments = (segments) ->
  buildSegmentValues = ->
    values = ""
    for segment in segments.split "&" when segment.length > 0
      kv = segment.split "="
      value = kv[1]
      values += "'#{value}',"
    values.substring(1, values.length - 2)

  key = segments.split("&")[0].split("=")[0]
  ".setTargeting('#{key}',['#{buildSegmentValues()}'])"

pageLevelCodePart1 = "
  var googletag = googletag || {};
  googletag.cmd = googletag.cmd || [];
  (function() {
    var gads = document.createElement(\"script\");
    gads.async = true;
    gads.type = \"text/javascript\";
    var useSSL = \"https:\" == document.location.protocol;
    gads.src = (useSSL ? \"https:\" : \"http:\") + \"//www.googletagservices.com/tag/js/gpt.js\";
    var node = document.getElementsByTagName(\"script\")[0];
    node.parentNode.insertBefore(gads, node);
  })();
"

pageLevelCodePart2 = "
  googletag.cmd.push(function() {
    googletag.pubads().enableAsyncRendering();
    googletag.pubads().collapseEmptyDivs();
    googletag.enableServices();
  });
"

# Beware: GPT ad request has a max length and beyond that any custom targeting is ignored
buildSlotDeclaration = (size) ->
  adUnitName = slot.getAttribute "data-ad-unit"
  "googletag.cmd.push(function() {
      googletag.defineSlot('/#{networkId}/#{adUnitName}', #{buildTargetSize(size)}, '#{slotName}')#{buildCustomTargeting()}#{buildAllThirdPartySegments()}.addService(googletag.pubads());
    });"

buildOutOfPageSlotDeclaration = ->
  adUnitName = slot.getAttribute "data-ad-unit"
  "googletag.cmd.push(function() {
      googletag.defineOutOfPageSlot('/#{networkId}/#{adUnitName}', '#{slotName}')#{buildCustomTargeting()}#{buildAllThirdPartySegments()}.addService(googletag.pubads());
    });"

buildSlotCode = ->
  "googletag.cmd.push(function() {
    googletag.display('#{slotName}');
  });"

insertScript = (content) ->
  script = document.createElement "script"
  slot.parentElement.appendChild script
  script.type = "text/javascript"
  script.text = content

insertAdConfig = ->
  isFirstAd = scripts.length == 1
  if isFirstAd
    insertScript pageLevelCodePart1
    insertScript pageLevelCodePart2
  size = slot.getAttribute "data-ad-size"
  if size == "0x0"
    insertScript buildOutOfPageSlotDeclaration()
  else
    insertScript buildSlotDeclaration(size)

insertAd = ->
  slotDiv = document.createElement "div"
  slotDiv.setAttribute("id", slotName)
  slot.parentElement.appendChild slotDiv
  insertScript buildSlotCode()

insertAdConfig()
insertAd()
