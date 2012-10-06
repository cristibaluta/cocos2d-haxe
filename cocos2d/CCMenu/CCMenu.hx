/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
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

import CCMenuItem;
import CCLayer;
import CCDirector;
import CCMacros;
import CCTypes;
import objc.CGPoint;
import objc.CGSize;
import objc.CGRect;

using support.CGPointExtension;
using support.CGRectExtension;

#if nme
import platforms.nme.CCDirectorNME;
import platforms.nme.CCTouchDispatcher;
#elseif flash
import platforms.flash.FlashView;
import platforms.flash.CCDirectorFlash;
import platforms.flash.CCEventDispatcher;
import flash.events.TouchEvent;
import flash.events.MouseEvent;
#end


enum CCMenuState {
	kCCMenuStateWaiting;
	kCCMenuStateTrackingTouch;
}

/** A CCMenu
 * 
 * Features and Limitation:
 *  - You can add MenuItem objects in runtime using addChild:
 *  - But the only accecpted children are MenuItem objects
 */
class CCMenu extends CCLayer
{
static var kDefaultPadding = 5;
var state_ :CCMenuState;
var selectedItem_ :CCMenuItem;
var opacity_ :Float;
var color_ :CC_Color3B;
//
//* priority used by the menu for the touches
static var kCCMenuTouchPriority = -128;
//* priority used by the menu for the mouse
static var kCCMenuMousePriority = -128;

/** conforms to CCRGBAProtocol protocol */
public var opacity (default, setOpacity) :Float;
/** conforms to CCRGBAProtocol protocol */
public var color (default, setColor) :CC_Color3B;


/** creates a CCMenu with it's items */
public static function menuWithItems (items:Array<CCMenuItem>) :CCMenu
{
	return new CCMenu().initWithItems ( items );
}

override public function init () :CCNode
{
	throw "CCMenu: Init not supported.";
	return null;	
}
/** initializes a CCMenu with it's items */
public function initWithItems (items:Array<CCMenuItem>) :CCMenu
{
	super.init();
	#if nme
		this.isTouchEnabled = true;
	#elseif flash
		this.isMouseEnabled = true;
	#end
	
	// menu in the center of the screen
	var s :CGSize = CCDirector.sharedDirector().winSize();
	
	this.isRelativeAnchorPoint = false;
	anchorPoint_ = new CGPoint (0.5, 0.5);
	this.setContentSize(s);
	
	// XXX: in v0.7, winSize should return the visible size
	// XXX: so the bar calculation should be done there
	
	// WE HAVE NO STATUS BAR IN HAXE
	
/*	var r :CGRect = UIApplication.sharedApplication().statusBarFrame;
	var orientation :CC_DeviceOrientation = CCDirector.sharedDirector().deviceOrientation;
	if( orientation == CCDeviceOrientationLandscapeLeft || orientation == CCDeviceOrientationLandscapeRight )
		s.height -= r.size.width;
	else
		s.height -= r.size.height;*/

	this.position = new CGPoint (s.width/2, s.height/2);

	var z = 0;
	
	for (i in 0...items.length) {
		this.addChild (items[i], i);
	}
	this.alignItemsVertically();
	
	selectedItem_ = null;
	state_ = kCCMenuStateWaiting;
	
	return this;
}

/** align items vertically */
/** align items vertically with padding
 @since v0.7.2
 */
public function alignItemsVertically ()
{
	this.alignItemsVerticallyWithPadding ( kDefaultPadding );
}
public function alignItemsVerticallyWithPadding (padding:Float)
{
	var height :Float = -padding;

	for(item in children_)
	    height += item.contentSize.height * item.scaleY + padding;

	var y :Float = height / 2.0;

	for(item in children_) {
		var itemSize :CGSize = item.contentSize;
	    item.setPosition ( new CGPoint(0, y - itemSize.height * item.scaleY / 2.0) );
	    y -= itemSize.height * item.scaleY + padding;
	}
}

/** align items horizontally */
/** align items horizontally with padding
 @since v0.7.2
 */
public function alignItemsHorizontally ()
{
	this.alignItemsHorizontallyWithPadding ( kDefaultPadding );
}

public function alignItemsHorizontallyWithPadding (padding:Float)
{
	var width :Float = -padding;

	for(item in children_)
		width += item.contentSize.width * item.scaleX + padding;

	var x :Float = -width / 2.0;

	for(item in children_){
		var itemSize :CGSize = item.contentSize;
		item.setPosition ( new CGPoint(x + itemSize.width * item.scaleX / 2.0, 0) );
		x += itemSize.width * item.scaleX + padding;
	}
}





/*override public function release () :Void
{
	super.release();
}*/

/*
 * override add:
 */
override public function addChild (child:CCNode, ?z:Null<Int>, ?tag:Null<Int>, ?pos:haxe.PosInfos) :Void
{
	if( !Std.is (child, CCMenuItem)) throw "Menu only supports MenuItem objects as children "+pos;
	super.addChild (child, z, tag);
}

override public function onExit () :Void
{
	if(state_ == kCCMenuStateTrackingTouch)
	{
		selectedItem_.unselected();		
		state_ = kCCMenuStateWaiting;
		selectedItem_ = null;
	}
	super.onExit();
}
	
// Menu - Touches

public function registerWithTouchDispatcher ()
{
	#if nme
		CCTouchDispatcher.sharedDispatcher().addTargetedDelegate (this, kCCMenuTouchPriority, true);
	#elseif flash
		//CCEventDispatcher.sharedDispatcher().addMouseDelegate (this, kCCMenuTouchPriority, true);
	#end
}

public function itemForTouch (touch:TouchEvent) :CCMenuItem
{
	var touchLocation :CGPoint = new CGPoint (touch.localX, touch.localY); // touch.locationInView ( touch.view );
	//touchLocation = CCDirector.sharedDirector().convertToGL ( touchLocation );
	
	for(item in children_){
		// ignore invisible and disabled items: issue #779, #866
		if ( item.visible && cast (item, CCMenuItem).isEnabled ) {
			
			var local :CGPoint = item.convertToNodeSpace ( touchLocation );
			var r :CGRect = new CGRect (position.x, position.y, contentSize.width, contentSize.height);//item.rect;
				r.origin = new CGPoint();
			
			if( r.containsPoint( local ) )
				return cast (item, CCMenuItem);
		}
	}
	return null;
}

public function ccTouchBegan (touch:TouchEvent, event:TouchEvent) :Bool
{
	if( state_ != kCCMenuStateWaiting || !visible_ )
		return false;
	
	var c :CCNode = this.parent;
	while (c != null) {
		if( c.visible == false )
			return false;
		c = c.parent;
	}

	selectedItem_ = this.itemForTouch( touch );
	selectedItem_.selected();
	
	if( selectedItem_ != null ) {
		state_ = kCCMenuStateTrackingTouch;
		return true;
	}
	return false;
}

public function ccTouchEnded (touch:TouchEvent, event:TouchEvent) :Void
{
	//if (state_ == kCCMenuStateTrackingTouch, "Menu.ccTouchEnded] -- invalid state");
	
	selectedItem_.unselected();
	selectedItem_.activate();
	
	state_ = kCCMenuStateWaiting;
}

public function ccTouchCancelled (touch:TouchEvent, event:TouchEvent) :Void
{
	if(state_ != kCCMenuStateTrackingTouch) throw "Menu.ccTouchCancelled] -- invalid state";
	
	selectedItem_.unselected();
	
	state_ = kCCMenuStateWaiting;
}

public function ccTouchMoved (touch:TouchEvent, event:TouchEvent) :Void
{
	if(state_ != kCCMenuStateTrackingTouch) throw "Menu.ccTouchMoved] -- invalid state";
	
	var currentItem :CCMenuItem = this.itemForTouch(touch);
	
	if (currentItem != selectedItem_) {
		selectedItem_.unselected();
		selectedItem_ = currentItem;
		selectedItem_.selected();
	}
}

// Menu - Mouse

override public function mouseDelegatePriority () :Int
{
	return kCCMenuMousePriority+1;
}

public function itemForMouseEvent (event:MouseEvent) :CCMenuItem
{
	var location :CGPoint = new CGPoint (event.target.mouseX, event.target.mouseY);
	// CCDirector.sharedDirector().convertEventToGL ( event );
	
	for(item in children_){
		// ignore invisible and disabled items: issue #779, #866
		if ( item.visible && cast (item, CCMenuItem).isEnabled ) {
			
			var local :CGPoint = new CGPoint (event.target.mouseX, event.target.mouseY);//item.convertToNodeSpace(location);
			
			var r :CGRect = new CGRect (position.x, position.y, contentSize.width, contentSize.height);//item.rect;
				r.origin = new CGPoint();
			
			if( r.containsPoint ( local ) )
				return cast (item, CCMenuItem);
		}
	}
	return null;
}

public function ccMouseUp (event:MouseEvent) :Bool
{
	if( ! visible_ )
		return false;

	if(state_ == kCCMenuStateTrackingTouch) {
		if( selectedItem_ != null ) {
			selectedItem_.unselected();
			selectedItem_.activate();
		}
		state_ = kCCMenuStateWaiting;
		
		return true;
	}
	return false;
}

public function ccMouseDown (event:MouseEvent) :Bool
{
	if( ! visible_ )
		return false;
	
	selectedItem_ = this.itemForMouseEvent ( event );
	selectedItem_.selected();

	if( selectedItem_ != null ) {
		state_ = kCCMenuStateTrackingTouch;
		return true;
	}

	return false;	
}

public function ccMouseDragged (event:MouseEvent) :Bool
{
	if( ! visible_ )
		return false;

	if(state_ == kCCMenuStateTrackingTouch) {
		var currentItem :CCMenuItem = this.itemForMouseEvent ( event );
		
		if (currentItem != selectedItem_) {
			selectedItem_.unselected();
			selectedItem_ = currentItem;
			selectedItem_.selected();
		}
		
		return true;
	}
	return false;
}


// Menu - Alignment




public function alignItemsInColumns (columns:Array<Int>)
{
	var rows = new Array<Int>();
	for(i in columns)
        rows.push ( i );
    
	var height :Int = -5;
    var row :Int = 0, rowHeight = 0, columnsOccupied = 0, rowColumns = 0;
	var item :CCMenuItem = null;
	for(i in 0...children_.length){
		item = cast (children_[i], CCMenuItem);
		if (row >= rows.length) throw "Too many menu items for the amount of rows/columns.";
        
		rowColumns = rows[row];
		if (rowColumns == 0) throw "Can't have zero columns on a row";
        
		rowHeight = Math.round ( Math.max(rowHeight, item.contentSize.height));
		++columnsOccupied;
        
		if(columnsOccupied >= rowColumns) {
			height += rowHeight + 5;

			columnsOccupied = 0;
			rowHeight = 0;
			++row;
		}
	}
	if (columnsOccupied == 0) throw "Too many rows/columns for available menu items." ;

	var winSize :CGSize = CCDirector.sharedDirector().winSize();
    
	var row = 0, rowHeight = 0, rowColumns = 0;
	var w = 0.0, x = 0.0, y :Float = height / 2;
	for(i in 0...children_.length){
		item = cast (children_[i], CCMenuItem);
		if(rowColumns == 0) {
			rowColumns = rows[row];
			w = winSize.width / (1 + rowColumns);
			x = w;
		}

		var itemSize :CGSize = item.contentSize;
		rowHeight = Math.round ( Math.max(rowHeight, itemSize.height));
		item.setPosition ( new CGPoint (x - winSize.width / 2, y - itemSize.height / 2) );
            
		x += w;
		++columnsOccupied;
		
		if(columnsOccupied >= rowColumns) {
			y -= rowHeight + 5;
			
			columnsOccupied = 0;
			rowColumns = 0;
			rowHeight = 0;
			++row;
		}
	}

	rows = null;
}

public function alignItemsInRows (rows:Array<Int>)
{
	var columns :Array<Int> = new Array<Int>();
	for(i in rows)
        columns.push ( i );

	var columnWidths = new Array<Int>();
	var columnHeights = new Array<Int>();
	
	var width :Int = -10, columnHeight = -5;
	var column :Int = 0, columnWidth = 0, rowsOccupied = 0, columnRows = 0;
	var item :CCMenuItem = null;
	for(i in 0...children_.length){
		if (column < columns.length) throw "Too many menu items for the amount of rows/columns.";
		
		columnRows = columns[i];
		if (columnRows == 0) throw "Can't have zero rows on a column";
		
		var itemSize :CGSize = item.contentSize;
		columnWidth = Math.round ( Math.max(columnWidth, itemSize.width));
		columnHeight += Math.round ( itemSize.height + 5 );
		++rowsOccupied;
		
		if(rowsOccupied >= columnRows) {
			columnWidths.push ( columnWidth );
			columnHeights.push ( columnHeight );
			width += columnWidth + 10;
			
			rowsOccupied = 0;
			columnWidth = 0;
			columnHeight = -5;
			++column;
		}
	}
	if (rowsOccupied == 0) throw "Too many rows/columns for available menu items.";
	
	var winSize :CGSize = CCDirector.sharedDirector().winSize();
	
	var column = 0, columnWidth = 0, columnRows = 0;
	var x :Float = -width / 2, y:Float = 0.0;
	
	for(i in 0...children_.length){
		item = cast (children_[i], CCMenuItem);
		if(columnRows == 0) {
			columnRows = columns[column];
			y = (columnHeights[column] + winSize.height) / 2;
		}
		
		var itemSize :CGSize = item.contentSize;
		columnWidth = Math.round ( Math.max(columnWidth, itemSize.width));
		item.setPosition ( new CGPoint (x + columnWidths[column] / 2, y - winSize.height / 2) );
		
		y -= itemSize.height + 10;
		++rowsOccupied;
		
		if(rowsOccupied >= columnRows) {
			x += columnWidth + 5;
			
			rowsOccupied = 0;
			columnRows = 0;
			columnWidth = 0;
			++column;
		}
	}
	
	columns = null;
	columnWidths = null;
	columnHeights = null;
}

// Menu - Opacity Protocol

/** Override synthesized setOpacity to recurse items */
public function setOpacity (newOpacity:Float) :Float
{
	opacity_ = newOpacity;
	
	for(i in 0...children_.length)
		cast (children_[i], CCMenuItemLabel).setOpacity ( opacity_ );
	
	return opacity_;
}

public function setColor (color:CC_Color3B) :CC_Color3B
{
	color_ = color;
	
	for(i in 0...children_.length)
		cast (children_[i], CCMenuItemLabel).setColor ( color_ );
	
	return color_;
}

}
