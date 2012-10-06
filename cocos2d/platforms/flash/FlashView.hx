/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

/*
 * Idea of subclassing NSOpenGLView was taken from  "TextureUpload" Apple's sample
 */

// Only compile this code on Mac. These files should not be included on your iOS project.
// But in case they are included, it won't be compiled.
package platforms.flash;

import flash.display.MovieClip;
import flash.display.Graphics;
import flash.events.Event;
import flash.events.MouseEvent;
//import flash.events.TouchEvent;
import platforms.flash.CCDirectorFlash;
import CCConfig;
import objc.CGRect;


class FlashView extends MovieClip
{
public var eventDelegate :Dynamic;
public var bounds :CGRect;
var _cmd :Dynamic;


public static function viewWithFrame (frameRect:CGRect) :FlashView {
	return new FlashView().initWithFrame ( frameRect );
}
public function initWithFrame (frameRect:CGRect) :FlashView
{
	trace("initWithFrame "+frameRect);
	
	// Add default background color
	graphics.lineStyle ( null );
	graphics.beginFill (0x333333, 1);
	graphics.drawRect (0, 0, frameRect.size.width, frameRect.size.height);
	graphics.endFill();
	
	eventDelegate = null;
	bounds = frameRect;
	this.x = frameRect.origin.x;
	this.y = frameRect.origin.y;
	
	return this;
}

public function reshape ()
{
	// We draw on a secondary thread through the display link
	// When resizing the view, -reshape is called automatically on the main thread
	// Add a mutex around to avoid the threads accessing the context simultaneously when resizing
	//CGLLockContext([[self openGLContext] CGLContextObj]);
	
	var director :CCDirector = CCDirector.sharedDirector();
	director.reshapeProjection ( bounds.size );
	
	// avoid flicker
	director.drawScene();
}

public function release()
{
	
}

inline function DISPATCH_EVENT(__event__:Event, __selector__) {
	Reflect.callMethod (eventDelegate, __selector__, [__event__]);
/*	id obj = eventDelegate;
	[obj performSelector:__selector__
			onThread:[(CCDirectorFlash*)[CCDirector sharedDirector] runningThread]
		  withObject:__event__
	   waitUntilDone:NO];*/
}



// Mouse events
public function mouseDown (theEvent:MouseEvent) {
	DISPATCH_EVENT(theEvent, _cmd);
}

public function mouseMoved (theEvent:MouseEvent) {
	DISPATCH_EVENT(theEvent, _cmd);
}

public function mouseDragged (theEvent:MouseEvent) {
	DISPATCH_EVENT(theEvent, _cmd);
}

public function mouseUp (theEvent:MouseEvent) {
	DISPATCH_EVENT(theEvent, _cmd);
}

public function rightMouseDown (theEvent:MouseEvent) {
	DISPATCH_EVENT(theEvent, _cmd);
}

public function rightMouseDragged (theEvent:MouseEvent) {
	DISPATCH_EVENT(theEvent, _cmd);
}

public function rightMouseUp (theEvent:MouseEvent) {
	DISPATCH_EVENT(theEvent, _cmd);
}

public function otherMouseDown (theEvent:MouseEvent) {
	DISPATCH_EVENT(theEvent, _cmd);
}

public function otherMouseDragged (theEvent:MouseEvent) {
	DISPATCH_EVENT(theEvent, _cmd);
}

public function otherMouseUp (theEvent:MouseEvent) {
	DISPATCH_EVENT(theEvent, _cmd);
}

public function mouseEntered (theEvent:MouseEvent) {
	DISPATCH_EVENT(theEvent, _cmd);
}

public function mouseExited (theEvent:MouseEvent) {
	DISPATCH_EVENT(theEvent, _cmd);
}

public function scrollWheel (theEvent:MouseEvent) {
	DISPATCH_EVENT(theEvent, _cmd);
}

// Key events

public function becomeFirstResponder () :Bool {
	return true;
}

public function acceptsFirstResponder () :Bool {
	return true;
}

public function resignFirstResponder () :Bool {
	return true;
}

public function keyDown (theEvent:MouseEvent) {
	DISPATCH_EVENT(theEvent, _cmd);
}

public function keyUp (theEvent:MouseEvent) {
	DISPATCH_EVENT(theEvent, _cmd);
}

public function flagsChanged (theEvent:MouseEvent) {
	DISPATCH_EVENT(theEvent, _cmd);
}


// Touch events
/*public function touchesBeganWithEvent (theEvent:TouchEvent) {
	DISPATCH_EVENT(theEvent, _cmd);
}

public function touchesMovedWithEvent (theEvent:TouchEvent) {
	DISPATCH_EVENT(theEvent, _cmd);
}

public function touchesEndedWithEvent (theEvent:TouchEvent) {
	DISPATCH_EVENT(theEvent, _cmd);
}

public function touchesCancelledWithEvent (theEvent:TouchEvent) {
	DISPATCH_EVENT(theEvent, _cmd);
}*/

}
