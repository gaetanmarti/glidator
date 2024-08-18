using Toybox.WatchUi;

class WatchDisplay
{
	var borderSize;
	var dc;

	// Retrieve these data from Store (https://developer.garmin.com/connect-iq/api-docs/Toybox/Application/Storage.html#getValue-instance_method)
    var climbingThreshold =  0.3;
    var sinkingThreshold  = -2.0;
	
    function initialize (deviceContext)
    {
    	dc = deviceContext;
        borderSize = dc.getWidth () / 12;
    }
    
    enum {VarioSink, VarioZeroing, VarioClimb}
    var varioColor = VarioZeroing;  
    
    function start (vario)
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
   
    	var color;
    
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
    
    function end ()
    {
    	dc.setColor( Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT );
	    dc.drawCircle (dc.getWidth ()/2, dc.getHeight ()/2, dc.getWidth ()/2-borderSize);
    }
    
    function waitForAltitude ()
    {
    	dc.setColor( Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT );
   		dc.drawText (dc.getWidth () / 2, dc.getHeight() / 2, Graphics.FONT_LARGE, "starting ...", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
    
    
    // Heading in radians
    function heading (heading)
    {
    	//heading = Math.toRadians(180+45);
    
    	var w = dc.getWidth ();
    	var h = dc.getHeight ();
    	var offset  = 0.5;
    	
    	var points  = [[-borderSize/2,-h/2+borderSize+offset],[0,-h/2],[borderSize/2,-h/2+borderSize+offset]];
    		
    	var pts = points.size ();
    	var cos = Math.cos(heading);
    	var sin = Math.sin(heading);
    		
    	for (var i = 0; i < pts; i++)
    	{
    		var x0 = -points[i][0];
    		var y0 = -points[i][1];
    	
    		var x1 = x0 * cos - y0 * sin;
    		var y1 = x0 * sin + y0 * cos;
    	
    		points[i][0] =  w / 2 - x1;
    		points[i][1] =  h / 2 - y1;
    	}
    	
		dc.setColor( Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT );
    	dc.fillCircle (w/2, h/2, w/2-borderSize);
    	
    	dc.setColor( /*Graphics.COLOR_BLUE*/ Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT );
    	dc.fillPolygon (points);
    	
    	dc.setPenWidth(2);
	    	dc.setColor( Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT );
	    	for (var i = 0; i + 1 < pts; i++) // Do not display last line. Was: for (var i = 0; i < pts; i++) 
	    	{
	    		dc.drawLine(points[i][0], points[i][1], points[(i+1)%pts][0], points[(i+1)%pts][1]);
	    	}
    	dc.setPenWidth(1);	
    	 	
    }
    	
    var blink = false;
    	
   	function altitude (alt, recording)
   	{
   		var unit = " m";
   	
        var yOffset = dc.getHeight() / 2;
        var xOffset = dc.getWidth () / 2;
        
        var dimAlt  = dc.getTextDimensions (alt,  Graphics.FONT_NUMBER_HOT);
        var dimUnit = dc.getTextDimensions (unit, Graphics.FONT_XTINY);
        
        xOffset -= (dimAlt[0] + dimUnit[0]) / 2;
        
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
        	xOffset += dimUnit[0] / 2;
        }
        
        
        dc.setColor( Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT );
        dc.drawText (xOffset, yOffset, Graphics.FONT_NUMBER_HOT, alt, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        
        xOffset += dimAlt[0];
        dc.setColor( Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT );
    	dc.drawText(xOffset, yOffset, Graphics.FONT_XTINY, unit, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
   	}
   	
   	function speed (speed)
   	{
   		var unit = " km/h";
   	
        var yOffset = dc.getHeight() / 4;
        var xOffset = dc.getWidth () / 2;
        
        var dimSpeed  = dc.getTextDimensions (speed, Graphics.FONT_NUMBER_MILD);
        var dimUnit = dc.getTextDimensions (unit, Graphics.FONT_XTINY);
        
        xOffset -= (dimSpeed[0] + dimUnit[0]) / 2;
        dc.setColor( Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT );
        dc.drawText (xOffset, yOffset, Graphics.FONT_NUMBER_MILD, speed, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        
        xOffset += dimSpeed[0];
        dc.setColor( Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT );
        dc.drawText (xOffset, yOffset, Graphics.FONT_XTINY, unit, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
   	}
   	
   	// https://www.w3schools.com/colors/colors_picker.asp
   	const COLOR_LT_RED = 0xff8080; // 0xffb3b3;
   	const COLOR_LT_GREEN = 0x33ff77; // 0xb3ffcc; // BUG in compiler when specifying HEX format without number!
   	
   	function vario (vario)
   	{
   		var unit = " m/s";
   	
        var yOffset = 3 * dc.getHeight() / 4;
        var xOffset = dc.getWidth () / 2;

		var color;
		
		switch (varioColor)
    	{
	    	case VarioSink:     color = COLOR_LT_RED; break;
	    	case VarioZeroing:  color = Graphics.COLOR_TRANSPARENT; break;
	    	case VarioClimb:    color = COLOR_LT_GREEN; break;
    	}

       	var text = vario < 0 ? vario.format("%.1f"): "+" + vario.format ("%.1f");
        
        var dimVario = dc.getTextDimensions (text, Graphics.FONT_NUMBER_MILD);
        var dimUnit  = dc.getTextDimensions (unit, Graphics.FONT_XTINY);
        
        if (color != Graphics.COLOR_TRANSPARENT)
        {	
	        dc.setColor( color, Graphics.COLOR_TRANSPARENT );
	        var y0 = 3 * dc.getHeight() / 4 - dimVario[1];
	        dc.setClip(0, y0, dc.getWidth (), dc.getHeight());
	        	dc.fillCircle(dc.getWidth () / 2, dc.getHeight() / 2, dc.getWidth () / 2 - borderSize);
	        dc.clearClip();
	    }
        
       	xOffset -= (dimVario[0] + dimUnit[0]) / 2;
        dc.setColor( Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT );
        dc.drawText (xOffset, yOffset, Graphics.FONT_NUMBER_MILD, text, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        
        xOffset += dimVario[0];
        dc.setColor( Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT );
        dc.drawText (xOffset, yOffset, Graphics.FONT_XTINY, unit, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
   	}
   	
/*   	
   	function displayVario (dc)
   	{
        var yOffset = 3 * dc.getHeight() / 4;
        var xOffset = dc.getWidth () / 2;
        
        var dx = dc.getWidth () / 2 / WatchData.varioMaxSize;
        var dymax = dc.getWidth () / 8;
        
        var scale = 3;
        var grayzone = 0.7;
        
        var delta = (WatchData.varioMaxSize / 2) * dx;
                        
        if (data.vario.size () != 0)
   		{
   			var x0 = xOffset + delta - dx;
   		
   			for (var i = data.vario.size () - 1; i > 0; i--)
	        {
	        	var val = data.vario [i];
	        	
	        	// Clamp
	        	val = val < -scale ? -scale: val;
	        	val = val >  scale ?  scale: val;
	        	
	        	var y0 = (val * dymax) / scale;
	        		
	        	if (val > 0)
	        	{
	        		dc.setColor(val > grayzone ? Graphics.COLOR_DK_GREEN : Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
	        		dc.fillRectangle(x0, yOffset-y0, dx, y0+1);
	        	}
	        	else
	        	{
	        		dc.setColor(val < -grayzone ? Graphics.COLOR_DK_RED : Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
	        		dc.fillRectangle(x0, yOffset, dx, -y0);
	        	}
    			
	        	x0 -= dx; 
	        }
	        
	        // DEBUG
	        var last = data.vario [data.vario.size () - 1];
	        dc.setColor( Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT );
	        dc.drawText (xOffset + delta + dx/2, yOffset - 2, Graphics.FONT_XTINY,
	                     last.format("%.1f"), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
   		}
   		
   		dc.setColor( Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT );
        dc.drawLine(xOffset - delta, yOffset, xOffset + delta, yOffset);
   	}
*/   	
}