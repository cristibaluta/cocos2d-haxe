//! A flower particle system
class CCParticleFlower extends ARCH_OPTIMAL_PARTICLE_SYSTEM
{
//
public function init () :CCParticleFlower
{
	return this.initWithTotalParticles ( 250 );
}

override public function initWithTotalParticles (p:Int) :CCParticleFlower
{
	super.initWithTotalParticles ( p );
	
		// duration
		duration = kCCParticleDurationInfinity;

		// Gravity Mode
		this.emitterMode = kCCParticleModeGravity;

		// Gravity Mode: gravity
		this.gravity = new CGPoint (0,0);
		
		// Gravity Mode: speed of particles
		this.speed = 80;
		this.speedVar = 10;
		
		// Gravity Mode: radial
		this.radialAccel = -60;
		this.radialAccelVar = 0;
		
		// Gravity Mode: tagential
		this.tangentialAccel = 15;
		this.tangentialAccelVar = 0;

		// angle
		angle = 90;
		angleVar = 360;
		
		// emitter position
		winSize:CGSize = CCDirector.sharedDirector().winSize();
		this.position = new CGPoint (winSize.width/2, winSize.height/2);
		posVar = new CGPoint(0,0);
		
		// life of particles
		life = 4;
		lifeVar = 1;
		
		// size, in pixels
		startSize = 30.0;
		startSizeVar = 10.0;
		endSize = kCCParticleStartSizeEqualToEndSize;

		// emits per second
		emissionRate = totalParticles/life;
		
		// color of particles
		startColor.r = 0.50;
		startColor.g = 0.50;
		startColor.b = 0.50;
		startColor.a = 1.0;
		startColorVar.r = 0.5;
		startColorVar.g = 0.5;
		startColorVar.b = 0.5;
		startColorVar.a = 0.5;
		endColor.r = 0.0;
		endColor.g = 0.0;
		endColor.b = 0.0;
		endColor.a = 1.0;
		endColorVar.r = 0.0;
		endColorVar.g = 0.0;
		endColorVar.b = 0.0;
		endColorVar.a = 0.0;
		
		this.texture = CCTextureCache.sharedTextureCache().addImage ("fire.png");

		// additive
		this.blendAdditive = true;
	}
		
	return this;
}
}