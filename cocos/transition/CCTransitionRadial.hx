/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Lam Pham
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
import cocos.CCDirector;
import cocos.CCTransitionRadial;
import cocos.CCRenderTexture;
import cocos.CCLayer;
import cocos.CCActionInstant;
import cocos.CCProgressTimer;
import cocos.support.CGPoint;
import cocos.support.CGSize;

using cocos.support.CGPointExtension;

// -
// Transition Radial CCW

class CCTransitionRadialCCW
{
static var kSceneRadial = 0xc001;
	
public function sceneOrder ()
{
	inSceneOnTop_ = false;
}

public function radialType () :CCProgressTimerType
{
	return kCCProgressTimerTypeRadialCCW;
}

public function onEnter ()
{
	super.onEnter();
	// create a transparent color layer
	// in which we are going to add our rendertextures
	var size:CGSize = CCDirector.sharedDirector().winSize();
		
	// create the second render texture for outScene
	var outTexture :CCRenderTexture = CCRenderTexture.renderTextureWithWidth (Math.round(size.width), Math.round(size.height));
	outTexture.sprite.anchorPoint = new CGPoint (0.5, 0.5);
	outTexture.position = new CGPoint (size.width/2, size.height/2);
	outTexture.anchorPoint = new CGPoint (0.5, 0.5);
	
	// render outScene to its texturebuffer
	outTexture.clear ( 0, 0, 0, 1 );
	outTexture.begin();
	outScene_.visit();
	outTexture.end();
	
	//	Since we've passed the outScene to the texture we don't need it.
	this.hideOutShowIn();
	
	//	We need the texture in RenderTexture.
	var outNode :CCProgressTimer = CCProgressTimer.progressWithTexture ( outTexture.sprite.texture );
	// but it's flipped upside down so we flip the sprite
	outNode.sprite.flipY = true;
	//	Return the radial type that we want to use
	outNode.type = this.radialType();
	outNode.percentage = 100.0;
	outNode.position = new CGPoint (size.width/2, size.height/2);
	outNode.anchorPoint = new CGPoint (0.5,0.5);
			
	// create the blend action
	var layerAction :CCActionInterval = CCSequence.actions (
									  CCProgressFromTo.actionWithDuration (duration_, 100.0, 0.0),
									  CCCallFunc.actionWithTarget (this, finish),
									  null);
	// run the blend action
	outNode.runAction ( layerAction );
	
	// add the layer (which contains our two rendertextures) to the scene
	this.addChild ( outNode, 2, kSceneRadial );
}

// clean up on exit
public function onExit ()
{
	// remove our layer and release all containing objects 
	this.removeChildByTag ( kSceneRadial, false );
	super.onExit();	
}
}

// -
// Transition Radial CW

class CCTransitionRadialCW
{
public function radialType () :CCProgressTimerType
{
	return kCCProgressTimerTypeRadialCW;
}
}
