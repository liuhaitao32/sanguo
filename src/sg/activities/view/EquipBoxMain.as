package sg.activities.view
{
	import ui.activities.equipBox.equipBoxMainUI;
	import sg.activities.model.ModelEquipBox;
	import sg.activities.model.ModelActivities;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.cfg.ConfigServer;
	import sg.manager.AssetsManager;
	import sg.utils.Tools;
	import sg.utils.StringUtil;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.manager.ModelManager;
	import sg.model.ModelItem;
	import sg.model.ModelGame;
	import laya.display.Animation;
	import sg.manager.EffectManager;
	import laya.ui.Button;
	import ui.bag.bagItemUI;
	import laya.ui.Box;
	import laya.utils.Tween;
	import laya.particle.Particle2D;
	import laya.maths.Point;
	import laya.utils.Ease;
	import sg.utils.MusicManager;
	import laya.media.SoundChannel;

	/**
	 * ...
	 * @author
	 */
	public class EquipBoxMain extends equipBoxMainUI{

		private var mModel:ModelEquipBox;
		private var mRecoverObj:Object;
		private var mCfg:Object;
		private var mFrontAin0:Animation;
		private var mFrontAin1:Animation;

		private var mReward:Array;
		private var mStep:Number;
		private var mEquipId:String;
		private var mTime:Number;

		private var mSc:SoundChannel;
		private var mEffect:Animation;
		public function EquipBoxMain(){
			mModel=ModelEquipBox.instance;
			this.mModel.on(ModelActivities.UPDATE_DATA, this, this.updateUI);

			this.btn0.on(Event.CLICK,this,onClick,[btn0]);
			this.btn1.on(Event.CLICK,this,onClick,[btn1]);
			this.btnCheck.on(Event.CLICK,this,onClick,[btnCheck]);
			this.btnReCylce.on(Event.CLICK,this,onClick,[btnReCylce]);
			this.btnEquip.on(Event.CLICK,this,onClick,[btnEquip]);
			this.btnShop.on(Event.CLICK,this,onClick,[btnShop]);

			//this.btnCheck.label=Tools.getMsgById("_star_text05");

			this.text0.text=Tools.getMsgById("happy_text01");
			
			this.btnEquip.label=Tools.getMsgById("equip_box0");//"查看混元套装";
			updateUI();
			setTimeLabel();

			this.comNum.on(Event.CLICK,this,function():void{
				ViewManager.instance.showItemTips(mModel.cfg.item_id);
			});
			
			var back:Animation=EffectManager.loadAnimation("glow_arr_equip_back");
			back.x=this.width/2;
			back.y=this.height/2;
			back.zOrder=-1;
			this.imgBG.zOrder=-2;
			this.addChild(back);

			mFrontAin0=EffectManager.loadAnimation("glow_arr_equip_front");
			mFrontAin0.x=this.aniBox.width/2;
			mFrontAin0.y=this.aniBox.height/2;
			mFrontAin0.play(0,true,"_0");
			this.aniBox.addChild(mFrontAin0);

			mFrontAin1=EffectManager.loadAnimation("glow_arr_equip_front1");
			mFrontAin1.blendMode = "lighter";
			mFrontAin1.x=this.aniBox.width/2;
			mFrontAin1.y=this.aniBox.height/2;
			mFrontAin1.play(0,true,"_0");
			this.aniBox.addChild(mFrontAin1);

			var part0:Particle2D = EffectManager.loadParticle("p015",-1,-1,partBox,false,partBox.width/2,partBox.height/2);
			var part1:Particle2D = EffectManager.loadParticle("p016",-1,-1,partBox,false,partBox.width/2,partBox.height/2);

			mBtn.alpha=0;
			mBtn.visible=false;
			mBtn.on(Event.CLICK,this,mBtnClick);
			mStep=0;

			var a:Animation = EffectManager.loadAnimation("glow041");
			this.btnReCylce.addChild(a);
			a.pos(this.btnReCylce.width/2,this.btnReCylce.height/2);
			

		}



		private function setTimeLabel():void{
			this.tTime.text=Tools.getTimeStyle(mModel.time);
			timer.once(1000,this,setTimeLabel);
		}

		public function updateUI():void{
			mCfg=mModel.getGoods();
			if(mCfg==null) return;

			if(mModel.mOneTimes<mCfg.buy_one[0]){
				this.btn0.gray=false;
				this.btn0.setData("",Tools.getMsgById("equip_box5"),-1,1);
			}else{
				this.btn0.gray=!Tools.isCanBuy("coin",mCfg.buy_one[1],false);
				this.btn0.setData(AssetsManager.getAssetItemOrPayByID("coin"),mCfg.buy_one[1]);
			}
				

			if(mModel.mTenTimes<mCfg.buy_ten[0]){
				this.btn1.gray=false;
				this.btn1.setData("",Tools.getMsgById("equip_box5"),-1,1);
			}else{
				this.btn1.gray=!Tools.isCanBuy("coin",mCfg.buy_ten[1],false);
				this.btn1.setData(AssetsManager.getAssetItemOrPayByID("coin"),mCfg.buy_ten[1]);
			}
				
			var item_name:String=ModelItem.getItemName(mModel.cfg.item_id);
			this.tInfo0.text=Tools.getMsgById("equip_box1",[mCfg.buy_one[2]+item_name,StringUtil.numberToChinese(1)]); 
			this.tInfo1.text=Tools.getMsgById("equip_box1",[mCfg.buy_ten[2]+item_name,StringUtil.numberToChinese(10)]);

			var n1:Number=mModel.mBuyTimes;
			var n2:Number=mCfg.limit;
			this.tLimit.text=Tools.getMsgById("equip_box2",[n1,n2]);
			if(n1>=n2){
				this.btn0.gray=this.btn1.gray=true;
			}
			if(n1+10>n2){
				this.btn1.gray=true;
			}

			mRecoverObj=mModel.getRecoverItem();
			this.btnReCylce.visible = mRecoverObj!=null;

			this.text1.text=item_name;
			this.comNum.setData(AssetsManager.getAssetItemOrPayByID(mModel.cfg.item_id),ModelItem.getMyItemNum(mModel.cfg.item_id));

			ModelGame.redCheckOnce(this.btnShop,mModel.redPointShop(),[this.btnShop.width-40,0]);
		}

		private function onClick(obj:*):void{
			switch(obj){
				case this.btn0:
					btnClick(0);
					break;
				case this.btn1:
					btnClick(1);
					break;
				case this.btnCheck:
					ViewManager.instance.showView(ConfigClass.VIEW_SHOW_PROBABILITY,['502073', mModel.getGoods()["show_chance"], true]);
					break;
				case this.btnReCylce:
					ViewManager.instance.showView(["ViewEquipBoxRecylce",ViewEquipBoxRecylce]);
					break;
				case this.btnEquip:
					ViewManager.instance.showView(["ViewEmboitement",ViewEmboitement],[mCfg.equip,mCfg.equip_info,Tools.getMsgById("equip_box7")]);
					break;
				case this.btnShop:
					ViewManager.instance.showView(["ViewTreasureShop",ViewTreasureShop], [mModel, 'equip_box3']);
					break;
				
			}
		}

		

		/**
		 * 是否可以进行第三步
		 */
		private function isCanShowStep1():Boolean{
			var a:Array=ModelManager.instance.modelProp.getRewardProp(mReward);
			for(var i:int=0;i<a.length;i++){
				if(a[i][0].indexOf("equip")!=-1){
					mEquipId=a[i][0];
					break;
				}
			}
			//mEquipId="equip001";
			return mEquipId!="";
		}

		/**
		 * 展示特殊宝物
		 */
		private function step1():void{
			if(!isCanShowStep1()){
				mStep=2;
				step3();
				return;
			}
			mEffect=EffectManager.loadAnimation("glow_arr_equip_effect","",1);
			mEffect.x=this.aniBox.width/2;
			mEffect.y=this.aniBox.height/2;
			//effect.blendMode="lighter";
			mEffect.name="effect";
			this.aniBox.addChild(mEffect);
			timer.once(3000,this,step1Over);
		}


		private function step1Over():void{
			var com:bagItemUI=new bagItemUI();
			com.setData(mEquipId,-1,-1);
			com.name="equip000";
			this.comBox.addChild(com);
			com.scaleX=com.scaleY=0.8;
			com.centerX=0;
			com.centerY=0;	
			com.anchorX=com.anchorY=0.5;
			Tween.to(com,{scaleX:1.0,scaleY:1.0},100,null,new Handler(this,function():void{
				mStep=1;
				comTween(com);
			}));
			
		}
		
		private function step1Quick():void{
			return;//这个动画不让跳过了
			if(this.aniBox.getChildByName("effect")){
				(this.aniBox.getChildByName("effect") as Animation).destroy();
			}
			timer.clear(this,step1Over);
			step1Over();
		}

		/**
		 * 特殊宝物收取
		 */
		private function step2():void{
			var c:*=this.comBox.getChildByName("equip000");
			if(c){
				var o:Object={};
				o[mEquipId]=1;
				//不收取了  直接干掉
				//comGet(c,o);	
				this.comBox.destroyChildren();
				mStep=2;
				//step3();
				step3Quick();
			}
			
		}

		/**
		 * 点击抽奖按钮
		 */
		private function step3():void{
			var key:String=mReward.length>2 ?  "_10" : "_1";
			mFrontAin1.on(Event.COMPLETE,this,ani3Complete);
			mFrontAin0.play(0,false,key);
			mFrontAin1.play(0,false,key);
			if(key=="_1"){
				timer.once(1000,this,showReward);
			}else{
				timer.once(1500,this,showReward);
			}
		}
		
		private function step3Over():void{
			mStep=3;
			for(var i:int=0;i<comBox.numChildren;i++){
				var com:*=comBox.getChildByName("com"+i);
				comTween(com);		
			}
			
		}

		private function step3Quick():void{
			if(mSc) mSc.volume=0;
			mFrontAin0.clear();
			mFrontAin1.clear();
			ani3Complete();
			showReward(false);
		}

		private function ani3Complete():void{
			timer.clear(this,showReward);
			mFrontAin0.play(0,true,"_0");
			mFrontAin1.play(0,true,"_0");
			mFrontAin1.off(Event.COMPLETE,this,ani3Complete);
		}

		/**
		 * 收取奖励
		 */
		private function step4():void{
			var a:Array=[];
			for(var i:int=0;i<mReward.length;i++){
				var aa:Array=ModelManager.instance.modelProp.getRewardProp(mReward[i]);
				a.push([aa[0][0],aa[0][1],aa[0][2]]);
			}
			for(var j:int=0;j<a.length;j++){
				var o:Object={};
				o[a[j][0]]=a[j][1];
				var c:bagItemUI=comBox.getChildByName("com"+j) as bagItemUI;
				if(c){
					comGet(c,o);
				}
			}
			comBox.destroyChildren();
			mStep=4;
			this.mBtn.visible=false;
		}


		/**
		 * 上下跳动
		 */
		private function comTween(com:*,b:Boolean=true):void{
			var _this:*=this;
			var m:Number=Tools.getRandom(0,7);
			var n:Number=com.y;
			Tween.to(com,{y:com.y+6},600,null,new Handler(_this,function():void{
				Tween.to(com,{y:n},600,null,new Handler(_this,function():void{
					comTween(com,false);
				}));
			}),(b?m*100:0));
		}

		/**
		 * 物品收到仓库动画
		 */
		private function comGet(com:*,o:Object):void{
			var pos:Point = Point.TEMP.setTo(com.x, com.y);
			pos = this.comBox.localToGlobal(pos, true);
			ViewManager.instance.showIcon(o,pos.x,pos.y,false,"",true);
		}

		

		private function mBtnClick():void{
			if(mStep==0){
				step1Quick();
			}else if(mStep==1){
				step2();
			}else if(mStep==2){
				step3Quick();
			}else if(mStep==3){
				step4();	
			}
		}


		private function showReward(isDelay:Boolean=true):void{
			mTime=ConfigServer.getServerTimer();
			var arr:Array=mReward;
			var a:Array=[];
			for(var i:int=0;i<arr.length;i++){
				var aa:Array=ModelManager.instance.modelProp.getRewardProp(arr[i]);
				a.push([aa[0][0],aa[0][1],aa[0][2]]);
			}
			comBox.destroyChildren();
			
			var n:Number=140;
			for(var j:int=0;j<a.length;j++){
				var com:bagItemUI=new bagItemUI();
				com.name="com"+j;
				com.setData(a[j][0],a[j][1],-1);
				com.scaleX=com.scaleY=0.8;
				comBox.addChild(com);
				if(a.length==2){//-22,165,680,375
					com.centerY=-70;
					com.x = comBox.width/2+(j==0 ? -60 : 60);
				}else{
					if(j<=2) com.y=0;
					if(j>2 && j<=6)  com.y=(comBox.height-com.height)/2;
					if(j>6 && j<=10) com.y=comBox.height-com.height;

					if(j<=2){ 
						com.x=comBox.width/2 + (j==0 ? -n : (j==2 ? n : 0));
					}else {
						var nn:Number = comBox.width/5;
						if(j>2 && j<=6)   com.x=(j-2)*nn;
						if(j>6 && j<=10)  com.x=(j-6)*nn;
					}
				}
				if(isDelay){
					com.alpha=0;
				}	
				com.anchorX=com.anchorY=0.5;	

			}
			if(isDelay){
				for(var k:int=0;k<a.length;k++){
					var cc:*=comBox.getChildByName("com"+k);
					comShow(cc,145*(k+1));
				}
				Laya.timer.once((a.length+1)*145,this,step3Over);
			}else{
				step3Over();
			}
		}


		private function comShow(com:*,delay:Number):void{
			com.alpha=0;
			com.scaleX=com.scaleY=0;
			Tween.to(com,{scaleX:0,scaleY:0},200,null,new Handler(this,function():void{
				var a:Animation=EffectManager.loadAnimation("glow_arr_equip_front2",'',1);
				glowBox.addChild(a);
				a.x=com.x;
				a.y=com.y;
				Tween.to(com,{alpha:1},100,null);	
				Tween.to(com,{scaleX:1,scaleY:1},250,null,new Handler(this,function():void{
					MusicManager.playSoundUI(MusicManager.SOUND_EQUIP_BOX_SHOW);
					Tween.to(com,{scaleX:0.8,scaleY:0.8},250,null,new Handler(this,function():void{
						
					}));
				}));
			}),delay);
			
		}

		private function btnClick(type:int):void{
			comBox.destroyChildren();
			mStep=0;
			mEquipId="";
			var n:Number=type==0 ? (mModel.mOneTimes<mCfg.buy_one[0] ? 0 : mCfg.buy_one[1]) : mCfg.buy_ten[1];
			if(!Tools.isCanBuy("coin",n)) return;

			var n1:Number=mModel.mBuyTimes;
			var n2:Number=mCfg.limit;
			if(n1>=n2 || (type!=0 && n1+10>n2)){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("equip_box6"));
				return;
			}
			if(mModel.active==false){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("happy_tips07"));
				return;
			}
			NetSocket.instance.send("buy_equip_box",{"buy_key":type==0 ? "buy_one" : "buy_ten"},new Handler(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				mReward=np.receiveData.gift_dict_list;
				mBtn.visible=true;
				step1();	
				if(type!=0){
					mSc = MusicManager.playSoundUI(MusicManager.SOUND_EQUIP_BOX_TEN);
				}			
			}));
		}

		public function removeCostumeEvent():void 
		{
			this.mModel.off(ModelActivities.UPDATE_DATA, this, this.updateUI);
		}
	}

}