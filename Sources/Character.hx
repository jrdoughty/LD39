package;

import sdg.Object;
import sdg.Graphic;
import kha.Canvas;
import kha.Scheduler;
import sdg.graphics.shapes.Polygon;
import sdg.manager.Mouse;
import sdg.manager.Keyboard;
import sdg.collision.Hitbox;
import sdg.components.Motion;
import sdg.components.EventDispatcher;
import sdg.event.EventObject;

class Character extends Object
{
	public var weapon:Object;
	public var bRecovering:Bool = false;
	var takingInput:Bool = true;
	var bAttacking:Bool = false;
	var bJumping:Bool = false;
	var p:Polygon;
	var speed:Float = .5;
	var startY:Float = 0;
	//var sprite:Sprite;	
	var motion:Motion;
	//var animator:Animator;
	var body:Hitbox;
	var flipX:Bool = false;
	var frameCount:UInt = 0;

	public function new(x:Float, y:Float, g:Graphic)
	{
		super(x,y,g);

		p = cast g;
		addComponent(new EventDispatcher());
		startY = y;
	}

	public override function added()
	{
		body = new Hitbox(this);
		weapon = new Weapon(x+width,y + height/2-4,Polygon.createRectangle(32,8,kha.Color.Green,true,.2));
		setSizeAuto();
		screen.add(weapon);
		motion = new Motion();
		motion.drag.x = 0.5;
		motion.drag.y = 0.5;
		motion.maxVelocity.x = 5;
		motion.maxVelocity.y = 5;

		motion.acceleration.y = 0.3;

		addComponent(motion);
	}

	public override function update()
	{
		frameCount++;
		screen.camera.x = x - 160;
		if((Mouse.isHeld(0) && Mouse.isHeld(1) || Keyboard.isHeld(' ')) && takingInput)
		{
			attackStart();
			takingInput = false;
		}
		else if((Keyboard.isHeld('ctrl') || Keyboard.isHeld('w') || Mouse.isHeld(2)) && takingInput)
		{
			takingInput = false;
			bJumping = true;
			motion.velocity.y = -15;
			eventDispatcher.dispatchEvent('action',new EventObject(true));
			p.color = kha.Color.Blue;
		}
		else if((Mouse.isHeld(1) || Keyboard.isHeld('d')) && takingInput)
		{
			flipX = false;
			move();
		}		
		else if(Mouse.isHeld(0) || Keyboard.isHeld('a') && takingInput)
		{
			flipX = true;
			move();
		}	
		else if(takingInput)
		{
			motion.acceleration.x = 0;
		}

		motion.update();

		visible = (!bRecovering || frameCount % 20 > 10);
		weapon.visible = visible;

		if(bAttacking)
		{
			attack();
		}
		if(bJumping)
		{
			jump();
		}

		if(!flipX)
			weapon.x = right;
		else
			weapon.x = x  - weapon.width;
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
		eventDispatcher.dispatchEvent('action',new EventObject(true));
		Scheduler.addTimeTask(attackEnd,.25);
		collidable = false;
	}
	private function attackEnd()
	{
		bAttacking = false;
		weapon.collidable = false;
		p.color = kha.Color.Blue;
		Scheduler.addTimeTask(idle,.5);
		collidable = true;
	}
	private function idle()
	{
		takingInput = true;
		p.color = kha.Color.Green;
		motion.acceleration.x = 0;
	}
	
	private function attack()
	{
		motion.acceleration.x = speed * (!flipX?1:-1);
		body.moveBy(motion.velocity.x, 0);
	}

	private function move()
	{
		motion.acceleration.x = speed / 2 * (!flipX?1:-1);
		body.moveBy(motion.velocity.x, 0);
	}

	private function jump()
	{
		body.moveBy(motion.velocity.x, motion.velocity.y);
		if(startY < y)
		{
			y = startY;
			motion.velocity.y = 0;
			bJumping = false;
			takingInput = true;
			p.color = kha.Color.Green;
		}
	}

	//public override function 

	public function hit()
	{
		trace('hit');
		eventDispatcher.dispatchEvent('hit',new EventObject(true));
		bRecovering = true;
		Scheduler.addTimeTask(function(){bRecovering = false;}, 1);
	}
}