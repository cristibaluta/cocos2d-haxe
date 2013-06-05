/**
 CCTransitionCrossFade:
 Cross fades two scenes using the CCRenderTexture object.
 */
class CCTransitionCrossFade extends CCTransitionScene
{
//
public function draw ()
{
	// override draw since both scenes (textures) are rendered in 1 scene
}

public function onEnter ()
{
	super.onEnter();
	
	// create a transparent color layer
	// in which we are going to add our rendertextures
	CC_Color4B  color = {0,0,0,0};
	size:CGSize = CCDirector.sharedDirector().winSize();
	var layer :CCLayerColor = CCLayerColor.layerWithColor ( color );
	
	// create the first render texture for inScene_
	var inTexture :CCRenderTexture = CCRenderTexture.renderTextureWithWidth:size.width height:size.height;
	inTexture.sprite.anchorPoint= new CGPoint (0.5,0.5);
	inTexture.position = new CGPoint (size.width/2, size.height/2);
	inTexture.anchorPoint = new CGPoint (0.5,0.5);
	
	// render inScene_ to its texturebuffer
	inTexture.begin;
	inScene_.visit();
	inTexture.end;
	
	// create the second render texture for outScene_
	var outTexture :CCRenderTexture = CCRenderTexture.renderTextureWithWidth:size.width height:size.height;
	outTexture.sprite.anchorPoint= new CGPoint (0.5,0.5);
	outTexture.position = new CGPoint (size.width/2, size.height/2);
	outTexture.anchorPoint = new CGPoint (0.5,0.5);
	
	// render outScene_ to its texturebuffer
	outTexture.begin;
	outScene_.visit();
	outTexture.end;
	
	// create blend functions
	
	CC_BlendFunc blend1 = {GL.ONE, GL.ONE}; // inScene_ will lay on background and will not be used with alpha
	CC_BlendFunc blend2 = {GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA}; // we are going to blend outScene_ via alpha 
	
	// set blendfunctions
	inTexture.sprite.setBlendFunc ( blend1 );
	outTexture.sprite.setBlendFunc ( blend2 );	
	
	// add render textures to the layer
	layer.addChild ( inTexture );
	layer.addChild ( outTexture );
	
	// initial opacity:
	inTexture.sprite.set_opacity ( 255 );
	outTexture.sprite.set_opacity ( 255 );
	
	// create the blend action
	var  * layerAction :CCActionInterval = CCSequence.actions:
									  CCFadeTo.actionWithDuration:duration_ opacity:0],
									  CCCallFunc.actionWithTarget:this selector:@selector(hideOutShowIn)],
									  CCCallFunc.actionWithTarget:this selector:@selector(finish)],
									  null ];
	
	
	// run the blend action
	[outTexture.sprite runAction: layerAction];
	
	// add the layer (which contains our two rendertextures) to the scene
	this.addChild ( layer, 2, kSceneFade );
}

// clean up on exit
public function onExit ()
{
	// remove our layer and release all containing objects 
	this.removeChildByTag ( kSceneFade,( false );
	
	super.onExit();	
}
}