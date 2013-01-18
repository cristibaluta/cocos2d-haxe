/** TimerDirector is a Director that calls the main loop from an NSTimer object
 *
 * Features and Limitations:
 * - Integrates OK with UIKit objects
 * - Is the slowest director
 * - The invertal update is customizable from 1 to 60
 *
 * It is the default Director.
 */
package cocos.platform.nme;

class CCDirectorTimer extends CCDirectorNME
{
public function startAnimation ()
{
	if (animationTimer == null) throw "animationTimer must be nil. Calling startAnimation twice?";
	
	lastUpdate_ = Date.now().getTime();
	
	animationTimer = new haxe.Timer (animationInterval_);
	animationTimer.run = mainLoop;
}

function mainLoop () :Void
{
	this.drawScene();
}

public function stopAnimation ()
{
	animationTimer.stop();
	animationTimer = null;
}

public function setAnimationInterval ( interval:Int )
{
	animationInterval_ = interval;
	
	if (animationTimer) {
		this.stopAnimation();
		this.startAnimation();
	}
}

override public function release () :Void
{
	animationTimer.release();
	super.release();
}
}
