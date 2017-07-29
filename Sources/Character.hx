package;

import sdg.Object;
import sdg.Graphic;
import kha.Scheduler;
import sdg.graphics.shapes.Polygon;
import sdg.manager.Mouse;
import sdg.components.Motion;
import sdg.collision.Hitbox;

class Character extends Object
{
	var takingInput:Bool = true;
	var bMoving:Bool = false;
	var p:Polygon;
	var speed:Float = 1;
	//var sprite:Sprite;	
	var motion:Motion;
	//var animator:Animator;
	var body:Hitbox;

	public function new(x:Float, y:Float, g:Graphic)
	{
		super(x,y,g);

		p = cast g;

		body = new Hitbox(this, null, 'collision');
		
		motion = new Motion();
		motion.drag.x = 0.5;
		motion.drag.y = 0.5;
		motion.maxVelocity.x = 3;
		motion.maxVelocity.y = 3;

		addComponent(motion);
	}

	public override function update()
	{
		if(Mouse.isPressed(0) && takingInput)
		{
			attackStart();
			takingInput = false;
		}

		if(bMoving)
		{
			move();
		}
		motion.update();
	}

	private function attackStart()
	{
		p.color = kha.Color.Blue;
		Scheduler.addTimeTask(attackMain,.5);
	}
	private function attackMain()
	{
		bMoving = true;
		p.color = kha.Color.Yellow;
		
		Scheduler.addTimeTask(attackEnd,.5);
	}
	private function attackEnd()
	{
		bMoving = false;
		p.color = kha.Color.Blue;
		Scheduler.addTimeTask(idle,.5);
	}
	private function idle()
	{
		takingInput = true;
		p.color = kha.Color.Green;
	}
	
	private function move()
	{
		motion.acceleration.x = speed;
		/*
		if(Math.abs(motion.acceleration.y) > 0 && Math.abs(motion.acceleration.x) > 0)
		{
			motion.acceleration.y *= Math.sqrt(2);
			motion.acceleration.x *= Math.sqrt(2);
		}
		*/
		trace(motion.velocity.x);

		body.moveBy(motion.velocity.x, motion.velocity.y, 'collision');

	}
}