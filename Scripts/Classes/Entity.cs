using Godot;
using System;
using System.Text.RegularExpressions;

[Tool]
public class Entity : StaticBody2D {
    
    [Export] 
    public Resource EntityDef {
        get => entityDef?.Resource;
        set {
            entityDef = value switch {
                null => null,
                RW_Entity entity => entity,
                _ => new RW_Entity(value)
            };
            if (entityDef != null) {
                SetEntity();
            }
        } 
    }

    private RW_Entity entityDef;
    
    [Export] 
    private Direction facing = Direction.Front;
    
    private enum Direction { 
        Front = 0,
        Back = 1,
        Left = 2,
        Right = 3
    }
    
    protected Sprite entitySprite;
    private CollisionShape2D collisionShape2D;

    private Vector2 convertedRectDimensions;
    private Vector2 absoluteSpritePosition;
    
    public override void _Ready() {
        entitySprite = (Sprite) GetNode("EntitySprite");
        collisionShape2D = (CollisionShape2D) GetNode("CollisionShape2D");
        
        if (!Engine.EditorHint) {
            if (entityDef == null) {
                entitySprite.Texture = null;
                throw new Exception("No entity_def defined in entity " + this + " with name: " + Name);
            }     
        }
    }

    private void SetEntity() {
        entitySprite = (Sprite) GetNode("EntitySprite");
        collisionShape2D = (CollisionShape2D) GetNode("CollisionShape2D");
        SetNodeName();
        SetSprite();
        CalculateSpriteData();

        switch (entityDef.EntityType) {
            case RW_Item.Type.Prop:
                SetSpriteFrames(1, 4);
                break;
            case RW_Item.Type.Lootable:
                SetSpriteFrames(3, 1);
                break;
            case RW_Item.Type.Craftable:
                return;
            default:
                throw new ArgumentOutOfRangeException();
        }
        SetCollisionShape();
        SetCollisionShapePosition();
        SetSpritePosition();
    }
    
    private void SetNodeName() {
        Name = entityDef == null ? "Entity" : entityDef.EntityName;
    }
    
    private void SetSprite() {
        entitySprite.Texture = entityDef.EntityTexture;
        entitySprite.FrameCoords = new Vector2(entitySprite.FrameCoords.x, (float) facing);
    }

    private void CalculateSpriteData() {
        Image imageData = entitySprite.Texture.GetData();
        Vector2 textureSize = entitySprite.Texture.GetSize();
        Vector2 individualFrameSize =
            new Vector2((textureSize.x / entitySprite.Hframes), (textureSize.y / entitySprite.Vframes));
        Image currentSpriteFrame = GetSpriteFrame(imageData, individualFrameSize);

        int shadowHeight = GetShadowHeight(currentSpriteFrame);
        convertedRectDimensions = (GetUsedRectDimensions(currentSpriteFrame) - new Vector2(0, shadowHeight)) / 2;
        absoluteSpritePosition = (GetUsedRectPosition(currentSpriteFrame) - (individualFrameSize / 2)) + convertedRectDimensions;
    }

    private void SetSpriteFrames(int hFrames, int vFrames) {
        entitySprite.Hframes = hFrames;
        entitySprite.Vframes = vFrames;
    }

    private void SetSpritePosition() {
        entitySprite.Position = -absoluteSpritePosition + new Vector2(convertedRectDimensions.x, -convertedRectDimensions.y);
    }

    private void SetCollisionShapePosition() {
        RectangleShape2D collisionRectangleShape = (RectangleShape2D) collisionShape2D.Shape;
        float collisionShapeHeight = collisionRectangleShape.Extents.y * 2;
        Vector2 collisionshapeFloorPosition = collisionShape2D.Position + new Vector2(0, collisionShapeHeight / 2);
        collisionShape2D.Position = new Vector2(collisionRectangleShape.Extents.x, -collisionRectangleShape.Extents.y);
    }

    private void SetCollisionShape() {
        RectangleShape2D rectangleShape2D = new RectangleShape2D();
        
        switch (facing) {
            case Direction.Left:
            case Direction.Right: {
                if ((int) Math.Round(convertedRectDimensions.x, 0) != (int) Math.Round(convertedRectDimensions.y, 0)) {
                    rectangleShape2D.Extents = new Vector2(entityDef.CollisionFootprint.y, entityDef.CollisionFootprint.x) / 2;
                }
                else {
                    rectangleShape2D.Extents = entityDef.CollisionFootprint / 2;
                }

                break;
            }
            case Direction.Front:
            case Direction.Back:
                rectangleShape2D.Extents = entityDef.CollisionFootprint / 2;
                break;
        }

        collisionShape2D.Shape = rectangleShape2D;
    }

    private Image GetSpriteFrame(Image imageData, Vector2 individualFrameSize) {
        Rect2 frame = new Rect2(new Vector2(0, (int) individualFrameSize.y * (int) facing), individualFrameSize);
        return imageData.GetRect(frame);
    }

    private Vector2 GetUsedRectDimensions(Image image) {
        Rect2 imageRect = image.GetUsedRect();
        return imageRect.Size;
    }
    
    private Vector2 GetUsedRectPosition(Image image) {
        Rect2 imageRect = image.GetUsedRect();
        return imageRect.Position;
    }
    
    private int GetShadowHeight(Image image) {
        Image spriteImage = image.GetRect(image.GetUsedRect());
        Vector2 spriteDimensions = GetUsedRectDimensions(spriteImage);
        
        int shadowHeight = 0;
        spriteImage.Lock();
        for (int pixely = (int) spriteDimensions.y - 1; pixely > 0; pixely--) {
            for (int pixelx = 0; pixelx < spriteDimensions.x; pixelx++) {
                if (spriteImage.GetPixel(pixelx, pixely).a >= 1) {
                    return shadowHeight;
                }
            }
            shadowHeight += 1;
        }
        spriteImage.Unlock();
        return shadowHeight;
    }
}
