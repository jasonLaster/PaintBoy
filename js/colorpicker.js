(function() {
  var brightness, color_box, color_selected_color_box, colorpicker_events, draw_colorbox, draw_huebox, hue, hue_bar, normalize_brightness, normalize_hue, normalize_saturation, saturation, selected_color;
  hue = 200;
  saturation = 50;
  brightness = 50;
  color_box = [];
  hue_bar = [];
  selected_color = [];
  draw_huebox = function() {
    var canvas, ctx, hColor, hSteps, i, strhHex, _ref, _results;
    canvas = document.getElementById('hue-bar');
    ctx = canvas.getContext("2d");
    hSteps = 360 / canvas.width;
    hColor = new Color([0, 100, 100], 'hsb');
    strhHex = "";
    _results = [];
    for (i = 1, _ref = canvas.width; (1 <= _ref ? i <= _ref : i >= _ref); (1 <= _ref ? i += 1 : i -= 1)) {
      ctx.strokeStyle = hColor.setHue(i * hSteps).rgbToHex();
      ctx.beginPath();
      ctx.moveTo(i, 0);
      ctx.lineTo(i, canvas.height);
      _results.push(ctx.stroke());
    }
    return _results;
  };
  draw_colorbox = function() {
    var canvas, canvas_size, ctx, saturationGradient, valueGradient;
    canvas = document.getElementById('color-box');
    ctx = canvas.getContext("2d");
    canvas_size = canvas.width;
    ctx.fillStyle = new Color([hue, 100, 100], 'hsb').rgbToHex();
    ctx.fillRect(0, 0, canvas_size, canvas_size);
    saturationGradient = ctx.createLinearGradient(0, 0, canvas_size, 0);
    saturationGradient.addColorStop(0, 'rgba(255,255,255,1)');
    saturationGradient.addColorStop(1, 'rgba(255,255,255,0)');
    ctx.fillStyle = saturationGradient;
    ctx.fillRect(0, 0, canvas_size, canvas_size);
    valueGradient = ctx.createLinearGradient(0, canvas_size, 0, 0);
    valueGradient.addColorStop(0, 'rgba(0,0,0,1)');
    valueGradient.addColorStop(1, 'rgba(0,0,0,0)');
    ctx.fillStyle = valueGradient;
    return ctx.fillRect(0, 0, canvas_size, canvas_size);
  };
  color_selected_color_box = function() {
    var color;
    color = new Color([hue, saturation, brightness], 'hsb').rgbToHex();
    return selected_color.css('background-color', color);
  };
  colorpicker_events = function() {
    color_box.click(function(e) {
      var offset, xPos, yPos;
      offset = color_box.offset();
      xPos = e.pageX - offset.left;
      yPos = e.pageY - offset.top;
      saturation = normalize_saturation(xPos);
      brightness = normalize_brightness(yPos);
      return color_selected_color_box();
    });
    return hue_bar.click(function(e) {
      var offset, xPos;
      offset = hue_bar.offset();
      xPos = e.pageX - offset.left;
      hue = normalize_hue(xPos);
      draw_colorbox();
      return color_selected_color_box();
    });
  };
  normalize_hue = function(input) {
    return Math.floor((360 / hue_bar.width()) * input);
  };
  normalize_saturation = function(input) {
    return Math.floor((100 / color_box.width()) * input);
  };
  normalize_brightness = function(input) {
    return 100 - Math.floor((100 / color_box.height()) * input);
  };
  $(document).ready(function() {
    var color;
    color = new Color([hue, 100, 100], 'hsb').rgbToHex();
    hue_bar = $('.hue-bar');
    color_box = $('.color-box');
    selected_color = $('.selected-color');
    draw_huebox();
    draw_colorbox();
    colorpicker_events();
    return color_selected_color_box();
  });
}).call(this);
