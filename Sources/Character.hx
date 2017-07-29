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
	var p:Polygon;
	public function new(x:Float, y:Float, g:Graphic)
	{
		super(x,y,g);
		p = cast g;
	}

	public override function update()
	{
		if(Mouse.isPressed(0))
		{
			attackStart();
		}
	}

	private function attackStart()
	{
		p.color = kha.Color.Blue;
		Scheduler.addTimeTask(attackMain,.5);
	}
	private function attackMain()
	{
		p.color = kha.Color.Yellow;
		Scheduler.addTimeTask(attackEnd,1);
	}
	private function attackEnd()
	{
		p.color = kha.Color.Blue;
		Scheduler.addTimeTask(idle,.5);
	}
	private function idle()
	{
		p.color = kha.Color.Green;
	}
}