package sg.map.view
{
	import laya.display.Sprite;
	import laya.ui.View;
	import sg.fight.client.utils.FightViewUtils;
	import sg.map.model.entitys.EntityCity;
	
	/**
	 * 点开城市，上方弹出的快捷信息条
	 * @author zhuda
	 */
	public class CityBar extends Sprite
	{
		private var cityFightBar:CityFightBar;
		private var cityTroopInfo:CityTroopBar;
		
		public function CityBar()
		{
			this.cityFightBar = new CityFightBar();
			this.cityTroopInfo = new CityTroopBar();
			//this.cityFightBar.y = -65;
			
			this.addChild(this.cityFightBar);
			this.addChild(this.cityTroopInfo);
		}
		public function hide():void
		{
			this.visible = false;
		}
		
		public function updateData(data:Object,height:Number):void
		{
			var ec:EntityCity = EntityCity.getEntityCity(data.cid);
			this.cityFightBar.y = -Math.max(70, ec.height * 0.8);
			var cityName:String = ec.getName();
			//cityName = cityName+cityName+cityName+cityName;
			if (data.fight)
			{
				var num:int = 0;
				if (data.fight.last_battle_result){
					num = 1;
				}
				if (data.fight.team_len){
					//支持简化版消息
					this.cityFightBar.setInfo(data.fight.fireCountry, data.country, data.fight.team_len[0] + num, data.fight.team_len[1] + num, cityName);
				}
				else{
					//兼容原版消息
					this.cityFightBar.setInfo(data.fight.fireCountry, data.country, data.fight.team[0].troop.length + num, data.fight.team[1].troop.length + num, cityName);
				}
			}
			else
			{
				//this.cityFightBar.setInfo(3, data.country, 12, 8, cityName);
				this.cityFightBar.visible = false;
			}
			this.cityTroopInfo.setNum(data.troop, data.city_total,ec);
			
			this.visible = true;
		}
		
	}

}