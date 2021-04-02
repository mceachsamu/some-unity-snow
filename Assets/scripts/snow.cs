using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class snow : MonoBehaviour
{
    private Vector3 maxVertex;

    private Vector3 max;

    private Texture2D imprint;

    public Texture2D drawTexture;

    public int textureSizeMultiplier = 1;

    // Start is called before the first frame update
    void Start()
    {
        List<Vector3> verts = new List<Vector3>();
        Mesh m = this.GetComponent<MeshFilter>().mesh;

        Vector3 maxBounds = m.bounds.max;
        maxBounds.x *= this.transform.localScale.x;
        maxBounds.y *= this.transform.localScale.y;
        maxBounds.z *= this.transform.localScale.z;
        maxBounds.z = maxBounds.y;
        max = maxBounds;

        imprint = new Texture2D((int)maxBounds.x * textureSizeMultiplier, (int)maxBounds.z * textureSizeMultiplier);
        for (int i = 0; i < imprint.width; i++)
        {
            for (int j = 0; j < imprint.height; j++) {
                imprint.SetPixel(i, j, Color.black);
            }
        }
        imprint.Apply();

        LoadMeshIntoMatrix(m);

        this.GetComponent<Renderer>().material.SetVector("_MeshDimensions", max);
        this.GetComponent<Renderer>().material.SetVector("_TextureDimensions", new Vector3(imprint.width, imprint.height, imprint.height));
    }

    private Vector4[][] LoadMeshIntoMatrix(Mesh mesh) {
        
        List<List<Vector4>> output = new List<List<Vector4>>();
        
        Vector3[] vertices = mesh.vertices;
        int xi = 0;
        int yi = 0;
        int numAdded = 0;
        int totalToAdd = vertices.Length;
        float previousMaxY = vertices[0].y;

        while (numAdded < totalToAdd) {
            //get max z (y since blender meshes be weird) and x
            float maxX = float.NegativeInfinity;
            int maxIndex = -1;
            float maxY = float.NegativeInfinity;
            Vector3 maxPosition = new Vector3(float.NegativeInfinity, float.NegativeInfinity, 0.0f);
            for (int i = 0; i < vertices.Length; i++){
                if (maxPosition.x < vertices[i].x) {
                    maxPosition.x = vertices[i].x;
                    maxPosition.y = vertices[i].y;
                    maxIndex = i;
                }
                if (maxPosition.x <= vertices[i].x && maxPosition.y <= vertices[i].y) {
                    maxPosition.x = vertices[i].x;
                    maxPosition.y = vertices[i].y;
                    maxIndex = i;
                }
            }
            float diff = Mathf.Abs(maxPosition.y - previousMaxY);
            if (diff >= mesh.bounds.max.x) {
                xi++;
                yi=0;
            }
            print(maxPosition.x + " " + maxPosition.y + " ---- " + diff + " " + mesh.bounds.max.x + " " + xi + " " + yi);
            // print(xi + " " + yi);
            previousMaxY = maxPosition.y;
            SetIndex(output, xi, yi, new Vector4(maxPosition.x, maxPosition.y, maxPosition.z, maxIndex));
            vertices[maxIndex] = new Vector3(float.NegativeInfinity,float.NegativeInfinity,float.NegativeInfinity);
            numAdded++;
            yi++;
        }
        
        return null;
    }

    private Vector4 GetIndex(List<List<Vector4>> list, int x, int y) {
        List<Vector4> xList = list.ToArray()[x];
        Vector4 val = xList.ToArray()[y];
        return val;
    }

    private void SetIndex(List<List<Vector4>> list, int x, int y, Vector4 value) {
        if (list.Count <= x) {
            list.Add(new List<Vector4>());
        }
        List<Vector4> yList = list.ToArray()[x];
        yList.Add(value);
    }



    // Update is called once per frame
    void Update()
    {
        this.GetComponent<Renderer>().material.SetTexture("_ImprintTexture", imprint);
    }

    private Vector2 GetTexturePositionFromWorldPosition(Vector3 position)
    {
        
        float posX = 1.0f - ((position.x + max.x) / (max.x*2.0f));
        float posZ = 1.0f - ((position.z + max.z) / (max.z*2.0f));

        int texX = (int)(posX * (float)imprint.width);
        int texY = (int)(posZ * (float)imprint.height);
        return new Vector2(texX, texY);
    }

    public void AddImprint(Vector3 position)
    {
        Vector2 texturePos = GetTexturePositionFromWorldPosition(position);
        imprint = DrawOnTop(imprint, drawTexture, texturePos);

        
    }

    private Texture2D DrawOnTop(Texture2D imprint, Texture2D other, Vector2 center)
    {
        for (int i = 0; i < other.width; i++)
        {
            for (int j = 0; j < other.height; j++)
            {
                int indexX = (i - other.width / 2.0) + (int)center.x > imprint.width ? imprint.width - 1 : (int)(i - other.width / 2.0) + (int)center.x;
                int indexY = (j - other.height / 2.0) + (int)center.y > imprint.height ? imprint.height - 1 : (int)(j - other.height / 2.0) + (int)center.y;

                Color c = Color.white;
                c.r = other.GetPixel(i, j).r;

                Color currentPix = imprint.GetPixel(indexX, indexY);
                currentPix.r += c.r/30.0f;

                imprint.SetPixel(indexX, indexY, currentPix);
            }
        }
        imprint.Apply();
        return imprint;
    }
}
