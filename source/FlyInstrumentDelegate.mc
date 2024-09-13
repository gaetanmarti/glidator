using Toybox.WatchUi;
using Toybox.ActivityRecording;

using Toybox.System as Sys;

// --------------------------------------------------------------------------------

class MyMenu2QuitDelegate extends WatchUi.Menu2InputDelegate
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

class OnToggleBeepDelegate extends WatchUi.Menu2InputDelegate
{
	var beepToggleMenu;

    function initialize(beepTM)
    {
        Menu2InputDelegate.initialize();
        beepToggleMenu = beepTM;
    }

    function onBack()
    {
    	$.preferences.setBeep (beepToggleMenu.isEnabled());
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}

// --------------------------------------------------------------------------------

class OnToggleRecordDelegate extends WatchUi.Menu2InputDelegate
{
	var recordToggleMenu;

    function initialize(recordTM)
    {
        Menu2InputDelegate.initialize();
        recordToggleMenu = recordTM;
    }
    
    // Note: do not save the recording is disabled from here
    function onBack()
    {
    	$.preferences.setRecording (recordToggleMenu.isEnabled());
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
        $.preferences.nextScreen ();
        return true;
    }
    
    function onBack()
    {
    	if ($.isRecording ())
    	{
	        var menu = new WatchUi.Menu2({:title=>"Quit ?"});
	        menu.addItem(new WatchUi.MenuItem("Resume", null, "resume", null));
	        menu.addItem(new WatchUi.MenuItem("Save",   null, "save",   null));
	        menu.addItem(new WatchUi.MenuItem("Ignore", null, "ignore", null));
	        var delegate = new MyMenu2QuitDelegate(); // a WatchUi.Menu2InputDelegate
	        
	        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
	    }
	    else
	    {
	    	System.exit ();
	    }
	    return true;
    }
    
    function onMenu()
    {
    	 var menu = new WatchUi.Menu2({:title=>"Preferences"});
	        
	        var beep = $.preferences.getBeep ();
	        var beepTM = new WatchUi.ToggleMenuItem("Beep",  "Set audio on/off", "beep", beep, null);
	        menu.addItem(beepTM);	      
	        var delegate = new OnToggleBeepDelegate(beepTM); // a WatchUi.Menu2InputDelegate
	        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
 
            var record = $.preferences.getRecording ();
	        var recordTM = new WatchUi.ToggleMenuItem("Record",  "Set recording on/off", "record", record, null);
	        menu.addItem(recordTM);	      
	        delegate = new OnToggleRecordDelegate(recordTM); // a WatchUi.Menu2InputDelegate
	        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
   	
	    return true;
    }
    
    function onKey(keyEvent)
    {
        System.println(keyEvent.getKey()); // e.g. KEY_MENU = 7
        return true;
    }
    
}