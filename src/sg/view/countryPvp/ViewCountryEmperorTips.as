package sg.view.countryPvp
{
	import ui.countryPvp.country_emperor_tipsUI;
	import ui.bag.bagItemUI;
	import laya.utils.Handler;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.utils.Tools;
	import sg.utils.SaveLocal;

	/**
	 * ...
	 * @author
	 */
	public class ViewCountryEmperorTips extends country_emperor_tipsUI{//君临天下
		public var mArr:Array;
		public function ViewCountryEmperorTips(){
			this.list.renderHandler=new Handler(this,listRender);
			this.list.itemRender=bagItemUI;
			this.text0.text=Tools.getMsgById("_countrypvp_text35");
			this.text1.text=Tools.getMsgById("_public114");
		}


		override public function onAdded():void{
			mArr=this.currArg?this.currArg:["",""];
			this.tCountry.text=Tools.getMsgById("country_"+mArr[0]);
			this.tCountry.color=ConfigServer.world.COUNTRY_COLORS[mArr[0]];
			this.tCountry.strokeColor=ConfigServer.world.COUNTRY_FONT_STROKE_COLORS[mArr[0]];
			this.tName.text=mArr[1];
			var arr:Array=ModelManager.instance.modelProp.getCfgPropArr(ConfigServer.country_pvp.winner.reward);
			this.list.repeatX=arr.length;
			this.list.array=arr;
			this.list.centerX=0;

			var o:Object={"time":ConfigServer.getServerTimer()};
            SaveLocal.save(SaveLocal.KEY_EMPEROR_TIPS_TIME+ModelManager.instance.modelUser.mUID,o,true);
		}

		private function listRender(cell:bagItemUI,index:int):void{
			cell.setData(this.list.array[index][0],this.list.array[index][1],-1);
		}

		override public function onRemoved():void{

		}
	}

}