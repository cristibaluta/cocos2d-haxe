
package cocos;

typedef TICK_IMP = Dynamic->Dynamic->Float->Void;//{ id:Dynamic, SEL:Dynamic, ccTime:Float }

//
// CCTimer
//
/** Light weight timer */
class CCTimer
{

public var target :Dynamic;
public var impMethod :TICK_IMP;
public var elapsed :Float;
public var interval :Float;
public var selector :Dynamic;


/** interval in seconds */
public function new () {trace("new");}
public function init () :CCTimer
{
	throw "CCTimer: Init not supported.";
	this.release();
	return null;
}


/** Allocates a timer with a target, a selector and an interval in seconds.
*/
public static function timerWithTarget (target:Dynamic, selector:Dynamic, ?interval:Float=0) :CCTimer
{
	return new CCTimer().initWithTarget (target, selector, interval);
}


/** Initializes a timer with a target, a selector and an interval in seconds.
*/
public function initWithTarget (t:Dynamic, s:Dynamic, ?seconds:Float=0) :CCTimer
{
	trace("init with target "+t);
#if COCOS2D_DEBUG
	var sig :NSMethodSignature = t.methodSignatureForSelector ( s );
	if(sig !=0 , "Signature not found for selector - does it have the following form? public function name: (Float) dt");
#end
	// target is not retained. It is retained in the hash structure
	target = t;
	selector = s;
	impMethod = Reflect.field (target, selector);//t.methodForSelector ( s );
	elapsed = -1;
	interval = seconds;	
	
	return this;
}

public function toString () :String
{
	return "<CCTimer | target:"+target+" selector:"+selector+">";
}

public function release ()
{
	trace("cocos2d: releaseing "+ this);
}

/** triggers the timer */
public function update ( dt:Float )
{
	trace("update CCTimer "+dt);
	if( elapsed == - 1)
		elapsed = 0;
	else
		elapsed += dt;
	if( elapsed >= interval ) {
		impMethod ( target, selector, elapsed );
		elapsed = 0;
	}
}
}
