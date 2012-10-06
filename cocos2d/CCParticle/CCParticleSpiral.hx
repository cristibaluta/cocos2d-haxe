//! An spiral particle system
class CCParticleSpiral extends ARCH_OPTIMAL_PARTICLE_SYSTEM
{
//
public function init () :CCParticleSpiral
{
	return this.initWithTotalParticles ( 500 );
}

override public function initWithTotalParticles (p:Int) :CCParticleSpiral
{
	super.initWithTotalParticles ( p );
	
		// duration
		duration = kCCParticleDurationInfinity;

		// Gravity Mode
		this.emitterMode = kCCParticleModeGravity;
		
		// Gravity Mode: gravity
		this.gravity = new CGPoint (0,0);
		
		// Gravity Mode: speed of particles
		this.speed = 150;
		this.speedVar = 0;
		
		// Gravity Mode: radial
		this.radialAccel = -380;
		this.radialAccelVar = 0;
		
		// Gravity Mode: tagential
		this.tangentialAccel = 45;
		this.tangentialAccelVar = 0;
		
		// angle
		angle = 90;
		angleVar = 0;
		
		// emitter position
		winSize:CGSize = CCDirector.sharedDirector().winSize();
		this.position = new CGPoint (winSize.width/2, winSize.height/2);
		posVar = new CGPoint(0,0);
		
		// life of particles
		life = 12;
		lifeVar = 0;
		
		// size, in pixels
		startSize = 20.0;
		startSizeVar = 0.0;
		endSize = kCCParticleStartSizeEqualToEndSize;

		// emits per second
		emissionRate = totalParticles/life;
		
		// color of particles
		startColor.r = 0.5;
		startColor.g = 0.5;
		startColor.b = 0.5;
		startColor.a = 1.0;
		startColorVar.r = 0.5;
		startColorVar.g = 0.5;
		startColorVar.b = 0.5;
		startColorVar.a = 0.0;
		endColor.r = 0.5;
		endColor.g = 0.5;
		endColor.b = 0.5;
		endColor.a = 1.0;
		endColorVar.r = 0.5;
		endColorVar.g = 0.5;
		endColorVar.b = 0.5;
		endColorVar.a = 0.0;
		
		this.texture = CCTextureCache.sharedTextureCache().addImage ("fire.png");

		// additive
		this.blendAdditive = false;
	}
	
	return this;
}
}