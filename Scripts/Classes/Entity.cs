using Godot;
using System;
using System.Linq;
using System.Text.RegularExpressions;
using Godot.Collections;

[Tool]
public class Entity : StaticBody2D {

    [Export] private R_Entity entityDef;
    
    private enum Direction { 
        FRONT = 0,
        BACK = 1,
        LEFT = 2,
        RIGHT = 3
    }
    
    [Export] 
    private Direction facing = Direction.FRONT;

    protected string nodename;
    protected Sprite entitySprite;
    private CollisionShape2D collisionShape2D;

    private Vector2 convertedRectDimensions;
    private Vector2 absoluteSpritePosition;

    public override void _Ready() {
        nodename = Name.LStrip("@").Split("@")[0].RStrip("0123456789");
        // Regex regex = new Regex(@"/\w\D/gm");
        // Match regexMatch = regex.Match(Name);
        // nodename = regexMatch.ToString();
        entitySprite = (Sprite) GetNode("EntitySprite");
        collisionShape2D = (CollisionShape2D) GetNode("CollisionShape2D");

        if (!Engine.EditorHint) {
            if (entityDef == null) {
                entitySprite.Texture = null;
                throw new Exception("No entity_def defined in entity " + this + " with name: " + Name);
            }     
        }
        SetNodeName();
        SetEntity(entityDef);
    }

    private void SetEntityDef(R_Entity entityDef) {
        this.entityDef = entityDef;
    }

    public override void _Process(float delta) {
        if (Engine.EditorHint) {
            if (IsInstanceValid(entityDef) && IsInstanceValid(GetNode("EntitySprite"))) {
                ((Sprite) GetNode("EntitySprite")).Texture = entityDef.EntityTexture;
            }
        }
    }

    private void SetNodeName() {
        // string formattedEntityname = entityDef.EntityName.Capitalize().Replace(" ", "");
        // if (Name != formattedEntityname) {
        //     Name = formattedEntityname;
        // }
        Name = entityDef.EntityName;
    }

    private void SetEntity(R_Entity entityDef) {
        this.entityDef = entityDef;
        entitySprite.Texture = entityDef.EntityTexture;
        entitySprite.FrameCoords = new Vector2(entitySprite.FrameCoords.x, (float) facing);

        switch (entityDef.EntityType) {
            case R_Item.Type.Prop:
                entitySprite.Hframes = 1;
                entitySprite.Vframes = 4;
                SetCollisionShape();
                SetEntityPosition();
                break;
            case R_Item.Type.Lootable:
                entitySprite.Hframes = 3;
                entitySprite.Vframes = 1;
                break;
            case R_Item.Type.Craftable:
                break;
            default:
                throw new ArgumentOutOfRangeException();
        }
    }

    private void SetEntityPosition() {
        RectangleShape2D collisionRectangleShape = (RectangleShape2D) collisionShape2D.Shape;
        float collisionShapeHeight = collisionRectangleShape.Extents.y * 2;
        Vector2 collisionshapeFloorPosition = collisionShape2D.Position + new Vector2(0, collisionShapeHeight / 2);
        collisionShape2D.Position = new Vector2(collisionRectangleShape.Extents.x, -collisionRectangleShape.Extents.y);
        entitySprite.Position = -absoluteSpritePosition + new Vector2(convertedRectDimensions.x, -convertedRectDimensions.y);
    }

    private void SetCollisionShape() {
        Image imageData = entitySprite.Texture.GetData();
        Vector2 textureSize = entitySprite.Texture.GetSize();
        Vector2 individualFrameSize =
            new Vector2((textureSize.x / entitySprite.Hframes), (textureSize.y / entitySprite.Vframes));
        Image currentSpriteFrame = GetSpriteFrame(imageData, individualFrameSize);

        int shadowHeight = GetShadowHeight(currentSpriteFrame);
        convertedRectDimensions = (GetUsedRectDimensions(currentSpriteFrame) - new Vector2(0, shadowHeight)) / 2;
        absoluteSpritePosition = (GetUsedRectPosition(currentSpriteFrame) - (individualFrameSize / 2)) + convertedRectDimensions;

        RectangleShape2D rectangleShape2D = new RectangleShape2D();
        
        if (facing == Direction.LEFT || facing == Direction.RIGHT) {
            if (convertedRectDimensions.x != convertedRectDimensions.y) {
                rectangleShape2D.Extents = new Vector2(entityDef.CollisionFootprint.y, entityDef.CollisionFootprint.x) / 2;
            }
            else {
                rectangleShape2D.Extents = entityDef.CollisionFootprint / 2;
            }
        }
        else if (facing == Direction.FRONT || facing == Direction.BACK) {
            rectangleShape2D.Extents = entityDef.CollisionFootprint / 2;
        }

        collisionShape2D.Shape = rectangleShape2D;
    }

    private Image GetSpriteFrame(Image imageData, Vector2 individualFrameSize) {
        Rect2 frame = new Rect2(new Vector2(0, individualFrameSize.y * (float) facing), individualFrameSize);
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
