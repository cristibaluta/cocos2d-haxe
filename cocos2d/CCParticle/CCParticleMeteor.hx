//! A meteor particle system
class CCParticleMeteor extends ARCH_OPTIMAL_PARTICLE_SYSTEM
{
//
public function init () :CCParticleMeteor
{
	return this.initWithTotalParticles ( 150 );
}

override public function initWithTotalParticles (p:Int) :CCParticleMeteor
{
	super.initWithTotalParticles ( p );

		// duration
		duration = kCCParticleDurationInfinity;
		
		// Gravity Mode
		this.emitterMode = kCCParticleModeGravity;

		// Gravity Mode: gravity
		this.gravity = new CGPoint (-200,200);

		// Gravity Mode: speed of particles
		this.speed = 15;
		this.speedVar = 5;
		
		// Gravity Mode: radial
		this.radialAccel = 0;
		this.radialAccelVar = 0;
		
		// Gravity Mode: tagential
		this.tangentialAccel = 0;
		this.tangentialAccelVar = 0;
		
		// angle
		angle = 90;
		angleVar = 360;
		
		// emitter position
		winSize:CGSize = CCDirector.sharedDirector().winSize();
		this.position = new CGPoint (winSize.width/2, winSize.height/2);
		posVar = new CGPoint(0,0);
		
		// life of particles
		life = 2;
		lifeVar = 1;
		
		// size, in pixels
		startSize = 60.0;
		startSizeVar = 10.0;
		endSize = kCCParticleStartSizeEqualToEndSize;

		// emits per second
		emissionRate = totalParticles/life;
		
		// color of particles
		startColor.r = 0.2;
		startColor.g = 0.4;
		startColor.b = 0.7;
		startColor.a = 1.0;
		startColorVar.r = 0.0;
		startColorVar.g = 0.0;
		startColorVar.b = 0.2;
		startColorVar.a = 0.1;
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