
package states;
import com.haxepunk.HXP;

typedef StateOverride = PrototypeState->Void;

enum OverrideType {
	CustomRender;
	CustomUpdate;
	CustomEnter;
	CustomExit;
}


/* Acts as a rapid-prototyping state
 * simply allows me to override functions inline so that 
 * I can test stuff out without building whole classes straight away
 */

class PrototypeState extends State {
	private var customRender:StateOverride;
	private var customUpdate:StateOverride;
	private var customEnter:StateOverride;
	private var customExit:StateOverride;

	public override function new(name:String) {
		super(name);
	}
	public override function update() {
		if (customUpdate != null) {
			customUpdate(this);
		}
		super.update();
	}

	public override function render() {
		if (customRender != null) {			
			customRender(this);
		}
		super.render();
	}

	public override function enter() {
		if (customEnter != null) {
			customEnter(this);
		}
		super.enter();
	}

	public override function exit() {
		if (customExit != null) {
			customExit(this);
		}
		super.exit();
	}

	public function setOverride(which:OverrideType, overrideFunc:StateOverride) {
		if (overrideFunc == null) {
			HXP.log("not setting null override");
			return;
		}		
		switch (which) {
			case CustomUpdate: customUpdate = overrideFunc;
			case CustomRender: customRender = overrideFunc;
			case CustomEnter: customEnter = overrideFunc;
			case CustomExit: customExit = overrideFunc;
		}
	}
}