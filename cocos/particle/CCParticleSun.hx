
package cocos.particle;

//! A sun particle system
class CCParticleSun extends ARCH_OPTIMAL_PARTICLE_SYSTEM
{
//
public function init () :CCParticleSun
{
	return this.initWithTotalParticles ( 350 );
}

override public function initWithTotalParticles (p:Int) :CCParticleSun
{
	super.initWithTotalParticles ( p );

		// additive
		this.blendAdditive = true;
			
		// duration
		duration = kCCParticleDurationInfinity;
		
		// Gravity Mode
		this.emitterMode = kCCParticleModeGravity;
		
		// Gravity Mode: gravity
		this.gravity = new CGPoint (0,0);
		
		// Gravity mode: radial acceleration
		this.radialAccel = 0;
		this.radialAccelVar = 0;
		
		// Gravity mode: speed of particles
		this.speed = 20;
		this.speedVar = 5;
				
		
		// angle
		angle = 90;
		angleVar = 360;
		
		// emitter position
		var winSize:CGSize = CCDirector.sharedDirector().winSize();
		this.position = new CGPoint (winSize.width/2, winSize.height/2);
		posVar = new CGPoint(0,0);
		
		// life of particles
		life = 1;
		lifeVar = 0.5;
		
		// size, in pixels
		startSize = 30.0;
		startSizeVar = 10.0;
		endSize = kCCParticleStartSizeEqualToEndSize;

		// emits per seconds
		emissionRate = totalParticles/life;
		
		// color of particles
		startColor.r = 0.76;
		startColor.g = 0.25;
		startColor.b = 0.12;
		startColor.a = 1.0;
		startColorVar.r = 0.0;
		startColorVar.g = 0.0;
		startColorVar.b = 0.0;
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
	}
		
	return this;
}
}