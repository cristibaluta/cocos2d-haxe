
package cocos.particle;

//! An smoke particle system
class CCParticleSmoke extends ARCH_OPTIMAL_PARTICLE_SYSTEM
{
//
public function init () :CCParticleSmoke
{
	return this.initWithTotalParticles ( 200 );
}

override public function initWithTotalParticles (p:Int) :CCParticleSmoke
{
	super.initWithTotalParticles ( p );
	
		// duration
		duration = kCCParticleDurationInfinity;
		
		// Emitter mode: Gravity Mode
		this.emitterMode = kCCParticleModeGravity;
		
		// Gravity Mode: gravity
		this.gravity = new CGPoint (0,0);

		// Gravity Mode: radial acceleration
		this.radialAccel = 0;
		this.radialAccelVar = 0;
		
		// Gravity Mode: speed of particles
		this.speed = 25;
		this.speedVar = 10;
		
		// angle
		angle = 90;
		angleVar = 5;
		
		// emitter position
		winSize:CGSize = CCDirector.sharedDirector().winSize();
		this.position = new CGPoint (winSize.width/2, 0);
		posVar = new CGPoint (20, 0);
		
		// life of particles
		life = 4;
		lifeVar = 1;
		
		// size, in pixels
		startSize = 60.0;
		startSizeVar = 10.0;
		endSize = kCCParticleStartSizeEqualToEndSize;

		// emits per frame
		emissionRate = totalParticles/life;
		
		// color of particles
		startColor.r = 0.8;
		startColor.g = 0.8;
		startColor.b = 0.8;
		startColor.a = 1.0;
		startColorVar.r = 0.02;
		startColorVar.g = 0.02;
		startColorVar.b = 0.02;
		startColorVar.a = 0.0;
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
		this.blendAdditive = false;
	}
	
	return this;
}
}