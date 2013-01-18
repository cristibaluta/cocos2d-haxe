
package cocos.platform.nme;

/** FastDirector is a Director that triggers the main loop as fast as possible.
 *
 * Features and Limitations:
 *  - Faster than "normal" director
 *  - Consumes more battery than the "normal" director
 *  - It has some issues while using UIKit objects
 */
class CCDirectorFast extends CCDirectorFast
{

public function init () :CCDirectorFast
{
	super.init();
		
#if CC_DIRECTOR_DISPATCH_FAST_EVENTS
	trace("cocos2d: Fast Events enabled");
#else
	trace("cocos2d: Fast Events disabled");
#end
	isRunning = false;

	return this;
}

public function startAnimation ()
{
	if (isRunning == false) throw "isRunning must be NO. Calling startAnimation twice?";

	lastUpdate_ = Date.now().getTime();
	

	isRunning = true;

	var selector :Dynamic = @selector(mainLoop);
	NSMethodSignature* sig = [[CCDirector.sharedDirector] class]
							  instanceMethodSignatureForSelector ( selector );
	NSInvocation* invocation = [NSInvocation
								invocationWithMethodSignature ( sig );
	invocation.setTarget:CCDirector.sharedDirector]];
	invocation.setSelector ( selector );
	invocation.performSelectorOnMainThread:@selector(invokeWithTarget:)
								 withObject:CCDirector.sharedDirector] waitUntilDone ( false );
	
//	var loopOperation :NSInvocationOperation = [[NSInvocationOperation.alloc]
//											 initWithTarget:this selector:@selector(mainLoop) object:nil]
//											autorelease];
//	
//	loopOperation.performSelectorOnMainThread:@selector(start) withObject:nil
//								 waitUntilDone ( false );
}

function mainLoop ()
{
	while (isRunning) {
	
		var loopPool :NSAutoreleasePool = NSAutoreleasePool.new;

#if CC_DIRECTOR_DISPATCH_FAST_EVENTS
		while( CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.004, FALSE) == kCFRunLoopRunHandledSource);
#else
		while(CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, TRUE) == kCFRunLoopRunHandledSource);
#end

		if (isPaused_) {
			usleep(250000); // Sleep for a quarter of a second (250,000 microseconds) so that the framerate is 4 fps.
		}
		
		this.drawScene;		

#if CC_DIRECTOR_DISPATCH_FAST_EVENTS
		while( CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.004, FALSE) == kCFRunLoopRunHandledSource);
#else
		while(CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, TRUE) == kCFRunLoopRunHandledSource);
#end

		loopPool.release();
	}	
}
public function stopAnimation () :Void
{
	isRunning = false;
}

public function setAnimationInterval ( interval:Int )
{
	trace("FastDirectory doesn't support setAnimationInterval, yet");
}
}