Class PickerSkyLight extends SkyLight
	placeable;

Function OnTurn(Bool sd) {
	LightComponent.SetEnabled(sd);
}

Function SetBrightness(Float f) {
	LightComponent.SetLightProperties(f);
    LightComponent.UpdateColorAndBrightness();
}

Function SetColor(Byte ir, Byte ig, Byte ib, Byte ia) {
	local Color c;
	
	c.R = ir;
	c.G = ig;
	c.B = ib;
	c.A = ia;

	LightComponent.SetLightProperties(,c); 
    LightComponent.UpdateColorAndBrightness();
}

Function SetCastDynamicShadows(Bool b) {
	LightComponent.CastDynamicShadows = b;
}

Event Tick(Float DT) {
	Super.Tick(DT);
	LightComponent.MaxDistFromCamForEnabled = 250000.0;
}

DefaultProperties
{
    bNoDelete=FALSE
	CastShadows=FALSE
	CastStaticShadows=FALSE
	CastDynamicShadows=TRUE
	bForceDynamicLight=TRUE
	UseDirectLightMap=FALSE
	bAllowPreShadow=TRUE
	bPrecomputedLightingIsValid=false
	LightAffectsClassification=ELightAffectsClassification.LAC_DYNAMIC_AND_STATIC_AFFECTING
    LightShadowMode=ELightShadowMode.LightShadow_Normal
	LightingChannels(bInitialized=true,BSP=true,Static=true,Dynamic=true,CompositeDynamic=true,Skybox=true,Unnamed_1=true,Unnamed_2=true,Unnamed_3=true,Unnamed_4=true,Unnamed_5=true,Unnamed_6=true,Cinematic_1=true,Cinematic_2=true,Cinematic_3=true,Cinematic_4=true,Cinematic_5=true,Cinematic_6=true,Cinematic_7=true,Cinematic_8=true,Cinematic_9=true,Cinematic_10=true,Gameplay_1=true,Gameplay_2=true,Gameplay_3=true,Gameplay_4=true,Crowd=true)
    bCollideActors=FALSE
	bCollideWorld=FALSE
	bBlockActors=FALSE
}