/** CCTransitionSlideInT:
 Slide in the incoming scene from the top border.
 */
class CCTransitionSlideInT extends CCTransitionSlideInL
{
//
public function sceneOrder ()
{
	inSceneOnTop_ = false;
}
public function initScenes ()
{
	var s :CGSize = CCDirector.sharedDirector().winSize();
	inScene_.setPosition: new CGPoint (0,s.height-ADJUST_FACTOR) ];
}

public function action () :CCActionInterval
{
	var s :CGSize = CCDirector.sharedDirector().winSize();
	return CCMoveBy.actionWithDuration:duration_ position:new CGPoint (0,-(s.height-ADJUST_FACTOR));
}
}