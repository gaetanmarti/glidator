using Toybox.Application;
using Toybox.Sensor;

using Toybox.Activity;
using Toybox.ActivityRecording;
using Toybox.Attention;

// --------------------------------------------------------------------------------
// Session recording
// --------------------------------------------------------------------------------

var session;

function isRecording ()
{
	return (Toybox has :ActivityRecording) &&  $.session != null && $.session.isRecording();
}

function stopRecording (save)
{
	if ($.isRecording ())
	{
		$.session.stop();
		if (save)
		{
        	$.session.save();
        }
        else
        {
        	$.session.discard();
        }
        
        
        if (Attention has :playTone)
	    {
   			Attention.playTone(Attention.TONE_STOP);
		}
		
		if (Attention has :vibrate)
		{
			var vibeData =
    		[
				new Attention.VibeProfile(25, 1000)
			];
			Attention.vibrate(vibeData);
        }
        
        $.session = null;
    }
}



function startRecording ()
{
	if (isRecording ())
	{
		return;
	}
	
	if (Toybox has :ActivityRecording)
	{
	    $.session = ActivityRecording.createSession({
	    	:name=>"Glide",
	    	:sport=>Activity.SPORT_FLYING});
	    $.session.start();
	    
	    if (Attention has :playTone)
	    {
   			Attention.playTone(Attention.TONE_START);
		}
		if (Attention has :vibrate)
		{
			var vibeData =
    		[
				new Attention.VibeProfile(100, 1000)
			];
			Attention.vibrate(vibeData);
        }
    }
}
         
// --------------------------------------------------------------------------------
// Globals
// --------------------------------------------------------------------------------
                  
var preferences;
  
// --------------------------------------------------------------------------------
// Main app
// --------------------------------------------------------------------------------

class FlyInstrumentApp extends Application.AppBase
{
	var mainView;
	
    function initialize ()
    {
        AppBase.initialize ();
        
        preferences = new Preferences ();
    }

    // onStart() is called on application start up
    function onStart (state)
    {
 		Position.enableLocationEvents (Position.LOCATION_CONTINUOUS, method (:onPosition));
 		Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_TEMPERATURE]);
 		Sensor.enableSensorEvents(method(:onSensor));
    }

    // onStop() is called when your application is exiting
    function onStop (state)
    {
    	$.stopRecording (false);
        Position.enableLocationEvents (Position.LOCATION_DISABLE, method (:onPosition));
        Sensor.enableSensorEvents (null);
        Sensor.unregisterSensorDataListener ();
    }
    
    function onPosition (info as $.Toybox.Position.Info) as Void
    {
        // Do nothing to avoid both call of onPosition and onSensor called in the same cycle
        // mainView.updateData ();   
    }
   
    // Should be called every 1Hz
    function onSensor (info as $.Toybox.Sensor.Info) as Void
    {
        mainView.updateData ();
    }
    
    // Return the initial view of your application here
    function getInitialView ()
    {
    	mainView = new FlyInstrumentView ();
        return [mainView, new BaseInputDelegate()];
    }

}
