package sg.fight.client.view
{
	import laya.display.Sprite;
	import laya.ui.Image;
	import sg.manager.AssetsManager;
	import sg.manager.EffectManager;
	import sg.cfg.ConfigServer;
	
	/**
	 * 国战对战情况下方进度条（上色）
	 * @author zhuda
	 */
	public class ViewFightCountryBar extends Sprite
	{
		private var bar0:Image;
		private var bar1:Image;
		private var barGlow:Image;
		
		private var w:Number;
		private var h:Number;
		
		public function ViewFightCountryBar(country0:int, country1:int, num0:int, num1:int, width:Number = 188, height:Number = 12)
		{
			this.w = width;
			this.h = height;
			
			this.bar0 = new Image(AssetsManager.getAssetsFight('fight_bg10'));
			this.bar0.height = height;
			this.bar0.anchorX = 0;
			this.bar0.anchorY = 0.5;
			this.bar0.x = -width / 2;
			
			this.bar1 = new Image(AssetsManager.getAssetsFight('fight_bg10'));
			this.bar1.height = height;
			this.bar1.anchorX = 1;
			this.bar1.anchorY = 0.5;
			this.bar1.x = width / 2;
			
			this.barGlow = new Image(AssetsManager.getAssetsFight('fight_light'));
			this.barGlow.width = height + 20;
			this.barGlow.height = height + 28;// 48
			this.barGlow.anchorX = 0.5;
			this.barGlow.anchorY = 0.5;
			
			this.addChild(this.bar0);
			this.addChild(this.bar1);
			this.addChild(this.barGlow);
			
			this.updateAll(country0, country1, num0, num1);
		}
		
		/**
		 * 更新国家和双方人数
		 */
		public function updateAll(country0:int, country1:int, num0:int, num1:int):void
		{
			EffectManager.changeSprColor(this.bar0, country0, true, ConfigServer.world.COUNTRY_COLOR_FILTER_MATRIX);
			EffectManager.changeSprColor(this.bar1, country1, true, ConfigServer.world.COUNTRY_COLOR_FILTER_MATRIX);
			this.updateNum(num0, num1);
		}
		
		/**
		 * 更新双方人数
		 */
		public function updateNum(num0:int, num1:int):void
		{
			var per:Number = num0 / (num0 + num1);
			this.bar0.width = this.w * per;
			this.bar1.width = this.w * (1 - per);
			this.barGlow.x = (per - 0.5) * this.w;
			
			if (per == 0 || per == 1){
				this.barGlow.visible = false;
			}else{
				this.barGlow.visible = true;
			}
		}
	
	}

}