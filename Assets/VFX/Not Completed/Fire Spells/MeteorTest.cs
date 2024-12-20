using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;
using UnityEngine.VFX;

public class MeteorTest : MonoBehaviour
{
    VisualEffect m_visualEffect;
    VFXEventAttribute m_vfxEventAttribute;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        m_visualEffect = GetComponent<VisualEffect>();
        m_vfxEventAttribute = m_visualEffect.CreateVFXEventAttribute();

        /*GraphicsBuffer buffer = new GraphicsBuffer(GraphicsBuffer.Target.Structured, 3, Marshal.SizeOf(typeof(GB_Custom)));

        List<GB_Custom> data = new List<GB_Custom>();
        data.Add(new GB_Custom() { position = new Vector3(-5, 5, 0), direction = Vector3.zero });
        data.Add(new GB_Custom() { position = new Vector3(5, 5, 0), direction = Vector3.zero });

        buffer.SetData(data);

        m_visualEffect.SetGraphicsBuffer("tt", buffer);*/


        //m_visualEffect.SetGraphicsBuffer()
    }

    // Update is called once per frame
    void Update()
    {

        print(m_visualEffect.HasGraphicsBuffer("attributeBuffer"));


    }
}

[VFXType(VFXTypeAttribute.Usage.GraphicsBuffer)]
public struct GB_Custom
{
    public Vector3 position;
    public Vector3 direction;
}
