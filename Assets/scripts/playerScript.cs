using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class playerScript : MonoBehaviour
{

    public float force = 0.5f;

    public Camera main;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        Rigidbody rg = this.GetComponent<Rigidbody>();

        
        Vector3 input = new Vector3(0.0f,0.0f,0.0f);
        if (Input.GetKey("a"))
        {
            input += new Vector3(0.0f, 0.0f, -force);
        }
        if (Input.GetKey("s"))
        {
            input += new Vector3(-force, 0.0f, 0.0f);
        }
        if (Input.GetKey("d"))
        {
            input += new Vector3(0.0f, 0.0f, force);
        }
        if (Input.GetKey("w"))
        {
            input += new Vector3(force, 0.0f, 0.0f);
        }

        Vector3 forward = main.transform.forward;
        Vector3 right = main.transform.right;

        forward.y = 0.0f;
        right.y = 0.0f;
        forward.Normalize();
        right.Normalize();

        rg.AddForce(input.x * forward + input.z * right);
    }
}
