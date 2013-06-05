/** CCTransitionFade:
 Fade out the outgoing scene and then fade in the incoming scene.'''
 */
class CCTransitionFade extends CCTransitionScene
{
var color :CC_Color4B;
}
/** creates the transition with a duration and with an RGB color
 * Example: FadeTransition.transitionWithDuration:2 scene:s withColor:ccc3(255,0,0); // red color
 */
public static function  transitionWithDuration:(Float)duration scene:(CCScene*)scene withColor:(CC_Color3B)color;
/** initializes the transition with a duration and with an RGB color */
-(id) initWithDuration:(Float)duration scene:(CCScene*)scene withColor:(CC_Color3B)color;

public static function  transitionWithDuration:(Float)d scene:(CCScene*)s withColor ( color:CC_Color3B )
{
	return new XXX().initWithDuration:d scene:s withColor:color] autorelease];
}

-(id) initWithDuration:(Float)d scene:(CCScene*)s withColor ( aColor:CC_Color3B )
{
	if( (this=super.initWithDuration:d scene:s]) ) {
		color.r = aColor.r;
		color.g = aColor.g;
		color.b = aColor.b;
	}
	
	return this;
}

-(id) initWithDuration:(Float)d scene ( s:CCScene )
{
	return this.initWithDuration ( d, s, ccBLACK );
}

public function onEnter ()
{
	super.onEnter();
	
	var l :CCLayerColor = CCLayerColor.layerWithColor ( color );
	inScene_.set_visible ( false );
	
	this.addChild ( l, 2, kSceneFade );
	
	
	var f :CCNode = this.getChildByTag ( kSceneFade );
	
	var a :CCActionInterval = CCSequence.actions:
						   CCFadeIn.actionWithDuration:duration_/2],
						   CCCallFunc.actionWithTarget:this selector:@selector(hideOutShowIn)],
						   CCFadeOut.actionWithDuration:duration_/2],
						   CCCallFunc.actionWithTarget:this selector:@selector(finish)],
						   null ];
	f.runAction ( a );
}

public function onExit ()
{
	super.onExit();
	this.removeChildByTag ( kSceneFade,( false );
}
}