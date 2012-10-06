/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 On-Core
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
	
//import platforms.CCGL;
import CCGrabber;
import CCMacros;
import CCTexture2D;
//import support.OpenGL.Internal;

class CCGrabber
{

public function new () {}

public function init () :CCGrabber
{
	// generate FBO
	//ccglGenFramebuffers(1, &fbo);
	return this;
}

public function grab (texture:CCTexture2D) :Void
{
	//glGetIntegerv(CC_GL.FRAMEBUFFER_BINDING, &oldFBO);
	
	// bind
	//ccglBindFramebuffer(CC_GL.FRAMEBUFFER, fbo);

	// associate texture with FBO
	//ccglFramebufferTexture2D(CC_GL.FRAMEBUFFER, CC_GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, texture.name, 0);
	
	// check if it worked (probably worth doing :) )
/*	var status :Int = ccglCheckFramebufferStatus(CC_GL.FRAMEBUFFER);
	if (status != CC_GL.FRAMEBUFFER_COMPLETE)*/
		trace("Could not attach texture to framebuffer");
	
	//ccglBindFramebuffer(CC_GL.FRAMEBUFFER, oldFBO);
}

public function beforeRender (texture:CCTexture2D) :Void
{
	//glGetIntegerv(CC_GL.FRAMEBUFFER_BINDING, &oldFBO);
	//ccglBindFramebuffer(CC_GL.FRAMEBUFFER, fbo);

	// BUG XXX: doesn't work with RGB565.


	//glClearColor(0,0,0,0);
	
	// BUG #631: To fix #631, uncomment the lines with #631
	// Warning: But it CCGrabber won't work with 2 effects at the same time
//	glClearColor(0.0,0.0,0.0,1.0);	// #631
	
	//glClear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);	
	
//	glColorMask(true, true, true, false);	// #631

}

public function afterRender (texture:CCTexture2D)
{
 	//ccglBindFramebuffer(CC_GL.FRAMEBUFFER, oldFBO);
//	glColorMask(true, true, true, true);	// #631
}

public function release ()
{
	trace("cocos2d: releaseing "+ this);
	//ccglDeleteFramebuffers(1, &fbo);
}

}
