using Toybox.WatchUi;
using Toybox.Attention;
using Toybox.Lang;

class WatchDisplay
{
	var borderSize; // width of the heading ring component

	// Retrieve these data from Store (https://developer.garmin.com/connect-iq/api-docs/Toybox/Application/Storage.html#getValue-instance_method)
    var climbingThreshold =  0.3;
    var sinkingThreshold  = -2.0;
	
    function initialize (dc)
    {
        borderSize = dc.getWidth () / 12;
    }
    
    enum {VarioSink, VarioZeroing, VarioClimb}
    var varioColor = VarioZeroing; // Color of the vario display
    
	// Set the default color according to the vario value and clear the display
    function start (dc, vario)
    {
    	if (vario <= sinkingThreshold)
    	{
    		varioColor = VarioSink;
   		}
   		else
   		{
	   		if (vario >= climbingThreshold)
	    	{
	    		varioColor = VarioClimb;
	   		}
	   		else
	   		{
	   			varioColor = VarioZeroing;
	   		}
   		}
   
    	var color = Graphics.COLOR_TRANSPARENT;
    
    	switch (varioColor)
    	{
    	case VarioSink:     color = Graphics.COLOR_RED; break;
    	case VarioZeroing:  color = Graphics.COLOR_LT_GRAY; break;
    	case VarioClimb:    color = Graphics.COLOR_GREEN; break;
    	}
     
     	// Set background color
        dc.setColor( Graphics.COLOR_TRANSPARENT, color);
        dc.clear();
    }
    
    function end (dc)
    {
    	// NOP
    }
    
