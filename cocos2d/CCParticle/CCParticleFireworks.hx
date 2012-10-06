//! A fireworks particle system
class CCParticleFireworks extends ARCH_OPTIMAL_PARTICLE_SYSTEM
{
//
public function init () :CCParticleFireworks
{
	return this.initWithTotalParticles ( 1500 );
}

override public function initWithTotalParticles (p:Int) :CCParticleFireworks
{
	super.initWithTotalParticles ( p );
		// duration
		duration = kCCParticleDurationInfinity;

		// Gravity Mode
		this.emitterMode = kCCParticleModeGravity;

		// Gravity Mode: gravity
		this.gravity = new CGPoint (0,-90);
		
		// Gravity Mode:  radial
		this.radialAccel = 0;
		this.radialAccelVar = 0;

		//  Gravity Mode: speed of particles
		this.speed = 180;
		this.speedVar = 50;
		
		// emitter position
		winSize:CGSize = CCDirector.sharedDirector().winSize();
		this.position = new CGPoint (winSize.width/2, winSize.height/2);
		
		// angle
		angle = 90;
		angleVar = 20;
				
		// life of particles
		life = 3.5;
		lifeVar = 1;
			
		// emits per frame
		emissionRate = totalParticles/life;
		
		// color of particles
		startColor.r = 0.5;
		startColor.g = 0.5;
		startColor.b = 0.5;
		startColor.a = 1.0;
		startColorVar.r = 0.5;
		startColorVar.g = 0.5;
		startColorVar.b = 0.5;
		startColorVar.a = 0.1;
		endColor.r = 0.1;
		endColor.g = 0.1;
		endColor.b = 0.1;
		endColor.a = 0.2;
		endColorVar.r = 0.1;
		endColorVar.g = 0.1;
		endColorVar.b = 0.1;
		endColorVar.a = 0.2;
		
		// size, in pixels
		startSize = 8.0;
		startSizeVar = 2.0;
		endSize = kCCParticleStartSizeEqualToEndSize;

		this.texture = CCTextureCache.sharedTextureCache().addImage ("fire.png");

		// additive
		this.blendAdditive = false;
	}
	
	return this;
}
}
}