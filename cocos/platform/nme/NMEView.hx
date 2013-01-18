/*

===== IMPORTANT =====

This is sample code demonstrating API, technology or techniques in development.
Although this sample code has been reviewed for technical accuracy, it is not
final. Apple is supplying this information to help you plan for the adoption of
the technologies and programming interfaces described herein. This information
is subject to change, and software implemented based on this sample code should
be tested with final operating system software and final documentation. Newer
versions of this sample code may be provided with future seeds of the API or
technology. For information about updates to this and other developer
documentation, view the New & Updated sidebars in subsequent documentation
seeds.

=====================

File: EAGLView.m
Abstract: Convenience class that wraps the CAEAGLLayer from CoreAnimation into a
UIView subclass.

Version: 1.3

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
("Apple") in consideration of your agreement to the following terms, and your
use, installation, modification or redistribution of this Apple software
constitutes acceptance of these terms.  If you do not agree with these terms,
please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject
to these terms, Apple grants you a personal, non-exclusive license, under
Apple's copyrights in this original Apple software (the "Apple Software"), to
use, reproduce, modify and redistribute the Apple Software, with or without
modifications, in source and/or binary forms; provided that if you redistribute
the Apple Software in its entirety and without modifications, you must retain
this notice and the following text and disclaimers in all such redistributions
of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may be used
to endorse or promote products derived from the Apple Software without specific
prior written permission from Apple.  Except as expressly stated in this notice,
no other rights or licenses, express or implied, are granted by Apple herein,
including but not limited to any patent rights that may be infringed by your
derivative works or by other works in which the Apple Software may be
incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/
package cocos.platform.nme;


// Only compile this code on iOS. These files should NOT be included on your Mac project.
// But in case they are included, it won't be compiled.
import EAGLView;
import ES1Renderer;
import cocos.CCDirector;
import ccMacros;
import cocos.CCConfiguration;
import Support/OpenGL.Internal;
import ESRenderer;

//CLASSES:

@class EAGLView;
@class EAGLSharegroup;

//PROTOCOLS:

@protocol EAGLTouchDelegate <NSObject>
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
@end

//CLASS INTERFACE:

/** EAGLView Class.
 * This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
 * The view content is basically an EAGL surface you render your OpenGL scene into.
 * Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
 */
@interface EAGLView : UIView
{
    id<ESRenderer>			renderer_;	
	var context_ :EAGLContext; // weak ref

	var pixelformat_ :String;
	var depthFormat_ :Int;
	var preserveBackbuffer_ :Bool;

	var size_ :CGSize;
	var discardFramebufferSupported_ :Bool;
	id<EAGLTouchDelegate>   touchDelegate_;

	//fsaa addition
	var multisampling_ :Bool;
	var requestedSamples_ :Int;
}

/** creates an initializes an EAGLView with a frame and 0-bit depth buffer, and a RGB565 color buffer. */
+ (id) viewWithFrame:(CGRect)frame;
/** creates an initializes an EAGLView with a frame, a color buffer format, and 0-bit depth buffer. */
+ (id) viewWithFrame:(CGRect)frame pixelFormat:(String*)format;
/** creates an initializes an EAGLView with a frame, a color buffer format, and a depth buffer. */
+ (id) viewWithFrame:(CGRect)frame pixelFormat:(String*)format depthFormat:(Int)depth;
/** creates an initializes an EAGLView with a frame, a color buffer format, a depth buffer format, a sharegroup, and multisamping */
+ (id) viewWithFrame:(CGRect)frame pixelFormat:(String*)format depthFormat:(Int)depth preserveBackbuffer:(Bool)retained sharegroup:(EAGLSharegroup*)sharegroup multiSampling:(Bool)multisampling numberOfSamples:(int)samples;

/** Initializes an EAGLView with a frame and 0-bit depth buffer, and a RGB565 color buffer */
public function initWithFrame (frame:CGRect) :id; //These also set the current context
/** Initializes an EAGLView with a frame, a color buffer format, and 0-bit depth buffer */
public function initWithFrame (frame:CGRect) :id pixelFormat:(String*)format;
/** Initializes an EAGLView with a frame, a color buffer format, a depth buffer format, a sharegroup and multisampling support */
public function initWithFrame (frame:CGRect) :id pixelFormat:(String*)format depthFormat:(Int)depth preserveBackbuffer:(Bool)retained sharegroup:(EAGLSharegroup*)sharegroup multiSampling:(Bool)sampling numberOfSamples:(int)nSamples;

/** pixel format: it could be RGBA8 (32-bit) or RGB565 (16-bit) */
@property(nonatomic,readonly) String* pixelFormat;
/** depth format of the render buffer: 0, 16 or 24 bits*/
public var depthFormat (get_depthFormat, null) :Int;

/** returns surface size in pixels */
@property(nonatomic,readonly) surfaceSize:CGSize;

