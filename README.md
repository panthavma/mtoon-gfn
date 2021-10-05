# Generated Face Normals Shader for Unity

This is a shader based on aVersionOfReality's GFN Blender Shader, explained in this video :
https://www.youtube.com/watch?v=sQW2wqltB0A

It was made by using Santahr's MToon as a base.
https://github.com/Santarh/MToon

This current version implements the whole math in the Blender shader, and adds a few low-level controls.
This is probably impractical in a lot of applications, although this does allow for a working result with a bit of tinkering.
As a warning, this hasn't been tested outside of Unity as of yet, which means bugs are likely to be found.

# How to use

Copy the whole folder into your Unity Project.
Make a new material using the shader "VRM/MToonGFN".

Add the "GFNViewer" script to an object.
Alter the GFN Object Coords parameters until the box is centered on the head and roughly it's size (see video).
(Note : you might need to adjust the GFNViewer's offset. To do this, go into debug mode 3 and aim for where the shading shifts)
Alter the other GFN Parameters to adjust the shading.
Now fill out the parameters as you would for MToon, except the normals.


# Next Steps

- [ ] Double check and clean up the math (especially for the differences between Blender and Unity)
- [ ] Expose more parameters
- [ ] Make it more user-friendly
- [ ] Add support for a vertex color mask
- [ ] Optimize computations
