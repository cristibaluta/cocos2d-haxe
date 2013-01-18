
package cocos.particle;

//! A rain particle system
class CCParticleRain extends ARCH_OPTIMAL_PARTICLE_SYSTEM
{
//
public function init () :CCParticleRain
{
	return this.initWithTotalParticles ( 1000 );
}

override public function initWithTotalParticles ( p:Int ) :CCParticleRain
{
	super.initWithTotalParticles ( p );
	
		// duration
		duration = kCCParticleDurationInfinity;
		
		this.emitterMode = kCCParticleModeGravity;

		// Gravity Mode: gravity
		this.gravity = new CGPoint (10,-10);
		
		// Gravity Mode: radial
		this.radialAccel = 0;
		this.radialAccelVar = 1;
		
		// Gravity Mode: tagential
		this.tangentialAccel = 0;
		this.tangentialAccelVar = 1;

		// Gravity Mode: speed of particles
		this.speed = 130;
		this.speedVar = 30;
		
		// angle
		angle = -90;
		angleVar = 5;
		
		
		// emitter position
		this.position = (CGPoint) {
			CCDirector.sharedDirector().winSize();.width / 2,
			CCDirector.sharedDirector().winSize();.height
		};
		posVar = new CGPoint ( CCDirector.sharedDirector().winSize();.width / 2, 0 );
		
		// life of particles
		life = 4.5;
		lifeVar = 0;
		
		// size, in pixels
		startSize = 4.0;
		startSizeVar = 2.0;
		endSize = kCCParticleStartSizeEqualToEndSize;

		// emits per second
		emissionRate = 20;
		
		// color of particles
		startColor.r = 0.7;
		startColor.g = 0.8;
		startColor.b = 1.0;
		startColor.a = 1.0;
		startColorVar.r = 0.0;
		startColorVar.g = 0.0;
		startColorVar.b = 0.0;
		startColorVar.a = 0.0;
		endColor.r = 0.7;
		endColor.g = 0.8;
		endColor.b = 1.0;
		endColor.a = 0.5;
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