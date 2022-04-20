using Godot;

public class BtContext {

    private KinematicBody2D aiNode;
    
    private AiBlackboard blackboard;
    
    private readonly float deltaTime;

    public BtContext(KinematicBody2D aiNode, AiBlackboard blackboard, float deltaTime) {
        this.aiNode = aiNode;
        this.blackboard = blackboard;
        this.deltaTime = deltaTime;
    }

    public KinematicBody2D AiNode => aiNode;

    public AiBlackboard Blackboard => blackboard;

    public float DeltaTime => deltaTime;
}
