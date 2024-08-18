using Toybox.Application;
using Toybox.WatchUi;
using Toybox.ActivityRecording;

class FlyInstrumentView extends WatchUi.View
{
	var data = new WatchData ();
	var display = null;

    function initialize()
    {
        View.initialize(); 
    }
    
    // Load your resources here
    function onLayout(dc)
    {
    	display = new WatchDisplay (dc);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow()
    {
    }
    
    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide()
    {
    }
    
    // Update the view
    function onUpdate (dc) 
    {
    	if (display == null)
    	{
    		return;
    	}

		// See note: https://developer.garmin.com/connect-iq/api-docs/Toybox/Graphics/Dc.html
		// "You should never directly instantiate a Dc object, or attempt to render to the screen outside of an onUpdate call."
		// It seems that on the new OS version, the Dc object is now passed as a parameter to the onUpdate method.
		display.dc = dc; // !!!
    
		var vario  = data.getVario ();
		var record = Toybox has :ActivityRecording && $.session != null && $.session.isRecording();
	
       	display.start (vario == null ? 0.0: vario);
       	
	        var heading = data.getHeading ();
			if (heading != null)
			{
				display.heading (heading); 
			}
	        
			var altitude = data.getAltitude ();
	        if (altitude == null)
	        {
	        	display.waitForAltitude ();
	   			return;
	        }
	        display.altitude (altitude == null ? null: Math.round(altitude).toNumber().toString(), record);
			
			var speed = data.getSpeed ();
			if (speed != null)
			{
				speed *= 3.6; // !!!
				display.speed (speed.format("%.0f"));
			
			}
				
			if (vario != null)
			{
				display.vario (vario); 
		} 
		
		display.end ();
		
		
		// DEBUG
		/*
		var heartRate = data.getHeartRate ();
		if (heartRate)
		{
			dc.setColor( Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT );
			dc.drawText (dc.getWidth () / 2, (3.5 * dc.getHeight()) / 4, Graphics.FONT_XTINY, heartRate.toString (), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		}
		if (Toybox has :ActivityRecording && $.session != null && $.session.isRecording())
		{
			dc.setColor( Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT );
			dc.drawText (dc.getWidth () / 2, (3.5 * dc.getHeight()) / 4, Graphics.FONT_XTINY, "recording", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		}
		
		*/
    }
    
    function updateData ()
    {
    	data.startMeasure();
    
    		var position = Position.getInfo();
    		if (position != null)
	    	{
	    		data.updateInfo (position);
	    	}
	    	
	    	var activity = Activity.getActivityInfo ();
	    	if (activity != null)
	    	{
	    		data.updateActivityInfo (activity);
	    	}
	    	
	    	var sensor = Sensor.getInfo();
	    	if (sensor != null)
	    	{
	    		data.updateSensorInfo (sensor);
	    	}
    	
    	data.endMeasure();
    	
        WatchUi.requestUpdate();
    }
}
