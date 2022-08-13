using Godot;
using System;

public class MainMenu : Control {

    private Button newGameButton;
    
    public override void _Ready() {
        newGameButton = GetNode<Button>("Menu/CenterContainer/CenterRow/Buttons/NewGame");

        newGameButton.Connect("pressed", this, nameof(OnNewGameButtonPressed));
    }

    private void OnNewGameButtonPressed() {
        Events.EmitEvent(nameof(Events.StartNewGame));
    }
}
