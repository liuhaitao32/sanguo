package sg.map.view {
	import laya.display.Sprite;
	import laya.maths.Point;
	import sg.cfg.ConfigServer;
	import sg.manager.EffectManager;
	import sg.map.model.MapModel;
	import sg.map.utils.ArrayUtils;
	import sg.map.utils.DistributionUtil;
	import sg.map.utils.Vector2D;
	import sg.map.view.entity.ChangChengClip;
	import sg.map.view.entity.CityClip;
	import sg.model.ModelCityBuild;
	import sg.model.ModelOffice;
	import sg.model.ModelOfficial;
	import sg.scene.SceneMain;
	import sg.scene.view.ui.NoScaleUI;
	import sg.utils.Tools;
	import ui.com.country_flag2UI;
	import ui.mapScene.ChangeChengInfoUI;
	import ui.mapScene.CityInfo_1UI;
	
	/**
	 * ...
	 * @author light
	 */
	public class ChangeChengInfo extends NoScaleUI {
		
		private var _info:ChangeChengInfoUI = new ChangeChengInfoUI();
		
		//private var _country2:country_flag2UI = new country_flag2UI();
		
		public function ChangeChengInfo() 	{
			super();			
			this.addChild(this._info);
		}
		
		public function update(changeChengClip:ChangChengClip):void {
			
			this._info.city_name_txt.text = changeChengClip.city.name + Tools.getMsgById("MiniMapTop_2");
			
			//this._info.city_name_txt.color = '#FFFFFF';
			this._info.city_name_txt.color = EffectManager.getFontColor(changeChengClip.city.faithCountry, ConfigServer.world.COUNTRY_COLORS);
			this._info.city_name_txt.bold = true;
			//this._info.city_name_txt.strokeColor = EffectManager.getFontColor(changeChengClip.city.faithCountry, ConfigServer.world.COUNTRY_COLORS);
			//this._info.city_name_txt.stroke = 6;
						
			//this._country2.setCountryFlag(changeChengClip.city.country);
			//this._country2.scale(0.7, 0.7);
			//this._info.icon_img.addChild(this._country2);
			
			var gw:Array = ModelCityBuild.getGreatWall3(changeChengClip.city.cityId.toString());
			var index:int = 0;
			if (!changeChengClip.locked) {
				for (var i:int = 0, len:int = gw.length; i < len; i++) {					
					if (gw[i].open) {
						index++;
					}
				
				}
				this._info.num_txt.text = index + "/4";
			} else {
				this._info.num_txt.text = "???";
			}
			
			var v:Vector2D = changeChengClip.grid.toScreenPos();
			this.x = v.x;
			this.y = v.y;
			MapViewMain.instance.mapLayer.infoLayer.addChild(this);
			
		}
		
	}

}