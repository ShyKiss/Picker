Class OLPickerProp extends StaticMeshActor;

//var() export editinline StaticMeshComponent PickerMesh;
DefaultProperties
{
    Begin Object Class=DynamicLightEnvironmentComponent Name=LE
        bEnabled=true
        bSynthesizeSHLight=true
    End Object

    Components.Add(LE)
    Begin Object Class=StaticMeshComponent Name=BaseMesh
        StaticMesh=StaticMesh'PrisonFloor_01a-Art.Airlock.Airlock-02'
        LightEnvironment = LE
        bCastDynamicShadow=true
        CastShadows=true
    End Object
    Components.Add(BaseMesh)
    bMovable=false
    bStatic=false
    bNoDelete=false
    bCollideActors=false
    bCollideWorld=false
    HiddenEditor=false
    HiddenGame=false
    //CollisionType=ECollisionType.COLLIDE_NoCollision
   // StaticMeshComponent=StaticMesh'olgame.Library.Futnitures.BibliothequeWithbooks'
}