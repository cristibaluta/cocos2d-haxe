/** CCTransitionSlideInB:
 Slide in the incoming scene from the bottom border.
 */
class CCTransitionSlideInB extends CCTransitionSlideInL
{
//
public function sceneOrder ()
{
	inSceneOnTop_ = true;
}

public function initScenes ()
{
	var s :CGSize = CCDirector.sharedDirector().winSize();
	inScene_.set_position ( new CGPoint (0,-(s.height-ADJUST_FACTOR)) );
}

public function action () :CCActionInterval
{
	var s :CGSize = CCDirector.sharedDirector().winSize();
	return CCMoveBy.actionWithDuration (duration_, new CGPoint (0, s.height-ADJUST_FACTOR));
}
}