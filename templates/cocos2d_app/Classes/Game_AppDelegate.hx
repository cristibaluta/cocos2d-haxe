//
//  ___PROJECTNAMEASIDENTIFIER___AppDelegate.m
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

import flash.display.MovieClip;
import cocos.CCDirector;


class Game_AppDelegate {
	
	public var window :MovieClip;
	public var viewController :RootViewController;
	
	public function new () {
		try{
			applicationDidFinishLaunching();
		}
		catch(e:Dynamic){
			trace(e);
			var stack = haxe.Stack.exceptionStack();
			trace ( haxe.Stack.toString ( stack ) );
		}
	}
	public function removeStartupFlicker ()
	{
		//
		// THIS CODE REMOVES THE STARTUP FLICKER
		//
		// Uncomment the following code if you Application only supports landscape mode
		//
		if (GameConfig.GAME_AUTOROTATION == GameConfig.kGameAutorotationUIViewController) {

			//	CC_ENABLE_DEFAULT_GL_STATES();
			//	CCDirector *director = [CCDirector sharedDirector];
			//	CGSize size = [director winSize];
			//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
			//	sprite.position = ccp(size.width/2, size.height/2);
			//	sprite.rotation = -90;
			//	[sprite visit];
			//	[[director openGLView] swapBuffers];
			//	CC_ENABLE_DEFAULT_GL_STATES();

		}// GAME_AUTOROTATION == kGameAutorotationUIViewController	
	}
	
	public function applicationDidFinishLaunching ()
	{
		trace("applicationDidFinishLaunching");
		// Init the window
		window = new MovieClip();
		flash.Lib.current.addChild ( window );

		// Try to use CADisplayLink director
		// if it fails (SDK < 3.1) use the default director
/*		if( ! CCDirector.setDirectorType ( kCCDirectorTypeDisplayLink ) )
			CCDirector.setDirectorType ( kCCDirectorTypeDefault );*/


		var director :CCDirector = CCDirector.sharedDirector();

		// Init the View Controller
		viewController = new RootViewController();
		//viewController.wantsFullScreenLayout = true;
		trace("viewController "+viewController);
		//
		// Create the View manually
		//  1. Create a RGBA format.
		//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
		//
		//
		var view :CC_VIEW = CC_VIEW.viewWithFrame ( new cocos.support.CGRect(0,0,640,320) );
		trace("view "+view);
		
		// attach the 'openglView' to the director
		director.setView ( view );

	//	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
/*		if( ! director.enableRetinaDisplay(true) )
			trace("Retina Display Not supported");*/

		//
		// VERY IMPORTANT:
		// If the rotation is going to be controlled by a UIViewController
		// then the device orientation should be "Portrait".
		//
		// IMPORTANT:
		// By default, this template only supports Landscape orientations.
		// Edit the RootViewController.m file to edit the supported orientations.
		//
/*		if (GameConfig.GAME_AUTOROTATION == GameConfig.kGameAutorotationUIViewController)
			director.setDeviceOrientation ( GameConfig.kCCDeviceOrientationPortrait );
		else
			director.setDeviceOrientation ( GameConfig.kCCDeviceOrientationLandscapeLeft );*/

		trace("director "+director);
		director.setAnimationInterval (1.0/60);
		director.setDisplayFPS (true);


		// make the OpenGLView a child of the view controller
		viewController.setView ( view );

		// make the View Controller a child of the main window
		window.addChild ( viewController.view );

		// Removes the startup flicker
		removeStartupFlicker();

		// Run the intro Scene
		var scene = HelloWorld.scene();
		CCDirector.sharedDirector().runWithScene ( scene );
		
/*		var v = new flash.display.Sprite();
			v.graphics.beginFill (0x345678);
			v.graphics.drawRect (20,20,200,300);
			view.addChild ( v );*/
			//view.addChild ( scene.view_ );
	}


	public function applicationWillResignActive () {
		CCDirector.sharedDirector().pause();
	}

	public function applicationDidBecomeActive () {
		CCDirector.sharedDirector().resume();
	}

	public function applicationDidReceiveMemoryWarning () {
		CCDirector.sharedDirector().purgeCachedData();
	}

	public function applicationDidEnterBackground () {
		CCDirector.sharedDirector().stopAnimation();
	}

	public function applicationWillEnterForeground () {
		CCDirector.sharedDirector().startAnimation();
	}

	public function applicationWillTerminate () {
		var director :CCDirector = CCDirector.sharedDirector();
		director.view.removeFromSuperview();
		viewController.release();
		window = null;
		director.end();
	}

	public function applicationSignificantTimeChange () {
		CCDirector.sharedDirector().setNextDeltaTimeZero(true);
	}

	public function release() {
		CCDirector.sharedDirector().release();
		window = null;
	}
}
