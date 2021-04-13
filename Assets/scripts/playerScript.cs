using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class playerScript : MonoBehaviour
{

    public float force = 0.5f;

    public float turnFriction = 00.1f;

    public float maxSpeed = 5.0f;

    public Camera main;

    private bool currentlyColliding = false;

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
            input += new Vector3(-0.0f, 0.0f, -force);

            // rg.velocity = rg.velocity * turnFriction;
        }
        if (Input.GetKey("s"))
        {
            input += new Vector3(-force, 0.0f, 0.0f);
        }
        if (Input.GetKey("d"))
        {
            input += new Vector3(0.0f, 0.0f, force);

            // rg.velocity = rg.velocity * turnFriction;
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

        Vector3 direction = (input.x * forward + input.z * right).normalized;
        float speed = rg.velocity.magnitude;
        if (speed > maxSpeed){
            speed = maxSpeed;
        }
        if (currentlyColliding) {
            rg.velocity += (speed * direction)/100.0f;
        }
    }

    public void setColliding(bool colliding) {
        this.currentlyColliding = colliding;
    }
}
