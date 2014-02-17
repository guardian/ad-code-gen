scriptName = "ad-gen.js"

networkId = "158186692"

scripts = document.querySelectorAll("script[src$='#{scriptName}']")
slot = scripts[scripts.length - 1]
slotName = slot.getAttribute "data-ad-slot-name"

buildTargetSize = ->
  size = slot.getAttribute "data-ad-size"
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
  if gsegQS? and gsegQS.length > 1
    targeting += buildThirdPartySegments(gsegQS)
  if quantSegs? and quantSegs.length > 1
    targeting += buildThirdPartySegments(quantSegs)
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

pageLevelCodePart1 = "(function () {
    var useSSL = 'https:' == document.location.protocol;
    var src = (useSSL ? 'https:' : 'http:') +
      '//www.googletagservices.com/tag/js/gpt.js';
    document.write('<scr' + 'ipt src=\"' + src + '\"></scr' + 'ipt>');
  })();"

pageLevelCodePart2 = "googletag.pubads().enableSyncRendering(); googletag.enableServices();"

buildSlotDeclaration = ->
  adUnitName = slot.getAttribute "data-ad-unit"
  "googletag.defineSlot('/#{networkId}/#{adUnitName}', #{buildTargetSize()}, '#{slotName}')#{buildCustomTargeting()}#{buildAllThirdPartySegments()}.addService(googletag.pubads());"

slotCode = "googletag.display('#{slotName}');"

insertScript = (content) ->
  document.write('<scr' + 'ipt type="text/javascript">' + content + '</scr' + 'ipt>')

insertAdConfig = ->
  isFirstAd = scripts.length == 1
  if isFirstAd
    insertScript pageLevelCodePart1
    insertScript pageLevelCodePart2
  insertScript buildSlotDeclaration()

insertAd = ->
  slotDiv = document.createElement "div"
  slotDiv.setAttribute("id", slotName)
  slot.parentElement.appendChild slotDiv
  insertScript slotCode

insertAdConfig()
insertAd()
