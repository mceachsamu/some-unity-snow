using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class particles : MonoBehaviour
{

    ParticleSystem system;
    ParticleSystem.Particle[] m_Particles;

    public GameObject player;

    // Start is called before the first frame update
    void Start()
    {
        system = this.GetComponent<ParticleSystem>();
        m_Particles = new ParticleSystem.Particle[system.main.maxParticles];
    }

    // Update is called once per frame
    void Update()
    {
        int numParticlesAlive = system.GetParticles(m_Particles);

        for (int i = 0; i < numParticlesAlive; i++)
        {
            float lifetime = m_Particles[i].startLifetime - m_Particles[i].remainingLifetime;
            if (lifetime < 0.01f)
            {
               m_Particles[i].position = player.transform.position;
            }
        }
        system.SetParticles(m_Particles, numParticlesAlive);

    }
}
