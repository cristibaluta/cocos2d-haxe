/** Animates a sprite given the name of an Animation */
@class CCAnimation;
@class CCTexture2D;


class CCAnimate extends CCActionInterval
{
	var animation_ :CCAnimation;
	id origFrame_;
	var restoreOriginalFrame_ :Bool;
}
/** animation used for the animage */
@property (readwrite,nonatomic,retain) CCAnimation * animation;

/** creates the action with an Animation and will restore the original frame when the animation is over */
public static function  actionWithAnimation:(CCAnimation*) a;
/** initializes the action with an Animation and will restore the original frame when the animtion is over */
-(id) initWithAnimation:(CCAnimation*) a;
/** creates the action with an Animation */
public static function  actionWithAnimation:(CCAnimation*) a restoreOriginalFrame:(Bool)b;
/** initializes the action with an Animation */
-(id) initWithAnimation:(CCAnimation*) a restoreOriginalFrame:(Bool)b;
/** creates an action with a duration, animation and depending of the restoreOriginalFrame, it will restore the original frame or not.
 The 'delay' parameter of the animation will be overrided by the duration parameter.
 @since v0.99.0
 */
public static function  actionWithDuration:(Float)duration animation:(CCAnimation*)animation restoreOriginalFrame:(Bool)b;
/** initializes an action with a duration, animation and depending of the restoreOriginalFrame, it will restore the original frame or not.
 The 'delay' parameter of the animation will be overrided by the duration parameter.
 @since v0.99.0
 */
-(id) initWithDuration:(Float)duration animation:(CCAnimation*)animation restoreOriginalFrame:(Bool)b;


public var animation (get_animation, set_animation) :;

public static function  actionWithAnimation: (CCAnimation*)anim
{
	return new XXX().initWithAnimation:anim restoreOriginalFrame:true] autorelease];
}

public static function  actionWithAnimation: (CCAnimation*)anim restoreOriginalFrame ( b:Bool )
{
	return new XXX().initWithAnimation:anim restoreOriginalFrame:b] autorelease];
}

public static function  actionWithDuration:(Float)duration animation: (CCAnimation*)anim restoreOriginalFrame ( b:Bool )
{
	return new XXX().initWithDuration:duration animation:anim restoreOriginalFrame:b] autorelease];
}

-(id) initWithAnimation: (CCAnimation*)anim
{
	if (anim!=null) throw "Animate: argument Animation must be non-null";
	return this.initWithAnimation ( anim, true );
}

-(id) initWithAnimation: (CCAnimation*)anim restoreOriginalFrame:(Bool) b
{
	if (anim!=null) throw "Animate: argument Animation must be non-null";

	if( (this=super.initWithDuration: [anim.frames] count] * anim.delay]]) ) {

		restoreOriginalFrame_ = b;
		this.animation = anim;
		origFrame_ = null;
	}
	return this;
}

-(id) initWithDuration:(Float)aDuration animation: (CCAnimation*)anim restoreOriginalFrame:(Bool) b
{
	if (anim!=null) throw "Animate: argument Animation must be non-null";
	
	if( (this=super.initWithDuration:aDuration] ) ) {
		
		restoreOriginalFrame_ = b;
		this.animation = anim;
		origFrame_ = null;
	}
	return this;
}


/*public function copyWithZone (zone:NSZone) :id
{
	return [[this.class] allocWithZone: zone] initWithDuration ( duration_, animation_, restoreOriginalFrame_ );
}*/

public function release () :Void
{
	animation_.release();
	origFrame_.release();
	super.release();
}

public function startWithTarget (aTarget:Dynamic) :Void
{
	super.startWithTarget ( aTarget );
	var sprite :CCSprite = target_;

	origFrame_.release();

	if( restoreOriginalFrame_ )
		origFrame_ = sprite.displayedFrame;
}

public function stop () :Void
{
	if( restoreOriginalFrame_ ) {
		var sprite :CCSprite = target_;
		sprite.setDisplayFrame ( origFrame_ );
	}
	
	super.stop();
}

function update (t:Float) :Void
{
	var frames :NSArray = animation_.frames;
	var numberOfFrames :Int = frames.count;
	
	var idx :Int = t * numberOfFrames;

	if( idx >= numberOfFrames )
		idx = numberOfFrames -1;
	
	var sprite :CCSprite = target_;
	if (! sprite.isFrameDisplayed: frames.objectAtIndex: idx]] )
		sprite.setDisplayFrame: frames.objectAtIndex ( idx );
}

public function reverse () :CCActionInterval
{
	var oldArray :Array = animation_.frames;
	var newArray :Array = new Array();
    
    for (i in 0...oldArray.length)
        newArray.push ( oldArray[oldArray.length-1-i] );
	
	var newAnim :CCAnimation = CCAnimation.animationWithFrames (newArray, animation_.delay);
	return CCActionInterval.actionWithDuration ( duration_, newAnim, restoreOriginalFrame_ );
}
}