	// Display a message while waiting for the altitude
    function waitForAltitude (dc)
    {
    	dc.setColor( Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT );
   		dc.drawText (dc.getWidth () / 2, dc.getHeight() / 2, Graphics.FONT_LARGE, "starting ...", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
    
    // Heading in radians
    function heading (dc, heading)
    {
    	var w = dc.getWidth ();
    	var h = dc.getHeight ();
    	var offset  = 0.5;
    	
		// Points composing the heading triangle
    	var points  = [[-borderSize/2,-h/2+borderSize+offset],[0,-h/2],[borderSize/2,-h/2+borderSize+offset]];
    		
    	var pts = points.size ();
    	var cos = Math.cos(heading);
    	var sin = Math.sin(heading);
    		
		// Rotate the heading triangle

    	for (var i = 0; i < pts; i++)
    	{
    		var x0 = -points[i][0];
    		var y0 = -points[i][1];
    	
    		var x1 = x0 * cos - y0 * sin;
    		var y1 = x0 * sin + y0 * cos;
    	
    		points[i][0] =  w / 2 - x1;
    		points[i][1] =  h / 2 - y1;
    	}
    	
		// Display the inner white circle (containing speed, altitude, vario)
		dc.setColor( Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT );
    	dc.fillCircle (w/2, h/2, w/2-borderSize);

    	// Display the heading triangle
    	dc.setColor( Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT );
    	dc.fillPolygon (points);
    	
		// Display the heading triangle border
    	dc.setPenWidth(2);
	    	dc.setColor( Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT );
	    	for (var i = 0; i + 1 < pts; i++) // Do not display last line. Was: for (var i = 0; i < pts; i++) 
	    	{
	    		dc.drawLine(points[i][0], points[i][1], points[(i+1)%pts][0], points[(i+1)%pts][1]);
	    	}
    	dc.setPenWidth(1);	
    	 	
    }
    	
    var blink = false;
    	
   	function altitude (dc, alt, recording)
   	{
   		var unit = " m";
   	
        var yOffset = dc.getHeight() / 2;
        var xOffset = dc.getWidth () / 2;
        
        var dimAlt  = dc.getTextDimensions (alt,  Graphics.FONT_NUMBER_HOT) as [ Lang.Number, Lang.Number ];
        var dimUnit = dc.getTextDimensions (unit, Graphics.FONT_XTINY) as [ Lang.Number, Lang.Number ];
        
        xOffset -= (dimAlt[0] + (recording ? 1.5: 1) * dimUnit[0]) / 2;
        
		// Display the recording indicator (red blinking circle)
        if (recording)
        {
        	if (blink)
        	{
        		dc.setColor( Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT );
        		dc.fillCircle(xOffset, yOffset, dimUnit [0] / 2);
        	}
        	blink = !blink;
        	
        	dc.setColor( Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT );
        	dc.drawCircle(xOffset, yOffset, dimUnit [0] / 2);
        	xOffset += 2 * dimUnit[0] / 3;
        }
        
        // Display the altitude
        dc.setColor( Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT );
        dc.drawText (xOffset, yOffset, Graphics.FONT_NUMBER_HOT, alt, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        
		// Display the unit of altitude
        xOffset += dimAlt[0];
        dc.setColor( Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT );
    	dc.drawText(xOffset, yOffset, Graphics.FONT_XTINY, unit, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
   	}
   	
   	function speed (dc, speed)
   	{
   		var unit = " km/h";
   	
        var yOffset = dc.getHeight() / 4;
        var xOffset = dc.getWidth () / 2;
        
        var dimSpeed  = dc.getTextDimensions (speed, Graphics.FONT_NUMBER_MILD) as [ Lang.Number, Lang.Number ];
        var dimUnit = dc.getTextDimensions (unit, Graphics.FONT_XTINY) as [ Lang.Number, Lang.Number ];
        
		// Display the speed
        xOffset -= (dimSpeed[0] + dimUnit[0]) / 2;
        dc.setColor( Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT );
        dc.drawText (xOffset, yOffset, Graphics.FONT_NUMBER_MILD, speed, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        
		// Display the unit of speed
        xOffset += dimSpeed[0];
        dc.setColor( Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT );
        dc.drawText (xOffset, yOffset, Graphics.FONT_XTINY, unit, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
   	}
   	
   	function beep (dc, vSpeedMS)
   	{
   		if (Attention has :playTone && $.preferences.getBeep ())
   		{
   			var freq = 600 + 75 * (vSpeedMS - climbingThreshold);
            freq = (freq < 600 ? 600: (freq > 2200 ? 2200: freq)); // clamp
   		
   			// http://blueflyvario.blogspot.com/2013/07/hardware-settings.html beep cadence
            // https://www.rpmsport.net/wordpress/wp-content/uploads/2015/01/Flymaster-VARIO-SD-manual-EN-v2.pdf  4.5.2
            // See also the matlab script beepDuration.m
            var dur = (vSpeedMS <= 0.0f ? 0.0f:  50.0f / ((vSpeedMS / 12.0f) + 0.1f));            
            dur = (dur < 75 ? 75: dur);	
            
            var toneProfile =
		    [
		        new Attention.ToneProfile( freq, dur )
		    ];
            
            Attention.playTone({:toneProfile=>toneProfile});	
		}
   	}
   	
   	
   	// https://www.w3schools.com/colors/colors_picker.asp
   	const COLOR_LT_RED = 0xff8080; // 0xffb3b3;
   	const COLOR_LT_GREEN = 0x33ff77; // 0xb3ffcc; // BUG in compiler when specifying HEX format without number!
   	
   	function vario (dc, vario)
   	{
   		var unit = " m/s";
   	
        var yOffset = 3 * dc.getHeight() / 4;
        var xOffset = dc.getWidth () / 2;

		var color = Graphics.COLOR_TRANSPARENT;
		
		switch (varioColor)
    	{
	    	case VarioSink:     color = COLOR_LT_RED; break;
	    	case VarioZeroing:  color = Graphics.COLOR_TRANSPARENT; break;
	    	case VarioClimb:    color = COLOR_LT_GREEN; beep (dc, vario); break;
    	}

       	var text = vario < 0 ? vario.format("%.1f"): "+" + vario.format ("%.1f");
        
        var dimVario = dc.getTextDimensions (text, Graphics.FONT_NUMBER_MILD) as [ Lang.Number, Lang.Number ];
        var dimUnit  = dc.getTextDimensions (unit, Graphics.FONT_XTINY) as [ Lang.Number, Lang.Number ];
        
		// Display the vario background color in the lower half of the screen
        if (color != Graphics.COLOR_TRANSPARENT)
        {	
	        dc.setColor( color, Graphics.COLOR_TRANSPARENT );
	        var y0 = yOffset - dimVario[1];
	        dc.setClip(0, y0, dc.getWidth (), dc.getHeight());
	        	dc.fillCircle(dc.getWidth () / 2, dc.getHeight() / 2, dc.getWidth () / 2 - borderSize);
	        dc.clearClip();
	    }
        
		// Display the vario
       	xOffset -= (dimVario[0] + dimUnit[0]) / 2;
        dc.setColor( Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT );
        dc.drawText (xOffset, yOffset, Graphics.FONT_NUMBER_MILD, text, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        
		// Display the unit of vario
        xOffset += dimVario[0];
        dc.setColor( Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT );
        dc.drawText (xOffset, yOffset, Graphics.FONT_XTINY, unit, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
   	}
}