<p align="center">
  <a href="http://motivateclock.org/en/">
    <img src="misc/logo-wide.png" width="400"/>
  </a>
</p>

# Motivate Clock

Motivate Clock is incredibly simple and absolutely free time tracking assistant for anyone whose work involves working with computer.

It is based on [Adobe AIR](https://get.adobe.com/air) and is written in ActionScript3. Currently app is translated to [EN, RU and UK languages](static/text.xml).

The app works in tandem with browser extensions: [Chrome](https://chrome.google.com/webstore/detail/motivate-clock-time-track/binhgmklnnecdadhiodcjcnhpbnknomg), [Firefox](https://addons.mozilla.org/firefox/addon/motivate-clock-extension/), [Opera](https://addons.opera.com/extensions/details/motivate-clock-extension/).  

Follow Motivate Clock on [Twitter](https://twitter.com/motivateclock), [Facebook](https://www.facebook.com/motivateclock) and [Instagram](https://www.instagram.com/motivateclock/) 
for important announcements.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

What things you need to install:

* [Apache Flex SDK](http://flex.apache.org/installer.html)
* [Java Development Kit](https://www.oracle.com/technetwork/java/javase/downloads/index.html)

### Building

A step by step series of examples that tell you how to get a development env running:

* Define path to Flex SDK inside [build.properties](build.properties):
```
FLEX_HOME=X:\sdk
```

* Perform ANT target to serve, compile and launch app in debug mode:
```
start
```

* Perform ANT target to compile and package app into installer:
```
package
```

[Read more](https://ant.apache.org/manual/running.html) about running Apache Ant targets. 

## Built With

* [Adobe AIR](https://get.adobe.com/air) - Adobe AIR is a cross-platform runtime system developed by Adobe Systems for building desktop applications and mobile applications, programmed using Adobe Animate, ActionScript and optionally Apache Flex.
* [Apache Ant](https://ant.apache.org) - Ant is a Java library and command-line tool whose mission is to drive processes described in build files as targets and extension points dependent upon each other.
* [PurePDF](https://github.com/sephiroth74/purePDF) - purePDF is a complete PDF library for Actionscript.
* [Tweener](https://github.com/zeh/tweener) - Tweener library for Actionscript.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/valeriy-bashtovoy/motivate-clock-desktop/tags). 

## Authors

* [Valeriy Bashtovoy](https://github.com/valeriy-bashtovoy) - *Initial work*
* [Dmitriy Starishev](https://www.linkedin.com/in/starishev) - *Design*

See also the list of [contributors](https://github.com/valeriy-bashtovoy/motivate-clock-desktop/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
