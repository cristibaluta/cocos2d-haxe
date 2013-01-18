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
package cocos;


//
// all cocos2d include files
//
import cocos.CCConfig;	// should be included first

import cocos.action.CCActionManager;
import cocos.action.CCAction;
import cocos.action.CCActionInstant;
import cocos.action.CCActionInterval;
import cocos.action.CCActionEase;
import cocos.action.CCActionCamera;
import cocos.action.CCActionTween;
import cocos.action.CCActionTiledGrid;
//import cocos.action.CCActionGrid3D;
import cocos.action.CCActionGrid;
import cocos.action.CCProgressTo;
//import cocos.action.CCActionPageTurn3D;

import cocos.CCAnimation;
import cocos.CCAnimationCache;
import cocos.CCSprite;
import cocos.CCSpriteFrame;
import cocos.CCSpriteBatchNode;
import cocos.CCSpriteFrameCache;

import cocos.CCLabelTTF;
import cocos.CCLabelBMFont;
import cocos.CCLabelAtlas;

import cocos.particle.CCParticleSystem;
//import cocos.particle.CCParticleSystemPoint;
//import cocos.particle.CCParticleSystemQuad;
//import cocos.particle.CCParticleExamples;

import cocos.CCTexture2D;
import cocos.CCTextureCache;
import cocos.CCTextureAtlas;

import cocos.transition.CCTransitionScene;
//import cocos.transition.CCTransitionPageTurn;
//import cocos.transition.CCTransitionRadial;

/*import cocos.CCTMXTiledMap;
import cocos.CCTMXLayer;
import cocos.CCTMXObjectGroup;
import cocos.CCTMXXMLParser;*/

import cocos.CCLayer;
import cocos.menu.CCMenu;
import cocos.menu.CCMenuItem;
import cocos.CCDrawingPrimitives;
import cocos.CCScene;
import cocos.CCScheduler;
import cocos.CCCamera;
import cocos.CCNode;
import cocos.CCDirector;
import cocos.CCAtlasNode;
import cocos.CCGrabber;
import cocos.CCGrid;
import cocos.CCParallaxNode;
import cocos.CCRenderTexture;
import cocos.CCMotionStreak;
import cocos.CCConfiguration;

//
// cocos2d macros
//
import cocos.CCTypes;
import cocos.CCMacros;


// Platform common
//import cocos.platform.CCGL;
//import cocos.platform.CCNS;

#if nme
import cocos.platform.flash.CCTouchDispatcher;
import cocos.platform.flash.CCTouchDelegateProtocol;
import cocos.platform.flash.CCTouchHandler;
#elseif flash
import cocos.platform.flash.CCEventDispatcher;
import cocos.platform.flash.FlashView;
import cocos.platform.flash.CCDirectorFlash;
import cocos.platform.flash.CCAssets;
#elseif js

#end

//
// cocos2d helper files
//
import cocos.support.CCArrayExtension;
import cocos.support.CCFileUtils;
import cocos.support.CCUtils;
import cocos.support.CGPoint;
import cocos.support.CGSize;
import cocos.support.CGRect;
import cocos.support.NSDictionary;
/*
#if CC_ENABLE_PROFILERS
import cocos.support.CCProfiling;
#end
*/

class Cocos2d {
	public static function main(){}
	public static function cocos2dVersion() :String
	{
		return "cocos2d v1.0.1";
	}
}
