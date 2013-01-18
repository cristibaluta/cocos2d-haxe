/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2011 Ricardo Quesada
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
package cocos.menu;

import cocos.CCNode;
import cocos.CCLabelTTF;
import cocos.CCLabelAtlas;
import cocos.action.CCActionInterval;
import cocos.CCSprite;
import cocos.support.CGRect;
import cocos.support.CGPoint;
using cocos.support.CGPointExtension;


private typedef NSInvocation = {
	target :Dynamic,
	selector :Dynamic
}

// -
// CCMenuItem
/** CCMenuItem base class
 *
 *  Subclass CCMenuItem (or any subclass) to create your custom CCMenuItem objects.
 */
class CCMenuItem extends CCNode
{
inline static var kCCItemSize = 32;
inline static var _fontSize :Int = kCCItemSize;
inline static var _fontName :String = "Marker Felt";
inline static var _fontNameRelease :Bool = false;
inline static var kCurrentItem :Int = 0xc0c05001;
inline static var kZoomActionTag :Int = 0xc0c05002;

var invocation_ :NSInvocation;
public var isEnabled :Bool;
public var isSelected :Bool;


/** Creates a CCMenuItem with a target/selector */
public static function itemWithTarget (r:Dynamic, s:Dynamic) :CCMenuItem
{
	return new CCMenuItem().initWithTarget (r, s);
}

/** Initializes a CCMenuItem with a target/selector */
public function initWithTarget (target:Dynamic, sel:Dynamic) :CCMenuItem
{
	super.init();
	
	anchorPoint_ = new CGPoint (0.5, 0.5);
	
	if( target != null && sel != null ) {
		invocation_ = {target:target, selector:sel};
	}
	
	isEnabled = true;
	isSelected = false;
	
	return this;
}


/** Returns the outside box in points */
public function rect () :CGRect
{
	return new CGRect( position_.x - contentSize_.width*anchorPoint_.x,
					  position_.y - contentSize_.height*anchorPoint_.y,
					  contentSize_.width, contentSize_.height);	
}

/** Activate the item */
public function activate ()
{
	if(isEnabled)
		Reflect.callMethod (invocation_.target, invocation_.selector, []);
}

/** The item was selected (not activated), similar to "mouse-over" */
public function selected ()
{
	isSelected = true;
}

/** The item was unselected */
public function unselected ()
{
	isSelected = false;
}

override public function init () :CCNode
{
	throw "MenuItemInit: Init not supported.";
	this.release();
	return null;
}


override public function release () :Void
{
	invocation_ = null;
	super.release();
}

}