/** OpenGL context */
@property(nonatomic,readonly) EAGLContext *context;

public var multiSampling (get_multiSampling, set_multiSampling) :Bool;

/** touch delegate */
@property(nonatomic,readwrite,assign) id<EAGLTouchDelegate> touchDelegate;

/** EAGLView uses double-buffer. This method swaps the buffers */
-(void) swapBuffers;

public function convertPointFromViewToSurface (point:CGPoint) :CGPoint;
public function convertRectFromViewToSurface (rect:CGRect) :CGRect;

//CLASS IMPLEMENTATIONS:

@interface EAGLView (Private)
- (Bool) setupSurfaceWithSharegroup:(EAGLSharegroup*)sharegroup;
- (int) convertPixelFormat:(String*) pixelFormat;
@end

@implementation EAGLView

public var surfaceSize (get_surfaceSize, set_surfaceSize) :;
public var pixelFormat (get_pixelFormat, set_pixelFormat) :, depthFormat=depthFormat_;
public var touchDelegate (get_touchDelegate, set_touchDelegate) :;
public var context (get_context, set_context) :;
public var multiSampling (get_multiSampling, set_multiSampling) :;

+ (Class) layerClass
{
	return CAEAGLLayer.class;
}

+ (id) viewWithFrame ( frame:CGRect )
{
	return [new this().initWithFrame:frame] autorelease];
}

+ (id) viewWithFrame:(CGRect)frame pixelFormat ( format:String )
{
	return [new this().initWithFrame:frame pixelFormat:format] autorelease];
}

+ (id) viewWithFrame:(CGRect)frame pixelFormat:(String*)format depthFormat ( depth:Int )
{
	return [new this().initWithFrame:frame pixelFormat:format depthFormat:depth preserveBackbuffer:NO sharegroup:nil multiSampling:NO numberOfSamples:0] autorelease];
}

+ (id) viewWithFrame:(CGRect)frame pixelFormat:(String*)format depthFormat:(Int)depth preserveBackbuffer:(Bool)retained sharegroup:(EAGLSharegroup*)sharegroup multiSampling:(Bool)multisampling numberOfSamples:(int)samples
{
	return [new this().initWithFrame:frame pixelFormat:format depthFormat:depth preserveBackbuffer:retained sharegroup:sharegroup multiSampling:multisampling numberOfSamples:samples] autorelease];
}

public function initWithFrame (frame:CGRect) :id
{
	return this.initWithFrame ( frame, kEAGLColorFormatRGB565, 0, NO, nil, NO, 0 );
}

public function initWithFrame (frame:CGRect) :id pixelFormat:(String*)format 
{
	return this.initWithFrame ( frame, format, 0, NO, nil, NO, 0 );
}

public function initWithFrame (frame:CGRect) :id pixelFormat:(String*)format depthFormat:(Int)depth preserveBackbuffer:(Bool)retained sharegroup:(EAGLSharegroup*)sharegroup multiSampling:(Bool)sampling numberOfSamples:(int)nSamples
{
	if((this = super.initWithFrame ( frame )))
	{
		pixelformat_ = format;
		depthFormat_ = depth;
		multiSampling_ = sampling;
		requestedSamples_ = nSamples;
		preserveBackbuffer_ = retained;
		
		if( ! this.setupSurfaceWithSharegroup ( sharegroup ) ) {
			this.release();
			return null;
		}
	}

	return this;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
	if( (this = super.initWithCoder ( aDecoder )) ) {
		
		CAEAGLLayer*			eaglLayer = (CAEAGLLayer*)this.layer;
		
		pixelformat_ = kEAGLColorFormatRGB565;
		depthFormat_ = 0; // GL.DEPTH_COMPONENT24_OES;
		multiSampling_= false;
		requestedSamples_ = 0;
		size_ = eaglLayer.bounds].size;

		if( ! this.setupSurfaceWithSharegroup ( nil ) ) {
			this.release();
			return null;
		}
    }
	
    return this;
}

public function setupSurfaceWithSharegroup (sharegroup:EAGLSharegroup) :Bool
{
	var eaglLayer :CAEAGLLayer = (CAEAGLLayer *)this.layer;
	
	eaglLayer.opaque = true;
	eaglLayer.drawableProperties = NSDictionary.dictionaryWithObjectsAndKeys:
									NSNumber.numberWithBool ( preserveBackbuffer_ ), kEAGLDrawablePropertyRetainedBacking,
									pixelformat_, kEAGLDrawablePropertyColorFormat, nil];
	
	
	renderer_ = new ES1Renderer().initWithDepthFormat:depthFormat_
										 withPixelFormat:this.convertPixelFormat ( pixelformat_ )
										  withSharegroup:sharegroup
									   withMultiSampling:multiSampling_
									 withNumberOfSamples ( requestedSamples_ );
	if (!renderer_)
		return false;
	
	context_ = renderer_.context;
	context_.renderbufferStorage ( GL.RENDERBUFFER_OES, eaglLayer );

	discardFramebufferSupported_ = CCConfiguration.sharedConfiguration().supportsDiscardFramebuffer];
	
	return true;
}

