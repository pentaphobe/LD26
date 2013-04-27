
package states;
import com.haxepunk.HXP;

/** StateMachine is itself a State allowing nested states
 * might seem like design overkill, but should save a lot of work 
 * plus it fits the "minimalism" theme :)
 */
class StateMachine<T : State> extends State {	
	var stateStack:List<T>;
	var states:Hash<T>;

	public function new(name:String) {
		super(name);
		stateStack = new List<T>();
		states = new Hash<T>();
	}

	public override function enter() {
		var currentState:T = stateStack.last();
		if (currentState != null) {
			currentState.enter();
		}
	}

	public override function exit() {
		clear();		
	}

	public override function update() {
		var currentState:T = stateStack.first();
		if (currentState == null) {
			set_isDone(true);
			return;
		}


		currentState.update();

		if (currentState.isDone) {
			popState();
		}
		if (stateStack.length == 0) {
			set_isDone(true);
		}
	}	

	public override function render() {
		var currentState:T = stateStack.first();
		if (currentState == null) {
			// HXP.log(this.name + " no state to render");
			return;
		}

		currentState.render();

	}

	public function clear() {
		for (state in stateStack) {
			state.exit();
		}
		stateStack.clear();
	}

	private function exitCurrent() {
		var currentState:T = stateStack.first();
		if (currentState == null) {
			return;
		}
		currentState.exit();
	}

	public function getCurrent():State {
		return stateStack.first();
	}

	public function replaceState(name:String) {
		if (!states.exists(name)) {
			HXP.log(this.name + ".replaceState : no state named " + name + ", leaving the current state");
			return;
		}
		exitCurrent();
		stateStack.pop();
		pushState(name);
	}

	public function pushState(name:String):T {
		HXP.log("pushing state [" + name + "] onto stack " + stateStack);
		if (!states.exists(name)) {
			HXP.log(this.name + ": no state named " + name);
			return null;
		}
		exitCurrent();
		return addStateAndEnter( states.get(name) );
	}

	public function addState(state:T):T {
		if (state == null) {
			HXP.log(this.name + " not pushing null state");
			return null;
		}
		HXP.log("adding state " + state.name);
		states.set(state.name, state);
		state.parent = this;
		HXP.log("  it's now here: " + states.get(state.name));
		return state;
	}

	public function addStateAndEnter(state:T):T {
		if (state == null) {
			HXP.log(this.name + ".addStateAndEnter : not adding null state");
			return null;
		}
		addState(state);
		exitCurrent();
		stateStack.push(state);
		state.enter();
		return state;
	}

	public function popState() {
		if (stateStack.length == 0) {
			HXP.log(this.name + " can't pop an empty stack");
			return;
		}
		exitCurrent();
		stateStack.pop();
		HXP.log("popped stack, now it's:" + stateStack);
		if (stateStack.length > 0) {
			stateStack.first().enter();
		}
	}
}