package sg.view.country
{
	import ui.country.country_alien_mainUI;
	import laya.events.Event;
	import sg.manager.ModelManager;
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;
	import sg.model.ModelGame;
	import ui.bag.bagItemUI;
	import laya.ui.Label;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.model.ModelClub;
	import sg.model.ModelItem;
	import laya.ui.Image;
	import laya.ui.Box;
	import sg.model.ModelHero;
	import sg.utils.StringUtil;
	import sg.manager.AssetsManager;
	import sg.fight.FightMain;
	import sg.model.ModelUser;
	import sg.cfg.ConfigApp;

	/**
	 * ...
	 * @author
	 */
	public class CountryAlienMain extends country_alien_mainUI{

		private var mTimeArr:Array;
		private var mselectData:Object;
		private var mHasMyHero:Boolean;
		private var mModel:ModelClub=ModelManager.instance.modelClub;
		private var mAlienLog:Object;
		private var mLogTimeObj:Object;
		private var mNow:Number;
		private var mRefreshTime:Number;
		private var mIsFight:Boolean;
		public function CountryAlienMain(){
			ModelManager.instance.modelClub.on(ModelClub.EVENT_ALIEN_MSG,this,eventCallBack);
			this.text0.text=Tools.getMsgById("_guild_text37");
			this.text1.text=Tools.getMsgById("_guild_text85");
			this.text2.text=Tools.getMsgById("_guild_text41");
			this.text3.text=Tools.getMsgById("_guild_text86");
			//this.text4.text=Tools.getMsgById("193007");
			//this.text5.text="";

			this.on(Event.REMOVED,this,this.onRemove);
			this.btn.on(Event.CLICK,this,btnClick);
			this.askBtn.on(Event.CLICK,this,askClick);
			this.rewardBox0.on(Event.CLICK,this,boxClick,[0]);
			this.rewardBox1.on(Event.CLICK,this,boxClick,[1]);
			this.rewardBox2.on(Event.CLICK,this,boxClick,[2]);
			this.list.scrollBar.visible=false;
			this.list.itemRender=Item;
			this.list.renderHandler=new Handler(this,listRender);
			this.list.selectHandler=new Handler(this,selectRender);
			this.rewardList.renderHandler=new Handler(this,rewardListRender);
			this.weakList.renderHandler=new Handler(this,weakListRender);
			this.rewardList.scrollBar.visible=false;

			this.html.style.fontSize = this.html2.style.fontSize=16;
			this.html.style.wordWrap = false;
			this.html2.style.wordWrap = (ConfigApp.lan() == 'kr');

			this.html.style.color=this.html2.style.color="#FFFFFF";
			this.html.style.align=this.html2.style.align="center";
			this.init();
		}

		public function eventCallBack():void{
			mRefreshTime=Tools.getTimeStamp(ModelManager.instance.modelClub.alien_refresh_time);
			setList();
			updateData();
			setUI();
			setRewardData();

			ModelManager.instance.modelUser.event(ModelUser.EVENT_USER_UPDATE,[{"country_club":""},true]);//通知红点刷新
			ModelManager.instance.modelClub.event(ModelClub.EVENT_COUNTRY_ALIEN_RED);
			//ModelManager.instance.modelClub.event(ModelClub.EVENT_UPDATE_ALIEN_TROOP_INFO,[this.list.selectedIndex]);
		}

		private function init():void{
			mNow=ConfigServer.getServerTimer();
			mRefreshTime=Tools.getTimeStamp(ModelManager.instance.modelClub.alien_refresh_time);
			setList();
			this.list.scrollBar.value=this.list.scrollBar.max;
			itemClick(mModel.alien.length-1);
			updateTime();
			setRewardData();
		}

		private function updateData():void{
			var n:Number=this.list.selectedIndex;
			if(n<0){
				return;
			}
			mHasMyHero=mModel.getMyHeroNum(n)>0;
			mIsFight=false;
			if(mLogTimeObj.hasOwnProperty(n+"")){
				var nn:Number=mLogTimeObj[n+""];					
				if(mNow-nn<30000){
					mIsFight=true;
				}
			}
		}

		private function setList():void{
			getAlienLog();
			var arr:Array=[];
			arr=mModel.alien.concat();
			if(arr.length<ConfigServer.country_club.alien.instance.length){
				arr.push({"lock":arr.length});
			}
			this.list.array=arr;
			
		}
		private function listRender(cell:Item,index:int):void{
			cell.setData(this.list.array[index],index);
			cell.setSelection(this.list.selectedIndex==index);
			if(mLogTimeObj.hasOwnProperty(index+"")){
				var n:Number=mLogTimeObj[index+""];					
				if(mNow-n<30000){
					cell.setFightIcon(true);
				}else{
					cell.setFightIcon(false);
				}
			}
			cell.off(Event.CLICK,this,this.itemClick);
			cell.on(Event.CLICK,this,this.itemClick,[index]);
		}

		private function getAlienLog():void{
			mAlienLog=null;
			mLogTimeObj={};
			
			if(mModel.alien_log!=null){
				mAlienLog=mModel.alien_log;
				var len:Number=mAlienLog.length;
				for(var s:String in mAlienLog)
				{	
					var n:Number=Tools.getTimeStamp(mAlienLog[s].fight_time);
					if(mNow-n<30000){
						mLogTimeObj[s]=n;
					}
				}
			}
			updateAlienLog();
		}

		private function updateAlienLog():void{
			if(mModel.alien_log!=null){
				for(var s:String in mAlienLog)
				{	
					if(mLogTimeObj[s] && mNow-mLogTimeObj[s]>=30000){
						delete mLogTimeObj[s];
						this.list.refresh();
						mIsFight=this.list.selectedIndex+""==s ? false : mIsFight;
						if(!mIsFight)
							setUI();
					}
				}
				timer.once(1000,this,updateAlienLog);
			}
		}
		private function updateTime():void{
			mNow=ConfigServer.getServerTimer();
			if(mRefreshTime-mNow){
				this.timerLabel.text=Tools.getTimeStyle(mRefreshTime-mNow);
				timer.once(1000,this,updateTime);
			}else{
				this.timerLabel.text="";
				//NetSocket.instance.send("get_club_alien",{},Handler.create(this,getClubCallBack));
			}
			setTimeLabel();
		}
		private function setTimeLabel():void{
			var n:Number=mModel.getFightTimeByIndex(this.list.selectedIndex);
			if(n==-1 || n-mNow<=0){
				this.html2.innerHTML=Tools.getMsgById("_country68");
			}else{
				this.html2.innerHTML=Tools.getMsgById("_country70",[Tools.getTimeStyle(n-mNow)]);
			}
			this.html2.width=this.html2.contextWidth;
			this.html2.x=this.btn.x + (this.btn.width-this.html2.width)/2;
		}

		private function getClubCallBack(np:NetPackage):void{
			ModelManager.instance.modelClub.updateData(np.receiveData.country_club);
			ViewManager.instance.closePanel();
			this.init();
		}

		public function selectRender(index:int):void{
			if(index>-1){
				
			}
		}

		private function itemClick(index:int):void{
			if(index<0){
				return;
			}
			
			if(this.list.selectedIndex!=index){
				this.list.selectedIndex=index;
			}
			updateData();
			mselectData=mModel.alien[this.list.selectedIndex]["team"];
			var troops:Array=mselectData[0]["troop"];
			
			
			var reward:Array=ConfigServer.country_club.alien.instance[this.list.selectedIndex].reward;
			this.rewardList.array=reward;

			var weak_arr:Array=[];
			var weak:Array=mselectData[1]["troop"][0].weak;
			if(weak){
				var config_weak:Array=ConfigServer.country_club.alien.weak.type;
				for(var i:int=0;i<weak.length;i++){
					var arr:Array=weak[i];
					for(var j:int=0;j<config_weak.length;j++){
						var a:Array=config_weak[j][0];
						if(a[0]==arr[0] && a[1]==arr[1]){
							weak_arr.push({"index":j,"icon":a[2],"text":a[3],"num":arr[2]});
							break;
						}
					}
				}
			}
			this.weakList.array=weak_arr;
			this.heroLv.setNum(this.list.selectedIndex+1);
			//this.indexLabel.text=this.list.selectedIndex+1+"";

			var hmd:ModelHero=new ModelHero(true);
			hmd.setData(mselectData[1]["troop"][0]);
			
			this.nameLabel.text=hmd.getName();
			
			this.comPower.setNum(hmd.getPower(hmd.getPrepare(false,mselectData[1]["troop"][0])));

			this.comHero.setHeroIcon(hmd.id,false);

			
			
			//TODO:
			//this.comPowerLow.setNum("");

			setUI();
		}

		private function setUI():void{
			var n:Number=ModelManager.instance.modelClub.getMyHeroNum(this.list.selectedIndex);
			var total:Number=mModel.alien[this.list.selectedIndex]["team"][0]["troop"].length;
			if(mIsFight){
				this.btn.label=Tools.getMsgById("_public98");//查看战斗
			}else{
				this.btn.label = n==mModel.max_player_hero ? Tools.getMsgById("_guild_text115") : Tools.getMsgById("_guild_text57");
			}
			if(total==0){
				this.html.innerHTML="";
				this.imgText.visible=false;
			}else{
				this.html.innerHTML=Tools.getMsgById("_country71",[total,mModel.max_hero]);// "集结中 "+n+"/"+mModel.max_hero;
				this.html.width=this.html.contextWidth;
				this.html.x=this.btn.x + (this.btn.width-this.html.width)/2;
				this.imgText.visible=true;
			}
			//this.comLow.setNum(mModel.getLowPower(this.list.selectedIndex));
			var nn:Number=mModel.getLowPower(this.list.selectedIndex);
			if(nn==0){
				this.comLow.text="";
			}else{
				this.comLow.text=Tools.getMsgById("193007")+" "+mModel.getLowPower(this.list.selectedIndex);
			}
			this.html2.innerHTML="";
			setTimeLabel();
		}



		public function rewardListRender(cell:bagItemUI,index:int):void{
			var it:ModelItem=ModelManager.instance.modelProp.getItemProp(this.rewardList.array[index][0]);
			cell.setData(it.id,1);
		}

		public function weakListRender(cell:Box,index:int):void{
			var obj:Object=this.weakList.array[index];
			var _img:Image=cell.getChildByName("img") as Image;
			var _label0:Label=cell.getChildByName("weak0") as Label;
			var _label1:Label=cell.getChildByName("weak1") as Label;
			
			_img.skin=AssetsManager.getAssetsICON(obj.icon+".png");
			_label0.text=Tools.getMsgById(obj.text);
			_label1.text=Tools.getMsgById("500081",[ModelHero.shogun_name[obj.index],StringUtil.numberToPercent(obj.num)]);
		}



		public function btnClick():void{
			if(mIsFight){
				var obj:Object=ModelManager.instance.modelClub.alien_log[this.list.selectedIndex];
				if(ModelManager.instance.modelClub.alien_log[this.list.selectedIndex]){
					FightMain.startBattle(obj, this, function():void{

					}, [obj]);
				}
				return;
			}
			if(mHasMyHero){
				ViewManager.instance.showView(["ViewAlienTroopInfo",ViewAlienTroopInfo],this.list.selectedIndex);
			}else{
				ViewManager.instance.showView(["ViewAlienTroop",ViewAlienTroop],this.list.selectedIndex);
			}
		}

		public function askClick():void{
			ViewManager.instance.showTipsPanel(Tools.getMsgById(ConfigServer.country_club.alien.info));
		}





		public function setRewardData():void{
			mTimeArr=[];//-1空的  0 可开启 其他开启剩余时间
			var boxData:Array=ModelManager.instance.modelUser.alien_reward;
			var now:Number=ConfigServer.getServerTimer();
			for(var i:int=0;i<3;i++)
			{				
				var img:bagItemUI=this["rewardBox"+i].getChildByName("comIcon") as bagItemUI;
				var o:Object=boxData[i];
				if(img){
					if(o){
						var n:Number=Tools.getTimeStamp(o[1]);
						var it:ModelItem=ModelManager.instance.modelProp.getItemProp(o[0]);
						img.setData(it.id);
						img.visible=true;
						if(now>n){
							mTimeArr.push(0);
						}else{
							mTimeArr.push(Tools.getTimeStamp(o[1]));
						}
					}else{
						img.setIcon("");
						img.setName("");
						img.mCanClick=false;
						mTimeArr.push(-1);
					}
				}
				
			}
			setRewardBox();
		}

		public function setRewardBox():void{
			var now:Number=ConfigServer.getServerTimer();
			for(var i:int=0;i<3;i++){
				var img:bagItemUI=this["rewardBox"+i].getChildByName("comIcon") as bagItemUI;
				img.mCanClick=true;
				var l:Label=this["rewardBox"+i].getChildByName("boxText1") as Label;
				if(mTimeArr[i]==0){
					ModelGame.redCheckOnce(img,true,[img.width-30,10]);
					l.text = Tools.getMsgById("_guild_text54");//"可打开";
					l.color = '#33FF00';
					img.mCanClick=false;
				}else if(mTimeArr[i]==-1){
					ModelGame.redCheckOnce(img,false,[img.width-30,10]);
					l.text = Tools.getMsgById("_guild_text53");//"空闲";
					l.color = '#cadfff';
					img.setIcon("");
					img.setName("");
					img.mCanClick=false;
				}else{
					if(now<mTimeArr[i]){
						ModelGame.redCheckOnce(img,false,[img.width-30,10]);
						l.text=Tools.getTimeStyle(mTimeArr[i]-now,3);						
					}else{
						ModelGame.redCheckOnce(img,true,[img.width-30,10]);
						l.text=Tools.getMsgById("_guild_text54");//"可打开";						
						mTimeArr[i]=0;
						img.mCanClick=false;
					}
				}
			}
			timer.once(1000,this,setRewardBox);
		}

		private function boxClick(index:int):void{
			var n:Number=0;
			if(index==1){
				n=1;
				if(mTimeArr[0]==-1){
					n=0;
				}
			}else if(index==2){
				n=2;
				if(mTimeArr[0]==-1 && mTimeArr[1]==-1){
					n=0;
				}
				if(mTimeArr[0]!=-1 && mTimeArr[1]==-1){
					n=1;
				}
				if(mTimeArr[0]==-1 && mTimeArr[1]!=-1){
					n=1;
				}

			}
			if(mTimeArr[index]==0){
				NetSocket.instance.send("get_alien_reward",{"index":n},Handler.create(this,socketCallBack,[index]));
			}else{

			}
		}

		private function socketCallBack(index:int,np:NetPackage):void{
			mTimeArr[index]=-1;
			ModelManager.instance.modelUser.updateData(np.receiveData);
			setRewardBox();
			ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
		}



		private function onRemove():void{
			ModelManager.instance.modelClub.off(ModelClub.EVENT_ALIEN_MSG,this,eventCallBack);
			this.destroyChildren();
            this.destroy(true);
		}
	}

}



