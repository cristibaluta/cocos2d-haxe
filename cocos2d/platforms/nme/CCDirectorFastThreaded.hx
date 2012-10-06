/** ThreadedFastDirector is a Director that triggers the main loop from a thread.
 *
 * Features and Limitations:
 *  - Faster than "normal" director
 *  - Consumes more battery than the "normal" director
 *  - It can be used with UIKit objects
 *
 * @since v0.8.2
 */
class CCDirectorFastThreaded extends CCDirectorNME
{
public function init () :id
{
	if(( this = super.init] )) {		
		isRunning = false;		
	}
	
	return this;
}

public function startAnimation () :Void
{
	if (isRunning != false) throw "isRunning must be false. Calling startAnimation twice?";

	lastUpdate_ = Date.now().getTime();
	isRunning = true;

	var thread :NSThread = new NSThread().initWithTarget:this selector:@selector(mainLoop) object ( nil );
	thread.start;
	thread.release();
}

public function mainLoop () :Void
{
	while( !isCancelled ) {
		if( isRunning ) {
			timer = new haxe.Timer(250);
			timer.run = drawScene;
		}
		//this.performSelectorOnMainThread:@selector(drawScene) withObject ( nil, true );
				
/*		if (isPaused_) {
			usleep(250000); // Sleep for a quarter of a second (250,000 microseconds) so that the framerate is 4 fps.
		} else {
//			usleep(2000);
		}*/
	}
}
public function stopAnimation () :Void
{
	isRunning = false;
}

public function setAnimationInterval ( interval:Int )
{
	trace("FastDirector doesn't support setAnimationInterval, yet");
}
}