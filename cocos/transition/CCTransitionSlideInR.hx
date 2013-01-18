/** CCTransitionSlideInR:
 Slide in the incoming scene from the right border.
 */
class CCTransitionSlideInR extends CCTransitionSlideInL 
{
//
public function sceneOrder ()
{
	inSceneOnTop_ = true;
}
public function initScenes ()
{
	var s :CGSize = CCDirector.sharedDirector().winSize();
	inScene_.setPosition: new CGPoint ( s.width-ADJUST_FACTOR,0) ];
}

public function action () :CCActionInterval
{
	var s :CGSize = CCDirector.sharedDirector().winSize();
	return CCMoveBy.actionWithDuration:duration_ position:new CGPoint (-(s.width-ADJUST_FACTOR),0);
}
}