# glidator
This application - developed for Garmin watches - provides basic and comprehensive flight instruments for gliders.

This application provides basic and comprehensive flight instruments for gliders. It shows altitude, GPS heading, as well as vertical and horizontal speeds. It is possible to record your flight (with the select button).The watch face clearly displays when climbing (rate higher than +0.3 m/s) or when sinking (rate lower than -2.0 m/s). The beep can be activated/deactivated using the menu button (long click on the center left button on the Fenix®).

# Monkey C - installation

1. Download and install the latest Garmin SDK (`https://developer.garmin.com/connect-iq/sdk/`). Current SDK version is `Connect IQ 7.2.1`.
2. Note that you need a Garmin developer Key that is used during the "Verify Installation" step. Ensure that you have selected the `.der` certificate file !

# Code compilation

1. (CMD + SHIFT + P) `> Monkey C: Build Current Project`.
2. Activate a `.mc` file and RUN or RUN in DEBUG MODE.

# Deployment

1. Export the project via command `Monkey C: Export Project`.
2. Go in Garmin IQ and upload the gernrated `glidator.iq` file.