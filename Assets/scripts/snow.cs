using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class snow : MonoBehaviour
{
    private Vector3 maxVertex;
    private Vector3 max;

    public Texture2D drawTexture;

    public GameObject player;

    public int textureSizeMultiplier = 1;

    public Camera camera;
    public Shader drawShader;

    private RenderTexture imprint;
    private Material imprintMat;
    private RaycastHit hit;

    void Start() {
        
        imprintMat = new Material(drawShader);
        imprintMat.SetVector("_Color", Color.red);

        //make a copy of this material (might need to get mesh renderer)
        Material mat = Instantiate(this.GetComponent<Renderer>().material);
        this.GetComponent<Renderer>().material = mat;

        imprint = new RenderTexture(600,600, 0, RenderTextureFormat.ARGBFloat);

        this.GetComponent<Renderer>().material.SetTexture("_ImprintTexture", imprint);
    }

    // Update is called once per frame
    void Update()
    {
            if (Physics.Raycast(player.transform.position, -Vector3.up, out hit, 1.5f)) {
                imprintMat.SetVector("_Coordinate", new Vector2(hit.textureCoord.x, hit.textureCoord.y));
            }

            RenderTexture temp = RenderTexture.GetTemporary(imprint.width, imprint.height, 0, RenderTextureFormat.ARGBFloat);
            Graphics.Blit(imprint, temp);
            Graphics.Blit(temp, imprint, imprintMat);
            RenderTexture.ReleaseTemporary(temp);
            this.GetComponent<Renderer>().material.SetTexture("_ImprintTexture", imprint);
        
    }

    // private void OnGUI() {
    //     GUI.DrawTexture(new Rect(0, 0, 256, 256), imprint, ScaleMode.ScaleToFit, false, 1);
    // }
}
