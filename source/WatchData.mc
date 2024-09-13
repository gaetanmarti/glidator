using Toybox.WatchUi;

class WatchData
{
	var gpsData = null;
	var activityData = null;
	var sensorData = null;

	var oldAlt = null;
	var vario = null;

	function startMeasure ()
	{
		gpsData = null;
		activityData = null;
		sensorData = null;
	}
	
	
	function endMeasure ()
	{
		var alt = getAltitude ();
		if (alt != null)
		{
			if (oldAlt != null)
			{
				vario = alt - oldAlt;
			}
			oldAlt = alt;
		}
	}

	function getVario ()
    {
    	return vario;
    }

	// Availability of data from the GPS
	// https://developer.garmin.com/connect-iq/api-docs/Toybox/Position/Info.html
	(:typecheck(false))
	// See https://forums.garmin.com/developer/connect-iq/i/bug-reports/the-type-checker-warns-about-info-field-even-after-checking-field-is-present
	function updateInfo (info)
	{
		var data = {};
		
		// The elevation above mean sea level in meters (m).
		// If no GPS is present, then no valid elevation will be returned.
		if (info has :altitude)
        {
        	data ["altitude"] = info.altitude;
        }
        
        // If no GPS is available or is between GPS fix intervals (typically 1 second),
        // the position is propagated (i.e. dead-reckoned) using the last known heading
        // and last known speed. After a short period of time, the position will cease
        // to be propagated to avoid excessive accumulation of position errors.
        if (info has :position)
        {
        	data ["lat"]  = info.position.toDegrees()[0];
        	data ["long"] = info.position.toDegrees()[1];
        }
        
        // A value of 0 indicates an accuracy value is not available, while a value of 4 indicates a good GPS 
        if (info has :accuracy)
        {
        	data ["accuracy"] = info.accuracy;
        }
        
        // Speed is derived from the most accurate source in the following order:

		// 1. GPS
		// 2. Foot pod
		// 3. Accelerometer
        
        // Speed is in mps
        
        if (info has :speed)
        {
        	data ["speed"] = info.speed;
        }
        
        // The true north referenced heading in radians.
        // This provides the direction of travel when moving. If supported by the device, it provides compass orientation when stopped.
        if (info has :heading)
        {
        	data ["heading"] = info.heading;
        }
        
        // The GPS time stamp of the obtained Location fix.
        // Class: Toybox::Time::Moment
        // https://developer.garmin.com/connect-iq/api-docs/Toybox/Time/Moment.html
        if (info has :when)
        {
        	data ["when"] = info.when;
        }
        
        gpsData = data;
    }
    
	// https://developer.garmin.com/connect-iq/api-docs/Toybox/Activity/Info.html
	function updateActivityInfo (info)
	{
		var data = {};
		
		// The current altitude in meters (m)
		if (info has :altitude)
        {
        	data ["altitude"] = info.altitude;
        }
        
        // The current heart rate in beats per minute (bpm).
		if (info has :currentHeartRate)
        {
        	data ["heartRate"] = info.currentHeartRate;
        }
        
    	activityData = data;
    }
    
    
    // https://developer.garmin.com/connect-iq/api-docs/Toybox/Sensor/Info.html
	(:typecheck(false))
	// See https://forums.garmin.com/developer/connect-iq/i/bug-reports/the-type-checker-warns-about-info-field-even-after-checking-field-is-present
    function updateSensorInfo (info)
	{
		var data = {};
		
		// Elevation is derived from the most accurate source: 
		// Barometer or GPS in order of descending accuracy.
		// If no GPS is present, then barometer readings will be used.
		if (info has :altitude)
        {
        	data ["altitude"] = info.altitude;
        }
        
       	// The heart rate in beats per minute (bpm).
		if (info has :heartRate)
        {
        	data ["heartRate"] = info.heartRate;
        }
        
        // The speed in meters per second (m/s).
        if (info has :speed)
        {
        	data ["speed"] = info.speed;
        }
        
    	sensorData = data;
    }
      
    (:typecheck(false))
	// See https://forums.garmin.com/developer/connect-iq/i/bug-reports/the-type-checker-warns-about-info-field-even-after-checking-field-is-present
    function getAltitude ()
    {
    	if (activityData != null && activityData.hasKey("altitude"))
    	{
    		return activityData	["altitude"];
    	}
    
    	// Fitlered altitude data (seems to require GPS)
    	if (sensorData != null && sensorData.hasKey("altitude"))
    	{
    		return sensorData ["altitude"];
    	}
    
    	if (gpsData != null && gpsData.hasKey("altitude"))
    	{
    		return gpsData ["altitude"];
    	}
    	
    	return null;
    }
    
    (:typecheck(false))
	// See https://forums.garmin.com/developer/connect-iq/i/bug-reports/the-type-checker-warns-about-info-field-even-after-checking-field-is-present
    function getSpeed ()
    {
    	if (sensorData != null && sensorData.hasKey("speed"))
    	{
    		return sensorData ["speed"];
    	}
    
    	if (gpsData != null && gpsData.hasKey("speed"))
    	{
    		return gpsData ["speed"];
    	}
    	
    	return null;
    }
    
	(:typecheck(false))
	// See https://forums.garmin.com/developer/connect-iq/i/bug-reports/the-type-checker-warns-about-info-field-even-after-checking-field-is-present
    function getHeartRate ()
    {
    	if (activityData != null && activityData.hasKey("heartRate"))
    	{
    		return activityData	["heartRate"];
    	}

    	if (sensorData != null && sensorData.hasKey("heartRate"))
    	{
    		return sensorData ["heartRate"];
    	}
    	    	
    	return null;
    }

    (:typecheck(false))
	// See https://forums.garmin.com/developer/connect-iq/i/bug-reports/the-type-checker-warns-about-info-field-even-after-checking-field-is-present
    function getHeading ()
    {
    	if (gpsData != null && gpsData.hasKey("heading"))
    	{
    		return gpsData ["heading"];
    	}
    	    	
    	return null;
    }
}