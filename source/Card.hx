package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.input.mouse.FlxMouseEvent;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class Card extends FlxSprite
{
	/**
	 * Whether the card has been turned around yet or not
	 */
	public var turned:Bool;

	/**
	 * Which card this is (index in the sprite sheet).
	 */
	public var slot:Slot;

	public var cardIndex:Int;
	public var val:Int;

	public var canClick:Bool;

	public function new(x:Float, y:Float, cardIndex:Int):Void
	{
		super(x, y);
		this.cardIndex = cardIndex;
		val = cardIndex % 13 + 1;
		turned = false;
		canClick = false;
		loadGraphic("assets/Deck.png", true, Reg.cardWidth, Reg.cardHeight);

		// The card starts out being turned around
		animation.frameIndex = 52;

		// Setup the mouse events
		// FlxMouseEvent.add(this, null, null, onOver, onOut, true);
	}

	// function onDown(_)

	public function magnify()
	{
		if (canClick)
			scale.x = scale.y = 1.2;
	}

	public function demagnify()
	{
		if (scale.x > 1)
			scale.x = scale.y = 1.0;
	}

	override public function destroy():Void
	{
		// Make sure that this object is removed from the FlxMouseEventManager for GC
		FlxMouseEvent.remove(this);
		super.destroy();
	}

	public function moveTo(targetSlot:Slot):Void
	{
		slot.cardsGrp.remove(this);
		targetSlot.cardsGrp.add(this); // Necessary so that card is rendered on top of others in targetSlot during the move
		FlxTween.tween(this, {x: targetSlot.x, y: targetSlot.y}, Reg.travelTime, {
			ease: FlxEase.quadOut,
			onComplete: function(?_)
			{
				slot.drawCard();
				targetSlot.addCard(this);
				slot = targetSlot;
				lowlight();
			}
		});
	}

	public function flip():Void
	{
		var card = this;
		FlxTween.tween(this.scale, {x: 0}, Reg.flipTime, {
			ease: FlxEase.quadOut,
			onComplete: function(?_)
			{
				if (turned)
					(animation.frameIndex = 52)
				else
					(animation.frameIndex = cardIndex);
				FlxTween.tween(this.scale, {x: 1}, Reg.flipTime, {
					ease: FlxEase.quadOut,
					onComplete: function(?_)(turned = !turned)
				});
			}
		});
	}

	public function lowlight():Void
	{
		var prev = animation.frameIndex;
		loadGraphic("assets/Deck.png", true, Reg.cardWidth, Reg.cardHeight);
		animation.frameIndex = prev;
	}

	public function highlight():Void
	{
		var prev = animation.frameIndex;
		loadGraphic("assets/DeckHighlight.png", true, Reg.cardWidth, Reg.cardHeight);
		animation.frameIndex = prev;
	}

	public function isBelow(card:Null<Card>):Bool
	{
		if (card == null)
			(return false);
		if (card.slot != slot)
			(return false);
		return (slot.cards.indexOf(this) < slot.cards.indexOf(card));
	}
}
