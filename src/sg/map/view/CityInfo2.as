package sg.map.view {
	import laya.display.Sprite;
	import sg.map.utils.ArrayUtils;
	import sg.map.utils.DistributionUtil;
	import sg.map.view.entity.CityClip;
	import sg.model.ModelCityBuild;
	import sg.model.ModelOffice;
	import sg.model.ModelOfficial;
	import sg.scene.SceneMain;
	import sg.scene.view.ui.NoScaleUI;
	import sg.utils.Tools;
	import ui.com.country_flag2UI;
	import ui.mapScene.CityInfo_1UI;
	
	/**
	 * ...
	 * @author light
	 */
	public class CityInfo2 extends NoScaleUI {
		
		private var _info:CityInfo_1UI = new CityInfo_1UI();
		
		private var _country2:country_flag2UI = new country_flag2UI();
		
		public function CityInfo2() 	{
			super();			
			this.addChild(this._info);
		}
		
		public function init(cityClip:CityClip):void {
			this._info.build_sp.removeChildren();
			
			if (ModelCityBuild.getBuildLv(cityClip.entityCity.cityId.toString(), "b09") > 0) {
				var img:Sprite = new Sprite();
				img.texture = Laya.loader.getRes("ui/icon_paopao37.png");
				this._info.build_sp.addChild(img);
				img.size(img.texture.width, img.texture.height);
				
			}			
			if (ModelCityBuild.getBuildLv(cityClip.entityCity.cityId.toString(), "b14") > 0) {
				var img2:Sprite = new Sprite();
				img2.texture = Laya.loader.getRes("ui/icon_paopao38.png");
				img2.size(img2.texture.width, img2.texture.height);
				this._info.build_sp.addChild(img2);
			}
			DistributionUtil.distribution(this._info.build_sp, this._info.build_sp.width);
			
			this._info.city_name_txt.text = cityClip.entityCity.name;
						
			this._country2.setCountryFlag(cityClip.entityCity.country);
			this._info.icon_img.addChild(this._country2);
			
			this._info.user_name_txt.text = ModelOfficial.getCityMayor(cityClip.entityCity.cityId.toString()) ? ModelOfficial.getCityMayor(cityClip.entityCity.cityId.toString())[1] : Tools.getMsgById('cityMayorNull');
			//this._info.user_name_txt.visible = cityClip.entityCity.cityId >= 0;
			
			if (cityClip.visit) {
				this._info.hero_icon.setHeroIcon(cityClip.visit.visit_hid);
				this._info.hero_icon.visible = true;
			} else {
				this._info.hero_icon.visible = false;
			}
			
		}

		public function setHeroIconGray(b:Boolean):void{
			this._info.hero_icon.gray = b;
		}
		
	}

}