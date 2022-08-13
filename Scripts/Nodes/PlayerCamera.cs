using Godot;
using System;

public class PlayerCamera : Camera2D {

    [Export] 
    private Vector2 tileSize = new Vector2(16, 16);
    
    [Export] 
    private NodePath cameraPath;
    
    [Export] 
    private bool drawGrid = true;
    
    [Export] 
    private float lineThickness = 1;
    
    [Export] 
    private Color lineColor = Colors.White;

    private Camera2D camera2D;
    
    private int screenWidth = (int) ProjectSettings.GetSetting("display/window/size/width");
    private int screenHeight = (int) ProjectSettings.GetSetting("display/window/size/height");
    private double extraScreenMargin;
    
    public override void _Ready() {
        camera2D = GetNode<Camera2D>(cameraPath);
        
        extraScreenMargin = screenWidth * 0.0625;
    }

    public override void _Draw() {
        if (camera2D == null || drawGrid == false) {
            return;
        }

        float width = (float) (screenWidth + extraScreenMargin) * camera2D.Zoom.x;
        float height = (float) (screenHeight + extraScreenMargin) * camera2D.Zoom.y;
        Vector2 globalCameraPos = (camera2D.GlobalPosition - new Vector2(width, height) / 2).Snapped(tileSize) - GlobalPosition;

        for (int i = 0; i < width / tileSize.x + 1; i++) {
            float x = tileSize.x * i + globalCameraPos.x;
            Vector2 from = new Vector2(x, globalCameraPos.y - tileSize.y / 2);
            Vector2 to = new Vector2(x, globalCameraPos.y + height + tileSize.y / 2);
            DrawLine(from, to, lineColor, lineThickness, false);
        }
        for (int j = 0; j < height / tileSize.y + 1; j++) {
            float y = tileSize.y * j + globalCameraPos.y;
            Vector2 from = new Vector2(globalCameraPos.x - tileSize.x / 2, y);
            Vector2 to = new Vector2(globalCameraPos.x + width + tileSize.x / 2, y);
            DrawLine(from, to, lineColor, lineThickness, false);
        }
    }

    public override void _Process(float delta) {
        Update();
    }
}
