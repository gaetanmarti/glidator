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
    
	function displayDefaultScreen (dc, vario, record)
	{
		display.start (dc, vario == null ? 0.0: vario);
       	
	        var heading = data.getHeading ();
			if (heading != null)
			{
				display.heading (dc, heading); 
			}
	        
			// Note that vario should be displayed before altitude
			if (vario != null)
			{
				display.vario (dc, vario); 
			} 

			var altitude = data.getAltitude ();
	        if (altitude == null)
	        {
	        	display.waitForAltitude (dc);
	   			return;
	        }
	        display.altitude (dc, altitude == null ? null: Math.round(altitude).toNumber().toString(), record);
			
			var speed = data.getSpeed ();
			if (speed != null)
			{
				speed *= 3.6; // !!!
				display.speed (dc, speed.format("%.0f"));
			}
				
		display.end (dc);
	}

	function displayThermalScreen (dc, vario, record)
	{
		System.println("TODO: Implement thermal screen");
	}

    // Update the view
    function onUpdate (dc) 
    {
    	if (display == null)
    	{
    		return;
    	}

		var vario  = data.getVario ();
		var record = Toybox has :ActivityRecording && $.session != null && $.session.isRecording();
	
       	switch (preferences.getCurrentScreen ())
	   	{
			default:
				System.println("Unknown screen!");
			case Preferences.DefaultScreen:
				displayDefaultScreen (dc, vario, record);
				break;
			case Preferences.ThermalScreen:
				displayThermalScreen (dc, vario, record);
				break;
		}
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
