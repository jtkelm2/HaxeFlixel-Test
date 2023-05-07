package;

import flixel.util.FlxColor;

var cardWidth:Int;
var cardHeight:Int;
var tabsAlignmentX:Int;
var tabsAlignmentY:Int;
var wastesAlignmentX:Int;
var wastesAlignmentY:Int;
var deckX:Int;
var deckY:Int;
var alignmentVertGap:Int;
var alignmentHorGap:Int;
var flipTime:Float;
var travelTime:Float;
var tabColor:FlxColor;

var valToString:Map<Int, String> = [
	1 => "A", 2 => "2", 3 => "3", 4 => "4", 5 => "5", 6 => "6", 7 => "7", 8 => "8", 9 => "9", 10 => "10", 11 => "J", 12 => "Q", 13 => "K"
];
