/** CCTransitionJumpZoom:
 Zoom out and jump the outgoing scene, and then jump and zoom in the incoming 
*/
class CCTransitionJumpZoom extends CCTransitionScene
{
//
public function onEnter ()
{
	super.onEnter();
	var s :CGSize = CCDirector.sharedDirector().winSize();
	
	inScene_.set_scale ( 0.5 );
	inScene_.set_position:new CGPoint ( s.width,0 );

	inScene_.set_anchorPoint:new CGPoint (0.5, 0.5);
	outScene_.set_anchorPoint:new CGPoint (0.5, 0.5);

	var  jump :CCActionInterval = CCJumpBy.actionWithDuration:duration_/4 position:new CGPoint (-s.width,0) height:s.width/4 jumps ( 2 );
	var  scaleIn :CCActionInterval = CCScaleTo.actionWithDuration:duration_/4 scale:1.0];
	var  scaleOut :CCActionInterval = CCScaleTo.actionWithDuration:duration_/4 scale:0.5];
	
	var  jumpZoomOut :CCActionInterval = CCSequence.actions: scaleOut, jump, null];
	var  jumpZoomIn :CCActionInterval = CCSequence.actions: jump, scaleIn, null];
	
	var  delay :CCActionInterval = CCDelayTime.actionWithDuration:duration_/2];
	
	outScene_.runAction ( jumpZoomOut );
	inScene_.runAction: CCSequence.actions: delay,
								jumpZoomIn,
								CCCallFunc.actionWithTarget:this selector:@selector(finish)],
								null] ];
}
}