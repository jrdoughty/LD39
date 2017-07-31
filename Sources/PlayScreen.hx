package;

import kha.Assets;
import kha.Scheduler;
import sdg.graphics.shapes.Polygon;
import sdg.Screen;
import sdg.Object;
import sdg.event.IEventDispatcher;
import sdg.event.EventSystem;
import sdg.event.EventObject;
import sdg.math.Vector2b;
import haxe.Constraints.Function;
import sdg.graphics.Sprite;
import sdg.atlas.Region;

class PlayScreen extends Screen implements IEventDispatcher
{


	/**
	 * map of Function arrays, and the Event Constant Strings used to trigger them
	 */
	private var listeners:Map<String, Array<Function>> = new Map();

	var stamina:Float = 1;
	var staminaMeter:Object;
	var char:Character;
	var bull:Bull;

	public function new()
	{
		super();
	}

	public override function init()
	{
		super.init();
		staminaMeter = new Object(16,16,Polygon.createRectangle(128,16,kha.Color.Blue,true,.2));
		staminaMeter.fixed = new Vector2b(true, true);
		add(new Object(0,0, new Sprite(new Region(Assets.images.bg,0,0,320,188))));
		add(staminaMeter);
		char = new Character(16,148,Assets.images.bot);
		bull = new Bull(200,148,Assets.images.enemy);
		add(bull);
		add(char);
		
		Scheduler.addTimeTask(function(){stamina -= .003;}, 0, .05);
		addEvent('action', function(e:EventObject){stamina -= .1;});
		addEvent('hit', function(e:EventObject){stamina -= .5;});
	}

	public override function update()
	{
		if(stamina <= 0)
		{
			stamina = 0;
			bull.active = false;
			if(!char.dead)
				char.death();
			char.dead = true;
		}
		cast(staminaMeter.graphic, Polygon).points[1].x = stamina * 128;
		cast(staminaMeter.graphic, Polygon).points[2].x = stamina * 128;


		
		super.update();
		if(doObjectsOverlap(char,bull) && char.collidable && !char.bRecovering && bull.active)
		{
			char.hit();
		}			
		if(doObjectsOverlap(char.weapon,bull) && char.weapon.collidable && bull.active && !bull.bRecovering)
		{
			bull.hit();
		}
		
	}

	
	public static function doObjectsOverlap(object1:Object, object2:Object):Bool
	{
		var topLeftX1:Float = object1.width >= 0 ? object1.x : object1.x + object1.width;
		var topLeftY1:Float = object1.height >= 0 ? object1.y : object1.y + object1.height;
		var bottomRightX1:Float = object1.width >= 0 ? object1.x + object1.width : object1.x;
		var bottomRightY1:Float = object1.height >= 0 ? object1.y + object1.height : object1.y;
		
		var topLeftX2:Float = object2.width >= 0 ? object2.x : object2.x + object2.width;
		var topLeftY2:Float = object2.height >= 0 ? object2.y : object2.y + object2.height;
		var bottomRightX2:Float = object2.width >= 0 ? object2.x + object2.width : object2.x;
		var bottomRightY2:Float = object2.height >= 0 ? object2.y + object2.height : object2.y;

		if (topLeftX1 > bottomRightX2 || topLeftX2 > bottomRightX1 || topLeftY1 > bottomRightY2 || topLeftY2 > bottomRightY1)
		{
			return false;
		}
		return true;
	}

	/**
	 * Adds Event Listener for the name string and addes the callback to the functions to be 
	 * run when that event is fired off
	 * @param	name 		Event String that maps to array of callbacks
	 * @param	callback	callback to be added to array of callbacks upon event dispatch
	 */

	public function addEvent(name:String, callback:Function)
	{
		if (!listeners.exists(name))
		{
			listeners.set(name, [callback]);
			EventSystem.get().addEvent(name,this);
		}
		else if (listeners[name].indexOf(callback) == -1)
		{
			listeners[name].push(callback);
			EventSystem.get().addEvent(name,this);
		}
	}

	

	/**
	 * Removes Event Listener for the strings/callback combination
	 * 
	 * @param	name 		Event String that maps to array of callbacks
	 * @param	callback	callback to be removed from event
	 */
	public function removeEvent(name:String, callback:Function)
	{
		var i:Int;
		if (listeners.exists(name) && listeners[name].indexOf(callback) != -1)
		{
			for (i in 0...listeners[name].length)
			{
				if (listeners[name][i] == callback)
				{
					listeners[name].splice(i, 1);
					EventSystem.get().removeEvent(name,this);
					break;
				}
			}
		}
	}
	

	/**
	 * Triggers event using the name string. 
	 * The eventObject is passed to all callback functions listening to the event
	 * @param	name		Event to Trigger
	 * @param	eventObject	data the Event's callback functions need, creates a blank EventObject if left null
	 */

	public function dispatchEvent(name:String, eventObject:EventObject = null)
	{
		if (eventObject == null)
		{
			eventObject = new EventObject();
		}

		if (listeners.exists(name) && !eventObject.bubble)
		{
			for (func in listeners[name])
			{
				func(eventObject);
			}
		}

		if(eventObject.bubble)
		{
			EventSystem.get().dispatch(name, eventObject);
		}
	}
}