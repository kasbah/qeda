enclosure = require './common/enclosure'

icon = Object.create
  width: 12
  height: 9
  lineWidth: 0
  draw: (symbol, x, y) ->
    space = 1.5
    gap = 1
    arrowWidth = 1.5
    symbol
      .lineWidth @lineWidth
      .center x, y # Set center to (x, y)
      .line -space, -@height/2, -space, @height/2
    if @depletion
      symbol.line 0, -@height/2, 0, @height/2
    else # Enhancement
      x = 0
      y = -@height/2
      l = (@height - 2*gap)/3
      for i in [1..3]
        symbol.line 0, y, 0, y + l
        y += l + gap

    y = (@height + gap)/3
    symbol
      .line -@width/2, 0, -space, 0
      .line 0, y, @width/2, y
      .line @width/2, y, @width/2, @height/2
      .line 0, -y, @width/2, -y
      .line @width/2, -y, @width/2, -@height/2

    if @bulk
      symbol
        .line 0, 0, @width/4, 0
        .line @width/4, 0, @width/4, y

    if @n then symbol.poly 0, 0, @width/8, arrowWidth/2, @width/8, -arrowWidth/2, 'background'
    if @p then symbol.poly @width/8, arrowWidth/2, @width/4, 0, @width/8, -arrowWidth/2, 'background'

    symbol.center 0, 0 # Restore default center point

module.exports = (symbol, element) ->
  element.refDes = 'VT'
  schematic = element.schematic
  settings = symbol.settings
  pins = element.pins
  pinGroups = element.pinGroups

  schematic.showPinNumbers = true

  options = if schematic.options? then schematic.options.replace(/\s+/g, '').split(',') else []
  for option in options
    icon[option.toLowerCase()] = true
  icon.lineWidth = settings.lineWidth.thick
  icon.width = 2 * symbol.alignToGrid(icon.width/2, 'ceil')
  icon.height = 2 * symbol.alignToGrid(icon.height/2, 'ceil')

  for k, v of pinGroups
    switch k
      when 'G' then gate = v
      when 'D' then drain = v
      when 'S' then source = v
      else needEnclosure = true
  valid = gate? and drain? and source?

  if (not valid) or needEnclosure
    schematic.showPinNames = true
    enclosure symbol, element, icon
  else
    width = icon.width
    height = icon.height
    pinLength = symbol.alignToGrid(settings.pinLength ? 10)
    step = symbol.alignToGrid 5
    r = width/2
    symbol
      .attribute 'refDes',
        x: 0
        y: -r - 1
        halign: 'center'
        valign: 'bottom'
      .attribute 'name',
        x: r + 1
        y: 0
        halign: 'left'
        valign: 'center'
      .icon 0, 0, icon
      .circle 0, 0, r

    # Gate
    y = 0
    for g in gate
      pin = pins[g]
      pin.x = -width/2 - pinLength
      pin.y = y
      pin.length = pinLength
      pin.orientation = 'right'
      symbol.pin pin
      y += step
    symbol.line -width/2, 0, -width/2, (gate.length - 1)*step

    # Drain
    x = width/2
    for d in drain
      pin = pins[d]
      pin.x = x
      pin.y = -height/2 - pinLength
      pin.length = pinLength
      pin.orientation = 'down'
      symbol.pin pin
      x += step
    symbol.line width/2, -height/2, width/2 + (drain.length - 1)*step, -height/2

    # Source
    x = width/2
    for s in source
      pin = pins[s]
      pin.x = x
      pin.y = height/2 + pinLength
      pin.length = pinLength
      pin.orientation = 'up'
      symbol.pin pin
      x += step
    symbol.line width/2, height/2, width/2 + (source.length - 1)*step, height/2