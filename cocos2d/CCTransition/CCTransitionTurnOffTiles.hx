/** CCTransitionTurnOffTiles:
 Turn off the tiles of the outgoing scene in random order
 */
class CCTransitionTurnOffTiles extends CCTransitionScene <CCTransitionEaseScene>
{
//
// override addScenes, and change the order
public function sceneOrder ()
{
	inSceneOnTop_ = false;
}

public function onEnter ()
{
	super.onEnter();
	var s :CGSize = CCDirector.sharedDirector().winSize();
	var aspect :Float = s.width / s.height;
	var x :Int = 12 * aspect;
	var y :Int = 12;
	
	var toff :id = CCTurnOffTiles.actionWithSize: new CC_GridSize(x,y) duration ( duration_ );
	var action :id = this.easeActionWithAction ( toff );
	outScene_.runAction: CCSequence.actions: action,
				   CCCallFunc.actionWithTarget:this selector:@selector(finish)],
				   CCStopGrid.action],
				   null]
	 ];

}
public function easeActionWithAction (action:CCActionInterval) :CCActionInterval
{
	return action;
//	return EaseIn.actionWithAction (action, 2.0);
}
}