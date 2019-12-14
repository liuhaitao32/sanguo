package sg.view.country
{
	import sg.manager.ModelManager;
	import sg.net.NetPackage;
	import sg.manager.ViewManager;
	import sg.fight.FightMain;
	import sg.model.ModelClub;
	import laya.utils.Handler;
	import sg.net.NetSocket;
	import ui.guild.guildTroopUI;
	import sg.view.fight.ItemTroop;
	import laya.events.Event;
	import sg.utils.Tools;

	/**
	 * ...
	 * @author
	 */
	public class ViewAlienTroop extends guildTroopUI{

		private var mLv:Number;
		private var mListData:Array=[];
		private var mIsOne:Boolean;
		private var mModel:ModelClub;
		private var mHeroArr:Array=[];
		private var mBusyHeroArr:Array=[];
		private var mLowPower:Number;
		public function ViewAlienTroop(){
			this.list.scrollBar.visible=false;
			this.list.itemRender=ItemTroop;
			this.list.renderHandler=new Handler(this,this.listRender);
			this.list.selectHandler=new Handler(this,this.listSelect);
			this.btnOK.on(Event.CLICK,this,this.joinClick);
			this.text2.text="";
			this.text3.text=Tools.getMsgById("_guild_text47");
			this.text4.text=Tools.getMsgById("_guild_text114");
			this.text5.text=Tools.getMsgById("193007");
		}

		override public function onAdded():void{
			mHeroArr=[];
			mBusyHeroArr=[];
			this.btnOK.gray=true;
			mLv=this.currArg;
			mModel=ModelManager.instance.modelClub;
			mLowPower=mModel.getLowPower(mLv);
			this.box0.visible=false;
			this.comTitle.setViewTitle(Tools.getMsgById("_guild_text57"));
			this.btnOK.label=Tools.getMsgById("_guild_text59");//"确认创建":"确认加入";
			this.comPower.setNum(mLowPower);
			setData();
		}

		public function setData():void{
			getBusyHeroArr();
			mListData=ModelManager.instance.modelUser.getMyHeroArr(true,"",null,true);
			this.list.array=mListData;
			this.list.selectedIndex=-1;
			var n:Number=ModelManager.instance.modelClub.getMyHeroNum(mLv);
			mIsOne=n==ModelManager.instance.modelClub.max_player_hero-1;
			setTextLabel(n);
		}

		public function getBusyHeroArr():void{
			mBusyHeroArr=[];
			var all:Array=ModelManager.instance.modelClub.alien;
			for(var i:int=0;i<all.length;i++){
				if(all[i].lock==null){
					var team:Array=all[i]["team"][0]["troop"];
					for(var j:int=0;j<team.length;j++){
						var o:Object=team[j];
						if(o.uid==ModelManager.instance.modelUser.mUID){
							mBusyHeroArr.push(o.hid);
						}
					}
				}
			}
		}


		public function setTextLabel(n:Number):void{
			this.box0.visible=true;
			this.text2.text=n+"/"+ModelManager.instance.modelClub.max_player_hero;
			btnOK.gray=!(n>=1);
		}

		public function listSelect(index:int):void{

		}

		public function listRender(cell:ItemTroop,index:int):void{
			cell.setData(mHeroArr.indexOf(mListData[index].id)!=-1,mListData[index]);
			cell.boxState.visible=false;
			cell.all.gray=(mBusyHeroArr.indexOf(mListData[index].id)!=-1) || (mListData[index].getPower()<mLowPower);
			cell.tPowerInfo.visible=(mListData[index].getPower()<mLowPower);
			cell.offAll(Event.CLICK);
			cell.on(Event.CLICK,this,this.itemClick,[index,cell]);
		}

		public function itemClick(index:int,item:ItemTroop):void{
			if(item.all.gray){
				return;
			}
			if(mIsOne){
				btnOK.gray=false;
				if(index==this.list.selectedIndex){
					return;
				}
				mHeroArr=[];
				mHeroArr.push(this.mListData[index].id);
				this.list.selectedIndex=index;
			}else{
				if(item.mSelected){
					var n:Number=mHeroArr.indexOf(this.mListData[index].id);
					if(n!=-1){
						mHeroArr.splice(n,1);
					}
					item.setData(false,null);	
				}else{
					if(mHeroArr.length==2){
						return;
					}
					mHeroArr.push(this.mListData[index].id);
					item.setData(true,null);
				}
				setTextLabel(mHeroArr.length);
			}
		}

		public function joinClick():void{
			if(mHeroArr.length==0){
				return;
			}
			var sendData:Object={};
			sendData["hids"]=mHeroArr;
			sendData["alien_id"]=mLv;
			NetSocket.instance.send("club_alien_join",sendData,Handler.create(this,socketCallBack));
		}

		public function socketCallBack(np:NetPackage):void{
			ModelManager.instance.modelUser.updateData(np.receiveData);
			ViewManager.instance.closePanel(this);
			//异族入侵加入队伍，人满自动开战
			var receiveData:* = np.receiveData;
			if (receiveData.pk_data){
				FightMain.startBattle(receiveData, this, this.outFight, [receiveData]);
			}else{
				ModelManager.instance.modelClub.event(ModelClub.EVENT_ALIEN_MSG);
			}
		}
		private function outFight(receiveData:*):void{
			NetSocket.instance.send("get_club_alien",{},Handler.create(this,function(pp:NetPackage):void{
				ModelManager.instance.modelUser.updateData(pp.receiveData);
				ModelManager.instance.modelClub.event(ModelClub.EVENT_ALIEN_MSG);
			}));
		}

		override public function onRemoved():void{
			this.list.scrollBar.value=0;
		}
	}
}