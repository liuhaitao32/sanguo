package sg.view.country
{
	import ui.country.alien_troop_infoUI;
	import laya.utils.Handler;
	import laya.events.Event;
	import sg.manager.ModelManager;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.model.ModelClub;
	import sg.manager.ViewManager;
	import sg.utils.Tools;
	import sg.cfg.ConfigClass;
	import sg.model.ModelHero;
	import sg.cfg.ConfigServer;
	import sg.model.ModelOfficial;

	/**
	 * ...
	 * @author
	 */
	public class ViewAlienTroopInfo extends alien_troop_infoUI{

		private var mListData:Array;
		private var mLv:Number=0;
		private var mCanJoin:Boolean=false;
		private var mRefreshTime:Number;
		private var mTroopLen:Number;
		public function ViewAlienTroopInfo(){
			ModelManager.instance.modelClub.on(ModelClub.EVENT_ALIEN_MSG,this,eventCallBack);
			this.btn1.on(Event.CLICK,this,chatClick);
			this.btn2.on(Event.CLICK,this,joinClick);
			this.btn2.label=Tools.getMsgById("_guild_text57");
			this.list.scrollBar.visible=false;
			this.list.itemRender=Item;
			this.list.renderHandler=new Handler(this,listRender);

			this.text0.text=Tools.getMsgById("_country80");
			this.text1.text=Tools.getMsgById("_country79");
			this.text2.text=Tools.getMsgById("_country66");
			
			this.comTitle.setViewTitle(Tools.getMsgById("_country81"));
		}

		public function eventCallBack():void{
			var n:Number=ModelManager.instance.modelClub.alien[mLv]["team"][0]["troop"];
			if(n!=mTroopLen){
				setData();
			}
		}


		override public function onAdded():void{
			ModelManager.instance.modelOfficel.on(ModelOfficial.EVENT_UPDATE_ALIEN_CD,this,setCallBtn);
			mLv=this.currArg?this.currArg:0;
			setData();
		}

		public function setData():void{
			mRefreshTime=ModelManager.instance.modelClub.getFightTimeByIndex(mLv);
			setCallBtn();
			setTimerLabel();
			mListData=ModelManager.instance.modelClub.alien[mLv]["team"][0]["troop"];
			mTroopLen=mListData.length;
			if(mListData.length==0){
				ViewManager.instance.closePanel(this);
				return;
			}else{
				this.list.array=mListData;
				var n:Number=ModelManager.instance.modelClub.getMyHeroNum(mLv);
				mCanJoin = n<ModelManager.instance.modelClub.max_player_hero;
			}
			this.btn2.gray=!mCanJoin;

			this.numLabel.text=mListData.length+"/"+ModelManager.instance.modelClub.max_hero;
		}

		public function listRender(cell:Item,index:int):void{
			var o:Object=this.list.array[index];
			cell.setData(o,index);
			cell.btn0.on(Event.CLICK,this,this.btnClick,[index]);

		}

		public function btnClick(index:int):void{
			var sendData:Object={};
			sendData["troop_index"]=index;
			sendData["alien_id"]=mLv;
			NetSocket.instance.send("club_alien_quit",sendData,Handler.create(this,outCallBack));
		}

		public function outCallBack(np:NetPackage):void{
			ModelManager.instance.modelUser.updateData(np.receiveData);
			ModelManager.instance.modelClub.event(ModelClub.EVENT_ALIEN_MSG);
			setData();
		}

		public function joinClick():void{
			if(mCanJoin){
				ViewManager.instance.showView(["ViewAlienTroop",ViewAlienTroop],mLv);
			}
		}

		public function chatClick():void{
		//	if(ModelManager.instance.modelGuild.getAlienLastTime(curLv)!=0){
		//		return;
		//	}
			if(btn1.gray){
				return;
			}
			var sendData:Object={};
			sendData["icon"]=1;
			sendData["type"]="country_call";
			sendData["key"]=mLv;
			sendData["msg"]=ModelHero.getHeroName(ModelManager.instance.modelClub.alien[mLv]["team"][1]["troop"][0]["hid"]);
			NetSocket.instance.send("chat",sendData,new Handler(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				ModelManager.instance.modelChat.acceptMSG(np.receiveData.chat);
				ModelManager.instance.modelOfficel.setCallCD(np.receiveData.call_cd);
				//ModelManager.instance.modelGuild.alienCallCD[curLv+""]=ConfigServer.getServerTimer();
				//setCallBtn();
				setCallBtn();
			}));
		}

		public function setCallBtn():void{
			var n:Number = ConfigServer.getServerTimer()-ModelManager.instance.modelOfficel.getCallCD(mLv);
			var m:Number = ConfigServer.country_club.alien.cd * 1000;
			if(n>m){
				this.btn1.label=Tools.getMsgById("_guild_text45");//"召集";
				this.btn1.gray=false;
			}else{
				this.btn1.label=Tools.getTimeStyle(m-n);
				this.btn1.gray=true;
				timer.once(1000,this,setCallBtn);
			}
			
			
			
		}
		public function setTimerLabel():void{
			var now:Number=ConfigServer.getServerTimer();
			if(mRefreshTime-now<=0){
				this.timerLabel.text="";
			}else{
				this.timerLabel.text=Tools.getTimeStyle(mRefreshTime-now);
			}
			timer.once(1000,this,setTimerLabel);
		}

		override public function onRemoved():void{
			ModelManager.instance.modelOfficel.off(ModelOfficial.EVENT_UPDATE_ALIEN_CD,this,setCallBtn);
		}
	}

}

import sg.model.ModelHero;
import sg.manager.ModelManager;
import sg.utils.Tools;
import sg.cfg.ConfigServer;
import sg.model.ModelPrepare;
import ui.country.item_alien_troop_infoUI;
import sg.manager.EffectManager;

class Item extends item_alien_troop_infoUI{
	public function Item(){

	}

	public function setData(obj:*,index:int):void{
		var hmd:ModelHero;
		var pmd:ModelPrepare;
		this.btn0.label=Tools.getMsgById("_guild_text50");
		if(obj.uid+""==ModelManager.instance.modelUser.mUID){
			hmd=ModelManager.instance.modelGame.getModelHero(obj.hid);
			pmd=hmd.getPrepare();
			this.btn0.visible=true;
		}else{
			this.btn0.visible=false;
			hmd=new ModelHero(true);
			hmd.setData(obj);
			pmd=hmd.getPrepare(true,obj);
		}
		
		this.heroIcon.setHeroIcon(hmd.getHeadId(),true,hmd.getStarGradeColor());
		this.uNameLabel.text = obj.uname;
		this.hNameLabel.text = hmd.getName();
		this.hNameLabel.color = hmd.getNameColor();
		this.comPower.setNum(hmd.getPower());
		this.comType.setHeroType(hmd.getType());
		this.comArmy0.setArmyIcon(hmd.army[0],0,true);
		this.comArmy1.setArmyIcon(hmd.army[1],0,true);
		this.lvLabel.text = hmd.getLv() + "";
		this.imgBG.visible = false;
		//EffectManager.changeSprColor(this.imgBG,hmd.getStarGradeColor());
		this.indexLabel.text=Tools.getMsgById("_guild_text84",[index+1]);// "第"+(index+1)+"阵";
		
		
	}
}