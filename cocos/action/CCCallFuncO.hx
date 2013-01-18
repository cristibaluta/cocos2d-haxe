/** Calls a 'callback' with an object as the first argument.
 O means Object.
 @since v0.99.5
 */
package cocos.action;

class CCCallFuncO extends CCCallFunc
{
var object_ :Dynamic;
//
//@synthesize  object = object_;

public static function actionWithTarget (t:Dynamic, s:Dynamic, object:Dynamic) :CCCallFuncO
{
	return new CCCallFuncO().initWithTargetSelectorObject (t, s, object);
}

public function initWithTargetSelectorObject (t:Dynamic, s:Dynamic, object:Dynamic) :CCCallFuncO
{
	super.initWithTargetSelector (t, s);
	this.object_ = object;
	
	return this;
}

override public function release ()
{
	object_.release();
	super.release();
}

override public function execute ()
{
	targetCallback_.selector_ ( object_ );
}


// Blocks Support

/** Executes a callback using a block.
 */
/*class CCCallBlock extends CCActionInstant
{
//
public static function actionWithBlock:(void(^)())block
{
	return new XXX().initWithBlock:block] autorelease];
}

public function initWithBlock (block
{
	super.init();
	block_ = block.copy;
	
	return this;
}*/

/*public function copyWithZone (zone:NSZone) :id
{
	var copy :CCActionInstant = [[this.class] allocWithZone: zone] initWithBlock ( block_ );
	return copy;
}*/

/*public function startWithTarget (aTarget:Dynamic) :CCCallBlock
{
	super.startWithTarget ( aTarget );
	this.execute();
}

public function execute ()
{
	block_();
}

public function release () :Void
{
	block_.release();
	super.release();
}
}*/


/** Executes a callback using a block with a single CCNode parameter.
 */
/*class CCCallBlockN extends CCActionInstant
{

public static function actionWithBlock (block:CCNode) :CCCallBlockN
{
	return new CCCallBlockN().initWithBlock ( block );
}

public function initWithBlock (block:CCNode) :CCCallBlockN
{
	super.init();
	block_ = block.copy;
	
	return this;
}*/

/*public function copyWithZone (zone:NSZone) :id
{
	var copy :CCActionInstant = CCCallBlockN.allocWithZone: zone] initWithBlock ( block_ );
	return copy;
}*/

/*public function startWithTarget (aTarget:Dynamic)
{
	super.startWithTarget ( aTarget );
	this.execute();
}

public function execute ()
{
	block_(target_);
}

public function release () :Void
{
	block_.release();
	super.release();
}*/

}
