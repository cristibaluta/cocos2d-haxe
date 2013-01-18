/** CCTransitionZoomFlipAngular:
 Flips the screen half horizontally and half vertically doing a little zooming out/in.
 The front face is the outgoing scene and the back face is the incoming scene.
 */
class CCTransitionZoomFlipAngular extends CCTransitionSceneOriented
{
//
public function onEnter ()
{
	super.onEnter();
	
	CCActionInterval *inA, *outA;
	inScene_.setVisible ( false );
	
	var inDeltaZ :Float, inAngleZ :Float;
	var outDeltaZ :Float, outAngleZ :Float;
	
	if( orientation == kOrientationRightOver ) {
		inDeltaZ = 90;
		inAngleZ = 270;
		outDeltaZ = 90;
		outAngleZ = 0;
	} else {
		inDeltaZ = -90;
		inAngleZ = 90;
		outDeltaZ = -90;
		outAngleZ = 0;
	}
		
	inA = CCSequence.actions:
		   CCDelayTime.actionWithDuration:duration_/2],
		   CCSpawn.actions:
			CCOrbitCamera.actionWithDuration: duration_/2 radius: 1 deltaRadius:0 angleZ:inAngleZ deltaAngleZ:inDeltaZ angleX:-45 deltaAngleX:0],
			CCScaleTo.actionWithDuration:duration_/2 scale:1],
			CCShow.action],
			null],						   
		   CCShow.action],
		   CCCallFunc.actionWithTarget:this selector:@selector(finish)],
		   null ];
	outA = CCSequence.actions:
			CCSpawn.actions:
			 CCOrbitCamera.actionWithDuration: duration_/2 radius: 1 deltaRadius:0 angleZ:outAngleZ deltaAngleZ:outDeltaZ angleX:45 deltaAngleX:0],
			 CCScaleTo.actionWithDuration:duration_/2 scale:0.5],
			 null],							
			CCHide.action],
			CCDelayTime.actionWithDuration:duration_/2],							
			null ];
	
	inScene_.scale = 0.5;
	inScene_.runAction ( inA );
	outScene_.runAction ( outA );
}
}