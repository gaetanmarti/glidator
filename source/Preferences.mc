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

}