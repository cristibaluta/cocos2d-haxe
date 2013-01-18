/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Valentin Milea
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
 */
package cocos;


import cocos.CCGrid;
import cocos.CCDirector;
import cocos.action.CCAction;
import cocos.action.CCActionManager;
import cocos.CCCamera;
import cocos.CCScheduler;
import cocos.CCConfig;
import cocos.CCMacros;
using cocos.support.CGPointExtension;
using cocos.support.CGRectExtension;
using cocos.support.CGSizeExtension;
using cocos.support.CCArrayExtension;
import cocos.support.CGPoint;
import cocos.support.CGSize;
import cocos.support.CGRect;
import cocos.support.CGAffineTransform;
#if flash
import cocos.platform.flash.CCDirectorFlash;
typedef Sprite = flash.display.Sprite;
#elseif nme
import cocos.platform.nme.CCDirectorNME;
typedef Sprite = nme.display.Sprite;
#end


class CCNode
{

inline static var kCCNodeTagInvalid = -1;

var position_ :CGPoint;
var positionInPixels_ :CGPoint;
var anchorPointInPixels_ :CGPoint;
// anchor point normalized
var anchorPoint_ :CGPoint;
	// If true the transformations will be relative to (-transform.x, -transform.y).
	// Sprites, Labels and any other "small" object uses it.
	// Scenes, Layers and other "whole screen" object don't use it.
var isRelativeAnchorPoint_ :Bool;
var contentSize_ :CGSize;
var contentSizeInPixels_ :CGSize;

// transform
var transform_ :CGAffineTransform;
var inverse_ :CGAffineTransform;

var vertexZ_ :Float;// openGL real Z vertex
var camera_ :CCCamera;
public var camera (getCamera, null) :CCCamera;
public var children_ :Array<CCNode>;// array of children
public var parent :CCNode;// weakref to parent
var userData_ :Void;
var visible_ :Bool;

// To reduce memory, place Bools that are not properties here:
var isTransformDirty_ :Bool;
var isInverseDirty_ :Bool;

//public var children (default, setChildren) :CCNode;
public var visible (getVisible, setVisible) :Bool;
public var grid :CCGridBase;
public var zOrder :Int;
public var tag :Int;// a tag. any number you want to assign to the node
public var vertexZ (default, setVertexZ) :Float;
public var isRunning :Bool;
public var userData :Void;
public var view_ :Sprite;

// CCNode - Transform related properties

public var rotation (default, setRotation) :Float;
public var scaleX (default, setScaleX) :Float;
public var scaleY (default, setScaleY) :Float;
public var skewX (default, setSkewX) :Null<Float>;
public var skewY (default, setSkewY) :Null<Float>;
public var position (getPosition, setPosition) :CGPoint;
public var positionInPixels (getPositionInPixels, setPositionInPixels) :CGPoint;
public var anchorPoint (default, setAnchorPoint) :CGPoint;
public var anchorPointInPixels (getAnchorPointInPixels, null) :CGPoint;
// untransformed size of the node
public var contentSize (getContentSize, setContentSize) :CGSize;
public var contentSizeInPixels (getContentSizeInPixels, setContentSizeInPixels) :CGSize;
public var isRelativeAnchorPoint (default, setIsRelativeAnchorPoint) :Bool;



public function new () {
	view_ = new Sprite();
/*	view_.graphics.beginFill (0xffaa99, 0.8);
	view_.graphics.drawRect (0, 0, 100, 100);
	view_.graphics.endFill();*/
}

public function setSkewX(newSkewX:Null<Float>):Null<Float>
{
	skewX = newSkewX;
	isTransformDirty_ = isInverseDirty_ = true;
#if CC_NODE_TRANSFORM_USING_AFFINE_MATRIX
	isTransformGLDirty_ = true;
#end
	return skewX;
}

public function setSkewY (newSkewY:Null<Float>) :Null<Float>
{
	skewY = newSkewY;
	isTransformDirty_ = isInverseDirty_ = true;
#if CC_NODE_TRANSFORM_USING_AFFINE_MATRIX
	isTransformGLDirty_ = true;
#end
	return skewY;
}


// getters explicit, setters explicit

function setRotation (newRotation:Float) :Float
{
	rotation = newRotation;
	isTransformDirty_ = isInverseDirty_ = true;
#if CC_NODE_TRANSFORM_USING_AFFINE_MATRIX
	isTransformGLDirty_ = true;
#end
	return rotation;
}

function setScaleX (newScaleX:Float) :Float
{
	scaleX = newScaleX;
	isTransformDirty_ = isInverseDirty_ = true;
#if CC_NODE_TRANSFORM_USING_AFFINE_MATRIX
	isTransformGLDirty_ = true;
#end
	return scaleX;
}

function setScaleY (newScaleY:Float) :Float
{
	scaleY = newScaleY;
	isTransformDirty_ = isInverseDirty_ = true;
#if CC_NODE_TRANSFORM_USING_AFFINE_MATRIX
	isTransformGLDirty_ = true;
#end
	return scaleY;
}

public function setPosition (newPosition:CGPoint) :CGPoint
{
	trace("setPosition "+newPosition);
	position_ = newPosition;
	if( CCConfig.CC_CONTENT_SCALE_FACTOR == 1 )
		positionInPixels_ = position_;
	else
		positionInPixels_ = newPosition.mult ( CCConfig.CC_CONTENT_SCALE_FACTOR );
	
	// Prepare the view to reposition at the next frame
	isTransformDirty_ = isInverseDirty_ = true;
	
	return position_;
}
public function getPosition () :CGPoint
{
	trace("getPosition "+position_);
	return position_;
}

function setPositionInPixels (newPosition:CGPoint) :CGPoint
{trace("setPositionInPixels "+newPosition);
	positionInPixels_ = newPosition;

	if( CCConfig.CC_CONTENT_SCALE_FACTOR == 1 )
		position_ = positionInPixels_;
	else
		position_ = newPosition.mult ( 1/CCConfig.CC_CONTENT_SCALE_FACTOR );
	
	isTransformDirty_ = isInverseDirty_ = true;
	
	return positionInPixels_;
}
public function getPositionInPixels () :CGPoint
{
	return positionInPixels_;
}

function setIsRelativeAnchorPoint (newValue:Bool) :Bool
{
	isRelativeAnchorPoint_ = newValue;
	isTransformDirty_ = isInverseDirty_ = true;
#if CC_NODE_TRANSFORM_USING_AFFINE_MATRIX
	isTransformGLDirty_ = true;
#end
	return isRelativeAnchorPoint_;
}

function setAnchorPoint (point:CGPoint) :CGPoint
{
	if( ! point.equalToPoint (anchorPoint_) ) {
		anchorPoint_ = point;
		anchorPointInPixels_ = new CGPoint ( contentSizeInPixels.width * anchorPoint_.x, contentSizeInPixels.height * anchorPoint_.y );
		isTransformDirty_ = isInverseDirty_ = true;
#if CC_NODE_TRANSFORM_USING_AFFINE_MATRIX
		isTransformGLDirty_ = true;
#end
	}
	return point;
}
function getAnchorPointInPixels () :CGPoint
{
	return anchorPointInPixels_;
}

function setContentSize (size:CGSize) :CGSize
{
	if (size == null) throw "New contentSize must not be null";
	if( ! size.equalToSize ( contentSize_ ) ) {
		contentSize_ = size;
		
		if( CCConfig.CC_CONTENT_SCALE_FACTOR == 1 )
			contentSizeInPixels_ = contentSize_;
		else
			contentSizeInPixels_ = new CGSize ( size.width * CCConfig.CC_CONTENT_SCALE_FACTOR, size.height * CCConfig.CC_CONTENT_SCALE_FACTOR );
		
		anchorPointInPixels_ = new CGPoint ( contentSizeInPixels_.width * anchorPoint_.x, contentSizeInPixels_.height * anchorPoint_.y );
		isTransformDirty_ = isInverseDirty_ = true;
	}
	return size;
}
function getContentSize () :CGSize {
	return contentSize_;
}

function setContentSizeInPixels (size:CGSize) :CGSize
{
	if( ! size.equalToSize ( contentSizeInPixels_ ) ) {
		contentSizeInPixels_ = size;
		var w = size.width / CCConfig.CC_CONTENT_SCALE_FACTOR;
		var h = size.height / CCConfig.CC_CONTENT_SCALE_FACTOR;
		contentSize_ = new CGSize ( w, h );
		anchorPointInPixels_ = new CGPoint ( contentSizeInPixels_.width * anchorPoint_.x, contentSizeInPixels_.height * anchorPoint_.y );
		isTransformDirty_ = isInverseDirty_ = true;
	}
	return size;
}
function getContentSizeInPixels () :CGSize {
	return contentSizeInPixels_;
}

public function boundingBox() :CGRect
{
	return CCMacros.CC_RECT_PIXELS_TO_POINTS( boundingBoxInPixels() );
}

public function boundingBoxInPixels() :CGRect
{
	var rect :CGRect = new CGRect (0, 0, contentSizeInPixels.width, contentSizeInPixels.height);
		rect.applyAffineTransform ( nodeToParentTransform() );
	return rect;
}

function setVertexZ (vertexZ:Float) :Float
{
	return vertexZ_ = vertexZ * CCConfig.CC_CONTENT_SCALE_FACTOR;
}

public function getVertexZ () :Float
{
	return vertexZ_ / CCConfig.CC_CONTENT_SCALE_FACTOR;
}

public function getScale () :Float
{
	if (scaleX != scaleY) throw "CCNode#scale. ScaleX != ScaleY. Don't know which one to return";
	return scaleX;
}

function setScale (s:Float) :Float
{
	scaleX = scaleY = s;
	isTransformDirty_ = isInverseDirty_ = true;
	
	return s;
}
function getVisible () :Bool {
	return visible_;
}
function setVisible (v:Bool) :Bool {
	return visible_ = v;
}


/**
 *  CCNode - Init & cleanup
 **/

public static function node () :CCNode
{
	return new CCNode().init();
}

public function init () :CCNode
{
	trace("init CCNode");
	isRunning = false;
	
	skewX = skewY = 0.0;
	rotation = 0.0;
	scaleX = scaleY = 1.0;
	positionInPixels_ = position_ = new CGPoint(0,0);
	anchorPointInPixels_ = anchorPoint_ = new CGPoint(0,0);
	contentSizeInPixels_ = contentSize_ = new CGSize(0,0);
	// "whole screen" objects. like Scenes and Layers, should set isRelativeAnchorPoint to NO
	isRelativeAnchorPoint_ = true;
	isTransformDirty_ = isInverseDirty_ = true;
	
	vertexZ_ = 0;
	grid = null;
	visible = true;
	tag = kCCNodeTagInvalid;
	zOrder = 0;
	camera_ = null;// lazy alloc
	children_ = null;// children (lazy allocs)
	userData_ = null;// userData is always inited as null
	parent = null;//initialize parent to null
	
	return this;
}

public function cleanup () :Void
{
	// actions
	stopAllActions();
	unscheduleAllSelectors();
	
	// timers
	if (children_ != null)
		children_.makeObjectsPerformSelector ( cleanup );
}

public function toString () :String
{
	return "CCNode | Tag = "+tag;
}

public function release () :Void
{
	trace("cocos2d: releaseing "+ this);
	
	// attributes
	camera_.release();
	grid.release();
	
	// children
	for (child in children_)
		child.parent = null;
	
	children_ = null;
}

/**
*	CCNode Composition
*/

function childrenAlloc () :Void
{
	children_ = new Array<CCNode>();
}

// camera: lazy alloc
function getCamera () :CCCamera
{
	if( camera_ == null ) {
		camera_ = new CCCamera().init();
		
		// by default, center camera at the Sprite's anchor point
		//		camera_.setCenterX:anchorPointInPixels_.x centerY:anchorPointInPixels_.y centerZ:0();
		//		camera_.setEyeX:anchorPointInPixels_.x eyeY:anchorPointInPixels_.y eyeZ:1();
		
		//		camera_.setCenterX:0 centerY:0 centerZ:0();
		//		camera_.setEyeX:0 eyeY:0 eyeZ:1();
	}
	
	return camera_;
}

public function getChildByTag (aTag:Int) :CCNode
{
	if (aTag == kCCNodeTagInvalid) throw "Invalid tag";
	for( node in children_ ) {
		if( node.tag == aTag )
			return node;
	}
	// not found
	return null;
}

/* "add" logic MUST only be on this method
 * If a class want's to extend the 'addChild' behaviour it only needs
 * to override this method
 */
public function addChild (child:CCNode, ?z:Null<Int>, ?tag:Null<Int>, ?pos:haxe.PosInfos) :Void
{
	if (child == null) throw ("Argument must be non-null");
	if (child.parent != null) throw ("child already added. It can't be added again: "+pos);
	
	if (z == null)
		z = child.zOrder;
	if (tag == null)
		tag = child.tag;
	if (children_ == null)
		childrenAlloc();
	
	insertChild (child, z);
	
	child.tag = tag;
	child.parent = this;
	
	if( isRunning ) {
		child.onEnter();
		child.onEnterTransitionDidFinish();
	}
}

public function removeFromParentAndCleanup (cleanup:Bool)
{
	parent.removeChild (this, cleanup);
}

/* "remove" logic MUST only be on this method
 * If a class want's to extend the 'removeChild' behavior it only needs
 * to override this method
 */
public function removeChild (child:CCNode, cleanup:Bool) :Void
{
	// explicit null handling
	if (child == null)
		return;
	
	if (children_.containsObject(child) )
		this.detachChild (child, cleanup);
}

public function removeChildByTag (aTag:Int, cleanup:Bool) :Void
{
	//if (aTag != kCCNodeTagInvalid) throw "Invalid tag";
	var child:CCNode = this.getChildByTag ( aTag );
	
	if (child == null)
		trace("cocos2d: removeChildByTag: child not found!");
	else
		this.removeChild (child, cleanup);
}

public function removeAllChildrenWithCleanup (cleanup:Bool)
{
	// not using detachChild improves speed here
	var c:CCNode;
	for (c in children_)
	{
		// IMPORTANT:
		//  -1st do onExit
		//  -2nd cleanup
		if (isRunning)
			c.onExit();
		
		if (cleanup)
			c.cleanup();
		
		// set parent null at the end (issue #476)
		c.parent = null;
	}
	
	children_ = [];
}

function detachChild (child:CCNode, doCleanup:Bool) :Void
{
	// IMPORTANT:
	//  -1st do onExit
	//  -2nd cleanup
	if (isRunning)
		child.onExit();
	
	// If you don't do cleanup, the child's actions will not get removed and the
	// its scheduledSelectors_ dict will not get released!
	if (doCleanup)
		child.cleanup();
	
	// set parent null at the end (issue #476)
	child.parent = null;
	children_.remove ( child );
}

// used internally to alter the zOrder variable. DON'T call this method manually
function _setZOrder (z:Int) :Void
{
	zOrder = z;
}

// helper used by reorderChild & add
public function insertChild (child:CCNode, z:Int)
{
	var index=0;
	var a:CCNode = children_.lastObject();
	
	// quick comparison to improve performance
	if (a == null || a.zOrder <= z)
		children_.push ( child );
	
	else
	{
		for (a in children_) {
			if ( a.zOrder > z ) {
				children_.insert (index, child);
				break;
			}
			index++;
		}
	}
	
	child._setZOrder ( z );
}

function reorderChild (child:CCNode, z:Int) :Void
{
	if ( child != null ) throw ("Child must be non-null");
	
	children_.removeObject ( child );
	
	this.insertChild (child, z);
	
	child.release();
}




/**
 *  CCNode Draw
 **/

public function draw () :Void
{
	//trace("DRAW");
	// override me
	// Only use this function to draw your staff.
	// DON'T draw your stuff outside this method
/*	trace(CCDirector.sharedDirector().view);
	trace(CCDirector.sharedDirector().view.width);
	trace(CCDirector.sharedDirector().view.height);*/
	//trace("view_ = "+this.view_+" -> "+view_.width+"x"+view_.height);
}

public function visit () :Void
{
	//trace("\n-------------------- visit ----------- ");trace(toString());
	// quick return if not visible
	if (!visible)
		return;
	
	if (grid != null && grid.active) {
		grid.beforeDraw();
		this.transformAncestors();
	}

	this.transform();
	
	if (children_ != null) {
		var arrayData :Array<CCNode> = children_;
		
		// draw children zOrder < 0
		for(i in 0...arrayData.length) {
			var child:CCNode = arrayData[i];
			if ( child.zOrder < 0 )
				child.visit();
			else
				break;
		}
		
		// this draw
		this.draw();
		
		// draw children zOrder >= 0
		for(i in 0...arrayData.length) {
			var child :CCNode = arrayData[i];
			child.visit();
		}

	} else {
		this.draw();
	}
	
	if (grid != null && grid.active)
		grid.afterDraw ( this );
}



// CCNode - Transformations

function transformAncestors () :Void
{
	if( parent != null ) {
		parent.transformAncestors();
		parent.transform();
	}
}

function transform () :Void
{
	//trace("transform "+isRelativeAnchorPoint_+", anchro "+anchorPointInPixels_+", position "+positionInPixels);
	//return;
	// transformations
	// BEGIN original implementation
	// 
	// translate
	if ( isRelativeAnchorPoint_ && (anchorPointInPixels_.x != 0 || anchorPointInPixels_.y != 0 ) ) {
		view_.x = RENDER_IN_SUBPIXEL(-anchorPointInPixels_.x);
		view_.y = RENDER_IN_SUBPIXEL(-anchorPointInPixels_.y);
	}
	if (anchorPointInPixels_.x != 0 || anchorPointInPixels_.y != 0) {
		view_.x = RENDER_IN_SUBPIXEL(positionInPixels.x - anchorPointInPixels_.x);
		view_.y = RENDER_IN_SUBPIXEL(positionInPixels.y - anchorPointInPixels_.y);//, vertexZ_);
/*	trace(view_.x);
	trace(view_.y);*/
	}
	else if ( positionInPixels.x != 0 || positionInPixels.y != 0 || vertexZ_ != 0) {
		view_.x = RENDER_IN_SUBPIXEL(positionInPixels.x);
		view_.y = RENDER_IN_SUBPIXEL(positionInPixels.y);//, vertexZ_ );
	}
	
	// rotate
	if (rotation != 0.0 ) {
		view_.rotation = rotation;
	}
	
	// skew
	if (skewX != 0.0 || skewY != 0.0) {
/*		var skewMatrix :CGAffineTransform = CGAffineTransformMake( 1.0, tanf(CC_DEGREES_TO_RADIANS(skewY)), tanf(CC_DEGREES_TO_RADIANS(skewX)), 1.0, 0.0, 0.0 );
		Float	glMatrix[16();
		CGAffineToGL(&skewMatrix, glMatrix);															 
		glMultMatrixf(glMatrix);*/
	}
	
	// scale
	if (scaleX != 1.0 || scaleY != 1.0) {
		view_.scaleX = scaleX;
		view_.scaleY = scaleY;
	}
	
	if (camera_ != null && !(grid != null && grid.active))
		camera_.locate();
	
	// restore and re-position point
/*	if (anchorPointInPixels_.x != 0.0 || anchorPointInPixels_.y != 0.0) {
		view_.x = RENDER_IN_SUBPIXEL(-anchorPointInPixels_.x);
		view_.y = RENDER_IN_SUBPIXEL(-anchorPointInPixels_.y);//, 0);
	}*/
	//
	// END original implementation
}



// CCNode SceneManagement

public function onEnter () :Void
{
	children_.makeObjectsPerformSelector ( onEnter );
	this.resumeSchedulerAndActions();
	
	isRunning = true;
}

public function onEnterTransitionDidFinish () :Void
{
	children_.makeObjectsPerformSelector ( onEnterTransitionDidFinish );
}

public function onExit () :Void
{
	this.pauseSchedulerAndActions();
	isRunning = false;
	
	children_.makeObjectsPerformSelector ( onExit );
}

// CCNode Actions

public function runAction (action:CCAction) :CCAction
{
	if (action == null) throw "Argument must be non-null";
	CCActionManager.sharedManager().addAction (action, this, !isRunning);
	return action;
}

public function stopAllActions () :Void
{
	CCActionManager.sharedManager().removeAllActionsFromTarget ( this );
}

public function stopAction (action:CCAction) :Void
{
	CCActionManager.sharedManager().removeAction ( action );
}

public function stopActionByTag (aTag:Int)
{
	//if (aTag != kCCActionTagInvalid) throw "Invalid tag";
	CCActionManager.sharedManager().removeActionByTag (aTag, this);
}

public function getActionByTag (aTag:Int) :CCAction
{
	//if (aTag != kCCActionTagInvalid) throw "Invalid tag";
	return CCActionManager.sharedManager().getActionByTag (aTag, this);
}

public function numberOfRunningActions () :Int
{
	return CCActionManager.sharedManager().numberOfRunningActionsInTarget(this);
}



// CCNode - Scheduler

function scheduleUpdate () :Void
{
	this.scheduleUpdateWithPriority ( 0 );
}

function scheduleUpdateWithPriority (priority:Int)
{
	CCScheduler.sharedScheduler().scheduleUpdateForTarget (this, priority, !isRunning);
}

function unscheduleUpdate () :Void
{
	CCScheduler.sharedScheduler().unscheduleUpdateForTarget ( this );
}

public function schedule (selector:Dynamic, ?interval:Float=0) :Void
{
	if( selector == null) throw "Argument must be non-null";
	if( interval <0) throw "Arguemnt must be positive";
	
	CCScheduler.sharedScheduler().scheduleSelector (selector, this, interval, !isRunning);
}

public function unschedule (selector:Dynamic)
{
	// explicit null handling
	if (selector == null)
		return;
	
	CCScheduler.sharedScheduler().unscheduleSelector (selector, this );
}

function unscheduleAllSelectors () :Void
{
	CCScheduler.sharedScheduler().unscheduleAllSelectorsForTarget ( this );
}
public function resumeSchedulerAndActions () :Void
{
	CCScheduler.sharedScheduler().resumeTarget ( this );
	CCActionManager.sharedManager().resumeTarget ( this );
}

public function pauseSchedulerAndActions () :Void
{
	CCScheduler.sharedScheduler().pauseTarget ( this );
	CCActionManager.sharedManager().pauseTarget ( this );
}

// CCNode Transform

public function nodeToParentTransform () :CGAffineTransform
{
	if ( isTransformDirty_ ) {
		
		transform_ = new CGAffineTransform().identity();
		
		if ( !isRelativeAnchorPoint_ && !anchorPointInPixels_.equalToPoint ( new CGPoint(0,0) ))
			transform_.translate (anchorPointInPixels_.x, anchorPointInPixels_.y);

		if( ! positionInPixels.equalToPoint ( new CGPoint(0,0) ))
			transform_.translate (positionInPixels.x, positionInPixels.y);
		
		if( rotation != 0 )
			transform_.rotate (-CCMacros.CC_DEGREES_TO_RADIANS(rotation));
		
		if( skewX != 0 || skewY != 0 ) {
			// create a skewed coordinate system
			var skew = new CGAffineTransform (1.0, Math.tan(CCMacros.CC_DEGREES_TO_RADIANS(skewY)), Math.tan(CCMacros.CC_DEGREES_TO_RADIANS(skewX)), 1.0, 0.0, 0.0);
			// apply the skew to the transform
			transform_.concat ( skew );
		}
		
		if( ! (scaleX == 1 && scaleY == 1) )
			transform_.scale (scaleX, scaleY);
		
		if( ! anchorPointInPixels_.equalToPoint ( new CGPoint(0,0) ) )
			transform_.translate (-anchorPointInPixels_.x, -anchorPointInPixels_.y);
		
		isTransformDirty_ = false;
	}
	
	return transform_;
}

public function parentToNodeTransform () :CGAffineTransform
{
	if ( isInverseDirty_ ) {
		inverse_ = this.nodeToParentTransform();
		inverse_.invert();
		isInverseDirty_ = false;
	}
	
	return inverse_;
}

public function nodeToWorldTransform () :CGAffineTransform
{
	var t :CGAffineTransform = this.nodeToParentTransform();
	var p : CCNode = parent;
	
	while (p != null) {
		t.concat ( p.nodeToParentTransform() );
		p = p.parent;
	}
	
	return t;
}

public function worldToNodeTransform () :CGAffineTransform
{
	var m :CGAffineTransform = this.nodeToWorldTransform();
	m.invert();
	return m;
}

public function convertToNodeSpace (worldPoint:CGPoint) :CGPoint
{
	var ret :CGPoint = null;
	if( CCConfig.CC_CONTENT_SCALE_FACTOR == 1 )
		ret = worldPoint.applyAffineTransform ( this.worldToNodeTransform() );
	else {
		ret = worldPoint.mult ( CCConfig.CC_CONTENT_SCALE_FACTOR );
		ret = ret.applyAffineTransform ( this.worldToNodeTransform() );
		ret = ret.mult ( 1/CCConfig.CC_CONTENT_SCALE_FACTOR );
	}
	
	return ret;
}

public function convertToWorldSpace (nodePoint:CGPoint) :CGPoint
{
	var ret :CGPoint = null;
	if( CCConfig.CC_CONTENT_SCALE_FACTOR == 1 )
		ret = nodePoint.applyAffineTransform ( this.nodeToWorldTransform() );
	else {
		ret = nodePoint.mult ( CCConfig.CC_CONTENT_SCALE_FACTOR );
		ret = ret.applyAffineTransform ( this.nodeToWorldTransform() );
		ret = ret.mult ( 1/CCConfig.CC_CONTENT_SCALE_FACTOR );
	}
	
	return ret;
}

public function convertToNodeSpaceAR (worldPoint:CGPoint) :CGPoint
{
	var nodePoint :CGPoint = this.convertToNodeSpace ( worldPoint );
	var anchorInPoints :CGPoint;
	if( CCConfig.CC_CONTENT_SCALE_FACTOR == 1 )
		anchorInPoints = anchorPointInPixels_;
	else
		anchorInPoints = anchorPointInPixels_.mult ( 1/CCConfig.CC_CONTENT_SCALE_FACTOR );
	   
	return nodePoint.sub ( anchorInPoints );
}

public function convertToWorldSpaceAR (nodePoint:CGPoint) :CGPoint
{
	var anchorInPoints:CGPoint;
	if( CCConfig.CC_CONTENT_SCALE_FACTOR == 1 )
		anchorInPoints = anchorPointInPixels_;
	else
		anchorInPoints = anchorPointInPixels_.mult ( 1/CCConfig.CC_CONTENT_SCALE_FACTOR );
	
	nodePoint = nodePoint.add ( anchorInPoints );
	return this.convertToWorldSpace ( nodePoint );
}

public function convertToWindowSpace (nodePoint:CGPoint) :CGPoint
{
	return this.convertToWorldSpace ( nodePoint );
/*    var worldPoint:CGPoint = this.convertToWorldSpace ( nodePoint );
	return CCDirector.sharedDirector().convertToUI ( worldPoint );*/
}

#if nme
// convenience methods which take a UITouch instead of CGPoint

public function convertTouchToNodeSpace (touch:nme.events.TouchEvent) :CGPoint
{
	var point :CGPoint = new CGPoint (touch.localX, touch.localY);
	return this.convertToNodeSpace( point );
}
public function convertTouchToNodeSpaceAR (touch:nme.events.TouchEvent) :CGPoint
{
	var point :CGPoint = new CGPoint (touch.localX, touch.localY);
	return this.convertToNodeSpaceAR( point );
}
#end

inline function RENDER_IN_SUBPIXEL (v:Float) :Float {
	return Std.int ( v );
}

}
