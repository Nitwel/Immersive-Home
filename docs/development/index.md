# Getting Started

Thanks for your interest in contributing to the project! This guide will help you get started with the development environment and the project structure.

## Prerequisites

In order to contribute to this project, you need to have [Godot 4.2.x](https://godotengine.org/download/archive/) installed on your computer.

[Git](https://git-scm.com/) and [Git-LFS](https://git-lfs.com/) is also required to clone the repository and download the large binary files.

## Local Development

1. Clone the repository from GitHub:

```bash
git clone https://github.com/Nitwel/Immersive-Home.git
```

2. Open the project in your Editor of choice. We recommend using [Visual Studio Code](https://code.visualstudio.com/) with the [Godot Tools](https://marketplace.visualstudio.com/items?itemName=geequlim.godot-tools) extension.

3. Open Godot and import the project by selecting the `project.godot` file in the root of the repository.

::: warning
Development is currently **only supported on Windows and Linux**. If you are using a Mac, the project might not work correctly due to the `godot-cdt` addon only having binaries for Windows and Linux.
:::

## Fundamentals

Communication with the Smart Home Environment is done using the HomeApi global. Each environment is made up of devices and entities. A device is a collection of different entities and entities can represent many different things in a smart home. For example, the entity of name `lights.smart_lamp_1` would control the kitchen lamps while `state.smart_lamp_1_temp` would show the current temperature of the lamp.

### File Structure

```plaintext
.
├── app/               (Main Godot Project)
│   ├── addons             (All installed Godot Addons are saved here)
│   ├── assets             (Files like logos or assets that are shared across scenes)
│   ├── content/           (Main files of the project)
│   │   ├── entities       (Entities that can be placed into the room)
│   │   ├── functions      (Generic functions that can be used in scenes)
│   │   └── ui             (User Interface Scenes and related files)
│   └── lib/               (Shared code)
│       ├── globals        (Globally running scripts)
|       ├── home_apis       (Code that communicates with the smart home environment)
|       ├── stores         (Stores that hold the state of the app)
│       └── utils          (Utility functions)
├── docs/              (Documentation)
│   ├── development        (Development related documentation)
│   ├── getting-started    (Getting started guides)
│   └── vendor-integration (Integration guides for different smart home vendors)
└── vendors/          (Vendor specific code)
    └── home-assistant_integration (Home Assistant Integration)
```

### Scene Structure

When the app starts, globals and the `main.tscn` are loaded. The `main.tscn` is the main scene of the app and is responsible for loading the other scenes.

```plaintext
root
├── HomeApi      (Global access for talking to the smart home environment)
├── EventSystem  (Global Event System)
├── Store        (Global access the the app state)
├── House        (Global House reference to the current house)
└── Main         (Main Scene)
```

### Code Reference and Documentation

Static code reference can be found in the Reference section of the documentation at the top right. It is exported from Godot and contains all available scripts from the `/lib` folder.

The documentation is written in Markdown and can be found in the `docs` folder of the repository.