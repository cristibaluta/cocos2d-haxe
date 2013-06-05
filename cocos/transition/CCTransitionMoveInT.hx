/** CCTransitionMoveInT:
 Move in from to the top the incoming scene.
 */
class CCTransitionMoveInT extends CCTransitionMoveInL 
{
//
public function initScenes ()
{
	var s :CGSize = CCDirector.sharedDirector().winSize();
	inScene_.set_position ( new CGPoint ( 0, s.height) );
}
}