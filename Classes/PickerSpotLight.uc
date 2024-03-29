Class PickerSpotLight extends SpotLightMovable
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

//Default 1024.0
Function SetRadius(Float r) {
	SpotLightComponent(LightComponent).Radius = r;
}

//Default 2.0
Function SetFallOffExponent(Float e) {
	SpotLightComponent(LightComponent).FalloffExponent = e;
}

//Default 2.0
Function SetShadowFalloffExponent(Float e) {
	SpotLightComponent(LightComponent).ShadowFalloffExponent = e;
}

//Default 1.1
Function SetShadowRadiusMultiplier(Float f) {
	SpotLightComponent(LightComponent).ShadowRadiusMultiplier = f;
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
   /* bNoDelete=FALSE
	bStatic=FALSE
	CastShadows=TRUE
	CastStaticShadows=TRUE
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
	bBlockActors=FALSE*/
	bNoDelete=FALSE
	bStatic=FALSE
	OuterConeAngle=15.0
    LightShaftConeAngle=50.0
    CachedParentToWorld=(XPlane=(X=0.0,Y=-0.9998820,Z=0.0,W=-0.0153390),YPlane=(X=0.0,Y=0.0,Z=1.0,W=0.0),ZPlane=(X=0.0,Y=0.0153390,Z=0.0,W=-0.9998820),WPlane=(X=1.0,Y=-32.509070,Z=0.0248410,W=-1.1567380))
    Translation=(X=-32.509070,Y=0.0248410,Z=-1.1567380)
    LightmassSettings=(LightSourceRadius=32.0)
    LightGuid=(A=-1469459632,B=1157639902,C=-1920017986,D=-1318663716)
    LightmapGuid=(A=1022433191,B=1302926668,C=-47744875,D=28197039)
    Brightness=5.0
    LightColor=(R=205,G=227,B=255,A=0)
    Function=LightFunction
    bPrecomputedLightingIsValid=false
    LightingChannels=(Unnamed_1=true,Unnamed_2=true,Unnamed_3=true,Unnamed_4=true,Unnamed_5=true,Unnamed_6=true)
    LightAffectsClassification=ELightAffectsClassification.LAC_DYNAMIC_AND_STATIC_AFFECTING
    OcclusionDepthRange=200.0
    BloomScale=6.0
    OcclusionMaskDarkness=0.0
}