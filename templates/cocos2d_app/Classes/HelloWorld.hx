//
//  HelloWorldLayer.m
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

import objc.CGSize;
import objc.CGPoint;
import platforms.flash.CCAssets;


// HelloWorld implementation
class HelloWorld extends CCLayer {
	
	var label :CCLabelTTF;
	var grossini :CCSprite;
	var tamara :CCSprite;
	var kathia :CCSprite;

public static function scene () :CCScene
{
	var scene :CCScene = CCScene.node();
	var layer :HelloWorld = HelloWorld.node();
	
	// add layer as a child to scene
	scene.addChild ( layer );
	
	// return the scene
	return scene;
}
public static function node () :HelloWorld
{
	return cast ( new HelloWorld().init() );
}

// on "init" you need to initialize your instance
override public function init () :CCNode
{
	// always call "super" init
	super.init();
	
	// create and initialize a Label
	label = CCLabelTTF.labelWithString ("Hello CCWorld", null,null,null, "Marker Felt", 64);
	
	// ask director the the window size
	var size :CGSize = CCDirector.sharedDirector().winSize();

	// position the label on the center of the screen
	var center = new objc.CGPoint ( size.width /2, size.height/2 );
	label.position = center;
	
	// add the label as a child to this Layer
	this.addChild ( label );
	
	
	// Because flash is async, we preload the assets first
	CCAssets.onComplete = addGrossini;
	CCAssets.loadFile ("grossini.png");
	CCAssets.loadFile ("grossinis_sister1.png");
	CCAssets.loadFile ("grossinis_sister2.png");
	
	return this;
}
function addGrossini(){
	
	grossini = new CCSprite().initWithFile("grossini.png");
	tamara = new CCSprite().initWithFile("grossinis_sister1.png");
	kathia = new CCSprite().initWithFile("grossinis_sister2.png");
	
	addChild (grossini, 1);
	addChild (tamara, 2);
	addChild (kathia, 3);
	
	var s = CCDirector.sharedDirector().winSize();
	
	grossini.setPosition ( new CGPoint (s.width/2-100, s.height/3) );
	tamara.setPosition ( new CGPoint (s.width/2, 2*s.height/3) );
	kathia.setPosition ( new CGPoint (s.width/2+100, s.height/2) );
	
	//flash.Lib.current.stage.addEventListener (flash.events.MouseEvent.CLICK, startActions);
	testActions();
	//testSpritesheet();
}
function testActions(){
	trace("start actions");
	var s = CCDirector.sharedDirector().winSize();
	// add some action
/*	var actionTo = CCMoveTo.actionWithDuration (2, new CGPoint(s.width-40, s.height-40));
	var actionBy = CCMoveBy.actionWithDuration (1, new CGPoint(80,80));
	var actionByBack = actionBy.reverse();
	
	tamara.runAction ( actionTo );
	grossini.runAction ( CCSequence.actions ([actionBy, actionByBack]) );
	kathia.runAction ( CCMoveTo.actionWithDuration (1, new CGPoint(40,40)) );*/
	
	
	var actionTo = CCJumpTo.actionWithDuration (2, new CGPoint(100,300), 50, 4);
	var actionBy = CCJumpBy.actionWithDuration (2, new CGPoint(400,0), 50, 4);
	var actionUp = CCJumpBy.actionWithDuration (2, new CGPoint(0,0), 80, 4);
	var actionByBack = actionBy.reverse();
	
	var blink = CCBlink.actionWithDuration (2, 10);
	var fade = CCFadeTo.actionWithDuration ( 2, 50 );
	
	tamara.runAction( fade );
	grossini.runAction ( CCSequence.actions ( [actionBy, actionByBack] ));
	kathia.runAction ( CCRepeatForever.actionWithAction (actionUp) );
}
function testSpritesheet ()
{
	var size = CCDirector.sharedDirector().winSize();
	
	var spritesBgNode = CCSpriteBatchNode.batchNodeWithFile("players.png");
	addChild ( spritesBgNode );
	
	CCSpriteFrameCache.sharedSpriteFrameCache().addSpriteFramesWithFile("players.plist");
	
	var images = ["alex-n.png", "andra-n.png", "cezara-n.png", "cristi-n.png", "dan-n.png", "maria-n.png"];       
	for (i in 0...images.length) {
		var offsetFraction = (i+1)/(images.length+1);        
		var spriteOffset = new CGPoint (size.width*offsetFraction, size.height/2);
		var sprite = CCSprite.spriteWithSpriteFrameName ( images[i] );
			sprite.position = spriteOffset;
		spritesBgNode.addChild (sprite);
	}
}




// on "dealloc" you need to release all your retained objects
override public function release()
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	super.release();
}
override public function visit(){
	//trace("---------------------------------------------------VISITING THE HELLOWORLD");
	super.visit();
}


override public function onEnter () {
	trace("onEnter");
	super.onEnter();
	
	var actionTo = CCMoveTo.actionWithDuration (2, new objc.CGPoint (0, 0));
	var actionBy = CCMoveBy.actionWithDuration (2, new objc.CGPoint(80,80));
	var actionByBack = actionBy.reverse();
	
	label.runAction ( actionTo );
/*		[grossini runAction: [CCSequence actions:actionBy, actionByBack, nil]];
		[kathia runAction:[ CCMoveTo actionWithDuration:1 position:ccp(40,40)]];*/
}

}
