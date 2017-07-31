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
import sdg.components.Animator;
import sdg.event.EventObject;
import kha.Image;
import sdg.atlas.Region;
import sdg.atlas.Atlas;
import sdg.graphics.Sprite;

class Character extends Object
{
	public var weapon:Object;
	public var bRecovering:Bool = false;
	public var dead:Bool = false;
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
	var rl:Array<Region>;
	var anim:Animator;

	public function new(x:Float, y:Float, i:Image)
	{
		rl = Atlas.createRegionList(i,16,32);

		super(x,y,new Sprite(rl[0]));

		//p = cast g;
		addComponent(new EventDispatcher());
		startY = y;
	}

	public override function added()
	{
		body = new Hitbox(this);

		weapon = new Weapon(x+width,y + height/2-4,kha.Assets.images.weapon);
		setSizeAuto();
		screen.add(weapon);
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
		a.addAnimation('dead',[rl[16],rl[17],rl[18],rl[19]],2);
		a.addAnimation('deadF',[rl[19]],2);
		addComponent(a);
		a.play('idle', true);
	}

	public override function update()
	{
		frameCount++;
		//screen.camera.x = x - 160;
		if(!dead && (Mouse.isHeld(0) && Mouse.isHeld(1) || Keyboard.isHeld(' ')) && takingInput)
		{
			attackStart();
			takingInput = false;
		}
		else if(!dead && (Keyboard.isHeld('ctrl') || Keyboard.isHeld('w') || Keyboard.isHeld('up') || Mouse.isHeld(2)) && takingInput)
		{
			takingInput = false;
			bJumping = true;
			motion.velocity.y = -15;
			eventDispatcher.dispatchEvent('action',new EventObject(true));
			//p.color = kha.Color.Blue;
		}
		else if(!dead && (Mouse.isHeld(1) || Keyboard.isHeld('d') || Keyboard.isHeld('right')) && takingInput)
		{
			flipX = false;
			move();
		}		
		else if(!dead && (Mouse.isHeld(0) || Keyboard.isHeld('a') || Keyboard.isHeld('left')) && takingInput)
		{
			flipX = true;
			move();
		}	
		else if(takingInput)
		{
			motion.acceleration.x = 0;
		}

		for(i in components)
		{
			i.update();
		}
		cast(graphic, Sprite).flip.x = flipX;
		cast(weapon.graphic, Sprite).flip.x = flipX;

		visible = (!bRecovering || frameCount % 20 > 10);
		weapon.visible = visible;

		if(!dead && bAttacking)
		{
			attack();
		}
		if(bJumping)
		{
			jump();
		}

		if(x < 0)
			x = 0;
		else if(x > 320 - width)
			x = 320 - width;
		
		if(!flipX)
			weapon.x = right;
		else
			weapon.x = x  - weapon.width;

		weapon.y = y + (height/2)-4;
	}

	private function attackStart()
	{
		if(dead)
			return;
		//p.color = kha.Color.Blue;
		Scheduler.addTimeTask(attackMain,.5);
		anim.play('attackReady');
	}
	private function attackMain()
	{
		if(dead)
			return;
		bAttacking = true;
		weapon.collidable = true;
		//p.color = kha.Color.Yellow;
		eventDispatcher.dispatchEvent('action',new EventObject(true));
		Scheduler.addTimeTask(attackEnd,.25);
		collidable = false;
		anim.play('attack');
	}
	private function attackEnd()
	{
		if(dead)
			return;
		bAttacking = false;
		weapon.collidable = false;
		//p.color = kha.Color.Blue;
		Scheduler.addTimeTask(idle,.5);
		collidable = true;
		anim.play('attackFinish', true);
	}
	private function idle()
	{
		if(dead)
			return;
		takingInput = true;
		//p.color = kha.Color.Green;
		motion.acceleration.x = 0;
		anim.play('idle', true);
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
			//p.color = kha.Color.Green;
		}
	}


	public function hit()
	{
		eventDispatcher.dispatchEvent('hit',new EventObject(true));
		bRecovering = true;
		Scheduler.addTimeTask(function(){bRecovering = false;}, 1);
	}

	public function death()
	{
		anim.play('dead', false);
		Scheduler.addTimeTask(function(){anim.play('deadF');},2);//looping doesn't stop
		weapon.collidable = false;
	}
}