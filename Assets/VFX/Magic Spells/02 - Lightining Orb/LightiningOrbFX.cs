using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.VFX;

public class LightiningOrbFX : MonoBehaviour
{
    private int m_subOrbCount = 3;
    [SerializeField] private float m_distanceToCenter = 1f;
    [SerializeField] private float m_rotationSpeed = 2f;

    private List<GameObject> m_subGameObjects = new List<GameObject>();

    private VisualEffect m_visualEffect;

    void Start()
    {
        m_visualEffect = GetComponent<VisualEffect>();

        var anglePerObject = 360 / m_subOrbCount;
        for (int i = 0; i < m_subOrbCount; i++)
        {
            var go = new GameObject(); //GameObject.CreatePrimitive(PrimitiveType.Sphere);
            go.transform.SetParent(transform);
            var position = Quaternion.AngleAxis(anglePerObject * i, Vector3.up) * (Vector3.forward * m_distanceToCenter);
            go.transform.localPosition = position;
            m_subGameObjects.Add(go);
        }
    }

    void Update()
    {

        foreach (var go in m_subGameObjects)
        {
            go.transform.RotateAround(transform.position, Vector3.up, Time.deltaTime * m_rotationSpeed);
        }

        m_visualEffect.SetVector3("Center Position", transform.position);
        m_visualEffect.SetVector3("First Orb Position", m_subGameObjects[0].transform.position);
        m_visualEffect.SetVector3("Second Orb Position", m_subGameObjects[1].transform.position);
        m_visualEffect.SetVector3("Third Orb Position", m_subGameObjects[2].transform.position);


    }


}
