hue = 200
saturation = 50
brightness = 50
color_box = []
hue_bar = [] 
selected_color = []
color_picker = []
color_viewer = []
css_selector_input = []
hue_handle = []
color_handle = []
cancel_button = []
confirm_button = []
selected_color_hex_output = []
selected_color_rgb_output = []
css_selector = ""
color_viewer_option_selected = ""

draw_color_picker = () ->
  color_picker = 
  '''
  <div id="color-picker">
    <div class="hue-bar">
      <div class="handle"></div>
      <canvas id="hue-bar" width="250" height="15"></canvas>
    </div>
    <div class="color-box">
      <canvas id="color-box" width="250" height="250"></canvas>
      <div class="handle"></div>
    </div>
    <div class="selected-color"></div>
    <div class="color-formats">
      <span class="rgb"></span> <br />
      <span class="hex"></span>
    </div>
    <div class="buttons">
      <input type="submit" name="confirm" value="Confirm" />
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
  cancel_button = color_picker.find('input[name="cancel"]')
  confirm_button = color_picker.find('input[name="confirm"]')
  selected_color_hex_output = color_picker.find('.hex')
  selected_color_rgb_output = color_picker.find('.rgb')
  
  hue_handle.draggable({axis: "x", containment: "parent"})
  color_handle.draggable({containment: "parent"})


draw_color_viewer = () ->
  color_viewer = 
  '''
  <div id="color-viewer">
    <input type="text" name="css_selector" />
    <div class="colors">
      <div color-type="background" class="color background"></div>
      <div color-type="border" class="color border"></div>
      <div color-type="font" class="color font">A</div>
      <div style="clear:both;"></div>
    </div>
  </div>
  '''
  $('body').append($(color_viewer))
  
  color_viewer = $('#color-viewer')
  css_selector_input = color_viewer.find('input[name="css_selector"]')


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

move_handles = () ->
  hue_handle.css('left', normalize_hue(hue, false)  - adjust_handle_position())
  color_handle.css('left', normalize_saturation(saturation, false) - adjust_handle_position())
  color_handle.css('top', normalize_brightness(brightness, false) - adjust_handle_position())

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
  
  cancel_button.click ->
    wipe_css_selector()

  confirm_button.click ->
    if (css_selector isnt "") and (color_viewer_option_selected isnt "")
      color = new Color([hue, saturation, brightness], 'hsb').rgbToHex()
      console.log(color)
      switch color_viewer_option_selected
        when 'background'
          $(css_selector).css('background-color', color)
          color_viewer.find('.color.background').css('background-color', color)
        when 'border'
          $(css_selector).css('border-top-color', color).css('border-right-color', color).css('border-bottom-color', color).css('border-left-color', color)
          color_viewer.find('.color.border').css('border-right-color', color).css('border-bottom-color', color).css('border-left-color', color)
        when 'font'
          $(css_selector).css('color', color)
          color_viewer.find('.color.font').css('color', color)
      
      

color_viewer_events = () ->
  color_viewer.keypress (e) ->
    if e.which is 13
      css_selector = css_selector_input.val()
      if $(css_selector).length > 0
        get_colors(css_selector)
      else
        wipe_css_selector()
  
  color_viewer.find('.color').click ->
    if css_selector isnt ""
      $(this).toggleClass('selected')
      $(this).siblings().removeClass('selected')
      color = switch $(this).attr('color-type')
        when 'background' 
          color_viewer_option_selected = if color_viewer_option_selected == 'background' then '' else 'background'
          $(this).css('background-color')
        when 'border' 
          color_viewer_option_selected = if color_viewer_option_selected == 'border' then '' else 'border'
          $(this).css('border-top-color')
        when 'font' 
          color_viewer_option_selected = if color_viewer_option_selected == 'font' then '' else 'font'
          $(this).css('color')
      hsb = new Color(color).rgbToHsb()
      get_values_from_hsb(hsb)
      draw_colorbox()
      draw_selected_color_box()
      move_handles()
  



get_colors = (selector) ->
  background = $(selector).css('background-color')
  border = $(selector).css('border-top-color')
  font = $(selector).css('color')
  
  color_viewer.find('.background.color').css('background-color', background)
  color_viewer.find('.font.color').css('color', font)
  color_viewer.find('.border.color').css('border-top-color', border).css('border-right-color', border).css('border-bottom-color', border).css('border-left-color', border)


wipe_css_selector = () ->
  css_selector_input.val('')
  css_selector = ""
  color_viewer.find('.color').removeClass('selected')
  color_viewer.find('.background.color').css('background-color', '')
  color_viewer.find('.font.color').css('color', '')
  color_viewer.find('.border.color').css('border-top-color', '').css('border-right-color', '').css('border-bottom-color', '').css('border-left-color', '')



get_hue = () ->
  normalize_hue(hue_handle.offset().left - hue_bar.offset().left - adjust_handle_position())

  
get_saturation = () ->
  normalize_saturation(color_handle.offset().left - color_box.offset().left - adjust_handle_position())

get_brightness = () ->
  normalize_brightness(color_handle.offset().top - color_box.offset().top - adjust_handle_position())

adjust_handle_position = () ->
  border = parseInt(hue_handle.css('border-top-width')) * 2
  side = parseInt(hue_handle.css('width')) / 2
  border + side
  

normalize_hue = (input, x_to_h = true) -> 
  if x_to_h
    Math.floor((360 / hue_bar.width()) * input)
  else
    Math.floor((hue_bar.width() / 360) * input)

normalize_saturation = (input, x_to_s = true) ->
  if x_to_s
    Math.floor((100 / color_box.width()) * input)
  else
    Math.floor((color_box.width() / 100 ) * input)


normalize_brightness = (input, y_to_b = true) ->
  if y_to_b
    100 - Math.floor((100 / color_box.height()) * input)
  else
    parseInt(color_box.width()) - Math.floor((color_box.height() / 100) * input)


get_values_from_hsb = (hsb) ->
  hue = hsb[0]
  saturation = hsb[1]
  brightness = hsb[2]


$(document).ready ->
  console.log 'start'

  draw_color_picker()  
  hue = get_hue()
  saturation = get_saturation()
  brightness = get_brightness()
  draw_color_viewer()
  draw_huebox()
  draw_colorbox()
  colorpicker_events()
  draw_selected_color_box()
  color_viewer_events()




















