package server;
import com.haxepunk.HXP;

import server.ServerEventHandler;

class TutorialStep {
	public var text:String;
	public var events:Array<String>;
	public var activationEvent:String;
	public function new(txt:String, jsonEvents:Array<Dynamic>, activation:String=null) {
		this.text = txt;
		this.activationEvent = activation;
		this.events = new Array<String>();
		if (jsonEvents != null) {
			for ( event in jsonEvents ) {
				events.push( cast event );
			}
		}
		if (events.length == 0) {
			events.push("hitSpacebar");
			this.text += "\n\n(press SPACE to continue)";
		}
	}
}

class TutorialController {
	public var receivedEvents:Hash<Bool>;
	var sections:Array<TutorialStep>;
	var currentIndex:Int;
	var isDone:Bool;
	var didChangeSections:Bool;
	public function new() {
		reset();
	}
	public function reset() {
		clearEvents();
		sections = new Array<TutorialStep>();
		currentIndex = 0;
		isDone = false;
		didChangeSections = true;
	}
	public function loadSections(jsonData:Array<Dynamic>) {
		reset();
		// resize the array once
		// sections[jsonData.length + 1] = null;

		for ( step in jsonData ) {
			var activation:String = null;
			if ( Reflect.hasField( step, "activationEvent" )) {
				activation = step.activationEvent;
			}
			var section:TutorialStep = new TutorialStep( step.text, step.events, activation );
			sections.push(section);
		}
	}
	public function getCurrentText():String {
		if (isDone || sections.length == 0) return "";
		var section:TutorialStep = sections[currentIndex];
		if (section.activationEvent != null && !receivedEvents.exists(section.activationEvent)) {
			return "";
		}
		return section.text;
	}
	public function sendEvent(name:String) {
		if (isDone) return;
		didChangeSections = false;
		receivedEvents.set(name, true);
		checkSectionCompletion();
	}

	private function clearEvents() {
		receivedEvents = new Hash<Bool>();		
	}
	private function getCurrent():TutorialStep {
		if (isDone || sections.length == 0) return null;
		return sections[currentIndex];
	}	
	private function checkSectionCompletion() {
		var current = getCurrent();
		for ( event in current.events ) {
			if (!receivedEvents.exists(event)) {
				return;
			}
		}
		if (receivedEvents.exists("hitSpacebar")) {
			receivedEvents.remove("hitSpacebar");
		}
		nextSection();
	}
	private function nextSection() {
		didChangeSections = true;
		clearEvents();
		if (++currentIndex >= sections.length) {
			isDone = true;
		}		
	}
	private function checkEvent(name:String):Bool {
		return receivedEvents.get(name);
	}
}