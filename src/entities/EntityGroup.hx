
package entities;
import com.haxepunk.Entity;
import com.haxepunk.HXP;

class EntityGroup<E:Entity> extends Entity {
	var entities:List<E>;
	public function new(?x:Float=0, ?y:Float=0) {
		super(x, y);
		clearEntities();
	}
	public function add(e:E):E {
		entities.add(e);
		HXP.scene.add(e);
		return e;
	}
	
	public function clearEntities() {
		if (entities == null) {
			entities = new List<E>();
		} else {
			HXP.scene.removeList(entities);			
			entities.clear();
		}		
	}
}