//
//  RootViewController.m
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

//
// RootViewController + iAd
// If you want to support iAd, use this class as the controller of your iAd
//
import cocos.CCDirector;
import cocos.support.CGRect;
import cocos.support.CGSize;
import cocos.platform.flash.FlashView;


class RootViewController
{
public function new () {}

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
	[super viewDidLoad];
 }
 */


// Override to allow orientations other than the default portrait orientation.
public function shouldAutorotateToInterfaceOrientation (interfaceOrientation:UIInterfaceOrientation) :Bool {
	
	//
	// There are 2 ways to support auto-rotation:
	//  - The OpenGL / cocos2d way
	//     - Faster, but doesn't rotate the UIKit objects
	//  - The ViewController way
	//    - A bit slower, but the UiKit objects are placed in the right place
	//
	
	if (GameConfig.GAME_AUTOROTATION == GameConfig.kGameAutorotationNone) {
		//
		// EAGLView won't be autorotated.
		// Since this method should return YES in at least 1 orientation, 
		// we return YES only in the Portrait orientation
		//
		return ( interfaceOrientation == UIInterfaceOrientationPortrait );
	}
	else if (GameConfig.GAME_AUTOROTATION == GameConfig.kGameAutorotationCCDirector) {
		//
		// EAGLView will be rotated by cocos2d
		//
		// Sample: Autorotate only in landscape mode
		//
		if( interfaceOrientation == UIInterfaceOrientationLandscapeLeft ) {
			//CCDirector.sharedDirector().setDeviceOrientation ( kCCDeviceOrientationLandscapeRight );
		}
		else if( interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
			//CCDirector.sharedDirector().setDeviceOrientation ( kCCDeviceOrientationLandscapeLeft );
		}

		// Since this method should return YES in at least 1 orientation, 
		// we return YES only in the Portrait orientation
		return ( interfaceOrientation == UIInterfaceOrientationPortrait );
	}
	else if (GameConfig.GAME_AUTOROTATION == GameConfig.kGameAutorotationUIViewController) {
		//
		// EAGLView will be rotated by the UIViewController
		//
		// Sample: Autorotate only in landscpe mode
		//
		// return YES for the supported orientations

		//return ( UIInterfaceOrientationIsLandscape( interfaceOrientation ) );
	}
	
	// Shold not happen
	return false;
}

//
// This callback only will be called when GAME_AUTOROTATION == kGameAutorotationUIViewController
//
public function willRotateToInterfaceOrientation (toInterfaceOrientation:UIInterfaceOrientation)
{
	if (GameConfig.GAME_AUTOROTATION == GameConfig.kGameAutorotationUIViewController)
	{
		//
		// Assuming that the main window has the size of the screen
		// BUG: This won't work if the EAGLView is not fullscreen
		///
		var screenRect :CGRect = new CGRect (0,0,0,0);
		var rect :CGRect = new CGRect (0,0,0,0);

		if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)		
			rect = screenRect;

		else if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
			rect.size = new CGSize ( screenRect.size.height, screenRect.size.width );

		var director :CCDirector = CCDirector.sharedDirector();
		var view :FlashView = director.view;
		var contentScaleFactor :Float = 1.0;//director.contentScaleFactor;

		if( contentScaleFactor != 1 ) {
			rect.size.width *= contentScaleFactor;
			rect.size.height *= contentScaleFactor;
		}
		view.frame = rect;
	}
}

public function didReceiveMemoryWarning () {
    // Releases the view if it doesn't have a superview.
    
    // Release any cached data, images, etc that aren't in use.
	
}

public var view :CC_VIEW;
public function setView (view:CC_VIEW) :CC_VIEW {
	return this.view = view;
}
public function viewDidUnload () {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

public function release () {
	
}

}


enum CCDeviceOrientation
{
	kCCDeviceOrientationPortrait;
	kCCDeviceOrientationPortraitUpsideDown;
	kCCDeviceOrientationLandscapeLeft;
	kCCDeviceOrientationLandscapeRight;
}
enum UIInterfaceOrientation
{
	UIInterfaceOrientationPortrait;
	UIInterfaceOrientationPortraitUpsideDown;
	UIInterfaceOrientationLandscapeLeft;
	UIInterfaceOrientationLandscapeRight;
}
