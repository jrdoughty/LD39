package;

import sdg.Object;
import sdg.Graphic;
import kha.Scheduler;
import sdg.graphics.shapes.Polygon;
import sdg.manager.Mouse;
import sdg.components.Motion;
import sdg.collision.Hitbox;

class Weapon extends Object
{
	var p:Polygon;
	var body:Hitbox;

	public function new(x:Float, y:Float, g:Graphic)
	{
		super(x,y,g);

		p = cast g;
		body = new Hitbox(this, null, 'collision');
		collidable = false;
	}

	public override function update()
	{
		if(collidable)
		{
			p.color = kha.Color.Yellow;
		}
		else
		{
			p.color = kha.Color.Green;
		}
	}
}