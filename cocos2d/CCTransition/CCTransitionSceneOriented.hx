/** A CCTransition that supports orientation like.
 * Possible orientation: LeftOver, RightOver, UpOver, DownOver
 */
class CCTransitionSceneOriented extends CCTransitionScene
{
	tOrientation orientation;

/** creates a base transition with duration and incoming scene */
public static function transitionWithDuration (t:Float, s:CCScene, o:tOrientation) :id;
/** initializes a transition with duration and incoming scene */
public function initWithDuration (t:Float, s:CCScene, o:tOrientation) :id;

public static function transitionWithDuration (t:Float, s:CCScene, o:tOrientation) :id
{
	return new XXX().initWithDuration:t scene:s orientation:o] autorelease];
}

public function initWithDuration (t:Float, s:CCScene, o:tOrientation) :id
{
	if( (this=super.initWithDuration:t scene:s]) )
		orientation = o;
	return this;
}
}
