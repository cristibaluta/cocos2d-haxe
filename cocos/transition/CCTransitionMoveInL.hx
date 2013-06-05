/** CCTransitionMoveInL:
 Move in from to the left the incoming scene.
*/
class CCTransitionMoveInL extends CCTransitionScene
{
/** initializes the scenes */
public function initScenes;
/** returns the action that will be performed */
public function action () :CCActionInterval
{
	return CCMoveTo.actionWithDuration:duration_ position:new CGPoint (0,0);
}


public function onEnter ()
{
	super.onEnter();
	
	this.initScenes();
	
	var  a :CCActionInterval = this.action;

	inScene_.runAction: CCSequence.actions:
						 this.easeActionWithAction:a],
						 CCCallFunc.actionWithTarget:this selector:@selector(finish)],
						 null]
	];
	 		
}


public function easeActionWithAction (action:CCActionInterval) :CCActionInterval
{
	return CCEaseOut.actionWithAction (action, 2.0);
//	return EaseElasticOut.actionWithAction (action, 0.4);
}

public function initScenes ()
{
	var s :CGSize = CCDirector.sharedDirector().winSize();
	inScene_.set_position ( new CGPoint (-s.width, 0));
}
}