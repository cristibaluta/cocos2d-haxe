/** CCTransitionFlipX:
 Flips the screen horizontally.
 The front face is the outgoing scene and the back face is the incoming scene.
 */
class CCTransitionFlipX extends CCTransitionSceneOriented
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
		   CCShow.action],
		   CCOrbitCamera.actionWithDuration: duration_/2 radius: 1 deltaRadius:0 angleZ:inAngleZ deltaAngleZ:inDeltaZ angleX:0 deltaAngleX:0],
		   CCCallFunc.actionWithTarget:this selector:@selector(finish)],
		   null ];
	outA = CCSequence.actions:
			CCOrbitCamera.actionWithDuration: duration_/2 radius: 1 deltaRadius:0 angleZ:outAngleZ deltaAngleZ:outDeltaZ angleX:0 deltaAngleX:0],
			CCHide.action],
			CCDelayTime.actionWithDuration:duration_/2],							
			null ];
	
	inScene_.runAction ( inA );
	outScene_.runAction ( outA );
	
}
}