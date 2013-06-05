/** CCTransitionRotoZoom:
 Rotate and zoom out the outgoing scene, and then rotate and zoom in the incoming 
 */
class CCTransitionRotoZoom extends CCTransitionScene
{
//
public function onEnter ()
{
	super.onEnter();
	
	inScene_.set_scale ( 0.001 );
	outScene_.set_scale ( 1.0 );
	
	inScene_.set_anchorPoint:new CGPoint (0.5, 0.5);
	outScene_.set_anchorPoint:new CGPoint (0.5, 0.5);
	
	var  rotozoom :CCActionInterval = CCSequence.actions: CCSpawn.actions:
								   CCScaleBy.actionWithDuration:duration_/2 scale:0.001],
								   CCRotateBy.actionWithDuration:duration_/2 angle:360 *2],
								   null],
								CCDelayTime.actionWithDuration:duration_/2],
							null];
	
	
	outScene_.runAction ( rotozoom );
	inScene_.runAction: CCSequence.actions:
					rotozoom.reverse],
					CCCallFunc.actionWithTarget:this selector:@selector(finish)],
				  null]];
}
}