package;

import kha.Assets;
import kha.Scheduler;
import sdg.graphics.shapes.Polygon;
import sdg.Screen;
import sdg.Object;
import sdg.event.IEventDispatcher;
import sdg.event.EventSystem;
import sdg.event.EventObject;
import haxe.Constraints.Function;

class PlayScreen extends Screen implements IEventDispatcher
{


	/**
	 * map of Function arrays, and the Event Constant Strings used to trigger them
	 */
	private var listeners:Map<String, Array<Function>> = new Map();

	var stamina:Float = 1;
	var staminaMeter:Object;
	var char:Object;
	var bull:Object;

	public function new()
	{
		super();
	}

	public override function init()
	{
		super.init();
		staminaMeter = new Object(16,16,Polygon.createRectangle(128,16,kha.Color.Green,true,.2));
		add(staminaMeter);
		char = new Character(16,200,Polygon.createRectangle(32,32,kha.Color.Green,true,.2));
		add(char);

		bull = new Object(200,200,Polygon.createRectangle(64,32,kha.Color.Red,true,.2));
		add(bull);
		
		Scheduler.addTimeTask(function(){stamina -= .003;}, 0, .05);
		addEvent('action', function(e:EventObject){stamina -= .1;});
	}

	public override function update()
	{
		super.update();
		cast(staminaMeter.graphic, Polygon).points[1].x = stamina * 128 + staminaMeter.x;
		cast(staminaMeter.graphic, Polygon).points[2].x = stamina * 128 + staminaMeter.x;
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