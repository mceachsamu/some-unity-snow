using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class playerScript : MonoBehaviour
{

    public GameObject snow;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        Rigidbody rg = this.GetComponent<Rigidbody>();

        if (Input.GetKey("a"))
        {
            rg.AddForce(new Vector3(-1.0f, 0.0f, 0.0f));
        }
        if (Input.GetKey("s"))
        {
            rg.AddForce(new Vector3(0.0f, 0.0f, -1.0f));
        }
        if (Input.GetKey("d"))
        {
            rg.AddForce(new Vector3(1.0f, 0.0f, 1.0f));
        }
        if (Input.GetKey("w"))
        {
            rg.AddForce(new Vector3(0.0f, 0.0f, 1.0f));
        }
        snow s = snow.GetComponent<snow>();
        s.AddImprint(this.transform.position);
    }
}
