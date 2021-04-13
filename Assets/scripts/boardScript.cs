using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class boardScript : MonoBehaviour
{
    public GameObject player;

    public GameObject dummy;

    public float displacement = 0.1f;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        this.transform.position = player.transform.position;

        Vector3 direction = player.GetComponent<Rigidbody>().velocity * Time.fixedDeltaTime;
        dummy.transform.position = player.transform.position;
        dummy.transform.rotation = player.transform.rotation;
        // dummy.transform.scale = player.transform.scale;
        dummy.transform.up = direction;

        this.GetComponent<Rigidbody>().MoveRotation(dummy.transform.rotation);
        

        this.transform.position -= direction * displacement;
    }
}
