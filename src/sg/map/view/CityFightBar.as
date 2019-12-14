package sg.map.view 
{
	import sg.cfg.ConfigServer;
	import sg.fight.client.view.ViewFightCountryBar;
	import sg.manager.EffectManager;
	import ui.mapScene.CityFightBarUI;
	/**
	 * 国战对战情况，显示城池名称和攻守部队数
	 * @author zhuda
	 */
	public class CityFightBar extends CityFightBarUI
	{
		public var bar:ViewFightCountryBar;
		
		public function CityFightBar() 
		{
			this.visible = false;
		}
		
		public function setInfo(country0:int,country1:int,num0:int,num1:int,cityName:String) :void
		{
			this.country0.setCountryFlag(country0);
			this.country1.setCountryFlag(country1);
			EffectManager.changeSprColor(this.bg0, country0, true, ConfigServer.world.COUNTRY_COLOR_FILTER_MATRIX);
			EffectManager.changeSprColor(this.bg1, country1, true, ConfigServer.world.COUNTRY_COLOR_FILTER_MATRIX);
			
			this.num0.text = num0.toString();
			this.num1.text = num1.toString();
			
			this.cityName.text = cityName;
			var tempWidth:Number = this.cityName.textField.textWidth;
			tempWidth = Math.max(200, tempWidth + 160);
			this.box.width = tempWidth;
			
			if (!this.bar){
				this.bar = new ViewFightCountryBar(country0, country1, num0, num1, tempWidth, this.barBox.height);
				
				this.bar.y = this.barBox.height * 0.5;
				this.barBox.addChild(this.bar);
			}
			else{
				this.bar.updateAll(country0, country1, num0, num1);
			}
			tempWidth -= 50;
			this.bar.x = tempWidth * 0.5;

			this.visible = true;
		}
		
	}

}