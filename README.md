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

Add the VSF_SetShaderParamFromTransform script from the VSF SDK to an object in the model's hierarchy.
Set the parameters as follows :
- Reference Transform : The head bone of the model's rig.
- Target Material : The material used for the head.
- Shader Parameter Name : _gfnHeadWLMatrix
- Mode : World to Local Matrix

Add the "GFNViewer" script to an object outside the hierarchy in order to make the adjustments more easily.
Set the parameters as follows :
- GFN Material : The material used for the head (same as Target Material)
- Head Bone : The head bone of the model's rig (same as Reference Transform)
Now alter the GFN Object Coords parameters until the box is centered on the head and roughly it's size (see aVersionOfReality's video and refer to the empty object if needed).

Alter the other GFN Parameters to adjust the shading.
Now fill out the parameters as you would for MToon, except the normals.

Please note that the current version doesn't update the shading in real-time.

# Potential Problems

## The shading doesn't work !
For now, the parameters aren't updated in edit mode, please try playing the scene to check if it is there.

## During export, it says that 'Detected invalid components on avatar : GFNViewer'
The GFNViewer is a script that only helps during editing and as such must be placed outside the hierarchy.

## During export, it says that 'Detected invalid components on avatar : VSeeFace.VSF_SetShaderParamFromTransform'
This shouldn't happen, but since it did happen to me the fix is as follows :
- Open "VSF SDK/AvatarCheck.cs"
- Add `"VSeeFace.VSF_SetShaderParamFromTransform",` after line 170 (it should be a list of all accepted parameters)
- Export your model.
This may be caused by specific versions of VSF.


# Next Steps

- [ ] Allow real-time editing in the editor
- [ ] Make it more user-friendly
- [ ] Expose more parameters
- [ ] Double check and clean up the math (especially for the differences between Blender and Unity)
- [ ] Optimize computations
- [ ] Add support for a vertex color mask

# Releases

2021-10-06 : Initial release
2021-11-21 : Added head tracking in the shader, and a separate script now in the VSF SDK to set it.
