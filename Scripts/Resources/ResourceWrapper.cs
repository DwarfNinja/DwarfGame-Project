using Godot;
using System;

public abstract class ResourceWrapper : Resource {
    private Resource resource;

    public Resource Resource {
        get => resource;
        set => resource = value;
    }

    protected ResourceWrapper(Resource resource) {
        Resource = resource;
    }
}