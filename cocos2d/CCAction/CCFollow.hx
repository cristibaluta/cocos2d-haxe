
/** CCFollow is an action that "follows" a node.
 
 Eg:
	layer.runAction: CCFollow.actionWithTarget ( hero );
 
 Instead of using CCCamera as a "follower", use this action instead.
 @since v0.99.2
 */
class CCFollow extends CCAction
{
//
/* node to follow */
var followedNode_ :CCNode;

/* whether camera should be limited to certain area */
public var boundarySet :Bool;

/* if screensize is bigger than the boundary - update not needed */
var boundaryFullyCovered :Bool;

/* fast access to the screen dimensions */
var halfScreenSize :CGPoint;
var fullScreenSize :CGPoint;

/* world boundaries */
var leftBoundary :Float;
var rightBoundary :Float;
var topBoundary :Float;
var bottomBoundary :Float;


public function initWithTarget (fNode:CCNode) :CCFollow
{
	return new CCFollow().initWithTarget ( fNode );
}

public function actionWithTargetAndWorldBoundary (fNode:CCNode, rect:CGRect) :CCFollow
{
	return new CCFollow().initWithTargetAndWorldBoundary ( fNode, rect );
}

public function initWithTarget (fNode:CCNode) :CCFollow
{
	super.init();
	
	followedNode_ = fNode;
	boundarySet = false;
	boundaryFullyCovered = false;
		
	var s :CGSize = CCDirector.sharedDirector().winSize();
	fullScreenSize = new CGPoint(s.width, s.height);
	halfScreenSize = ccpMult(fullScreenSize, .5);
	
	return this;
}

public function initWithTargetAndWorldBoundary (fNode:CCNode, rect:CGRect) :CCFollow
{
	super.init();
	
	followedNode_ = fNode;
	boundarySet = true;
	boundaryFullyCovered = false;
	
	var winSize :CGSize = CCDirector.sharedDirector().winSize();
	fullScreenSize = new CGPoint(winSize.width, winSize.height);
	halfScreenSize = ccpMult (fullScreenSize, .5);
	
	leftBoundary = -((rect.origin.x+rect.size.width) - fullScreenSize.x);
	rightBoundary = -rect.origin.x ;
	topBoundary = -rect.origin.y;
	bottomBoundary = -((rect.origin.y+rect.size.height) - fullScreenSize.y);
	
	if(rightBoundary < leftBoundary)
	{
		// screen width is larger than world's boundary width
		//set both in the middle of the world
		rightBoundary = leftBoundary = (leftBoundary + rightBoundary) / 2;
	}
	if(topBoundary < bottomBoundary)
	{
		// screen width is larger than world's boundary width
		//set both in the middle of the world
		topBoundary = bottomBoundary = (topBoundary + bottomBoundary) / 2;
	}
	
	if( (topBoundary == bottomBoundary) && (leftBoundary == rightBoundary) )
		boundaryFullyCovered = true;
	
	return this;
}

/*public function copyWithZone (zone:NSZone) :id
{
	var  copy :CCAction = [[this.class] allocWithZone: zone] init];
	copy.tag = tag_;
	return copy;
}*/

public function step (dt:Float) :Void
{
	if(boundarySet)
	{
		// whole map fits inside a single screen, no need to modify the position - unless map boundaries are increased
		if(boundaryFullyCovered)
			return;
		
		var tempPos :CGPoint = CGPointExtension.sub( halfScreenSize, followedNode_.position);
		target_.setPosition ( new CGPoint (clampf(tempPos.x,leftBoundary,rightBoundary), clampf(tempPos.y,bottomBoundary,topBoundary)) );
	}
	else
		target_.setPosition ( CGPointExtension.sub( halfScreenSize, followedNode_.position ));
}


public function isDone () :Bool
{
	return !followedNode_.isRunning;
}

override public function stop () :Void
{
	target_ = null;
	super.stop();
}

override function release () :Void
{
	followedNode_.release();
	super.release();
}
}