import sg.model.ModelItem;
import sg.manager.ModelManager;
import sg.utils.Tools;
import sg.cfg.ConfigServer;
import sg.manager.AssetsManager;
import ui.country.item_country_alienUI;

class Item extends item_country_alienUI{

	public function Item(){

	}

	public function setData(obj:Object,index:int):void{
		this.img1.visible=this.img2.visible=false;
		this.gray=false;
		this.boxLabel.text="";
		if(obj.hasOwnProperty("lock")){
			this.mouseEnabled=false;
			this.gray=true;
			this.img2.visible=true;
			this.comHero.setHeroIcon("hero000");
			this.boxLabel.text=Tools.getMsgById("_guild_text55",[obj.lock]);
		}else{
			this.mouseEnabled=true;
			this.gray=false;
			if(obj.team[0].troop.length!=0){
				this.img1.visible=true;
				this.img1.skin=AssetsManager.getAssetsUI("icon_jiaobiao05.png");
			}else{
				
			}
			var hid:String=obj["team"][1]["troop"][0]["hid"];
			this.comHero.setHeroIcon(hid);
			this.boxLabel.text=Tools.getMsgById(ConfigServer.hero[hid].name);
		}
		this.heroLv.setNum(index+1);
		//this.indexLabel.text=index+1+"";
		this.textBox.height=this.boxLabel.height+4;
		this.boxLabel.centerY=0;
	}

	public function setFightIcon(b:Boolean):void{
		this.img1.visible=b;
		this.img1.skin=b?AssetsManager.getAssetsUI("icon_jiaobiao19.png"):AssetsManager.getAssetsUI("icon_jiaobiao05.png");
	}

	public function setSelection(b:Boolean):void{
		this.imgSelect.visible=b;
	}

}