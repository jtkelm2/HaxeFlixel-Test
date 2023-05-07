package;

import Slot.SlotType;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.input.mouse.FlxMouseEvent;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.math.BGRA;

class PlayState extends FlxState
{
	var bg:FlxSprite;
	var selectedCard:Null<Card>;
	var inMotion:Bool;
	var slotGrp:FlxTypedGroup<Slot>;
	var slotTextGrp:FlxTypedGroup<FlxText>;
	var hoverCards:Array<Card>;
	var deck:Slot;
	var deckText:AutoText<Int>;
	var cards:Array<Card>;

	override public function create():Void
	{
		Reg.cardWidth = 70;
		Reg.cardHeight = 94;

		Reg.deckX = 100;
		Reg.deckY = 3;

		Reg.alignmentVertGap = 7;
		Reg.alignmentHorGap = 3;

		Reg.wastesAlignmentX = 200;
		Reg.wastesAlignmentY = 3 + Reg.cardHeight + Reg.alignmentVertGap;

		Reg.tabsAlignmentX = Reg.wastesAlignmentX + Reg.cardWidth + 20 * Reg.alignmentHorGap;
		Reg.tabsAlignmentY = Reg.wastesAlignmentY;

		Reg.flipTime = 0.4;
		Reg.travelTime = 0.5;

		Reg.tabColor = 0xffa300;

		bg = new FlxSprite(0, 0, "assets/Table.png");
		add(bg);

		slotGrp = new FlxTypedGroup<Slot>();
		slotTextGrp = new FlxTypedGroup<FlxText>();
		add(slotGrp);
		add(slotTextGrp);

		inMotion = false;
		hoverCards = new Array<Card>();

		FlxG.plugins.add(new FlxMouseEventManager());

		// Create the deck

		deck = initSlot(Reg.deckX, Reg.deckY, DeckSlot);
		cards = [for (i in 0...52) initCard(i)];
		FlxG.random.shuffle(cards);
		for (card in cards)
		{
			deck.addCard(card);
		}
		deckText = new AutoText<Int>(Reg.deckX + Reg.cardWidth + Reg.alignmentHorGap, Reg.deckY + Reg.cardHeight / 2 - 16, deck.cards.length, Prepend("x "));
		deckText.size = 32;
		add(deckText);

		// Create the wastes

		var x = Reg.wastesAlignmentX;
		var y = Reg.wastesAlignmentY;
		for (i in 0...4)
		{
			initSlot(x, y, WasteSlot, i + 1);
			y += Reg.cardHeight + Reg.alignmentVertGap;
		}

		// Create the tableaux

		y = Reg.tabsAlignmentY;
		for (i in 0...4)
		{
			x = Reg.tabsAlignmentX;
			for (j in 0...13)
			{
				initSlot(x, y, TabSlot, i + 1, j + 1);
				x += Reg.cardWidth + Reg.alignmentHorGap;
			}
			y += Reg.cardHeight + Reg.alignmentVertGap;
		}

		refreshLights();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// Keyboard hotkey to reset the state
		if (FlxG.keys.pressed.R)
		{
			for (card in cards)
			{
				if (card.slot.slotType != DeckSlot)
				{
					card.moveTo(deck);
					card.flip();
				}
			}
			new FlxTimer().start(2 * Reg.flipTime, function(_)
			{
				FlxG.resetState();
			});
		}
	}

	function initCard(cardIndex:Int):Card
	{
		var card = new Card(0, 0, cardIndex);

		FlxMouseEvent.add(card, null, null, cardOnOver, cardOnOut, true);
		return card;
	}

	function initSlot(x:Float, y:Float, slotType:SlotType, ?rowNumber:Int, ?tabIndex:Int):Slot
	{
		var slot = new Slot(x, y, Reg.cardWidth, Reg.cardHeight, slotType, 13, -16, 0, rowNumber, tabIndex);
		slot.slotType = slotType;
		switch (slotType)
		{
			case DeckSlot:
				{
					slot.displayLimit = 5;
					slot.offsetX = -5;
				}
			case WasteSlot:
				{}
			case TabSlot:
				{
					slot.displayLimit = 1;
					slotTextGrp.add(slot.txt);
				}
		}
		FlxMouseEvent.add(slot, null, slotClicked, null, null, true, true, false);
		add(slot.cardsGrp);
		slotGrp.add(slot);
		return slot;
	}

	function slotClicked(slot):Void
	{
		if (!inMotion)
		{
			switch (selectedCard)
			{
				case null:
					if (slot.slotType == TabSlot || !slot.occupied())
						(return {});
					selectedCard = slot.cards[slot.cards.length - 1];
					selectedCard.highlight();
					if (!selectedCard.turned)
						(selectedCard.flip());
				case card:
					static var wasteSelfClick:Bool = card.slot == slot && slot.slotType == WasteSlot;
					static var wasteToWaste:Bool = card.slot.slotType == WasteSlot && slot.slotType == WasteSlot;
					if (wasteSelfClick || wasteToWaste)
					{
						selectedCard = null;
						card.lowlight();
						return {};
					}
					if (willAccept(slot, card))
					{
						if (card.slot.slotType == DeckSlot)
							(deckText.value -= 1);
						card.moveTo(slot);
						pauseInputs(Reg.travelTime);
						selectedCard = null;
					}
			}
		}
	}

	function willAccept(slot:Slot, card:Card):Bool
	{
		switch (slot.slotType)
		{
			case DeckSlot:
				return false;
			case WasteSlot:
				return (slot.cards.length < slot.displayLimit);
			case TabSlot:
				if (card.val != slot.val || slot.occupied())
					(return false);
				switch (precSlot(slot))
				{
					case null:
						return true;
					case otherSlot:
						return (otherSlot.occupied());
				}
		}
	}

	function pauseInputs(t:Float):Void
	{
		inMotion = true;
		new FlxTimer().start(t + 0.05, function(?_)
		{
			inMotion = false;
			refreshLights();
		});
	}

	function cardOnOver(card:Card):Void
	{
		if (!card.turned || card.slot.slotType == TabSlot)
			(return);
		var i = 0;
		for (_ in 0...hoverCards.length)
		{
			if (!card.isBelow(hoverCards[i]))
			{
				hoverCards[i].demagnify();
				i += 1;
			}
			else
				(break);
		}
		hoverCards.insert(i, card);
		refreshLights();
	}

	function cardOnOut(card:Card):Void
	{
		card.demagnify();
		hoverCards.remove(card);
		refreshLights();
	}

	function precSlot(slot:Slot):Null<Slot>
	{
		for (otherSlot in slotGrp)
		{
			if (otherSlot.rowNumber == slot.rowNumber && otherSlot.tabIndex + 1 == slot.tabIndex)
				(return otherSlot);
		}
		return null;
	}

	function refreshLights():Void
	{
		if (hoverCards.length > 0)
		{
			var card = hoverCards[hoverCards.length - 1];
			card.magnify();
			for (slot in slotGrp)
			{
				if (card.val == slot.val)
					(slot.highlightText())
				else
					(slot.lowlightText());
			}
		}
		else
		{
			var prec:Null<Slot>;
			for (slot in slotGrp)
			{
				prec = precSlot(slot);
				switch (prec)
				{
					case null:
						if (!slot.occupied())
							(slot.highlightText())
						else
							(slot.lowlightText());
					case otherSlot:
						if (otherSlot.occupied() && !slot.occupied())
							(slot.highlightText())
						else
							(slot.lowlightText());
				}
			}
		}
	}
}
