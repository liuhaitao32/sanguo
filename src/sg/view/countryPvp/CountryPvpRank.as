package sg.view.countryPvp
{
	import laya.events.Event;
	import ui.countryPvp.country_pvp_rankUI;
	import laya.utils.Handler;
	import ui.countryPvp.item_country_pvp_rankUI;
	import sg.utils.Tools;
	import sg.model.ModelCountryPvp;
	import sg.manager.ModelManager;
	import sg.model.ModelUser;
	import sg.cfg.ConfigServer;
	import ui.bag.bagItemUI;
	import sg.manager.ViewManager;

	/**
	 * ...
	 * @author
	 */
	public class CountryPvpRank extends country_pvp_rankUI{//战功排行

		private var mModel:ModelCountryPvp;
		private var mArr:Array;
		private var mMyRank:Number;
		private var mCredit:Number;
		private var mReward:Array;
		public function CountryPvpRank(_data:*){
			this.on(Event.REMOVED,this,this.onRemove);
			var n:Number=Laya.stage.height-60-45-55;			
			if(n>788){
				this.height=n;
			}else{
				this.height=788;
			}
			mModel=ModelManager.instance.modelCountryPvp;
			mArr=_data?_data:[];
			this.cTitle.setSamllTitle(Tools.getMsgById("_countrypvp_text15"));//"襄阳战结束时结算排行，通过邮件发送奖励");
			this.text01.text=Tools.getMsgById("_countrypvp_text16");//"排行";
			this.text02.text=Tools.getMsgById("_countrypvp_text17");//"玩家名称";
			this.text03.text=Tools.getMsgById("_countrypvp_text18");//"战功";
			this.text04.text=Tools.getMsgById("_countrypvp_text19");//"奖励";
			
			this.list.itemRender=ItemCountryPvpRank;
			this.list.renderHandler=new Handler(this,listRender);
			this.list.scrollBar.visible=false;
			
			mCredit=mModel.myCredit;
			mMyRank=-1;
			var cfgReward:Array=ConfigServer.country_pvp.total_ranking['reward_'+ModelManager.instance.modelUser.mergeNum];
			for(var i:int=0;i<mArr.length;i++){
				if(mArr[i].data[0]==ModelManager.instance.modelUser.mUID){
					mMyRank=i;
					mCredit=mArr[i].num;
				}
				for(var j:int=0;j<cfgReward.length;j++){
					if(i<cfgReward[j][0]){
						mArr[i]["reward"]=ModelManager.instance.modelProp.getCfgPropArr(cfgReward[j][1]);
						break;
					}
				}
			}
			this.bAsk.on(Event.CLICK,this,askClick);
			setData();
			this.list.scrollBar.value=0;
		}

		private function setData():void{
			var m:ModelUser=ModelManager.instance.modelUser;
			this.list.array=mArr;
			mReward=mMyRank==-1?[]:this.list.array[mMyRank].reward;
			renderItem(cItem,{"data":[m.mUID,m.uname,m.head,m.country],"num":mCredit,"reward":mReward},mMyRank);
			this.tTips.text=mArr.length==0 ? Tools.getMsgById("_countrypvp_text32") : "";
		}

		private function listRender(cell:ItemCountryPvpRank,index:int):void{
			//[uid,uname,head,country,online,b001lv,power,kill,build,dead]
			var a:Array=this.list.array[index];
			cell.setData(a,index);
			cell.off(Event.CLICK,this,itemClick);
			cell.on(Event.CLICK,this,itemClick,[a.data[0]]);
		}

		private function itemClick(_uid:String):void{
			ModelManager.instance.modelUser.selectUserInfo(_uid);
		}

		private function renderItem(item:*,obj:Object,index:int):void{
			item.cRank.setRankIndex(index+1,Tools.getMsgById("_public101"),true);
			item.tName.text=obj.data[1];
			item.tName.color=(obj.data[0]+""==ModelManager.instance.modelUser.mUID)?"#10F010":"#FFFFFF";
			item.cFlag.setCountryFlag(obj.data[3]);
			item.tNum.text=obj.num;			
			item.list.renderHandler=new Handler(this,rListRender);
			item.list.array=mReward;
		}

		private function rListRender(cell:bagItemUI,index:int):void{
			cell.setData(mReward[index][0],mReward[index][1],-1);
		}

		private function askClick():void{
			ViewManager.instance.showTipsPanel(Tools.getMsgById(ConfigServer.country_pvp.total_ranking.info));
		}


		private function onRemove():void{
            this.destroyChildren();
            this.destroy(true);
        }
	}

}

