
package cocos.action;

typedef CC_CALLBACK_ND = { var id:Dynamic; var SEL:Dynamic; }
/** Calls a 'callback' with the node as the first argument and the 2nd argument is data.
 * ND means: Node and Data. Data is void , so it could be anything.
 */
class CCCallFuncND extends CCCallFuncN
{
var data_ :Void;
var callbackMethod_ :CC_CALLBACK_ND;
//
//public var callbackMethod (get_callbackMethod, set_callbackMethod) :;

public static function actionWithTarget (t:Dynamic, selector:Dynamic, data) :CCCallFuncND
{
	return new CCCallFuncND().initWithTarget (t, selector, data);
}

public function initWithTarget (t:Dynamic, selector:Dynamic, data) :CCCallFuncND
{
	super.initWithTarget (t, selector);
	data_ = d;

#if COCOS2D_DEBUG
	var sig = t.methodSignatureForSelector ( s ); // added
	if(sig ==0) throw "Signature not found for selector - does it have the following form? public function name (sender:id, :Void*)data") :Void
#end
	callbackMethod_ = t.methodForSelector ( s );
	
	return this;
}

public function release () :Void
{
	// nothing to release really. Everything is release on super (CCCallFuncN)
	super.release();
}

public function execute ()
{
	callbackMethod_(targetCallback_,selector_,target_, data_);
}
}