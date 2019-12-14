package sg.view.countryPvp
{
	import ui.countryPvp.country_pvp_tipsUI;
	import sg.utils.Tools;
	import sg.utils.SaveLocal;
	import sg.manager.ModelManager;
	import sg.scene.view.MapCamera;
	import sg.utils.MusicManager;

	/**
	 * ...
	 * @author
	 */
	public class ViewCountryPvpTips extends country_pvp_tipsUI{ //襄阳争夺战开始
		public function ViewCountryPvpTips(){
			this.text0.text=Tools.getMsgById("_public114");
			MusicManager.playSoundUI(MusicManager.SOUND_XYZ_3);
		}

		override public function onAdded():void{
			SaveLocal.save(SaveLocal.KEY_XYZ_BEGIN + ModelManager.instance.modelUser.mUID,{"season_num":ModelManager.instance.modelCountryPvp.mSeasonNum},true);
		}


		override public function onRemoved():void{
			MapCamera.lookAtCity(-1);
		}
		
	}

}