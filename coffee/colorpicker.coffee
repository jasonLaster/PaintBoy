hue = 200
saturation = 50
brightness = 50
color_box = []
hue_bar = [] 
selected_color = []
color_picker = []
color_viewer = []
hue_handle = []
color_handle = []
selected_color_hex_output = []
selected_color_rgb_output = []
css_selector = ""
background_selected = false
border_selected = false
font_selected = false

draw_color_picker = () ->
  color_picker = 
  '''
  <div id="color-picker">
    <div class="hue-bar">
      <div class="handle"></div>
      <canvas id="hue-bar" width="150" height="10"></canvas>
    </div>
    <div class="color-box">
      <canvas id="color-box" width="150" height="150"></canvas>
      <div class="handle"></div>
    </div>
    <div class="selected-color"></div>
    <div class="color-formats">
      <span class="rgb"></span> <br />
      <span class="hex"></span>
    </div>
    <div class="buttons">
      <input type="submit" name="select" value="Confirm" />
      <input type="submit" name="cancel" value="Cancel" />
    </div>
  </div>
  '''
  
  $('body').append($(color_picker))
  hue_bar = $('.hue-bar')
  color_box = $('.color-box')
  selected_color = $('.selected-color')
  color_picker = $('#color-picker')
  hue_handle = hue_bar.find('.handle')
  color_handle = color_box.find('.handle')
  selected_color_hex_output = color_picker.find('.hex')
  selected_color_rgb_output = color_picker.find('.rgb')
  
  hue_handle.draggable({axis: "x", containment: "parent"})
  color_handle.draggable({containment: "parent"})
  console.log(hue_handle)


draw_color_viewer = () ->
  color_viewer = 
  '''
  <div id="color-viewer">
    <input type="text" name="css_selector" />
    <div class="colors">
      <div class="color background"></div>
      <div class="color border"></div>
      <div class="color font">A</div>
      <div style="clear:both;"></div>
    </div>
  </div>
  '''
  $('body').append($(color_viewer))


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


draw_selected_color_box = () ->
  color = new Color([hue,saturation,brightness], 'hsb').rgbToHex()
  selected_color.css('background-color', color)
  write_color_formats()


write_color_formats = () ->
  color = new Color([hue,saturation,brightness], 'hsb')
  selected_color_hex_output.text(color.rgbToHex())
  selected_color_rgb_output.text("[#{color[0]}, #{color[1]}, #{color[2]}]")
  console.log color


colorpicker_events = () ->
  color_handle.mouseup (e) ->
    xPos = e.pageX - color_box.offset().left
    yPos = e.pageY - color_box.offset().top
    saturation = normalize_saturation(xPos)
    brightness = normalize_brightness(yPos)
    draw_selected_color_box()
  
  color_box.click (e) ->
    xPos = e.pageX - color_box.offset().left
    yPos = e.pageY - color_box.offset().top
    
    color_handle.css('left', xPos)
    color_handle.css('top', yPos)
    
    saturation = normalize_saturation(xPos)
    brightness = normalize_brightness(yPos)
    draw_selected_color_box()
  
  hue_handle.mouseup (e) -> 
    hue = normalize_hue(e.pageX - hue_bar.offset().left)
    draw_colorbox()
    draw_selected_color_box()
  
  hue_bar.click (e) ->
    xPos = e.pageX - hue_bar.offset().left
    hue = normalize_hue(xPos)
    hue_handle.css('left', xPos)
    draw_colorbox()
    draw_selected_color_box()
  
    


color_viewer_events = () ->
  color_viewer.keypress (e) ->
    if e.which is 13
      css_selector = color_viewer.find('input[name="css_selector"]').val()
      get_colors(css_selector)
  


get_colors = (selector) ->
  background = $(selector).css('background-color')
  border = $(selector).css('border-top-color')
  font = $(selector).css('color')
  
  color_viewer.find('.background.color').css('background-color', background)
  color_viewer.find('.font.color').css('color', font)
  color_viewer.find('.border.color').css('border-top-color', border).css('border-right-color', border).css('border-bottom-color', border).css('border-left-color', border)
  console.log background, border, font
  console.log color_viewer, color_viewer.find('.background.color')


get_hue = () ->
  border = parseInt(hue_handle.css('border-top-width')) * 2
  width = parseInt(hue_handle.css('width')) / 2
  normalize_hue(hue_handle.offset().left - hue_bar.offset().left - border - width)

  
get_saturation = () ->
  border = parseInt(hue_handle.css('border-top-width')) * 2
  width = parseInt(hue_handle.css('width')) / 2
  normalize_saturation(color_handle.offset().left - color_box.offset().left)


get_brightness = () ->
  border = parseInt(hue_handle.css('border-top-width')) * 2
  width = parseInt(hue_handle.css('width')) / 2
  normalize_brightness(color_handle.offset().top - color_box.offset().top)


normalize_hue = (input) -> 
  Math.floor((360 / hue_bar.width()) * input)


normalize_saturation = (input) ->
  Math.floor((100 / color_box.width()) * input)


normalize_brightness = (input) ->
  100 - Math.floor((100 / color_box.height()) * input)



$(document).ready ->
  console.log 'start'

  draw_color_picker()
  
  hue = get_hue()
  saturation = get_saturation()
  brightness = get_brightness()
  color = new Color([hue,100,100], 'hsb').rgbToHex()
  
  draw_color_viewer()
  color_viewer = $('#color-viewer')

  draw_huebox()
  draw_colorbox()
  colorpicker_events()
  draw_selected_color_box()
  color_viewer_events()




















