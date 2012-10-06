//
//  Cocos2d
//
//  Created by Baluta Cristian on 2011-10-12.
//  Copyright (c) 2011 ralcr.com. All rights reserved.
//
/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the x;Softwarex;), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED x;AS ISx;, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

//
// all cocos2d include files
//
import CCConfig;	// should be included first

import CCActionManager;
import CCAction;
import CCActionInstant;
import CCActionInterval;
import CCActionEase;
import CCActionCamera;
import CCActionTween;
import CCActionTiledGrid;
//import CCActionGrid3D;
import CCActionGrid;
import CCProgressTo;
//import CCActionPageTurn3D;

import CCAnimation;
import CCAnimationCache;
import CCSprite;
import CCSpriteFrame;
import CCSpriteBatchNode;
import CCSpriteFrameCache;

import CCLabelTTF;
import CCLabelBMFont;
import CCLabelAtlas;

import CCParticleSystem;
//import CCParticleSystemPoint;
//import CCParticleSystemQuad;
//import CCParticleExamples;

import CCTexture2D;
import CCTextureCache;
import CCTextureAtlas;

import CCTransitionScene;
//import CCTransitionPageTurn;
//import CCTransitionRadial;

/*import CCTMXTiledMap;
import CCTMXLayer;
import CCTMXObjectGroup;
import CCTMXXMLParser;*/

import CCLayer;
import CCMenu;
import CCMenuItem;
import CCDrawingPrimitives;
import CCScene;
import CCScheduler;
import CCCamera;
import CCNode;
import CCDirector;
import CCAtlasNode;
import CCGrabber;
import CCGrid;
import CCParallaxNode;
import CCRenderTexture;
import CCMotionStreak;
import CCConfiguration;

//
// cocos2d macros
//
import CCTypes;
import CCMacros;


// Platform common
//import platforms.CCGL;
//import platforms.CCNS;

#if nme
import platforms.flash.CCTouchDispatcher;
import platforms.flash.CCTouchDelegateProtocol;
import platforms.flash.CCTouchHandler;
#elseif flash
import platforms.flash.CCEventDispatcher;
import platforms.flash.FlashView;
import platforms.flash.CCDirectorFlash;
import platforms.flash.CCAssets;
#elseif js

#end

//
// cocos2d helper files
//
import support.CCArrayExtension;
import support.CCFileUtils;
import support.CCUtils;
import objc.CGPoint;
import objc.CGSize;
import objc.CGRect;
import objc.NSDictionary;
/*
#if CC_ENABLE_PROFILERS
import support.CCProfiling;
#end
*/

class Cocos2d {
	public static function main(){}
	public static function cocos2dVersion() :String
	{
		return "cocos2d v1.0.1";
	}
}
