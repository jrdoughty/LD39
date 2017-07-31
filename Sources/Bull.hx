package;

import sdg.Object;
import sdg.Graphic;
import sdg.collision.Hitbox;
import sdg.components.Motion;
import sdg.graphics.shapes.Polygon;
import kha.Scheduler;
import sdg.components.Animator;
import sdg.atlas.Region;
import sdg.atlas.Atlas;
import sdg.graphics.Sprite;

class Bull extends Object
{
	public var bRecovering:Bool = false;
	var body:Hitbox;
	var speed:Float = .5;
	var motion:Motion;
	var flipX:Bool = false;
	var bAttacking:Bool = false;
	var p:Polygon;
	var health:Int = 3;
	var anim:Animator;
	var rl:Array<Region>;
	var s:Sprite;

	public function new(x:Float, y:Float, i:kha.Image)
	{
		rl = Atlas.createRegionList(i,16,32);
		setSizeAuto();
		s = new Sprite(rl[0]);
		super(x,y, s);
	}

	public override function added()
	{
		body = new Hitbox(this);		
		motion = new Motion();
		motion.drag.x = 0.5;
		motion.drag.y = 0.5;
		motion.maxVelocity.x = 5;
		motion.maxVelocity.y = 5;

		motion.acceleration.y = 0.3;

		addComponent(motion);
		var a = new Animator();
		anim = a;
		a.addAnimation('idle',[rl[0],rl[1],rl[2],rl[3],rl[2],rl[1]],12);
		a.addAnimation('attackReady',[rl[8],rl[9],rl[10],rl[11],rl[12],rl[13],rl[14],rl[15]],16);
		a.addAnimation('attack',[rl[4],rl[5],rl[6],rl[7],rl[6],rl[5]],12);
		a.addAnimation('attackFinish',[rl[15],rl[14],rl[13],rl[12],rl[1],rl[10],rl[9],rl[8]],12);
		addComponent(a);
		idle();		
	}

	private function attack()
	{
		motion.acceleration.x = speed * (!flipX?1:-1);
		body.moveBy(motion.velocity.x, 0);
	}

	public override function update()
	{
		motion.update();
		anim.update();
		if(bAttacking)
			attack();
		s.flip.x = flipX;
	}
	private function attackStart()
	{
		Scheduler.addTimeTask(attackMain,.5);
		anim.play('attackReady');
	}
	private function attackMain()
	{
		bAttacking = true;
		Scheduler.addTimeTask(attackEnd,.65);
		anim.play('attack');
		collidable = false;
	}
	private function attackEnd()
	{
		bAttacking = false;
		Scheduler.addTimeTask(idle,.5);
		collidable = true;
		anim.play('attackFinish', true);
	}
	private function idle()
	{
		motion.acceleration.x = 0;
		Scheduler.addTimeTask(attackStart,1);
		flipX = !flipX;
		anim.play('idle', true);
	}
	public function hit()
	{
		trace('ouch');
		health--;
		bRecovering = true;
		Scheduler.addTimeTask(function(){bRecovering = false;}, .3);
		if(health <= 0)
		{
			screen.remove(this, true);
			active = false;
		}
	}
}