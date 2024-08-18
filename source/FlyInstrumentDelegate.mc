using Toybox.WatchUi;
using Toybox.ActivityRecording;

using Toybox.System as Sys;

// --------------------------------------------------------------------------------

class MyMenu2Delegate extends WatchUi.Menu2InputDelegate
{
    function initialize()
    {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item)
    {
    	if( item.getId().equals("resume") )
    	{
             WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
        else if( item.getId().equals("save") )
        {
            $.stopRecording (true);
            System.exit ();
        }
        else if( item.getId().equals("ignore") )
        {
            $.stopRecording (false);
            System.exit ();
        }
        
    }
    
    function onBack()
    {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}

// --------------------------------------------------------------------------------

class BaseInputDelegate extends WatchUi.BehaviorDelegate
{

    function initialize()
    {
        BehaviorDelegate.initialize();
    }

    function onSelect()
    {
    	$.startRecording();
    	WatchUi.requestUpdate();
        return true;
    }
    
    function onBack()
    {
    	Sys.println( "On BaseInputDelegate:onBack" );
    
    	if ($.isRecording ())
    	{
	        var menu = new WatchUi.Menu2({:title=>"Quit ?"});
	        menu.addItem(new WatchUi.MenuItem("Resume", null, "resume", null));
	        menu.addItem(new WatchUi.MenuItem("Save",   null, "save",   null));
	        menu.addItem(new WatchUi.MenuItem("Ignore", null, "ignore", null));
	        var delegate = new MyMenu2Delegate(); // a WatchUi.Menu2InputDelegate
	        
	        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
	    }
	    else
	    {
	    	System.exit ();
	    }
	    return true;
    }
    
}