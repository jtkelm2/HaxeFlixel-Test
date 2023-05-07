package;

import flixel.FlxSprite;
// import flixel.addons.ui.FlxClickArea;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

enum SlotType
{
	DeckSlot;
	WasteSlot;
	TabSlot;
}

class Slot extends FlxSprite
{
	public var slotType:SlotType;
	public var cards:Array<Card>;

	public var cardsGrp:FlxTypedGroup<Card>;

	public var rowNumber:Int;
	public var tabIndex:Int;
	public var val:Int;

	public var highlight:Bool;

	public var displayLimit:Int;
	public var offsetX:Int;
	public var offsetY:Int;

	public var txt:FlxText;

	public function new(x:Float, y:Float, width:Float, height:Float, slotType:SlotType, displayLimit:Int = 13, offsetX:Int = -16, offsetY:Int = 0,
			rowNumber:Int = -1, tabIndex:Int = -1)
	{
		super(x, y);
		this.slotType = slotType;
		this.rowNumber = rowNumber;
		this.tabIndex = tabIndex;
		this.val = (rowNumber * tabIndex - 1) % 13 + 1;
		switch (slotType)
		{
			case WasteSlot:
				loadGraphic("assets/WasteSlot.png");
				this.txt = new FlxText(0, 0);
			case TabSlot:
				loadGraphic("assets/TabSlot.png");
				this.txt = new FlxText(x, y + height / 2 - 16, width, Reg.valToString[val], 32);

				txt.alignment = FlxTextAlign.CENTER;
				txt.setBorderStyle(FlxTextBorderStyle.SHADOW, 0xFF808080);
				txt.color = Reg.tabColor;
			case DeckSlot:
				loadGraphic("assets/TabSlot.png");
				this.txt = new FlxText(0, 0);
		};
		this.alpha = 0.8;
		this.width = width;
		this.height = height;
		this.displayLimit = displayLimit;
		this.offsetX = offsetX;
		this.offsetY = offsetY;
		this.cards = [];
		this.cardsGrp = new FlxTypedGroup<Card>();
	}

	public function addCard(card:Card)
	{
		cards.push(card);
		cardsGrp.add(card);
		updatePile();
		card.slot = this;
	}

	public function drawCard():Null<Card>
	{
		var card = cards.pop();
		cardsGrp.remove(card);
		updatePile();
		return card;
	}

	function updatePile():Void
	{
		var j:Int = cards.length;
		if (j == 0)
		{
			this.alpha = 0.8;
			txt.visible = true;
			return {};
		}
		else
		{
			this.alpha = 0;
			txt.visible = false;
		}
		for (i in 0...cards.length)
		{
			j -= 1;
			if (i < displayLimit)
			{
				cards[j].reset(x + i * offsetX, y + i * offsetY);
			}
			else
			{
				cards[j].kill();
			}
			if (i > 0)
			{
				cards[j].canClick = false;
				cards[j].demagnify();
			}
			else
			{
				cards[j].canClick = true;
			}
		}
	}

	public function highlightText():Void
	{
		txt.alpha = 1;
	}

	public function lowlightText():Void
	{
		txt.alpha = 0.3;
	}

	public function occupied():Bool
	{
		return (cards.length > 0);
	}
}
