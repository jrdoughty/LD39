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
	var bAttacking:Bool = false;
	var p:Polygon;
	var speed:Float = 1;
	//var sprite:Sprite;	
	var motion:Motion;
	//var animator:Animator;
	var body:Hitbox;
	var weapon:Object;

	public function new(x:Float, y:Float, g:Graphic)
	{
		super(x,y,g);

		p = cast g;

	}

	public override function added()
	{
		body = new Hitbox(this, null, 'collision');
		weapon = new Weapon(x+width,y + height/2-4,Polygon.createRectangle(32,8,kha.Color.Green,true,.2));
		setSizeAuto();
		screen.add(weapon);
		motion = new Motion();
		motion.drag.x = 0.5;
		motion.drag.y = 0.5;
		motion.maxVelocity.x = 5;
		motion.maxVelocity.y = 5;

		addComponent(motion);
	}

	public override function update()
	{
		if(Mouse.isPressed(0) && takingInput)
		{
			attackStart();
			takingInput = false;
		}

		motion.update();
		if(bAttacking)
		{
			attack();
		}
		weapon.x = x + width;
		weapon.y = y + (height/2)-4;
	}

	private function attackStart()
	{
		p.color = kha.Color.Blue;
		Scheduler.addTimeTask(attackMain,.5);
	}
	private function attackMain()
	{
		bAttacking = true;
		weapon.collidable = true;
		p.color = kha.Color.Yellow;
		
		Scheduler.addTimeTask(attackEnd,.25);
	}
	private function attackEnd()
	{
		bAttacking = false;
		weapon.collidable = false;
		p.color = kha.Color.Blue;
		Scheduler.addTimeTask(idle,.5);
	}
	private function idle()
	{
		takingInput = true;
		p.color = kha.Color.Green;
	}
	
	private function attack()
	{
		motion.acceleration.x = speed;
		body.moveBy(motion.velocity.x, motion.velocity.y, 'collision');
	}
}