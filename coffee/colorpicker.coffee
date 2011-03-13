hue = 200
saturation = 50
brightness = 50
color_box = []
hue_bar = [] 
selected_color = []
color_picker = []

draw_color_picker = () ->
  $('body').append($('<div id="color-picker"><div class="hue-bar"><canvas id="hue-bar" width="150" height="10"></canvas></div><div class="color-box"><canvas id="color-box" width="150" height="150"></canvas></div><div class="selected-color"></div></div>').hide())


draw_huebox = () ->
  canvas = document.getElementById('hue-bar')
  ctx = canvas.getContext("2d")
  hSteps = 360 / canvas.width
  hColor = new Color([0,100,100], 'hsb')
  strhHex = ""
  
  for i in [1..canvas.width]
      ctx.strokeStyle = hColor.setHue(i*hSteps).rgbToHex()
      ctx.beginPath()
      ctx.moveTo(i,0)
      ctx.lineTo(i,canvas.height)
      ctx.stroke();

draw_colorbox = () ->
  canvas = document.getElementById('color-box')
  ctx = canvas.getContext("2d")
  canvas_size = canvas.width 
  ctx.fillStyle = new Color([hue,100,100], 'hsb').rgbToHex()
  ctx.fillRect(0,0,canvas_size,canvas_size)
  saturationGradient = ctx.createLinearGradient(0,0,canvas_size,0)
  saturationGradient.addColorStop(0, 'rgba(255,255,255,1)')
  saturationGradient.addColorStop(1, 'rgba(255,255,255,0)')
  ctx.fillStyle = saturationGradient
  ctx.fillRect(0,0,canvas_size,canvas_size)
  
  valueGradient = ctx.createLinearGradient(0,canvas_size,0,0)
  valueGradient.addColorStop(0, 'rgba(0,0,0,1)')
  valueGradient.addColorStop(1, 'rgba(0,0,0,0)')
  ctx.fillStyle = valueGradient
  ctx.fillRect(0,0,canvas_size,canvas_size)

color_selected_color_box = () ->
  color = new Color([hue,saturation,brightness], 'hsb').rgbToHex()
  selected_color.css('background-color', color)

colorpicker_events = () ->
  color_box.click (e) ->
    offset = color_box.offset()
    xPos = e.pageX - offset.left
    yPos = e.pageY - offset.top
    
    saturation = normalize_saturation(xPos)
    brightness = normalize_brightness(yPos)
    color_selected_color_box()    
  
  hue_bar.click (e) -> 
    offset = hue_bar.offset()
    xPos = e.pageX - offset.left
    hue = normalize_hue(xPos)
    draw_colorbox()
    color_selected_color_box()
  


normalize_hue = (input) -> 
  Math.floor((360 / hue_bar.width()) * input)

normalize_saturation = (input) ->
  Math.floor((100 / color_box.width()) * input)

normalize_brightness = (input) ->
  100 - Math.floor((100 / color_box.height()) * input)


$(document).ready ->
  console.log 'start'
  color = new Color([hue,100,100], 'hsb').rgbToHex()
  
  draw_color_picker()
  hue_bar = $('.hue-bar')
  color_box = $('.color-box')
  selected_color = $('.selected-color')
  color_picker = $('#color-picker')

  draw_huebox()
  draw_colorbox()
  colorpicker_events()
  color_selected_color_box()
  

chrome.extension.onRequest.addListener (request, sender, sendResponse) ->
  if request is "create_extension"
    color_picker.toggle()




















