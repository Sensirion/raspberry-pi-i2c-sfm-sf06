# Sensirion Raspberry Pi I2C SFM-SF06 Driver

This document explains how to set up the SFM-SF06 sensor to run on a Raspberry Pi
using the provided code. The current code example uses the sensor *SFM3119*

[<center><img src="images/sfm3119.png" width="300px"></center>](https://github.com/Sensirion/raspberry-pi-i2c-sfm-sf06)

Other supported products are:

 * SFM3003
 * SFM4300
 * SFM3119
 * SFM3012
 * SFM3019


Click [here](https://www.sensirion.com/flow-sensors/) to learn more about the Sensirion SFM-SF06 flow sensors.


## Setup Guide

### Connecting the Sensor

Your sensor has the four different connectors: VCC, GND, SDA, SCL. Use
the following pins to connect your SFM-SF06 (example product: SFM-3119):

 *SFM-SF06* |    *Raspberry Pi*
 :------:   | :------------------:
   VCC      |        Pin 1
   GND      |        Pin 6
   SDA      |        Pin 3
   SCL      |        Pin 5


<center><img src="images/GPIO-Pinout-Diagram.png" width="900px"></center>
<center><img src="images/sfm3119_pinout.png" width="450px"></center>

### Raspberry Pi

- [Install the Raspberry Pi OS on to your Raspberry Pi](https://projects.raspberrypi.org/en/projects/raspberry-pi-setting-up)
- [Enable the I2C interface in the raspi-config](https://www.raspberrypi.org/documentation/configuration/raspi-config.md)
- Download the driver for the [Sensirion Github Page](https://github.com/Sensirion/raspberry-pi-i2c-sfm-sf06) and extract the `.zip` on your Raspberry Pi
- The provided example is working with a SFM3119. In order to use the code with another product you need to change the used I2C address in the function call *init_driver()*. The list of supported I2C-addresses is found in the header *sfm_sf06_i2c.h*.
- Compile the driver
    1. Open a [terminal](https://www.raspberrypi.org/documentation/usage/terminal/?)
    2. Navigate to the driver directory. E.g. `cd ~/raspberry-pi-i2c-sfm-sf06`
    3. Run the `make` command to compile the driver

       Output:
       ```
       rm -f sfm_sf06_i2c_example_usage
       cc -Os -Wall -fstrict-aliasing -Wstrict-aliasing=1 -Wsign-conversion -fPIC -I. -o sfm_sf06_i2c_example_usage  sfm_sf06_i2c.h sfm_sf06_i2c.c sensirion_i2c_hal.h sensirion_i2c.h sensirion_i2c.c \
           sensirion_i2c_hal.c sensirion_config.h sensirion_common.h sensirion_common.c sfm_sf06_i2c_example_usage.c
       ```
- Test your connected sensor
    - Run `./sfm_sf06_i2c_example_usage` in the same directory you used to
      compile the driver.

      Output:
      ```
     
     Product identifier: 67371397
     Serial number: 0, 0, 0, 0, 120, 209, 158, 83, 
        flow	 temperature	      status
      -24574	        5318	        3071
      -24574	        5323	        3071
      -24574	        5336	        3071
      -24575	        5334	        3071
      -24574	        5324	        3071
      -24574	        5334	        3071
      -24573	        5329	        3071
      -24574	        5344	        3071

      ...
      ```

## Troubleshooting

### Building driver failed

If the execution of `make` in the compilation step 3 fails with something like

> -bash: make: command not found

your RaspberryPi likely does not have the build tools installed. Proceed as follows:

```
$ sudo apt-get update
$ sudo apt-get upgrade
$ sudo apt-get install build-essential
```

### Initialization failed

If you run `./sfm_sf06_i2c_example_usage` but do not get sensor readings but something like this instead

```
Error executing sfm_sf06_stop_continuous_measurement(): -1
Error executing sfm_sf06_read_product_identifier(): -1
Error executing sfm_sf06_start_o2_continuous_measurement(): -1

...
```

then go through the below troubleshooting steps.


-   Ensure that you connected the sensor correctly: All cables are fully
    plugged in and connected to the correct pin.
-   Ensure that I2C is enabled on the Raspberry Pi. For this redo the steps on
    "Enable the I2C interface in the raspi-config" in the guide above.
-   Ensure that your user account has read and write access to the I2C device.
    If it only works with user root (`sudo ./sfm_sf06_i2c_example_usage`), it's
    typically due to wrong permission settings. See the next chapter how to solve this.

### Missing I2C permissions

If your user is missing access to the I2C interface you should first verfiy
the user belongs to the `i2c` group.

```
$ groups
users input some other groups etc
```
If `i2c` is missing in the list add the user and restart the Raspberry Pi.

```
$ sudo adduser your-user i2c
Adding user `your-user' to group `i2c' ...
Adding user your-user to group i2c
Done.
$ sudo reboot
```

If that did not help you can make globally accessible hardware interfaces
with a udev rule. Only do this if everything else failed and you are
reasoably confident you are the only one having access to your Pi.

Go into the `/etc/udev/rules.d` folder and add a new file named
`local.rules`.
```
$ cd /etc/udev/rules.d/
$ sudo touch local.rules
```
Then add a single line `ACTION=="add", KERNEL=="i2c-[0-1]*", MODE="0666"`
to the file with your favorite editor.
```
$ sudo vi local.rules
```
