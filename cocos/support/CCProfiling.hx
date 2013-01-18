/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Stuart Carnie
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
 *
 */
package cocos.support;

import cocos.CCConfig;

#if CC_ENABLE_PROFILERS

class CCProfiler
{

public var activeTimers :Array<CCProfilingTimer>;
static var g_sharedProfiler :CCProfiler;

public static function sharedProfiler () :CCProfiler {
	if (!g_sharedProfiler)
		g_sharedProfiler = new CCProfiler().init();
	
	return g_sharedProfiler;
}
public static function timerWithName (timerName:String, instance:Dynamic) :CCProfilingTimer {
	var p :CCProfiler = CCProfiler.sharedProfiler();
	var t :CCProfilingTimer = new CCProfilingTimer().initWithName ( timerName, instance );
	p.activeTimers.push ( t );
	
	return t;
}
public static function releaseTimer (timer:CCProfilingTimer) :Void {
	var p :CCProfiler = CCProfiler.sharedProfiler();
	p.activeTimers.remove ( timer );
}
public function displayTimers () {
	for (timer in activeTimers) {
		trace(timer.description+"\n");
	}
}

public function init () :CCProfiler {
	super.init();
	
	activeTimers = new Array<CCProfilingTimer>();
	
	return this;
}

public function release ()
{
	activeTimers = null;
	super.release();
}

}




class CCProfilingTimer
{
var name :String;
var startTime :Int;
var averageTime :Int;

//extern void CCProfilingBeginTimingBlock(CCProfilingTimer* timer);
//extern void CCProfilingEndTimingBlock(CCProfilingTimer* timer);

public function initWithName (timerName:String, instance:Dynamic ) :CCProfilingTimer
{
	super.init();
	
	name = timerName+" ("+instance+")";
	
	return this;
}

public function release () {
	super.release();
}

public function description () :String {
	return name+" : avg time, "+averageTime;
}

/*void CCProfilingBeginTimingBlock(CCProfilingTimer* timer) {
	gettimeofday(&timer.startTime, null);
}

typedef int uint32;
void CCProfilingEndTimingBlock(CCProfilingTimer* timer) {
	struct timeval currentTime;
	gettimeofday(&currentTime, null);
	timersub(&currentTime, &timer.startTime, &currentTime);
	var duration :double = currentTime.tv_sec * 1000.0 + currentTime.tv_usec / 1000.0;
	
	// return in milliseconds
	timer.averageTime = (timer.averageTime + duration) / 2.0;
}*/

}

#end
