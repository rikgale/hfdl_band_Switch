# hfdl_band_Switch
 A script for switching the bands your HFDL set up monitors at certain times of day. Useful if you have a limited number of SDRs and/or do not wish to monitor all the bands all the time.

 Assumes that you have set up your HFDL to use services and timers to start / stop / monitor dumpHFDL, and that all services are working as you want. If you followed [this guide](https://github.com/rikgale/hfdl_install) then you should be well away.

 Clone the repo and make the script excutable:

 ```bash
git clone https://github.com/rikgale/hfdl_band_Switch.git
cd hfdl_band_Switch
sudo chmod +x bandSwitch.sh
cd
```

Set up script parameters manually. Requires a start and end time for the day period, a start and end time for the night period, the name of the service to run during the day, the name of the service to run during the night and optionally, which bands those services cover.

```bash
#Display script switches and descriptions
/home/pi/hfdl_band_Switch/bandSwitch.sh -h
```

example:
```bash
/home/pi/hfdl_band_Switch/bandSwitch.sh -startdaytime 07:30 -enddaytime 22:30 -startnighttime 22:31 -endnighttime 07:29 -serviceday dumphfdl5 -servicenight dumphfdl4 -bandday "Band 17" -bandnight "Band 5-6"
```
dumphfdl4 and dumphfdl5 are set up to use the same SDR, so only one can be used at any given time. The above example switches between them at different times of the day. enddaytime should be no later than 23:58 (still working out the logic to get it to work properly).

Running the script should place `bandSwitch.log` in your home drive.



Once you have it working, add script to sudo crontab. Must be sudo crontab as this script works with services.
```
sudo crontab -e
```

Set it to run at least a couple of times/hour incase the computer restarts for any reason, then it should notice and select the correct dumphfdl to run given the time of day.
```nano
1-59/5 * * * * /home/pi/hfdl_band_Switch/bandSwitch.sh -startdaytime 08:30 -enddaytime 22:30 -startnighttime 22:31 -endnighttime 08:29 -serviceday dumphfdl5 -servicenight dumphfdl4 -bandday "Band 17" -bandnight "Band 2-4"
2-59/5 * * * * /home/pi/hfdl_band_Switch/bandSwitch.sh -startdaytime 09:30 -enddaytime 23:30 -startnighttime 23:31 -endnighttime 09:29 -serviceday dumphfdl3 -servicenight dumphfdl6 -bandday "Band 21" -bandnight "Band 5-6"
```
The above `sudo crontab -e` entries switch between band 17 and 21 during the day to band 2-4 and 5-6 over night. 17 & 2-4 share the same SDR, 21 & 5-6 also share an SDR. The lower bands are more likely to be active overnight and bands 17 and 21 are very active during the day.

