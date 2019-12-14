package sg.view.countryPvp
{
	import ui.countryPvp.buildCarUI;
	import sg.cfg.ConfigServer;
	import sg.manager.AssetsManager;
	import sg.utils.Tools;
	import sg.manager.ModelManager;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import sg.net.NetSocket;
	import sg.model.ModelCountryPvp;
	import sg.net.NetPackage;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import laya.ui.Box;
	import laya.html.dom.HTMLDivElement;
	import sg.model.ModelOfficial;
	import sg.utils.StringUtil;
	import sg.cfg.ConfigColor;
	import laya.display.Animation;
	import sg.manager.EffectManager;
	import ui.countryPvp.item_carUI;
	import sg.utils.MusicManager;
	import laya.maths.Point;

	/**
	 * ...
	 * @author
	 */
	public class ViewBuildCar extends buildCarUI{

		private var cfg:Object;
		private var mModel:ModelCountryPvp;
		private var cfgGoldHammer:Object;
		private var cfgAirHammer:Object;
		private var mCarId:String;
		private var mCarIndex:Number;
		private var mCarExp:Number;
		private var userXyz:Object;
		private var mGoldNum:Number;
		private var mAirNum:Number;
		private var mGoldTime:Number;
		private var mAirTime:Number;
		public function ViewBuildCar(){
			this.cTitle.setViewTitle(Tools.getMsgById("_countrypvp_text27"));//"攻城器械");
			this.text0.text=Tools.getMsgById("_countrypvp_text45");
			this.btn0.on(Event.CLICK,this,btnClick,[0]);
			this.btn1.on(Event.CLICK,this,btnClick,[1]);

			this.list.renderHandler=new Handler(this,listRender);
			this.list.scrollBar.visible=false;
			this.list.scrollBar.touchScrollEnable=false;

			this.btnAsk.on(Event.CLICK,this,function():void{
				ViewManager.instance.showTipsPanel(Tools.getMsgById(ConfigServer.country_pvp.ballista.info));
			});

			this.carPanel.hScrollBar.visible=false;
			this.carPanel.hScrollBar.touchScrollEnable=false;
		}

		override public function onAdded():void{
			//this.timeBox0.visible=
			this.timeBox1.visible=false;
			ModelManager.instance.modelCountryPvp.on(ModelCountryPvp.EVENT_XYZ_TIME_OUT,this,callBack);
			mModel=ModelManager.instance.modelCountryPvp;
			userXyz=ModelManager.instance.modelUser.xyz;
			mModel.on(ModelCountryPvp.EVENT_UPDATE_BALLISTA,this,eventCallBack);
			cfg=ConfigServer.country_pvp.ballista;
			setData();
			setPro();
			this.pPro.value=mCarExp/cfg[mCarId].install;
			this.tPro.text=mCarExp+"/"+cfg[mCarId].install;
			
			this.btn0.label=Tools.getMsgById("_countrypvp_text33");
			this.btn1.label=Tools.getMsgById("_countrypvp_text34");

			
			if(mModel.isOpen==false){
				//this.tTime0.text=
				this.tTime1.text="";	
				this.btn0.gray=this.btn1.gray=true;
				setBtn(-1,0);
				this.cCost0.setData(AssetsManager.getAssetItemOrPayByID(cfgGoldHammer.consume[0]),cfgGoldHammer.consume[1]);
				this.cCost1.setData(AssetsManager.getAssetItemOrPayByID(cfgAirHammer.consume[0]),cfgAirHammer.consume[1]);
				this.cCost2.setData("ui/icon_army13.png","1");
			}else{
				this.btn0.gray=this.btn1.gray=false;
				updateBtn();
			}

			setInfoList();
			initCar();
		}

		public function callBack():void{
			this.closeSelf();
		}

		private function setData():void{
			mCarExp=mModel.xyz   ? mModel.xyz.ballista_exp[ModelManager.instance.modelUser.country]:0;
			mCarIndex=mModel.xyz ? mModel.xyz.ballista_num[ModelManager.instance.modelUser.country]:0;
			mCarIndex=mCarIndex % cfg.order.length;
			mCarId=cfg.order[mCarIndex];

			cfgGoldHammer=cfg.gold_hammer;//花钱的
			cfgAirHammer=cfg.air_hammer;//免费的

			//var reward0:Array=ModelManager.instance.modelProp.getRewardProp(cfgGoldHammer.reward);
			//var reward1:Array=ModelManager.instance.modelProp.getRewardProp(cfgAirHammer.reward);
			
			this.cCost0.off(Event.CLICK,this,rewardClick);
			this.cCost0.on(Event.CLICK,this,rewardClick,[cfgGoldHammer.consume[0]]);

			this.cCost1.off(Event.CLICK,this,rewardClick);
			this.cCost1.on(Event.CLICK,this,rewardClick,[cfgAirHammer.consume[0]]);
			
			

		}

		private function initCar():void{
			carPanel.destroyChildren();
			var n:Number=0;
			for(var i:int=0;i<=cfg.order.length;i++){
				var c:item_carUI=new item_carUI();
				c.name="com"+(cfg.order.length - i);
				carPanel.addChild(c);
				c.x=c.width*i;
				n+=c.width;
			}
			carPanel.hScrollBar.max=n;
			carPanel.hScrollBar.value=carPanel.hScrollBar.max;
			for(var j:int=0;j<=cfg.order.length;j++){
				var com:item_carUI=carPanel.getChildByName("com"+j) as item_carUI;
				setCarCom(com,j);
				com.boxSelect.visible=j==0;
			}

		}

		private function carClick(index:int):void{
			this.imgBig.skin=AssetsManager.getAssetsAD(cfg[cfg.order[(index+mCarIndex) % cfg.order.length]].chart);
			for(var j:int=0;j<=cfg.order.length;j++){
				var com:item_carUI=carPanel.getChildByName("com"+j) as item_carUI;
				com.boxSelect.visible=j==index;
			}

		}

		private function updateCar():void{
			carPanel.hScrollBar.value=carPanel.hScrollBar.max;
			for(var j:int=0;j<=cfg.order.length;j++){
				var com:item_carUI=carPanel.getChildByName("com"+j) as item_carUI;
				setCarCom(com,j);
				com.boxSelect.visible=j==0;
			}
			carClick(0);
		}

		private function setCarCom(com:item_carUI,index:int):void{
			com.text0.text=Tools.getMsgById("_countrypvp_text46");
			com.text1.text=Tools.getMsgById("_countrypvp_text47");
			com.off(Event.CLICK,this,carClick);
			com.on(Event.CLICK,this,carClick,[index]);
			var n:Number = (index+mCarIndex) % cfg.order.length;
			var cid:String = cfg.order[n];
			if(ModelManager.instance.modelCountryPvp.isOpen){
				com.box0.visible = index!=0;
				com.box1.visible = index==0;
			}else{
				com.box0.visible=com.box1.visible=false;
			}

			var a:Animation;
			com.aniBox.destroyChildren();
			a = EffectManager.loadHeroAnimation(ModelCountryPvp.carObj[cid],true);
			a.name="car";
			com.aniBox.addChild(a);			
			a.play(0,true,"down");
			if(index!=0) a.stop();
			
			a.alpha = com.box0.alpha = com.box1.alpha = index==0 ? 1 : 0.5;

			a.scaleX=a.scaleY=0.45;
			a.x=com.width/2;
			a.y=com.height*2/3;
			
		}

		private function eventCallBack():void{
			mCarExp=mModel.xyz.ballista_exp[ModelManager.instance.modelUser.country];
			mCarId=cfg.order[mCarIndex];
			var n:Number=mModel.xyz.ballista_num[ModelManager.instance.modelUser.country];
			n=n % cfg.order.length;
			var b:Boolean=n==mCarIndex;
			mCarIndex=mModel.xyz.ballista_num[ModelManager.instance.modelUser.country];
			mCarIndex=mCarIndex % cfg.order.length;
			mCarId=cfg.order[mCarIndex];
			if(!b){
				MusicManager.playSoundUI(MusicManager.SOUND_XYZ_5);
				var a:Animation=EffectManager.loadAnimation("glow052",'',1);
				this.proBox.addChild(a);
				a.x=this.proBox.width/2;
				a.y=this.proBox.height/2;
				a.scaleX=1.08;
				Tween.to(carPanel.hScrollBar,{value:0},200,null,new Handler(this,function():void{
					updateCar();
				}));
				setPro();
			}
			updatePro();
			setInfoList();
		}


		private function setInfoList():void{
			var arr:Array=mModel.buildInfoArr;
			this.list.array=arr;
			this.list.scrollBar.value=this.list.scrollBar.max;
			this.infoBox.height=arr.length>=7 ? 154 : arr.length*22;
		}

		private function listRender(cell:Box,index:int):void{
			var info:HTMLDivElement=cell.getChildByName("info") as HTMLDivElement;
			info.style.color="#ffffff";
			info.style.fontSize=16;
			info.style.align="left";
			info.style.letterSpacing=1;
			info.style.leading=0;
			var a:Array=this.list.array[index];
			var s:String=StringUtil.htmlFontColor(a[0]+"",a[0]==1000 ? "#abff67" : "#ffffff");
			info.innerHTML=Tools.getMsgById("500032",[ModelOfficial.getOfficerName(a[2],ModelOfficial.getInvade()),a[1],s]);
		}

		private function setPro():void{
			//this.tTitle.text=Tools.getMsgById(cfg[mCarId].info);
			this.tName.text=Tools.getMsgById(cfg[mCarId].name);
			this.imgBig.skin=AssetsManager.getAssetsAD(cfg[mCarId].chart);

		}

		private function updatePro():void{
			var n:Number=mCarExp/cfg[mCarId].install;
			if(cfg[mCarId] && cfg[mCarId].install) proTween(this.pPro.value,n,500);
			else this.pPro.value=0;

			if(cfg[mCarId] && cfg[mCarId].install) this.tPro.text=mCarExp+"/"+cfg[mCarId].install;
			else this.tPro.text="";
		}

		private function proTween(n1:Number,n2:Number,t:Number):void{
			var _this:*=this;
			
			if(n2>n1){
				Tween.to(this.pPro,{"value":n2},t,null,new Handler(this,function():void{
					_this.pPro.value=mCarExp/cfg[mCarId].install;
				}));
			}else{
				Tween.to(this.pPro,{"value":1},t*(1-n2),null,new Handler(this,function():void{
					_this.pPro.value=0;
					if(n1==n2 && n1==0) return;
					proTween(0,n2,t*n2);
				}));
			}
			
		}

		private function updateBtn():void{
			var n:Number=ConfigServer.getServerTimer();
			mGoldNum = -1;//getHammerNum(0);
			mAirNum  = getHammerNum(1);
			mGoldNum = mGoldNum>cfg.gold_hammer.num_max ? cfg.gold_hammer.num_max : mGoldNum;
			mAirNum  = mAirNum>cfg.air_hammer.num_max   ? cfg.air_hammer.num_max  : mAirNum;

			var b0:Boolean=Tools.isCanBuy(cfgGoldHammer.consume[0],cfgGoldHammer.consume[1],false);
			var b1:Boolean=Tools.isCanBuy(cfgAirHammer.consume[0],cfgAirHammer.consume[1],false);

			this.btn0.gray=mGoldNum==0 || !b0;
			this.btn1.gray=mAirNum==0 || !b1;

			this.cCost0.setData(AssetsManager.getAssetItemOrPayByID(cfgGoldHammer.consume[0]),cfgGoldHammer.consume[1],b0 ? 0 : 1);
			this.cCost1.setData(AssetsManager.getAssetItemOrPayByID(cfgAirHammer.consume[0]),cfgAirHammer.consume[1],b1 ? 0 : 1);
			this.cCost2.setData("ui/icon_army13.png","1",mAirNum>0 ? 0 : 1);

			//setBtn(mGoldNum,mAirNum);
			this.tAir.text=mAirNum+"/"+cfgAirHammer.num_max;
			
			var b:Boolean=false;
			
			if(mAirNum<cfg.air_hammer.num_max){
				this.hamBox.y=0;
				b=true;
			}else {
				//this.tTime1.text=Tools.getMsgById("_countrypvp_text44",[Math.round(cfgAirHammer.num_reply/60)]);
				this.hamBox.y=11;
				this.tTime1.text="";
			}
			this.timeBox1.visible=(mAirNum!=-1);

			Laya.timer.clear(this,setTimerLabel);
			mGoldTime=-1;//getHammerTime(0);
			mAirTime=getHammerTime(1);
			if(b) setTimerLabel();
			
		}

		private function setBtn(n0:Number,n1:Number):void{
			//this.btn0.setData(AssetsManager.getAssetsUI("icon_army13.png"),(n0==-1) ? "" : "("+n0+"/"+cfg.gold_hammer.num_max+")");
			//this.btn1.setData(AssetsManager.getAssetsUI("icon_army13.png"),(n1==-1) ? "" : "("+n1+"/"+cfg.air_hammer.num_max+")");

			//this.btn0.textlabel.y=(n0==-1) ? 18 : 4;
			//this.btn1.textlabel.y=(n1==-1) ? 18 : 4;
		}

		private function rewardClick(_id:String):void{
			ViewManager.instance.showItemTips(_id);
		}

		private function btnClick(type:int):void{
			if(mModel.isOpen==false){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_countrypvp_text40"));
				return;
			}
			var s:String;
			if(type==0){
				s="gold_hammer";
				if(!Tools.isCanBuy(cfgGoldHammer.consume[0],cfgGoldHammer.consume[1])) return;
				if(mGoldNum==0) return;
         
				ViewManager.instance.showAlert(Tools.getMsgById("_countrypvp_text49"),
						Handler.create(this,this.sendSocket,[s]),["coin",cfgGoldHammer.consume[1]],"",false,false,"build_car");


			}else{
				s="air_hammer";
				if(!Tools.isCanBuy(cfgAirHammer.consume[0],cfgAirHammer.consume[1])) return;
				if(mAirNum==0) return;

				sendSocket(s,0);
			}
		}

		private function sendSocket(s:String,type:int):void{
			if(type!=0) return;
			NetSocket.instance.send("w.build_ballista",{"type":s},Handler.create(this,this.socketCallBack));
		}

		private function socketCallBack(np:*):void{
			MusicManager.playSoundUI(MusicManager.SOUND_XYZ_4);
			ModelManager.instance.modelUser.updateData(np.receiveData);
			var pos:Point = Point.TEMP.setTo(this.mouseX,this.mouseY);
			pos = this.localToGlobal(pos, true);
			ViewManager.instance.showIcon(np.receiveData.gift_dict,pos.x,pos.y,false,"");
			ModelManager.instance.modelCountryPvp.updateXYZ(np.receiveData);
			ModelManager.instance.modelCountryPvp.buildInfoArr.push([ConfigServer.country_pvp.ballista[np.sendData.type].progress,
																	ModelManager.instance.modelUser.uname,
																	ModelOfficial.getMyOfficerId()]);
			userXyz=ModelManager.instance.modelUser.xyz;
			updateBtn();
			eventCallBack();
		}


		private function setTimerLabel():void{
			var now:Number=ConfigServer.getServerTimer();
			if(mGoldTime==-1){
				//this.tTime0.text="";
			}else if(mGoldTime<=0){
				updateBtn();
			}else{
				//this.tTime0.text=Tools.getMsgById("_countrypvp_text28",[Tools.getTimeStyle(mGoldTime)]);
			}
			if(mAirTime==-1){
				this.tTime1.text="";
			}else if(mAirTime<0){
				updateBtn();
			}else{
				this.tTime1.text=Tools.getMsgById("_countrypvp_text28",[Tools.getTimeStyle(mAirTime)]);
			}

			//this.timeBox0.visible=this.tTime0.text != "";
			this.timeBox1.visible=this.tTime1.text != "";

			if(mGoldTime>0) mGoldTime-=1000;
			if(mAirTime>0) mAirTime-=1000;

			Laya.timer.clear(this,setTimerLabel);
			Laya.timer.once(1000,this,setTimerLabel);
		}

		/**
		 * 锤子数
		 */
		private function getHammerNum(type:int):Number{
			var num:Number=0;
			var n:Number=ConfigServer.getServerTimer();
			var _config:Object = type==0 ? cfg.gold_hammer : cfg.air_hammer;
			var _user:Object   = userXyz ? userXyz.season_num!=mModel.mSeasonNum ? null : (type==0?userXyz.gold_hammer:userXyz.air_hammer) : null;
			var _min:Number    = _config.num_ini;
			var _max:Number    = _config.num_max;
			var _reply:Number  = _config.num_reply*Tools.oneMillis;
			if(_min==-1){
				return -1;//无限次
			}
			if(_user==null){
				if(mModel.isOpen){
					num = _min+Math.round((n-mModel.mSunrise)/_reply);
				}
			}else{
				num = Math.floor((n-Tools.getTimeStamp(_user))/_reply)
			}
			num = num>_max ? _max : num;
			return num;
		}

		/**
		 * 锤子时间
		 */
		private function getHammerTime(type:int):Number{
			var n:Number=ConfigServer.getServerTimer();
			var _config:Object = type==0 ? cfg.gold_hammer : cfg.air_hammer;
			var _min:Number    = _config.num_ini;
			var _max:Number    = _config.num_max;
			var _reply:Number  = _config.num_reply*Tools.oneMillis;
			var _user:Object   = userXyz ? userXyz.season_num!=mModel.mSeasonNum ? null : (type==0 ? userXyz.gold_hammer : userXyz.air_hammer) : null;
			var num:Number     = type==0 ? mGoldNum : mAirNum;
			var re:Number=-1;
			if(num==_max || num==-1){
				re=-1;
			}else{
				if(_user==null){
					if(mModel.isOpen){
						var nn:Number=_reply-(n-mModel.mSunrise)%_reply;
						if(n>0){
							re=nn;
						}else{
							re=-1;
						}
					}
				}else{
					re=_reply-(n-Tools.getTimeStamp(_user))%_reply;
				}
			}
			return re;

		}



		override public function onRemoved():void{
			ModelManager.instance.modelCountryPvp.off(ModelCountryPvp.EVENT_XYZ_TIME_OUT,this,callBack);
			ModelManager.instance.modelCountryPvp.off(ModelCountryPvp.EVENT_UPDATE_BALLISTA,this,eventCallBack);
			Laya.timer.clear(this,setTimerLabel);
		}
	}

}