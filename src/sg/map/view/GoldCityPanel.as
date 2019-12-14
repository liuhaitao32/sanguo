package sg.map.view 
{
	import sg.manager.AssetsManager;
	import sg.view.map.ViewCountryInvadeMain;
	import ui.mapScene.GoldCityPanelUI;
	
	/**
	 * ...
	 * @author light
	 */
	public class GoldCityPanel extends GoldCityPanelUI 
	{
		
		public function GoldCityPanel() {
			
		}
		
		override public function initData():void {
			super.initData();
			this.bg_img.skin = AssetsManager.getAssetsAD("actPay1_3.png");
		}
	}

}