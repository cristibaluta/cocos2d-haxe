/** CCTransitionSlideInL:
 Slide in the incoming scene from the left border.
 */
class CCTransitionSlideInL extends CCTransitionScene <CCTransitionEaseScene>
{}
/** initializes the scenes */
public function initScenes;
/** returns the action that will be performed by the incomming and outgoing scene */
-(CCActionInterval*) action;

// The adjust factor is needed to prevent issue #442
// One solution is to use DONT_RENDER_IN_SUBPIXELS images, but NO
// The other issue is that in some transitions (and I don't know why)
// the order should be reversed (In in top of Out or vice-versa).
#define ADJUST_FACTOR 0.5
public function onEnter ()
{
	super.onEnter();

	this.initScenes();
	
	var  in :CCActionInterval = this.action;
	var  out :CCActionInterval = this.action;

	var inAction :id = this.easeActionWithAction ( in );
	var outAction :id = CCSequence.actions:
					this.easeActionWithAction:out],
					CCCallFunc.actionWithTarget:this selector:@selector(finish)],
					null];
	
	inScene_.runAction ( inAction );
	outScene_.runAction ( outAction );
}
public function sceneOrder ()
{
	inSceneOnTop_ = false;
}
public function initScenes ()
{
	var s :CGSize = CCDirector.sharedDirector().winSize();
	inScene_.setPosition: new CGPoint ( -(s.width-ADJUST_FACTOR),0) ];
}
public function action () :CCActionInterval
{
	var s :CGSize = CCDirector.sharedDirector().winSize();
	return CCMoveBy.actionWithDuration:duration_ position:new CGPoint (s.width-ADJUST_FACTOR,0);
}

public function easeActionWithAction (action:CCActionInterval) :CCActionInterval
{
	return CCEaseOut.actionWithAction (action, 2.0);
//	return EaseElasticOut.actionWithAction (action, 0.4);
}
}