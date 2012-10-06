/** DisplayLinkDirector is a Director that synchronizes timers with the refresh rate of the display.
 *
 * Features and Limitations:
 * - Only available on 3.1+
 * - Scheduled timers & drawing are synchronizes with the refresh rate of the display
 * - Only supports animation intervals of 1/60 1/30 & 1/15
 *
 * It is the recommended Director if the SDK is 3.1 or newer
 *
 * @since v0.8.2
 */
package platforms.flash;

class CCDirectorDisplayLink extends CCDirectorFlash
{

var displayLink :haxe.Timer;

//public function addToRunLoop (arg1:id, forMode:(id)arg2;
//public function setFrameInterval (interval:Int) :Void {}
//public function invalidate () :Void {}


override public function setAnimationInterval ( interval:Float )
{
	animationInterval_ = interval;
	if (displayLink != null) {
		this.stopAnimation();
		this.startAnimation();
	}
}

override public function startAnimation () :Void
{
	if (displayLink != null) throw "displayLink must be null. Calling startAnimation twice?";

	lastUpdate_ = Date.now().getTime();
	
	// approximate frame rate
	// assumes device refreshes at 60 fps
	var frameInterval :Int = Math.floor (animationInterval_ *1000);
	
	trace("cocos2d: Frame interval: "+ frameInterval);

/*	displayLink = [NSClassFromString("CADisplayLink") displayLinkWithTarget:this selector:@selector(mainLoop:);
	displayLink.setFrameInterval ( frameInterval );
	displayLink.addToRunLoop:NSRunLoop.currentRunLoop] forMode ( NSDefaultRunLoopMode );
	*/
		//return;
	displayLink = new haxe.Timer ( frameInterval );
	displayLink.run = mainLoop;
	//mainLoop();
}
static var i = 0;
public function mainLoop ()
{
	try{
		//trace("............................................... ITERATION ............................. "+i);
		this.drawScene();
		i++;
		if (i==540) stopAnimation();
	}
	catch(e:Dynamic){
		trace(e);
		var stack = haxe.Stack.exceptionStack();
		trace ( haxe.Stack.toString ( stack ) );
		stopAnimation();
	}
}

override public function stopAnimation () :Void
{
	trace("MAIN LOOP STOPPED");
	if (displayLink != null)
		displayLink.stop();
		displayLink = null;
}

override public function release () :Void
{
	stopAnimation();
	super.release();
}

}
