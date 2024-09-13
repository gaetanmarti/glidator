using Toybox.Application;

class Preferences
{
	var app;

	function initialize()
    {
    	app = Application.getApp();
    }
    
    function getBeep ()
    {
    	var beep = app.getProperty("beep");
		  return (beep == null ? false: beep);
    }
    
    function setBeep (newVal)
    {
    	app.setProperty("beep", newVal);
    }


    function getRecording ()
    {
    	return $.isRecording ();
    }
    
    function setRecording (newVal)
    {
    	if (newVal)
    	{
    		$.startRecording ();
    	}
    	else
    	{
    		$.stopRecording (false);
    	}
    }

    enum {DefaultScreen, ThermalScreen}
    function getCurrentScreen ()
    {
    	var screen = app.getProperty("screen");
		  return (screen == null ? DefaultScreen: screen);
    }

    function setCurrentScreen (newVal)
    {
    	app.setProperty("screen", newVal);
    }

    function nextScreen ()
    {
    	var screen = getCurrentScreen ();
    	screen = (screen == DefaultScreen ? ThermalScreen: DefaultScreen);
    	setCurrentScreen (screen);
    }

}