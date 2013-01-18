
package cocos.particle;

//! An explosion particle system
class CCParticleExplosion extends ARCH_OPTIMAL_PARTICLE_SYSTEM
{
//
public function init () :CCParticleExplosion
{
	return this.initWithTotalParticles ( 700 );
}

override public function initWithTotalParticles (p:Int) :CCParticleExplosion
{
	super.initWithTotalParticles ( p );
	
		// duration
		duration = 0.1;
		
		this.emitterMode = kCCParticleModeGravity;

		// Gravity Mode: gravity
		this.gravity = new CGPoint (0,0);
		
		// Gravity Mode: speed of particles
		this.speed = 70;
		this.speedVar = 40;
		
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
		life = 5.0;
		lifeVar = 2;
		
		// size, in pixels
		startSize = 15.0;
		startSizeVar = 10.0;
		endSize = kCCParticleStartSizeEqualToEndSize;

		// emits per second
		emissionRate = totalParticles/duration;
		
		// color of particles
		startColor.r = 0.7;
		startColor.g = 0.1;
		startColor.b = 0.2;
		startColor.a = 1.0;
		startColorVar.r = 0.5;
		startColorVar.g = 0.5;
		startColorVar.b = 0.5;
		startColorVar.a = 0.0;
		endColor.r = 0.5;
		endColor.g = 0.5;
		endColor.b = 0.5;
		endColor.a = 0.0;
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