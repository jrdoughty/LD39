package;

import sdg.Object;
import sdg.Graphic;
import sdg.collision.Hitbox;
import sdg.components.Motion;
import sdg.graphics.shapes.Polygon;
import kha.Scheduler;

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

	public function new(x:Float, y:Float, g:Graphic)
	{
		super(x,y,g);
		setSizeAuto();
		p = cast g;
		body = new Hitbox(this);		
		motion = new Motion();
		motion.drag.x = 0.5;
		motion.drag.y = 0.5;
		motion.maxVelocity.x = 5;
		motion.maxVelocity.y = 5;

		motion.acceleration.y = 0.3;

		addComponent(motion);
		//idle();
	}
	private function attack()
	{
		motion.acceleration.x = speed * (!flipX?1:-1);
		body.moveBy(motion.velocity.x, 0);
	}

	public override function update()
	{
		motion.update();
		if(bAttacking)
			attack();
	}
	private function attackStart()
	{
		p.color = kha.Color.Orange;
		Scheduler.addTimeTask(attackMain,.5);
	}
	private function attackMain()
	{
		bAttacking = true;
		p.color = kha.Color.Red;
		Scheduler.addTimeTask(attackEnd,.65);
		collidable = false;
	}
	private function attackEnd()
	{
		bAttacking = false;
		p.color = kha.Color.Orange;
		Scheduler.addTimeTask(idle,.5);
		collidable = true;
	}
	private function idle()
	{
		p.color = kha.Color.Purple;
		motion.acceleration.x = 0;
		Scheduler.addTimeTask(attackStart,1);
		flipX = !flipX;
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