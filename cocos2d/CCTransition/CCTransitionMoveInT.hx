/** CCTransitionMoveInT:
 Move in from to the top the incoming scene.
 */
class CCTransitionMoveInT extends CCTransitionMoveInL 
{
//
public function initScenes ()
{
	var s :CGSize = CCDirector.sharedDirector().winSize();
	inScene_.setPosition ( new CGPoint ( 0, s.height) );
}
}