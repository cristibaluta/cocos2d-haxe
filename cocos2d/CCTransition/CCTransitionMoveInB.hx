/** CCTransitionMoveInB:
 Move in from to the bottom the incoming scene.
 */
class CCTransitionMoveInB extends CCTransitionMoveInL
{
//
public function initScenes ()
{
	var s :CGSize = CCDirector.sharedDirector().winSize();
	inScene_.setPosition: new CGPoint ( 0, -s.height) ];
}
}