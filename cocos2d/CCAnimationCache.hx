/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
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
import CCMacros;
import CCAnimationCache;
import CCAnimation;
import CCSprite;


/** Singleton that manages the Animations.
 It saves in a cache the animations. You should use this class if you want to save your animations in a cache.
 */
class CCAnimationCache
{
static var sharedAnimationCache_ :CCAnimationCache = null;
var animations_ :Hash<CCAnimation>;
	

/** Retruns ths shared instance of the Animation cache */
public static function sharedAnimationCache () :CCAnimationCache
{
	if (sharedAnimationCache_ == null)
		sharedAnimationCache_ = new CCAnimationCache().init();
		
	return sharedAnimationCache_;
}

/** Purges the cache. It releases all the CCAnimation objects and the shared instance.
 */
public static function purgeSharedAnimationCache () :Void
{
	if (sharedAnimationCache_ != null)
		sharedAnimationCache_.release();
		sharedAnimationCache_ = null;
}

public function new () {}
public function init () :CCAnimationCache
{
	animations_ = new Hash<CCAnimation>();
	return this;
}

/** Adds a CCAnimation with a name.
 */
public function addAnimation (animation:CCAnimation, name:String) :Void
{
	animations_.set (name, animation);
}

/** Deletes a CCAnimation from the cache.
 */
public function removeAnimationByName (name:String) :Void
{
	if( name == null )
		return;

	animations_.remove ( name );
}

/** Returns a CCAnimation that was previously added.
 If the name is not found it will return null.
 You should retain the returned copy if you are going to use it.
 */
public function animationByName (name:String) :CCAnimation
{
	return animations_.get ( name );
}



public function toString () :String
{
	return "<CCAnimationCache | num of animations = "+animations_;
}

public function release () :Void
{
	trace("cocos2d: releaseing "+ this);
	
	animations_ = null;
}

}
