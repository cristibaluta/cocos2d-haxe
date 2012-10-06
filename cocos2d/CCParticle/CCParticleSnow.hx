//! An snow particle system
class CCParticleSnow extends ARCH_OPTIMAL_PARTICLE_SYSTEM
{
//
public function init () :CCParticleSnow
{
	return this.initWithTotalParticles ( 700 );
}

override public function initWithTotalParticles (p:Int) :CCParticleSnow
{
	super.initWithTotalParticles ( p );
	
		// duration
		duration = kCCParticleDurationInfinity;
		
		// set gravity mode.
		this.emitterMode = kCCParticleModeGravity;

		// Gravity Mode: gravity
		this.gravity = new CGPoint (0,-1);
		
		// Gravity Mode: speed of particles
		this.speed = 5;
		this.speedVar = 1;
		
		// Gravity Mode: radial
		this.radialAccel = 0;
		this.radialAccelVar = 1;
		
		// Gravity mode: tagential
		this.tangentialAccel = 0;
		this.tangentialAccelVar = 1;
		
		// emitter position
		this.position = (CGPoint) {
			CCDirector.sharedDirector().winSize();.width / 2,
			CCDirector.sharedDirector().winSize();.height + 10
		};
		posVar = new CGPoint ( CCDirector.sharedDirector().winSize();.width / 2, 0 );
		
		// angle
		angle = -90;
		angleVar = 5;

		// life of particles
		life = 45;
		lifeVar = 15;
		
		// size, in pixels
		startSize = 10.0;
		startSizeVar = 5.0;
		endSize = kCCParticleStartSizeEqualToEndSize;

		// emits per second
		emissionRate = 10;
		
		// color of particles
		startColor.r = 1.0;
		startColor.g = 1.0;
		startColor.b = 1.0;
		startColor.a = 1.0;
		startColorVar.r = 0.0;
		startColorVar.g = 0.0;
		startColorVar.b = 0.0;
		startColorVar.a = 0.0;
		endColor.r = 1.0;
		endColor.g = 1.0;
		endColor.b = 1.0;
		endColor.a = 0.0;
		endColorVar.r = 0.0;
		endColorVar.g = 0.0;
		endColorVar.b = 0.0;
		endColorVar.a = 0.0;
		
		this.texture = CCTextureCache.sharedTextureCache().addImage ("fire.png");
		
		// additive
		this.blendAdditive = false;
	}
		
	return this;
}
}