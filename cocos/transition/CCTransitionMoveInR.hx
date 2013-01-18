/** CCTransitionMoveInR:
 Move in from to the right the incoming scene.
 */
class CCTransitionMoveInR extends CCTransitionMoveInL
{
//
public function initScenes ()
{
	var s :CGSize = CCDirector.sharedDirector().winSize();
	inScene_.setPosition: new CGPoint ( s.width,0) ];
}
}