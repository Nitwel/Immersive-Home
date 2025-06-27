# Important Introduction

This project is called **SafeAR** (also known as **QuestWalk**), an app deployed on the stand-alone [Meta Quest 3](https://en.wikipedia.org/wiki/Meta_Quest_3) to easily create on-boarding, safety training and instructed procedures that can be used on-site in Augmented Reality.  Similar projects include [The Ghent Alterpiece](https://www.alfavision.be/project/ghent-altarpiece) by AlfaVision.

It is the result of work done between [18 February 2025](https://www.ukri.org/news/daresbury-laboratory-welcomes-first-businesses-to-new-5g-ecosystem/) and 21 March 2025 (not including time spent writing the bid application) for the [5G Ecosystem - Proof of Concept call](https://iuk-business-connect.org.uk/opportunities/5g-ecosystem-proof-of-concept-call/).

We could not have attempted this project in such a short time frame without starting from the incredible open source work of [**Immersive-Home**](https://github.com/Nitwel/Immersive-Home) and [Solar-XR](https://github.com/TU-Dublin-Computer-Science/Solar-XR). 

# Demonstration Video

This is an example of guiding someone to refill the coffee machine in the [DoESLiverpool hackspace](https://doesliverpool.com/).

[![Making Coffee in AR](https://github.com/user-attachments/assets/c20b158d-0c3e-4a36-b9cd-3a809a6a7bd1)](http://www.youtube.com/watch?v=QzLRFOMqT2g "SafeAR mixed reality training demonstration: How to make coffee at DoES Liverpool")

# Technical components

## Home Assistant

[Home Assistant](https://www.home-assistant.io/) is a huge modular home automation system that runs on an RaspberryPI.  [Immersive-Home](https://immersive-home.org/) is able to log into it to access its location-based sensors and controls and overlay them into Augmented Reality.

## Godot engine

The [Godot](https://godotengine.org/) engine is a free, lightweight open source Game Engine that supports Virtual Reality features such as pass-through cameras and hand-tracking.

## Exoplayer plugin

The Meta Quest 3 Virtual Reality headset runs Android which means that many the of the internal features of this operating system potentially available to an application running on it.  Partway through the project the [Godot-ExoPlayer](https://github.com/bnjmntmm/godot-exoplayer/) feature appeared, which made it suddenly very easy to download and playback videos.

## Node-RED

[Node-RED](https://nodered.org/) is an optional component of Home Assistant that provides a visual flow-based coding system.  It turns out to be pretty useful for planning and drawing flow charts for walk-throughs to be deployed to the Augmented Reality app.  The ability to make and plan content is in some ways more important than the software to show it.  

![image](https://github.com/user-attachments/assets/367fcd70-ede1-41b4-a6de-bee537beb455)

# Future work

SafeAR/QuestWalk is looking for real world uses and applications that could pay for and drive its future development.  You could theoretically download it and try it out yourself, but given the necessary sketchiness of the prototype product made on this time scale, you will need our help. Please contact [Dynamic Devices](https://www.dynamicdevices.co.uk/) for details.
