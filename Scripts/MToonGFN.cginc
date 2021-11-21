//[GFN]-----------------------------

float _gfnScaleXTop = 3.0; float _gfnScaleXBottom = 1.0;
float _gfnScaleXUpperMiddle = 3.0; float _gfnScaleXScaleMiddle = 2.0; float _gfnScaleXLowerMiddle = 1.0;
float _gfnScaleXScaleZPlus = 1.0; float _gfnScaleXScaleZMinus = 1.0;

float _gfnBendOnXTop = 0.0; float _gfnBendOnXBottom = 42.5; float _gfnBendOnXBottomJaw = 25.07;
float _gfnBendOnXUpperScale = 1.0; float _gfnBendOnXLowerScale = 0.35;
float _gfnBendOnXUpperLoc = -0.1; float _gfnBendOnXLowerLoc = -0.1;

float4x4 _gfnHeadWLMatrix = float4x4(1.0,0.0,0.0,0.0, 0.0,1.0,0.0,0.0, 0.0,0.0,1.0,0.0, 0.0,0.0,0.0,1.0);

// -----------------------------


float map(float value, float fromMin, float fromMax, float toMin, float toMax) {
	return (value - fromMin) / (fromMax - fromMin) * (toMax - toMin) + toMin;
}
float mapclamp(float value, float fromMin, float fromMax, float toMin, float toMax) {
	return clamp((value - fromMin) / (fromMax - fromMin), 0.0, 1.0) * (toMax - toMin) + toMin;
}
float mapsmoothstep(float value, float fromMin, float fromMax, float toMin, float toMax) {
	return clamp((value - fromMin) / (fromMax - fromMin), 0.0, 1.0) * (toMax - toMin) + toMin;
	// TODO Add the actual smoothstep
}



// ------------------------------
float GFNScaleX(half3 objectCoords, float top, float bottom, float upperMiddle, float scaleMiddle, float lowerMiddle, float scaleZPlus, float scaleZMinus) {
	// Scale Z
	float zScaled = objectCoords.z * (objectCoords.z > 0 ? scaleZMinus : scaleZPlus);
	// ^ Here as in the original shader but it seems inverted

	// Scale X
	float scaledXUpper = lerp(top, upperMiddle, map(zScaled, 0.0, 1.0, 1.0, 0.0));
	float scaledXLower = lerp(lowerMiddle, bottom, map(zScaled, 0.0, -1.0, 0.0, 1.0));
	float scaledX = lerp(scaleMiddle, (zScaled > 0 ? scaledXLower : scaledXUpper), abs(zScaled));
	// ^ Here as in the original shader but it seems inverted
	// ^ abs(zScaled) lacks a smoothstep


	scaledX = min(scaledX, 0.1);
	// Not a smooth maximum

	return scaledX * objectCoords.x;
}

float GFNBendOnX(half3 objectCoords, float upperAngle, float lowerAngle, float upperScale, float lowerScale, float upperLoc, float lowerLoc) {
	// Bend on X
	float rotationAngle = radians((objectCoords.z < 0 ? lowerAngle * map(objectCoords.z, -1.0, 0.0, 1.0, 0.0) : upperAngle * objectCoords.z));
	float cosRotationAngle = cos(rotationAngle);
	float sinRotationAngle = sin(rotationAngle);
	float4x4 rotationMatrix = float4x4(
		1.0, 0.0, 0.0, 0.0,
		0.0, cosRotationAngle, -sinRotationAngle, 0.0,
		0.0, sinRotationAngle, cosRotationAngle, 0.0,
		0.0, 0.0, 0.0, 1.0
	);
	half4 bentVector = mul(rotationMatrix, float4(objectCoords, 1.0));

	// Loc and scale
	float t = map(bentVector.z, -1.2, 1.2, 0.0, 1.0);
	float scaleY = lerp(lowerScale, upperScale, t);
	float translateY = lerp(lowerLoc, upperLoc, t);

	float4x4 transformationMatrix = float4x4(
		1.0, 0.0, 0.0, 0.0,
		0.0, scaleY, 0.0, translateY,
		0.0, 0.0, 1.0, 0.0,
		0.0, 0.0, 0.0, 1.0
	);

	// TODO optimizable a lot

	return mul(transformationMatrix, bentVector).y;
}

