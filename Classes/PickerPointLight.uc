Class PickerPointLight extends PointLightMovable
	placeable;

var PointLightComponent PickerPointLightComponent;

Function OnTurn(Bool Enable) {
	LightComponent.SetEnabled(Enable);
}

Function SetBrightness(Float Brightness) {
	LightComponent.SetLightProperties(Brightness);
    LightComponent.UpdateColorAndBrightness();
}

Function SetColor(Byte Red, Byte Green, Byte Blue, Byte Alpha) {
	local Color NewColor;
	
	NewColor.R = Red;
	NewColor.G = Green;
	NewColor.B = Blue;
	NewColor.A = Alpha;

	LightComponent.SetLightProperties(,NewColor); 
    LightComponent.UpdateColorAndBrightness();
}

Function SetRadius(Float Radius=1024.0) {
	PointLightComponent(LightComponent).Radius = Radius;
}

Function SetFallOffExponent(Float Exp=2.0) {
	PointLightComponent(LightComponent).FalloffExponent = Exp;
}

Function SetShadowFalloffExponent(Float Exp=2.0) {
	PointLightComponent(LightComponent).ShadowFalloffExponent = Exp;
}

Function SetShadowRadiusMultiplier(Float Mul=1.1) {
	PointLightComponent(LightComponent).ShadowRadiusMultiplier = Mul;
}

Function SetCastDynamicShadows(Bool Cast=true) {
	LightComponent.CastDynamicShadows = Cast;
}

Event Tick(Float DT) {
	Super.Tick(DT);
	LightComponent.MaxDistFromCamForEnabled = 250000.0;
}

DefaultProperties
{
    bNoDelete=FALSE
	CastShadows=TRUE
	bStatic=FALSE
	CastStaticShadows=TRUE
	CastDynamicShadows=TRUE
	bForceDynamicLight=TRUE
	UseDirectLightMap=FALSE
	bAllowPreShadow=TRUE
	bPrecomputedLightingIsValid=false
	LightAffectsClassification=ELightAffectsClassification.LAC_DYNAMIC_AND_STATIC_AFFECTING
    LightShadowMode=ELightShadowMode.LightShadow_Normal
	LightComponent.LightingChannels(bInitialized=true,BSP=true,Static=true,Dynamic=true,CompositeDynamic=true,Skybox=true,Unnamed_1=true,Unnamed_2=true,Unnamed_3=true,Unnamed_4=true,Unnamed_5=true,Unnamed_6=true,Cinematic_1=true,Cinematic_2=true,Cinematic_3=true,Cinematic_4=true,Cinematic_5=true,Cinematic_6=true,Cinematic_7=true,Cinematic_8=true,Cinematic_9=true,Cinematic_10=true,Gameplay_1=true,Gameplay_2=true,Gameplay_3=true,Gameplay_4=true,Crowd=true)
    bCollideActors=FALSE
	bCollideWorld=FALSE
	bBlockActors=FALSE
}