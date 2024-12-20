using System;
using System.Runtime.InteropServices.WindowsRuntime;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.VFX;
using UnityEngine.VFX.Utility;

public class SonarTest : MonoBehaviour
{
    VisualEffect m_visualEffect;
    VFXEventAttribute m_vfxEventAttribute;
    Unity.Mathematics.Random rnd;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        m_visualEffect = GetComponent<VisualEffect>();
        rnd = Unity.Mathematics.Random.CreateFromIndex((uint)Time.deltaTime);
    }

    int meteorPosition = Shader.PropertyToID("position");
    int meteorDirection = Shader.PropertyToID("direction");
    // Update is called once per frame

    Vector3 explodePoint = Vector3.zero;

    void Update()
    {

        if (Input.GetMouseButtonDown(0))
        {
            var camRay = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit hitinfo;
            if (Physics.Raycast(camRay, out hitinfo, float.MaxValue))
            {
                m_vfxEventAttribute = m_visualEffect.CreateVFXEventAttribute();
                m_vfxEventAttribute.SetVector3(meteorPosition, hitinfo.point + Vector3.up * 10);
                var dir = hitinfo.point - (hitinfo.point + Vector3.up * 10);
                explodePoint = hitinfo.point;
                m_vfxEventAttribute.SetVector3(meteorDirection, dir.normalized);
                //Debug.Log(hitinfo.point + Vector3.up * 2);
                m_visualEffect.SendEvent("Strike", m_vfxEventAttribute);
                Invoke("Explode", 5);
            }
        }

        if (Input.GetKeyDown(KeyCode.S))
        {
            //m_visualEffect.SetVector3(meteorPosition,  )
            //m_visualEffect.SendEvent("ExplosionWave", m_vfxEventAttribute);
            /*m_visualEffect.SetTexture(terrain_HeightMap, Terrain.activeTerrain.terrainData.heightmapTexture);
            m_visualEffect.SetVector3(terrain_Bounds_center, Terrain.activeTerrain.terrainData.bounds.center);
            m_visualEffect.SetVector3(terrain_Bounds_size, Terrain.activeTerrain.terrainData.bounds.size);
            m_visualEffect.SendEvent("Populate");*/
            //m_visualEffect.Play();


        }


        if (Input.GetKeyDown(KeyCode.A))
        {
            m_vfxEventAttribute.SetVector3("position", this.transform.position + Vector3.up * 3);
            m_visualEffect.SendEvent("Fire", m_vfxEventAttribute);
        }

    }

    void Explode()
    {
        m_vfxEventAttribute = m_visualEffect.CreateVFXEventAttribute();
        m_vfxEventAttribute.SetVector3(meteorPosition, explodePoint);
        m_visualEffect.SendEvent("Explode", m_vfxEventAttribute);
    }

    ExposedProperty outputEvent = "TestOut";

    public void OnOutputEventRecieved(VFXOutputEventArgs eventAttribute)
    {
        print(eventAttribute.nameId);
        if (eventAttribute.nameId == (int)outputEvent)
            print("Event received");
    }
}

