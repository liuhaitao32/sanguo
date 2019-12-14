package sg.view.countryPvp
{
	import ui.countryPvp.country_pvp_killUI;
	import ui.countryPvp.item_country_pvp_killUI;
	import laya.utils.Handler;
	import sg.model.ModelUser;
	import sg.utils.Tools;
	import laya.events.Event;
	import sg.manager.ModelManager;


	/**
	 * ...
	 * @author
	 */
	public class ViewCountryPvpKill extends country_pvp_killUI{
		
		private var mArr:Array;
		public function ViewCountryPvpKill(){
			this.list.scrollBar.visible=false;
			this.list.renderHandler=new Handler(this,listRender);
			this.text0.text=Tools.getMsgById("_countrypvp_text16");
			this.text1.text=Tools.getMsgById("_countrypvp_text17");
			this.text2.text=Tools.getMsgById("_country42");
		}

		override public function onAdded():void{
			this.cTitle.setViewTitle(Tools.getMsgById("_countrypvp_text12"));
			this.mArr = this.currArg ? this.currArg : [];
			this.list.array=this.mArr;
		}

		private function listRender(cell:item_country_pvp_killUI,index:int):void{
			var a:Array=this.list.array[index];
			cell.cRank.setRankIndex(index+1,"",true);
			cell.cHead.setHeroIcon(ModelUser.getUserHead(a.data[2]));
			cell.cFlag.setCountryFlag(a.data[3]);
			cell.tName.text=a.data[1];
			cell.tName.color=(a.data[0]+""==ModelManager.instance.modelUser.mUID)?"#10F010":"#FFFFFF";
			cell.tNum.text=a.num;
			
			cell.off(Event.CLICK,this,itemClick);
			cell.on(Event.CLICK,this,itemClick,[a.data[0]]);
		}

		private function itemClick(_uid:String):void{
			ModelManager.instance.modelUser.selectUserInfo(_uid);
		}



		override public function onRemoved():void{
			this.list.scrollBar.value=0;
		}
	}

}