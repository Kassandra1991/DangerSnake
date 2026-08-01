using UnityEngine;

namespace DangerSnake.Core
{
    /// <summary>
    /// Tiny colored mesh helper shared by runtime views.
    /// </summary>
    public static class QuadFactory
    {
        public static Transform Create(string name, Color color, float scale)
        {
            var go = GameObject.CreatePrimitive(PrimitiveType.Quad);
            go.name = name;
            Object.Destroy(go.GetComponent<Collider>());
            var mr = go.GetComponent<MeshRenderer>();
            var shader = Shader.Find("Sprites/Default");
            if (shader == null)
                shader = Shader.Find("Unlit/Color");
            mr.material = new Material(shader);
            mr.material.color = color;
            go.transform.localScale = Vector3.one * scale;
            return go.transform;
        }
    }
}
