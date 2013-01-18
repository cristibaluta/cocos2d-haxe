/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009-2010 Ricardo Quesada
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
 *
 */
package cocos;

import cocos.CCNode;
import cocos.support.CGPoint;
using cocos.support.CGPointExtension;
using cocos.support.CCArrayExtension;

/** CCParallaxNode: A node that simulates a parallax scroller
 The children will be moved faster / slower than the parent according the the parallax ratio.
 */
class CCParallaxNode extends CCNode
{

public var parallaxArray :Array<CGPointObject>;/** array that holds the offset / ratio of the children */
var lastPosition :CGPoint;

override public function init () :CCNode
{
	super.init();
	parallaxArray = new Array<CGPointObject>();		
	lastPosition = new CGPoint(-100,-100);
	return this;
}

override public function release ()
{
	parallaxArray = null;
	super.release();
}

/** Adds a child to the container with a z-order, a parallax ratio and a position offset
 It returns this, so you can chain several addChilds.
 @since v0.8
 */
public function addParallaxChild (child:CCNode, z:Int, ratio:CGPoint, offset:CGPoint) :Void
{
	if (child == null) throw "Argument must be non-null";
	var obj = new CGPointObject (ratio, offset);
	obj.child = child;
	parallaxArray.push(obj);
	
	var pos :CGPoint = this.position;
	pos.x = pos.x * ratio.x + offset.x;
	pos.y = pos.y * ratio.y + offset.y;
	child.position = pos;
	
	super.addChild (child, z, child.tag);
}

override public function removeChild (node:CCNode, cleanup:Bool) :Void
{
	for(i in 0...parallaxArray.length) {
		var point :CGPointObject = parallaxArray[i];
		if( point.child == node ) {
			parallaxArray.removeObjectAtIndex(i);
			break;
		}
	}
	super.removeChild (node, cleanup);
}

override public function removeAllChildrenWithCleanup (cleanup:Bool)
{
	parallaxArray.removeAllObjects();
	super.removeAllChildrenWithCleanup ( cleanup );
}

public function absolutePosition () :CGPoint
{
	var ret :CGPoint = position_;
	var cn :CCNode = this;
	
	while (cn.parent != null) {
		cn = cn.parent;
		ret = ret.add ( cn.position );
	}
	
	return ret;
}

/*
 The positions are updated at visit because:
   - using a timer is not guaranteed that it will called after all the positions were updated
   - overriding "draw" will only precise if the children have a z > 0
*/
override public function visit ()
{
//	var pos :CGPoint = position_;
//	var positions = this.convertToWorldSpace:new CGPoint(0,0)] :CGPoint;
	var pos :CGPoint = absolutePosition();
	if( ! pos.equalToPoint ( lastPosition ) ) {
		
		for(i in 0...parallaxArray.length) {

			var point :CGPointObject = parallaxArray[i];
			var x :Float = -pos.x + pos.x * point.ratio.x + point.offset.x;
			var y :Float = -pos.y + pos.y * point.ratio.y + point.offset.y;			
			point.child.position = new CGPoint (x, y);
		}
		
		lastPosition = pos;
	}
	
	super.visit();
}

}




class CGPointObject
{
public var ratio :CGPoint;
public var offset :CGPoint;
public var child :CCNode;	// weak ref

public function new (ratio:CGPoint, offset:CGPoint)
{
	this.ratio = ratio;
	this.offset = offset;
}

}
