package;

import sdg.Object;
import sdg.Graphic;
import kha.Scheduler;
import sdg.graphics.shapes.Polygon;
import sdg.manager.Mouse;
import sdg.components.Motion;
import sdg.collision.Hitbox;
import sdg.atlas.Region;
import sdg.graphics.Sprite;

class Weapon extends Object
{
	var s:Sprite;
	var body:Hitbox;
	var idleR:Region;
	var attackR:Region;

	public function new(x:Float, y:Float, i:kha.Image)
	{
		idleR = new Region(i,0,0,32,8);
		attackR = new Region(i,32,0,32,8);
		s = new Sprite(idleR);
		super(x,y,s);

		setSizeAuto();
		body = new Hitbox(this, null, 'collision');
		collidable = false;
	}

	public override function update()
	{
		
		if(collidable)
		{
			s.region = attackR;
		}
		else
		{
			s.region = idleR;
		}
		super.update();
		body.moveTo(x,y);
	}
}