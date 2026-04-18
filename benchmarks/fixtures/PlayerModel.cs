using System;
using UnityEngine;

[Serializable]
public sealed class PlayerModel
{
    [SerializeField] private int _health = 100;
    [SerializeField] private float _moveSpeed = 5f;

    public int Health => _health;
    public float MoveSpeed => _moveSpeed;
}
