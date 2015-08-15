This example source code was taken from ctrulib.
It shows a basic CMakeLists.txt for a project using shaders and picasso.

To use it, simply copy `DevkitArm3DS.cmake` and the `cmake` folder of the repository in this folder.

You can then create your build folder using cmake, and use the DevkitArm3DS.cmake toolchain file :

    mkdir build && cd build
    cmake -DCMAKE_TOOLCHAIN_FILE=DevkitArm3DS.cmake ..
    
Windows users will need to use the "Unix Makefiles" (or MinGW/MSYS...) generator :

    cmake -DCMAKE_TOOLCHAIN_FILE=DevkitArm3DS.cmake -G"Unix Makefiles" ..
    
You can then build the project as usual with :
    
    make
	
For more information, please take a look at this repository's README.md.

# GPU example

This is a simple GPU example using the `picasso` shader assembler which comes with devkitARM r45 and up.
Users of earlier versions of devkitARM need to install the tool, which can be found in the address below:

https://github.com/fincs/picasso/releases
