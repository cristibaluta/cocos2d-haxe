/**
 Shrink the outgoing scene while grow the incoming scene
 */
class CCTransitionShrinkGrow extends CCTransitionScene <CCTransitionEaseScene>
{
//
public function onEnter ()
{
	super.onEnter();
	
	inScene_.setScale ( 0.001 );
	outScene_.setScale ( 1.0 );

	inScene_.setAnchorPoint ( new CGPoint (2/3.0,0.5) );
	outScene_.setAnchorPoint ( new CGPoint (1/3.0,0.5) );
	
	var scaleOut :CCActionInterval = CCScaleTo.actionWithDuration (duration_, 0.01);
	var scaleIn :CCActionInterval = CCScaleTo.actionWithDuration (duration_, 1.0);

	inScene_.runAction ( this.easeActionWithAction(scaleIn) );
	outScene_.runAction ( CCSequence.actions ([
							this.easeActionWithAction(scaleOut),
							CCCallFunc.actionWithTarget (this, finish),
							null])
						);
}
public function easeActionWithAction (action:CCActionInterval) :CCActionInterval
{
	return CCEaseOut.actionWithAction (action, 2.0);
//	return EaseElasticOut.actionWithAction (action, 0.3);
}
}