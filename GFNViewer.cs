using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GFNViewer : MonoBehaviour
{
    public Material gfnMaterial;
    public Vector3 offset = new Vector3(0.0f, 0.0f, 0.0f);

    public void OnDrawGizmos() {
        if(gfnMaterial == null)
            return;

        Gizmos.color = Color.green;

        Vector3 centerRaw = new Vector3(
            gfnMaterial.GetFloat("_gfnObjectCoordsTranslateX"),
            gfnMaterial.GetFloat("_gfnObjectCoordsTranslateY"),
            gfnMaterial.GetFloat("_gfnObjectCoordsTranslateZ")
        );
        Vector3 scaleRaw = new Vector3(
            gfnMaterial.GetFloat("_gfnObjectCoordsScaleX"),
            gfnMaterial.GetFloat("_gfnObjectCoordsScaleY"),
            gfnMaterial.GetFloat("_gfnObjectCoordsScaleZ")
        );
        Vector3 center = new Vector3(-1.0f*centerRaw.x, -1.0f*centerRaw.y, -1.0f*centerRaw.z) + offset;
        Vector3 scale = new Vector3(2.0f/scaleRaw.x, 2.0f/scaleRaw.y, 2.0f/scaleRaw.z);

        Gizmos.DrawWireCube(center, scale);
        Gizmos.DrawLine(center + Vector3.right * scale.x, center + Vector3.left * scale.x);
        Gizmos.DrawLine(center + Vector3.up * scale.y, center + Vector3.down * scale.y);
        Gizmos.DrawLine(center + Vector3.forward * scale.z, center + Vector3.back * scale.z);
    }
}
