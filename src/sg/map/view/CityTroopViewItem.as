package sg.map.view 
{
	
import sg.utils.Tools

	import laya.display.Sprite;
	import laya.display.Text;
	import laya.events.Event;
	import sg.map.model.entitys.EntityCity;
	import sg.map.utils.TestUtils;
	import sg.model.ModelTroop;
	import sg.scene.view.InputManager;
	import ui.mapScene.CityTroopItemUI;
	
	/**
	 * ...
	 * @author light
	 */
	public class CityTroopViewItem extends CityTroopItemUI {
		
		public var troop:ModelTroop;
		public var entityCity:EntityCity;
		
		public function CityTroopViewItem(troop:ModelTroop, entityCity:EntityCity) {
			this.troop = troop;
			this.entityCity = entityCity;
			this.heroIcon.setHeroIcon(this.troop.hero, true, 2);
			this.update();
		}
		
		override public function event(type:String, data:* = null):Boolean {
			var isClick:Boolean = (type == Event.CLICK);
			if (isClick) {
				if (!InputManager.instance.canClick) return true;
				if (data is Event) {
					Event(data).stopPropagation();
				}
			}
			return super.event(type, data);
		}
		
		public function update():void {
			if (this.entityCity.fire) {
				this.state_txt.text = (this.entityCity.myCountry ? Tools.getMsgById("msg_CityTroopViewItem_0") : Tools.getMsgById("msg_CityTroopViewItem_1"));				
			} else {
				this.state_txt.text = "";
			}
			this.icon_img.visible = this.entityCity.fire;
			this.heroIcon.gray = this.entityCity.fire;
			this.value_pro.value = this.troop.getHpPer();			
		}
		
		
	}

}