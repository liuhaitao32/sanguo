package sg.map.view {
	import sg.map.utils.ArrayUtils;
	import sg.map.view.entity.CityClip;
	import sg.scene.SceneMain;
	import sg.scene.view.ui.NoScaleUI;
	import ui.com.country_flag1UI;
	import ui.mapScene.CityInfo_0UI;
	
	/**
	 * ...
	 * @author light
	 */
	public class CityInfo1 extends NoScaleUI {
		
		private var _info:CityInfo_0UI = new CityInfo_0UI();
		
		private var _country:country_flag1UI = new country_flag1UI();	
		
		public function CityInfo1() 	{
			super();		
			this.addChild(this._info);	
		}
		
		public function init(cityClip:CityClip):void {	
			this._info.city_name_txt.text = cityClip.entityCity.name;			
			this._country.setCountryFlag(cityClip.entityCity.country);
			this._info.icon_img.addChild(this._country);
		}
	}

}