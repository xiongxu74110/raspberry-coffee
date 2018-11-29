![Raspberry Coffee](./raspberryCoffee.png)
### Raspberry Coffee
#### Java code and wiring for the Raspberry Pi, featuring reusable libraries and snippets ####
It uses the [PI4J library](http://pi4j.com).

```
$ curl -s get.pi4j.com | sudo bash
```
---
This project contains Java code, mostly translated from Python, dedicated to usually *one* board (like BMP180, LSM303, etc).
More consistent samples can be found in the RasPISamples module (being moved to the Project.Trunk module), where several components have been assembled together.
Do take a look, it also comes with a readme file.

---
- [Main highlights](./Papers/README.md)
---

**Summary**
- [Setup a brand new Raspberry Pi](#setup-a-brand-new-raspberry-pi)
- [Developing on the Raspberry Pi, or Developing for the Raspberry Pi ?](#developing-on-the-raspberry-pi-or-developing-for-the-raspberry-pi-)
- [Raspberry Pi, a possible thing of the Internet of Things...](#raspberry-pi-a-possible-thing-of-the-internet-of-things)

#### Setup a brand new Raspberry Pi
To get started as quickly as possible, and not only for this project, from scratch.

##### Foundation Software
The goal here is to get ready with the minimal configuration you will be able to use to clone a git repository and start working on it.

Typically, you will need to have the minimal git tools and the right compilers. The code contained in the repo(s) will be responsible for
downloading the right dependencies at build time (`gradle` is definitely good at that).

##### Minimal setup
- Install Raspian (not NOOBS) as explained at https://www.raspberrypi.org/learning/software-guide/quickstart/, and burn your SD card
    - Depending on the OS you burn the SD card from, the procedure varies. Well documented in the link above.
- Boot on the Raspberry with the new SD card, USB keyboard and HDMI screen attached to it (if this is an old RPi, use a USB WiFi dongle too)
    - It should boot to the Graphical Desktop.
- Connect to your local network
- Use RPi-Config (from the Desktop GUI, Menu > Preferences > Raspberry Pi Configuration) to:
    - enable needed interfaces (ssh, serial, spi, i2c, VNC, etc)
        - `ssh` and `VNC` will allow remote access to your Raspberry Pi, the others depend on the projects you want to work on.
        - This can be modified or reverted at any time.
    - setup config (keyboard, locale, etc)
    - change pswd, hostname
        - for the hostname, you might need to go a Terminal, reach `sudo raspi-config`, and use `Network > Hostname`.
- Reboot (and now, you can use `ssh` if it has been enabled above) and reconnect

- From a terminal, run the following commands:
```
$ sudo apt-get update
$ sudo apt-get install vim
```
- setup your `.bashrc` as needed, adding for example lines like
```
alias ll="ls -lisah"
```
- recent Raspian releases come with a development environment that includes
    - JRE & JDK
    - git
    - python
    - C Compiler (gcc, g++)

```
#  Optional: sudo apt-get install -y curl git build-essential default-jdk
#  Optional too, to install nodejs and npm:
$ sudo su -
root# curl -sL https://deb.nodesource.com/setup_9.x | bash -
root# exit
$ sudo apt-get install -y nodejs
```
- make sure what you might need is installed, by typing:
```
$ java -version
$ javac -version
$ git --version
$ python --version
$ python3 --version
$ gcc -v
$ node -v
$ npm -v
```
- some utilities, to make sure they are present, type:
```
$ which scp
$ which curl
$ which wget
```
- You can use VNC (if enabled in the config above)
    - Run `vncserver` from a terminal, and use `VNC Viewer` from another machine to connect.

- You may also remove unwanted softwares, just in case you don't need them:
    - `$ sudo apt-get purge minecraft-pi`
    - `$ sudo apt-get purge sonic-pi`
    - `$ sudo apt-get purge libreoffice*`
    - `$ sudo apt-get clean`
    - `$ sudo apt-get autoremove`

- If you need AI and Deep Learning (Anaconda, Jupyter notebooks, TensorFlow, Keras), follow [this link](https://medium.com/@margaretmz/anaconda-jupyter-notebook-tensorflow-and-keras-b91f381405f8).
    - or type:
    ```
    $ wget https://repo.anaconda.com/archive/Anaconda3-5.3.0-Linux-x86_64.sh
    ```
    - [Anaconda on Raspberry Pi](https://qiita.com/jpena930/items/eac02cb4e635bfba83d8)
    - [Jupyter Notebooks on Raspberry Pi](https://www.instructables.com/id/Jupyter-Notebook-on-Raspberry-Pi/)
        - Start Jupyter Notebooks by typing `jupyter notebook [--allow-root] --ip 0.0.0.0 --no-browser`
        - Then the command to use to reach Jupyter would show up in the console.
    - _Note:_ Training a Neural Network is a very demanding operation, that requires computing resources not granted on a Raspberry Pi. Installing Keras on a Raspberry Pi might not be relevant. OpenCV, though, would be an option to consider. Google it ;).

###### Raspberry Pi as an Access Point _and_ Internet access.
Your Raspberry Pi can be turned into an Access Point, this means that it generates its own network, so you can connect to it from other devices (other Raspberry Pis, laptops, tablets, smart-phones, ESP8266, etc).
It can be appropriate when there is no network in the area you are in, for example when sailing in the middle of the ocean, kayaking in a remote place, hiking in the boonies, etc.

Setting up the Raspberry Pi to be an access point is well documented on the [Adafruit website](https://learn.adafruit.com/setting-up-a-raspberry-pi-as-a-wifi-access-point/install-software).

The thing is that when the Raspberry PI becomes a WiFi hotspot, you cannot use it to access the Internet, cannot use `apt-get install`, cannot use
`git pull origin master`, etc, that can rapidly become quite frustrating.

Now, for development purpose, you may very well need to have an Access Point **_and_** an Internet access (i.e. access to your local or wide area network).

For that, you need 2 WiFi adapters (yes, you could also use an Ethernet connection, which is a no brainer, we talk about WiFi here).
Recent Raspberry Pis are WiFi-enabled, you just need a WiFi dongle, that would fit on a USB port.
On older Raspberry Pis (not WiFi-enabled), you need 2 USB dongles.

As we said above, to enable `hostapd` to have your Raspberry PI acting as a WiFi hotspot, you can follow
<a href="https://learn.adafruit.com/setting-up-a-raspberry-pi-as-a-wifi-access-point/install-software" target="adafruit">those good instructions</a> from the Adafruit website.

> Note: On recent Raspberry Pi models (including the Zero W), you can comment the line of `/etc/hostapd/hostapd.conf` that mentions a driver:
```
# driver=rtl871xdrv
```
> The name and password of the network created by the Access Point is in the same file, `/etc/hostapd/hostapd.conf`.

<!-- TODO
  Can the the network address translation be skipped ?
 -->
The Raspberry PI 3 and the Zero W already have one embedded WiFi port, I just added another one, the small USB WiFi dongle I used to use
on the other Raspberry PIs.
This one becomes named `wlan1`. All I had to do was to modify `/etc/network/interfaces`:

```
# interfaces(5) file used by ifup(8) and ifdown(8)

# Please note that this file is written to be used with dhcpcd
# For static IP, consult /etc/dhcpcd.conf and 'man dhcpcd.conf'

# Include files from /etc/network/interfaces.d:
source-directory /etc/network/interfaces.d

auto lo
iface lo inet loopback

iface eth0 inet manual

allow-hotplug wlan0
iface wlan0 inet static
  address 192.168.42.1
  netmask 255.255.255.0

#iface wlan0 inet manual
#    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf

allow-hotplug wlan1
iface wlan1 inet dhcp
wpa-ssid "ATT856"
wpa-psk "<your network passphrase>"
```
See the 4 lines at the bottom of the file, that's it!

> Note: above, `192.168.42.1` will be the address of your hotspot, aka gateway. Feel free to change it to anything else, like `192.168.127.1`...
> If that was the case, you also need to make sure that the entry you've added in `/etc/dhcp/dhcpd.conf` matches this address range:
```
subnet 192.168.127.0 netmask 255.255.255.0 {
  range 192.168.127.10 192.168.127.50;
  option broadcast-address 192.168.127.255;
  option routers 192.168.127.1;
  default-lease-time: 600;
  max-lease-time: 7200;
  option domain-name "local-pi";
  option domain-name-servers 8.8.8.8 8.8.4.4;
}
```
The lines to pay attention to are the ones with a `127` in it...

Now, when the `wlan1` is plugged in, this Raspberry PI is a WiFi hotspot, *_and_* has Internet access.

This means that when you are on a Raspberry Pi with **two** WiFi adapters (the Raspberry Pi 3 with an extra dongle, where you do you developments from for example), you
have **two** WiFi interfaces, `wlan0` and `wlan1`.

When the same SD card runs on a Raspberry Pi with only **one** WiFi adapter (the Raspberry Pi Zero W you use to do some logging, when kayaking in the boonies for example),
you have only **one** WiFi interface `wlan0`, and the Raspberry Pi is a hotspot generating its own network, as defined by you in `/etc/hostapd/hostapd.conf`.

Now you're ready to rock!

_Note:_
Java code is compiled into `class` files, that run on a Java Virtual Machine (`JVM`). Java is not the only language that runs a `JVM`, this project also contains some small samples of
other JVM-aware languages, invoking and using the features of this project.

Those samples include Scala, Groovy, Kotlin..., and the list is not closed!

See in the [OthetJVM.languages](https://github.com/OlivierLD/raspberry-coffee/tree/master/OtherJVM.languages) directory.

---

#### How to build and run

_Note:_
This project uses `gradle` and `git`. `Gradle` will be installed automatically if it is not present on your system,
it uses the gradle wrapper (`gradlew`).

`Git` is usually installed on Linux and Mac, but not on all versions of Windows. On Windows, you need to install the [`git bash shell`](http://lmgtfy.com/?q=install+git+bash+shell+on+windows), and run _in it_ the commands mentioned in this document.
Recent versions of Windows (like Windows 10) seem to come with a git command available in  a Terminal. But this forward-slash/back-slash story
remains in your way, I have not tested it.

---
To build it, clone this project (this repo), make sure the script named `gradlew` is executable, and execute `gradlew`.
```
 Prompt> git clone https://github.com/OlivierLD/raspberry-coffee.git
 Prompt> cd raspberry-coffee
 Prompt> chmod +x gradlew
 Prompt> ./gradlew [--daemon] build
```
You are expecting an end like that one:
```


BUILD SUCCESSFUL in 55s
97 actionable tasks: 17 executed, 80 up-to-date
Prompt>
```
See the `gradle` web site for info about Gradle.

We will also be using the `shadowJar` gradle plugin is several projects.
This plugin is aggregating the required classes _and all their dependencies_ into a single archive, called a `fat Jar`. This simplifies the syntax of the `classpath`.

Typically, this operation will be run like this:
```
 Prompt> cd RESTNavServer
 Prompt> ../gradlew shadowJar
```
The expected archive will be produced in the local `build/libs` directory.


> _Important_ : If `JAVA_HOME` is not set at the system level, you can set it in `set.gradle.env` and execute it before running `gradlew`:
```
 Prompt> . ./set.gradle.env
```

> _Note:_ If you are behind a firewall, you need a proxy. Mention it in all the files named <code>gradle.propetries</code>, and in <b>all</b> the <code>build.gradle</code> scripts, uncomment the following two lines:
<pre>
// ant.setproxy(proxyhost: "$proxyHost", proxyport: "$proxyPort") //, proxyuser="user", proxypassword="password")
// compileJava.dependsOn(tellMeProxy)
</pre>

---
### Developing _on_ the Raspberry Pi, or Developing _for_ the Raspberry Pi ?

To write code, the simplest editor is enough. I have used `vi` for ages, mostly because this was the only one available, but also because it _**is**_ indeed good enough.
`vi` (and `vim`) is (are) available on the Raspberry Pi, `nano` too, graphical editors like `gedit`, `geany` are even easier to use, on a grahical desktop.

All the code provided here can be built from Gradle (all gradle scripts are provided), _**on the Raspberry Pi**_ itself.
The Raspberry Pi is self sufficient, if this is all you have, nothing is preventing you from accessing **_all_** the features presented here.

But let us be honest, Integrated Development Environments (IDE) are quite cool.
In my opinion, IntelliJ leads the pack, and Eclipse, JDeveloper, NetBeans follow. Cloud9 provides amazing features, on line.
Smaller ones like GreenFoot, BlueJ are also options to consider.


Those two last ones might be able to run on a Raspberry Pi, but forget about the others..., they use way too much RAM.
 The features they provide definitely increase productivity, and when you use them, you learn as you code. Code-insight, auto-completion
 and similar features are here to help. And I'm not even talking about the *remote debugging* features they provide as well.

 So, as the Raspberry Pi is not the only machine on my desk, I develop on a laptop using IntelliJ (with several GigaBytes of RAM, like 8, 16, ...), and I use `scp` to transfer the code to (and possibly from) the Raspberry Pi.
 Worst case scenario, I do a `git push` from the development machine, and a `git pull` from the Raspberry Pi.
 I found it actually faster and more efficient than developing directly on the Raspberry Pi.

##### Something to keep in mind

 The Java Virtual Machine (JVM) implements the Java Platform Debugging Architecture (JPDA). This allows **_remote debugging_**.
 In other words, you run the code on the Raspberry Pi,
 but you debug it (set breakpoints, introspect variable values, etc) on another machine (the one where the IDE runs).
 This is specially useful when the code interacts with sensors and other devices that are not supported from the laptop.
 This will make your life considerably easier than if you used another language missing it (like Python, C, and many others).
 It uses TCP between the debugger and the debuggee.

---

### Raspberry Pi, a possible thing of the Internet of Things...
  * The Raspberry Pi is a fully featured Linux computer, which can - as such - connect to the Internet.
  * The Raspberry Pi has a General Purpose Input Output (GPIO) interface that allows it to drive all kind of electronic components, from a simple LED to a complex robot, and including all kind of sensors (GPS, light resistors, pressure sensors, temperature sensors, all kinds!).
None of the above is new. Connecting to the Internet does not impress anyone anymore. Driving a robot, modern kitchens are full of robots, cars are loaded with electronic components...
**But** what if we put those two together, with the Raspberry Pi sitting in between.
**Then**, we can drive a robot over the Internet. And **this** is not that usual (yet).

---

The snippets provided in this project are here to help in this kind of context. Some will use the network aspect of the story, some others will interact with electronic components. The two aspects should be easy to bridge, that is the goal. If that was not the case, please let me know (email address of the left side).

---

#### Project list, growing...

Several projects are featured here:
  * Basic GPIO interaction
  * Two Leds
  * Use the Raspberry Pi to turn LEDs on and off, **through email** ([with doc](http://www.lediouris.net/RaspberryPI/email/readme.html))
  * Read Serial Port ([with doc](http://www.lediouris.net/RaspberryPI/serial/readme.html))
  * Read _and parse_ NMEA Data from a GPS ([with doc](http://www.lediouris.net/RaspberryPI/GPS/readme.html))
  * Read analog data with an Analog Digital Converter (ADC). ([with doc](http://www.lediouris.net/RaspberryPI/ADC/readme.html), with [node.js and WebSocket](http://www.lediouris.net/RaspberryPI/ADC/adc-websocket.html))
  * Drive servos using the  PCA9685. ([with doc](http://www.lediouris.net/RaspberryPI/servo/readme.html)).
  * Drive servos using the  PCA9685, **over the Internet**, with an Android client option. ([with doc](http://www.lediouris.net/RaspberryPI/servo/node.servo.html)).
  * Use the  LSM303. (I<sup>2</sup>C compass & accelerometer,  [with doc](http://www.lediouris.net/RaspberryPI/LSM303/readme.html)).
  * Use the  BMP180. (I<sup>2</sup>C temperature and pressure sensor,  [with doc](http://www.lediouris.net/RaspberryPI/BMP180/readme.html)).
  * Use the  BMP183. (SPI temperature and pressure sensor,  [with doc](http://www.lediouris.net/RaspberryPI/BMP183/readme.html)).
  * Use a relay, through email. ([with doc](http://www.lediouris.net/RaspberryPI/Relay.by.email/readme.html)).
  * Use a relay, through HTTP. ([with doc](http://www.lediouris.net/RaspberryPI/Relay.by.http/readme.html)).
  * Use a seven-segment display. ([with doc](http://www.lediouris.net/RaspberryPI/SevenSegment/readme.html)).
  * Use the  VCNL4000 (I<sup>2</sup>C proximity sensor).
  * Use the  TCS34725 (I<sup>2</sup>C color sensor, [demo](http://www.lediouris.net/RaspberryPI/TCS34725/readme.html)).
  * Use the  TSL2561 (I<sup>2</sup>C light sensor).
  * Use the  L3GD20 (I<sup>2</sup>C gyroscope, [demo](http://www.lediouris.net/RaspberryPI/L3GD20/readme.html)).
  * Use the  MCP4725 (I<sup>2</sup>C Digital to Analog Converter, [demo](http://www.lediouris.net/RaspberryPI/DAC/readme.html)).
  * ... and more.

---

All the doc - with more details than here - can be reached from [this page](http://raspberrypi.lediouris.net/).
