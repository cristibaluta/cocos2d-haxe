/** CCTransitionFadeTR:
 Fade the tiles of the outgoing scene from the left-bottom corner the to top-right corner.
 */
class CCTransitionFadeTR extends CCTransitionScene <CCTransitionEaseScene>
{}
-(CCActionInterval*) actionWithSize:(CC_GridSize) vector;

public function sceneOrder ()
{
	inSceneOnTop_ = false;
}

public function onEnter ()
{
	super.onEnter();
	
	var s :CGSize = CCDirector.sharedDirector().winSize();
	var aspect :Float = s.width / s.height;
	var x :Int = 12 * aspect;
	var y :Int = 12;
	
	id action  = this.actionWithSize:new CC_GridSize(x,y);

	outScene_.runAction: CCSequence.actions:
					this.easeActionWithAction:action],
				    CCCallFunc.actionWithTarget:this selector:@selector(finish)],
				    CCStopGrid.action],
				    null]
	 ];
}

-(CCActionInterval*) actionWithSize (v:CC_GridSize) 
{
	return CCFadeOutTRTiles.actionWithSize ( v, duration_ );
}

public function easeActionWithAction (action:CCActionInterval) :CCActionInterval
{
	return action;
//	return EaseIn.actionWithAction (action, 2.0);
}
}