
package entities;
import com.haxepunk.Entity;
import com.haxepunk.HXP;

class EntityGroup extends Entity {
	var entities:List<Entity>;

	public function add(e:Entity) {
		entities.add(e);
		HXP.scene.add(e);
	}
	
	public function clearEntities() {
		if (entities == null) {
			entities = new List<Entity>();
		} else {
			HXP.scene.removeList(entities);			
			entities.clear();
		}		
	}
}