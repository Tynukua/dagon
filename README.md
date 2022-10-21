<img align="left" alt="dagon logo" src="https://github.com/gecko0307/dagon/raw/master/logo/dagon-logo-320.png" width="100" style="vertical-align:top" />

Dagon
=====
The goal of this project is to create a modern, easy to use, extensible 3D game engine for [D language](https://dlang.org/). Dagon is based on OpenGL 4.0 core profile. It works on Windows and Linux.

The engine is still under development and lacks many important features. It is currently not recommended to use Dagon in production due to API instability. Follow the development on [Trello](https://trello.com/b/4sDgRjZI/dagon-0110) to see the priority tasks.

Dagon uses modern graphics techniques and so requires a fairly powerful graphics card to run. Turing-based NVIDIA cards are recommended (although ray tracing support is not required). The engine is only desktop, support for mobile and web platforms is not planned.

If you like Dagon, support its development on [Patreon](https://www.patreon.com/gecko0307) or [Liberapay](https://liberapay.com/gecko0307). You can also make a one-time donation via [NOWPayments](https://nowpayments.io/donation/gecko0307). I appreciate any support. Thanks in advance!

[![GitHub Actions CI Status](https://github.com/gecko0307/dagon/workflows/CI/badge.svg)](https://github.com/gecko0307/dagon/actions?query=workflow%3ACI)
[![DUB Package](https://img.shields.io/dub/v/dagon.svg)](https://code.dlang.org/packages/dagon)
[![DUB Downloads](https://img.shields.io/dub/dt/dagon.svg)](https://code.dlang.org/packages/dagon)
[![License](http://img.shields.io/badge/license-boost-blue.svg)](http://www.boost.org/LICENSE_1_0.txt)

Screenshots
-----------
[![Screenshot1](https://gamedev.timurgafarov.ru/wp-content/uploads/2021/08/dev_5nmhxA9u4n.jpg)](https://gamedev.timurgafarov.ru/wp-content/uploads/2021/08/dev_5nmhxA9u4n.jpg)

[![Screenshot2](https://gamedev.timurgafarov.ru/wp-content/uploads/2021/05/sponza10.jpg)](https://gamedev.timurgafarov.ru/wp-content/uploads/2021/05/sponza10.jpg)

[![Screenshot3](https://gamedev.timurgafarov.ru/wp-content/uploads/2021/08/003.jpg)](https://gamedev.timurgafarov.ru/wp-content/uploads/2021/08/003.jpg)

[![Screenshot4](https://gamedev.timurgafarov.ru/wp-content/uploads/2020/10/eevee_vs_dagon.jpg)](https://gamedev.timurgafarov.ru/wp-content/uploads/2020/10/eevee_vs_dagon.jpg)

[![Screenshot5](https://gamedev.timurgafarov.ru/wp-content/uploads/2020/01/cerberus.jpg)](https://gamedev.timurgafarov.ru/wp-content/uploads/2020/01/cerberus.jpg)

Features
--------
* Static and animated meshes, [glTF](https://www.khronos.org/gltf/), [OBJ](https://en.wikipedia.org/wiki/Wavefront_.obj_file) and [IQM](https://github.com/lsalzman/iqm) formats support
* Textures in PNG, JPG, DDS, HDR, TGA, BMP, GIF, PSD formats
* Deferred pipeline for opaque materials, forward pipeline for transparent materials and materials with custom shaders
* Physically based rendering (PBR)
* HDR rendering with Reinhard, Hable/Uncharted, Unreal, ACES and Filmic tonemapping operators
* HDRI environment maps. Preconvolved DDS cubemaps
* Directional lights with cascaded shadow mapping and volumetric scattering
* Spherical and tube area lights, spot lights
* Normal/parallax mapping, parallax occlusion mapping
* Deferred decals with normal mapping and PBR material properties
* Dynamic skydome with sun and day/night cycle
* Particle system with force fields. Blended particles, soft particles, shaded particles with normal map support, particle shadows
* Terrain rendering. Procedural terrain using OpenSimplex noise or any custom height field
* Water rendering
* Post-processing (FXAA, SSAO, DoF, lens distortion, motion blur, glow, color grading)
* UTF-8 text rendering using TTF fonts via Freetype
* GUI and 2D graphics extension based on [Nuklear](https://github.com/Immediate-Mode-UI/Nuklear). 2D canvas framework that renders vector shapes
* GUI extension based on [Dear ImGui](https://github.com/ocornut/imgui)
* Keyboard, mouse and joystick input. Input manager with abstract bindings and file-based configuration
* Unicode text input
* Ownership memory model
* Entity-component model
* Built-in camera logics for easy navigation: freeview and first person views
* [Box](https://github.com/gecko0307/box) container support for assets
* Physics using [Newton Dynamics](http://newtondynamics.com).

Planned in future:
* Screen-space reflections.

Getting Started
---------------
The recommended way to start using Dagon is creating a game template with `dub init`. Create an empty directory for the project, cd to it and run the following:
```
dub init --type=dagon
dub build
```

Runtime Dependencies
--------------------
* [SDL](https://www.libsdl.org) 2.0.14
* [Freetype](https://www.freetype.org) 2.8.1 (optional)
* [Newton Dynamics](https://github.com/MADEAPPS/newton-dynamics) 3.14 (optional)
* [Nuklear](https://github.com/Immediate-Mode-UI/Nuklear) (optional)
* [ImGui](https://github.com/ocornut/imgui) (optional)

Runtime dependencies are automatically deployed on Windows. On other platforms, you will have to install them manually.

Nuklear should be compiled as a dynamic library:

1. Install [CMake](https://cmake.org/)
2. Go to `extensions/nuklear/thirdparty/bindbc-nuklear-0.4.3/c/build`
3. Run `cmake ..`
4. Under Linux, run `make` and `sudo make install`. `libnuklear.so` will be installed to `/usr/local/lib`
5. Under Windows, open `nuklear.vcxproj` in Visual Studio and build `ALL_BUILD` project. Look for `nuklear.dll` in the `Release` directory.

Documentation
-------------
See [tutorials](https://github.com/gecko0307/dagon/wiki/Tutorials) and corresponding [examples](https://github.com/gecko0307/dagon-tutorials).

License
-------
Copyright (c) 2016-2022 Timur Gafarov, Rafał Ziemniewski, Mateusz Muszyński, dayllenger, Konstantin Menshikov, Björn Roberg, Isaac S., ijet. Distributed under the Boost Software License, Version 1.0 (see accompanying file COPYING or at http://www.boost.org/LICENSE_1_0.txt).

Sponsors
--------
Jan Jurzitza (WebFreak), Daniel Laburthe, Rafał Ziemniewski, Kumar Sookram, Aleksandr Kovalev, Robert Georges, Rais Safiullin (SARFEX), Benas Cernevicius, Koichi Takio, Konstantin Menshikov.

Made with Dagon
---------------
* [Electronvolt](https://github.com/gecko0307/electronvolt) - work-in-progress first person puzzle based on Dagon
* [dagon-sandbox](https://github.com/gecko0307/dagon-sandbox) - a test application that demonstrates some of Dagon's features
* [Dagoban](https://github.com/Timu5/dagoban) - a Sokoban clone
* [dagon-shooter](https://github.com/aferust/dagon-shooter) - a shooter game