public function release () :Void
{
	traceINFO("cocos2d: releaseing "+ this);


	renderer_.release();
	super.release;
}

public function layoutSubviews () :Void
{
	size_ = renderer_.backingSize;

	renderer_.resizeFromLayer:(CAEAGLLayer*)this.layer;

	// Issue #914 #924
	var director :CCDirector = CCDirector.sharedDirector;
	director.reshapeProjection ( size_ );
	
	// Avoid flicker. Issue #350
	director.performSelectorOnMainThread:@selector(drawScene) withObject ( nil, true );
}	

public function swapBuffers () :Void
{
	// IMPORTANT:
	// - preconditions
	//	. context_ MUST be the OpenGL context
	//	. renderbuffer_ must be the the RENDER BUFFER

#if __IPHONE_4_0
	
	if (multiSampling_)
	{
		/* Resolve from msaaFramebuffer to resolveFramebuffer */
		//glDisable(GL.SCISSOR_TEST);     
		glBindFramebufferOES(GL.READ_FRAMEBUFFER_APPLE, renderer_.msaaFrameBuffer]);
		glBindFramebufferOES(GL.DRAW_FRAMEBUFFER_APPLE, renderer_.defaultFrameBuffer]);
		glResolveMultisampleFramebufferAPPLE();
	}
	
	if( discardFramebufferSupported_)
	{	
		if (multiSampling_)
		{
			if (depthFormat_)
			{
				GLenum attachments[] = {GL.COLOR_ATTACHMENT0_OES, GL.DEPTH_ATTACHMENT_OES};
				glDiscardFramebufferEXT(GL.READ_FRAMEBUFFER_APPLE, 2, attachments);
			}
			else
			{
				GLenum attachments[] = {GL.COLOR_ATTACHMENT0_OES};
				glDiscardFramebufferEXT(GL.READ_FRAMEBUFFER_APPLE, 1, attachments);
			}
			
			glBindRenderbufferOES(GL.RENDERBUFFER_OES, renderer_.colorRenderBuffer]);
	
		}	
		
		// not MSAA
		else if (depthFormat_ ) {
			GLenum attachments[] = { GL.DEPTH_ATTACHMENT_OES};
			glDiscardFramebufferEXT(GL.FRAMEBUFFER_OES, 1, attachments);
		}
	}
	
#end // __IPHONE_4_0
	
	if(!context_.presentRenderbuffer ( GL.RENDERBUFFER_OES ))
		trace("cocos2d: Failed to swap renderbuffer in %s\n", __FUNCTION__);

#if COCOS2D_DEBUG
	CHECK_GL.ERROR();
#end
	
	// We can safely re-bind the framebuffer here, since this will be the
	// 1st instruction of the new main loop
	if( multiSampling_ )
		glBindFramebufferOES(GL.FRAMEBUFFER_OES, renderer_.msaaFrameBuffer]);
}

- (int) convertPixelFormat:(String*) pixelFormat
{
	// define the pixel format
	var pFormat :GLenum;
	
	
	if(pixelFormat.isEqualToString:"EAGLColorFormat565"]) 
		pFormat = GL.RGB565_OES;
	else 
		pFormat = GL.RGBA8_OES;
	
	return pFormat;
}

#pragma mark EAGLView - Point conversion

public function convertPointFromViewToSurface (point:CGPoint) :CGPoint
{
	var bounds :CGRect = this.bounds;
	
	return new CGPoint((point.x - bounds.origin.x) / bounds.size.width * size_.width, (point.y - bounds.origin.y) / bounds.size.height * size_.height);
}

public function convertRectFromViewToSurface (rect:CGRect) :CGRect
{
	var bounds :CGRect = this.bounds;
	
	return new CGRect ((rect.origin.x - bounds.origin.x) / bounds.size.width * size_.width, (rect.origin.y - bounds.origin.y) / bounds.size.height * size_.height, rect.size.width / bounds.size.width * size_.width, rect.size.height / bounds.size.height * size_.height);
}

// Pass the touches to the superview
#pragma mark EAGLView - Touch Delegate

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(touchDelegate_)
	{
		touchDelegate_.touchesBegan ( touches, event );
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(touchDelegate_)
	{
		touchDelegate_.touchesMoved ( touches, event );
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(touchDelegate_)
	{
		touchDelegate_.touchesEnded ( touches, event );
	}
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(touchDelegate_)
	{
		touchDelegate_.touchesCancelled ( touches, event );
	}
}

@end

#end // ios