package sg.map.view 
{
	import sg.manager.ModelManager;
	import sg.map.model.entitys.EntityCity;
	import sg.utils.Tools;
	import ui.mapScene.CityTroopBarUI;
	/**
	 * ...
	 * @author zhuda
	 */
	public class CityTroopBar extends CityTroopBarUI
	{
		
		public function CityTroopBar() 
		{
			
		}
		
		public function setNum(npcNum:int, userNum:int,ec:EntityCity) :void
		{
			this.npc_txt.text = npcNum.toString();
			this.user_txt.text = "+" + userNum;
			this.comLv.visible = true;
			if (ec.cityId < 0) {//襄阳城
				if (ec.cityId <= -10) {//国阵
					this.comLv.visible = false;
				} else {
					if (ModelManager.instance.modelCountryPvp.mIsToday) {//当天开启
						if (ec.country > 2) { //黄巾军才显示驻军。
							//黄巾军。
							this.comLv.setNum(ec.getNPCLevel());
						} else {
							this.comLv.visible = false;
						}
					} else {
						this.comLv.setNum("??");
					}
				}				
			} else {
				this.comLv.setNum(ec.getNPCLevel());
			}
			
			
			var cityB07lv:int = ec.getB07lv();
			this.com0.setCityBuffs(3,Tools.getMsgById("_lht31"));
            this.com1.setCityBuffs(3,Tools.getMsgById("_lht32"));
			
			this.com0.visible = cityB07lv >= 1;
			this.com1.visible = cityB07lv >= 5;
		}
		
	}

}