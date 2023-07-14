## GPRGRAVEL

<img src="logo.png" alt="GPRGRAVEL icon" width="96">

A simple **GPR** **GRAVEL** generator

- - -

### Table of Contents
1. [About](#about)
2. [Requirements](#requirements)
3. [Installation](#installation)
4. [Usage](#usage)
5. [ToDo](#todo)
6. [Cite as & References](#references)
7. [Changelog](CHANGELOG.md)

- - -
<a name="about"></a>
### About

**GPRGRAVEL** is a set of MATLAB<sup>TM</sup> tools to generate grain (gravel) "packings" to be used with 3D FDTD GPR simulations. The "packings" are created based on user defined grain size distributions. Please note that **GPRGRAVEL** creates a "packing" by randomly placing grains at arbitrary positions inside a given container. No gravimetric settlement of the grains is applied.

#### Basic features:
1. Choose between different grain shapes (*Sphere* or *Ellipsoid*)
2. Set a desired porosity and corresponding water and air fractions
3. Place an object (target) into the domain
4. Set a water saturation profile (*linear* or *exponential*)
5. etc.

<img src="gprgravel_gui.png" alt="GPRGRAVEL" width="400">

- - -
<a name="requirements"></a>
### Requirements

In order to work properly you need to meet the following requirements:

1. The [Mathworks](https://www.mathworks.com) MATLAB<sup>TM</sup> software development environment (tested with R2019a and newer)
2. The GUI Layout Toolbox (get it from [FEX](https://de.mathworks.com/matlabcentral/fileexchange/47982-gui-layout-toolbox)) (<span style="color:red">required</span>)
3. `findjobj` (get it from [FEX](https://de.mathworks.com/matlabcentral/fileexchange/14317-findjobj-find-java-handles-of-matlab-graphic-objects)) (<span style="color:red">required</span>)
4. `VoxelSurf` (get it from [FEX](https://de.mathworks.com/matlabcentral/fileexchange/66204-voxelsurf)) (optional)

#### Operating System

I tested it successfully under Windows 7 (64bit) and 10 (64bit) with Matlab R2019a and newer. Always with the latest version of the GUI Layout Toolbox (current version is afaik v2.3.5)

**NOTE:** So far I did not test anything on Linux or a Mac. If you get it to work on either of the two systems (which it basically should I guess) please let me know.

- - -
<a name="installation"></a>
### Installation

1. It is recommended to install the GUI Layout Toolbox directly into MATLAB<sup>TM</sup> via the mltbx-file (but it should also work via the old-school way of adding the toolbox folders to the MATLAB<sup>TM</sup> path)
2. To use **GPRGRAVEL** you just need to place the `GPRGRAVEL` folder from  the git repository on your hard drive and use the start script `startGPRGRAVEL` (within this script all necessary **GPRGRAVEL** folders are added to the MATLAB<sup>TM</sup> path)

- - -
<a name="usage"></a>
### Usage

1. By executing the start script (see above)
2. Simply type `GPRGRAVEL` on the MATLAB<sup>TM</sup> prompt (make sure the `GPRGRAVEL` folder is on the MATLAB<sup>TM</sup> path)
3. Check the example scripts for the usage of the core functions without the GUI (inside the `scripts` folder)

- - -
<a name="todo"></a>
### ToDo

In no particular order and without guarantee that it will ever happen :-) :

1. Add some more auxiliary options to the *Parameter* panel
2. Give the different export options via the GUI itself
3. Finalize the menu import/export routines
4. ... 


- - -
<a name="references"></a>
### Cite as
If you use GPRGRAVEL for your research, please cite it as:

Thomas Hiller. (2023, July 14). ThoHiller/gprgravel: v0.1.0 (Version v0.1.0). GitHub. [https://github.com/ThoHiller/gprgravel]

Note: This repository will be made available via Zenodo and will have a citable DOI. Even though the version number might change due to updates, this DOI is permanent (represents all versions) and always links to the latest version.


### References
1. Stadler, S., Schennen, S., Hiller, T. and Igel, J., "Realistic Simulation of GPR for Landmine and IED Detection Including Antenna Models, Soil Dispersion and Heterogeneity", Near Surface Geophysics (*submitted*), 2023.

- - -
<p style="text-align: center;"> MATLAB is a registered trademark of The Mathworks, Inc. </p>