half3 GFNNoseNormals(half3 objectCoords, half3 faceCoords) {
	/* Regular matrix backup
	float4x4 transformationMatrix1 = float4x4(
		0.1, 0.0, 0.0, 0.0,
		0.0, 0.1, 0.0, -0.92,
		0.0, 0.0, 0.1, -0.305,
		0.0, 0.0, 0.0, 1.0
	);
	float4x4 transformationMatrix2 = float4x4(
		0.0, 0.0, 0.0, 0.0,
		0.0, 0.0, 0.0, -0.92,
		0.0, 0.0, 0.3, -0.38,
		0.0, 0.0, 0.0, 1.0
	);
	*/

	// Define Shape
	float4x4 transformationMatrix1 = float4x4(
		10.0, 0.0, 0.0, 0.0,
		0.0, 10.0, 0.0, 7.42,
		0.0, 0.0, 10.0, 3.05,
		0.0, 0.0, 0.0, 1.0
	);
	// ^ Lacks the rotation of -1.4deg on X axis

	float4x4 transformationMatrix2 = float4x4(
		0.0, 0.0, 0.0, 0.0,
		0.0, 0.0, 0.0, -0.92,
		0.0, 0.0, 3.0, 0.9,
		0.0, 0.0, 0.0, 1.0
	);
	// ^ Can be optimized


	half3 transformedObjectCoords = mul(transformationMatrix1, half4(objectCoords, 1.0)).xyz;
	float shapeX = GFNScaleX(transformedObjectCoords, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0);
	float shapeY = GFNBendOnX(transformedObjectCoords, -2.0, 17.6, 0.63, 1.0, 0.2, 0.0);

	float shapeZ = mul(transformationMatrix2, half4(objectCoords, 1.0)).z;
	shapeZ = shapeZ * lerp(0.4, 1.44, mapclamp(shapeZ, -1.0, 0.0, 1.0, 0.0));

	// Adjust Ranges
	shapeX *= 10.0;//0.5;
	//shapeY = map(abs(shapeY), 0.0, 1.0, -0.5, -1.0);

	// TODO ShapeY is cursed from the transformation step, might need a rotate

	// Make Mask
	float mask = mapclamp(abs(shapeX), 0.0, 1.0, 1.0, 0.0) * mapclamp(shapeY, 0.0, 1.0, 1.0, 0.0) * mapclamp(shapeZ, 0.05, 0.3, 1.0, 0.0);//mapclamp(shapeZ, 0.0, 0.5, 1.0, 0.0);
	mask = clamp(mask, 0.0, 1.0);

	return lerp(faceCoords, half3(shapeX, mapclamp(abs(shapeY), 0.0, 1.0, -0.5, -1.0), shapeZ), mask);
}

half3 GFNObjectSpaceRotate(half3 objectNormals) {
	// TODO I think it's not needed here because we don't use an empty object here
	return objectNormals;
}

half3 GFNMaskMeshNormals(float meshMask, half3 objectNormals, half3 worldNormals, half3 regularNormals) {
	// TODO Maybe not needed for the final version
	float computeMask =
		mapsmoothstep(worldNormals.y, 0.0, 1.0, 0.0, 1.0) *
		mapsmoothstep(worldNormals.z, -1.0, 0.0, 1.0, 0.0);

	float t = lerp(computeMask, 1.0, meshMask);
	return lerp(worldNormals, regularNormals, t);
}

half3 GenerateFaceNormals(half3 objectCoords, float fac, float mask, half3 regularNormals) {
	// TODO Vertex Color for mask
	// TODO Recheck the math for smoothstep

	// Face normals
	half3 faceNormals = half3(
		GFNScaleX(objectCoords, _gfnScaleXTop, _gfnScaleXBottom, _gfnScaleXUpperMiddle, _gfnScaleXScaleMiddle, _gfnScaleXLowerMiddle, _gfnScaleXScaleZPlus, _gfnScaleXScaleZMinus),
		GFNBendOnX(objectCoords, _gfnBendOnXTop, lerp(_gfnBendOnXBottom, _gfnBendOnXBottomJaw, fac), _gfnBendOnXUpperScale, _gfnBendOnXLowerScale, _gfnBendOnXUpperLoc, _gfnBendOnXLowerLoc),
		objectCoords.z);
    faceNormals *= half3(10.0, 2.0, 1.0);// TODO Probably means that GFNScaleX is not good

	// Mix With Nose Normals
	half3 faceNoseNormals = GFNNoseNormals(objectCoords, faceNormals);

	// Add Empty Rotation
	half3 worldNormals = GFNObjectSpaceRotate(faceNoseNormals);

	// Mask to Head only
	return GFNMaskMeshNormals(mask, faceNoseNormals, worldNormals, regularNormals);
}
