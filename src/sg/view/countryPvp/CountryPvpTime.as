package sg.view.countryPvp
{
	import ui.countryPvp.country_pvp_timeUI;
	import laya.events.Event;
	import sg.utils.Tools;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigServer;
	import ui.bag.bagItemUI;
	import sg.manager.ModelManager;
	import laya.utils.Handler;
	import sg.model.ModelCountryPvp;
	import ui.countryPvp.item_country_pvp_rankUI;
	import sg.model.ModelUser;

	/**
	 * ...
	 * @author
	 */
	public class CountryPvpTime extends country_pvp_timeUI{//限时比拼

		private var cfg:Object;
		private var cfgScore:Array;
		private var mSelectIndex:int;

		private var mArr:Array;
		private var mMyRank:Number;
		private var mCredit:Number;
		private var mReward:Array;
		private var mModel:ModelCountryPvp;
		private var mCycTime:Number;
		public function CountryPvpTime(_data:*){
			this.on(Event.REMOVED,this,this.onRemove);
			mModel=ModelManager.instance.modelCountryPvp;
			this.cTitle.setSamllTitle(Tools.getMsgById("_countrypvp_text20"));//"战功达到要求后可获得阶段奖励，奖励通过邮件发放");
			this.text01.text=Tools.getMsgById("_countrypvp_text16");//"排行";
			this.text02.text=Tools.getMsgById("_countrypvp_text17");//"玩家名称";
			this.text03.text=Tools.getMsgById("_countrypvp_text18");//"战功";
			this.text04.text=Tools.getMsgById("_countrypvp_text19");//"奖励";
			this.text1.text=Tools.getMsgById("_countrypvp_text21");//"排行榜奖励倒计时";
			this.text2.text=Tools.getMsgById("_countrypvp_text22");//"阶段奖励";
			this.text3.text=Tools.getMsgById("_countrypvp_text23");//"需要战功";

			cfg=ConfigServer.country_pvp.personal;
			cfgScore = ConfigServer.country_pvp.personal.stage['score_'+ModelManager.instance.modelUser.mergeNum];
			mModel.updateCycleTime();
			mCycTime=mModel.mCycleTime;
			var n:Number=Laya.stage.height-60-45-55;			
			if(n>788){
				this.height=n;
			}else{
				this.height=788;
			}
			this.bLeft.on(Event.CLICK,this,onClick,[0]);
			this.bRight.on(Event.CLICK,this,onClick,[1]);
			this.rlist.renderHandler=new Handler(this,rListRender2);

			mArr=_data?_data:[];
			this.list.itemRender=ItemCountryPvpRank;
			this.list.renderHandler=new Handler(this,listRender);
			this.list.scrollBar.visible=false;
			
			mCredit=mModel.myCreditRound;
			mMyRank=-1;
			var cfgReward:Array=ConfigServer.country_pvp.personal.ranking['reward_'+ModelManager.instance.modelUser.mergeNum];
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

			setData();
			this.bAsk.on(Event.CLICK,this,askClick);

			if(mModel.isOpen==false){
				this.tTime.text=Tools.getMsgById("_countrypvp_text55");
			}else{
				setTimeLabel();
			}

			Tools.textLayout(text1,tTime,timeImg,timeBox);
			Tools.textLayout3(text2,tNum,text2Img,text2Box);
		}

		private function setData():void{
			var arr:Array=cfgScore;//ConfigServer.country_pvp.personal.stage.score;
			mSelectIndex=arr.length-1;
			var n:Number=mModel.myCredit;
			for(var i:int=0;i<arr.length;i++){
				if(n<=arr[i][0]){
					mSelectIndex=i;
					break;
				}
			}
			var m:ModelUser=ModelManager.instance.modelUser;
			this.list.array=mArr;
			mReward=mMyRank==-1?[]:this.list.array[mMyRank].reward;
			renderItem(cItem,{"data":[m.mUID,m.uname,m.head,m.country],"num":mCredit,"reward":mReward},mMyRank);
			setUI();
			this.tTips.text=mArr.length==0 ? Tools.getMsgById("_countrypvp_text32") : "";
		}

		private function setUI():void{
			
			var _credit:Number=mModel.myCredit;//当前战功
			this.tNum.text=(mSelectIndex+1)+"/"+cfgScore.length;
			this.tCredit.text=_credit+"/"+cfgScore[mSelectIndex][0];
			this.rlist.array=ModelManager.instance.modelProp.getCfgPropArr(cfgScore[mSelectIndex][1]);
			this.bLeft.visible=mSelectIndex>0;
			this.bRight.visible=mSelectIndex<cfgScore.length-1;
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

		
		private function renderItem(item:item_country_pvp_rankUI,obj:Object,index:int):void{
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

		private function rListRender2(cell:bagItemUI,index:int):void{
			cell.setData(this.rlist.array[index][0],this.rlist.array[index][1],-1);
		}

		private function setTimeLabel():void{
			if(mModel.isLast()){
				this.tTime.text=Tools.getMsgById("_countrypvp_text54");
				return;
			}
			if(mCycTime==0){
				this.tTime.text="";
				return;
			} 
			
			var n:Number=mCycTime-ConfigServer.getServerTimer();
			if(n<0){
				// trace("限时比拼排行榜刷新");
				mModel.updateCycleTime();
				mCycTime=mModel.mCycleTime;
				this.tTime.text="";
		}else{
				this.tTime.text=Tools.getTimeStyle(n);
			}
			Laya.timer.once(1000,this,setTimeLabel);
		}


		private function onClick(type:int):void{
			if(type==0){
				if(mSelectIndex==0) return;
				mSelectIndex-=1;
				setUI();
			}else{
				if(mSelectIndex==cfgScore.length-1) return;
				mSelectIndex+=1;
				setUI();
			}
		}

		private function askClick():void{
			ViewManager.instance.showTipsPanel(Tools.getMsgById(cfg.info));
		}

		private function onRemove():void{
            this.destroyChildren();
            this.destroy(true);
        }
	}

}