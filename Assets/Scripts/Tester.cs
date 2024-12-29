using UnityEngine;
using UnityEngine.AI;
using UnityEngine.VFX;

public class Tester : MonoBehaviour
{
    NavMeshAgent m_agent;
    public VisualEffect m_visualEffect;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        m_agent = GetComponent<NavMeshAgent>();
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            var camRay = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit hitinfo;
            if (Physics.Raycast(camRay, out hitinfo, float.MaxValue))
            {
                m_agent.SetDestination(hitinfo.point);

            }
        }

        m_visualEffect.transform.position = transform.position + Vector3.up * 2;

    }
}
