import flixel.text.FlxText;

enum Stringifier<T>
{
	Prepend(prep:String);
	GenStringifier(stringifier:T->String);
}

class AutoText<T> extends FlxText
{
	public var value(default, set):T;

	var stringifier:T->String;

	public function new(x:Float, y:Float, initValue:T, stringifier:Stringifier<T>)
	{
		super(x, y);
		switch (stringifier)
		{
			case Prepend(prep):
				this.stringifier = function(t:T) return (prep + t);
			case GenStringifier(f):
				this.stringifier = f;
		}
		value = initValue;
		text = this.stringifier(value);
	}

	public function set_value(newValue:T):T
	{
		value = newValue;
		updateText();
		return value;
	}

	private function updateText():Void
	{
		text = stringifier(value);
	}
}
