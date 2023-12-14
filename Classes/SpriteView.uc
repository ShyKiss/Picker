Class SpriteView extends Actor;

var SpriteComponent Sprite;

DefaultProperties 
{
    Begin Object Class=SpriteComponent Name=VisSprite
        HiddenGame=false
        HiddenEditor=false
        AlwaysLoadOnClient=False
        AlwaysLoadOnServer=False
        Scale=0.05
    End Object
    Sprite=VisSprite
	Components.Add(VisSprite)
}
