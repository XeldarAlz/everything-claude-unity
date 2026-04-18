using UnityEngine;
using System.Linq;

public class EnemyController : MonoBehaviour
{
    public float speed = 5f;

    private void Update()
    {
        var rb = GetComponent<Rigidbody>();
        var target = Camera.main.transform.position;

        if (gameObject.tag == "Enemy")
        {
            var enemies = FindObjectsOfType<EnemyController>();
            var nearest = enemies.Where(e => e != this).OrderBy(e => Vector3.Distance(transform.position, e.transform.position)).First();
        }

        Debug.Log("Enemy position: " + transform.position);
    }
}
