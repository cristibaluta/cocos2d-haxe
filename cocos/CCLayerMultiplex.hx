// -
// CCLayerMultiplex

/** CCLayerMultiplex is a CCLayer with the ability to multiplex it's children.
 Features:
   - It supports one or more children
   - Only one children will be active a time
 */
package cocos;

class CCLayerMultiplex extends CCLayer
{
var enabledLayer_ :Int;
var layers_ :Array<CCLayer>;


/** creates a CCMultiplexLayer with one or more layers using a variable argument list. */
public static function layerWithLayers (layer:Array<CCLayer>) :CCLayerMultiplex
{
	return new CCLayerMultiplex().initWithLayers ( layer );
}

/** initializes a MultiplexLayer with one or more layers using a variable argument list. */
public function initWithLayers (layer:Array<CCLayer>) :CCLayerMultiplex
{
	super.init();
	layers_ = new Array<CCLayer>();
	var n = Math.min (5, layer.length);
	for (i in 0...n) {
		layers_.push ( layer[i] );
	}
	enabledLayer_ = 0;
	this.addChild ( layers_[enabledLayer_] );
	
	return this;
}

public function release () :Void
{
	for(layer in layers_)
		layer.release();
	super.release();
}

/** switches to a certain layer indexed by n. 
 The current (old) layer will be removed from it's parent with 'cleanup:true'.
 */
public function switchTo (n:Int) :Void
{
	if( n >= layers_.length) throw "Invalid index in MultiplexLayer switchTo message";
	
	this.removeChild ( layers_[enabledLayer_], true);
	enabledLayer_ = n;
	this.addChild ( layers_[n] );	
}

/** release the current layer and switches to another layer indexed by n.
 The current (old) layer will be removed from it's parent with 'cleanup:true'.
 */
public function switchToAndReleaseMe (n:Int) :Void
{
	if( n >= layers_.length) throw "Invalid index in MultiplexLayer switchTo message";
	
	this.removeChild ( layers_[enabledLayer_], true);
	layers_[enabledLayer_] = null;
	enabledLayer_ = n;
	this.addChild ( layers_[n] );
}
}
