package sg.view.arena
{
	import ui.arena.arenaMainUI;
	import laya.utils.Handler;
	import sg.utils.Tools;
	import laya.events.Event;
	import sg.model.ModelArena;
	import sg.net.NetSocket;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.model.ModelUser;
	import sg.boundFor.GotoManager;
	import sg.net.NetPackage;
	import sg.fight.FightMain;
	import laya.utils.Tween;
	import laya.display.Animation;
	import sg.manager.EffectManager;
	import laya.ui.Label;
	import laya.utils.Ease;
	import laya.display.Node;
	import sg.manager.AssetsManager;
	import sg.model.ModelItem;

	/**
	 * ...
	 * @author
	 */
	public class ViewArenaMain extends arenaMainUI{

		private var model:ModelArena;
		private var mStatus:int;
		
		private var mItemArr:Array=[];
		private var mCurArg:int;
		private var mJoinNum:Number;
		private var mNextTime:Number;

		private var mSelectIndex:int;
		private var mTween:Tween;

		private var mTextArr:Array = [Tools.getMsgById('arena_text12'),Tools.getMsgById('arena_text09'),Tools.getMsgById('arena_text10')];
		private var mDarkIndex:int;
		
		public function ViewArenaMain(){
			
			//this.list.itemRender = itemArenaUI;
			//this.list.renderHandler = new Handler(this,listRender);


			this.text2.text = Tools.getMsgById('arena_text41');

			this.shopBtn.on(Event.CLICK,this,click,[shopBtn]);
			this.logBtn.on(Event.CLICK,this,click,[logBtn]);
			this.askBtn.on(Event.CLICK,this,click,[askBtn]);
			//this.addBtn.on(Event.CLICK,this,click,[addBtn]);
			
			this.comItem.on(Event.CLICK,this,function():void{
				if(model)
					ViewManager.instance.showItemTips(model.mItemId);
			});

			shopBtn.setGotoBtn(Tools.getMsgById("arena_shop"));
		}

		override public function onAdded():void{
			mDarkIndex = ModelManager.instance.modelUser.arena.dark_index;
			mSelectIndex = -1;
			mCurArg = this.currArg ? this.currArg : 0;
			model = ModelArena.instance;
			mNextTime = model.nextOpenTime();
			if(model.active){
				mCurArg = 0;
			}
			if(model.mTotalGet!=0){
				var gift:Object = {};
				gift[model.mItemId] = model.mTotalGet;
				var o:Object = {"gift_dict":gift,"act":3};
				//getItemCallBack(o);
				ViewManager.instance.showView(["ViewArenaReward",ViewArenaReward],o);
			}
			
			ModelManager.instance.modelUser.on(ModelUser.EVENT_USER_UPDATE,this,updateUserData);
			this.setTitle(Tools.getMsgById("500119"));
			
			model.on(ModelArena.EVENT_UPDATE_ARENA,this,setData);
			model.on(ModelArena.EVENT_GET_ITEM,this,getItemCallBack);
			model.on(ModelArena.EVENT_FINAL_WINNER,this,finalCallBack);

			mStatus = model.status;
			imgBlack.visible = mStatus == 2;
			mItemArr = [];			

			for(var i:int=0;i<4;i++){
				var item:ItemArena = new ItemArena(i);
				mItemArr.push(item);
				this.comBox.addChild(item);

				switch(i){
					case 0:
						item.top = item.left = 0;
						break;
					case 1:
						item.top = item.right = 0;
						break;
					case 2:
						item.bottom = item.left = 0;
						break;
					case 3:
						item.bottom = item.right = 0;
						break;
				
				}
				
			}
			//this.comBox.width = 310*2 + 8;
			this.comBox.centerX = 0;

			this.imgBlack.x = (this.comBox.width-this.imgBlack.width)/2;
			this.imgBlack.y = (this.comBox.height-this.imgBlack.height)/2;
			imgBlack.zOrder = 100;
			
			setData();
			this.comItem.setData(AssetsManager.getAssetItemOrPayByID(model.mItemId),ModelItem.getMyItemNum(model.mItemId));
			setAni();
		}


		private function getItemCallBack(re:*):void{
			if(re.gift_dict){
				// if(!FightMain.inFight){
				// 	ViewManager.instance.showView(["ViewArenaReward",ViewArenaReward],re);
				// }

				//竞猜  攻擂  守擂
				var n:Number = -1;
				if(re.act == 0){
					n = 1;
				}else if(re.act == 1 || re.act == 3){
					n = 2;
				}else if(re.act == 2){
					n = 0;
				}

				var m:Number = re.gift_dict[model.mItemId];
				var s:String = n == -1 ? '+'+m  :  mTextArr[n] + '+' + m;
				tweenLabel(s);
			}
			model.mTotalGet = 0;
		}
		private function finalCallBack(re:*):void{
			var n:Number = re;
			var item:* = this.mItemArr[n];
			if(item){
				var effect:* = new EffectArena();
				item.addChild(effect);
			}
		}

		private function tweenLabel(s:String):void{
			var startX:Number = comItem.x + 50;
			var startY:Number = comItem.y;
			var time:Number = 2000;
			var label:Label = new Label();
			label.pos(startX, startY);
			label.stroke = 1;
			label.color = "#3dff00";
			label.fontSize = 18;
			label.text = s;
			label.align = 'center';
			label.valign = 'middle';
			label.height = 28;
			label.anchorX = 0.5;
			label.anchorY = 0.5;
			label.scaleX = 0.5;
			label.scaleY = 0.5;
			Tween.to(label, {scaleX: 1, scaleY: 1}, 300, Ease.backOut);
			Tween.to(label, {y: startY - 40}, time, Ease.sineIn);
			Tween.to(label, {alpha: 0, scaleX: 1.5, scaleY: 1.5}, 300, Ease.sineIn, Handler.create(this, tweenComplete, [label]), time - 300);
			this.addChild(label);
			comItem.setData(AssetsManager.getAssetItemOrPayByID(model.mItemId),ModelItem.getMyItemNum(model.mItemId));
		}

		private function tweenComplete(n:Node):void{
			Tools.destroy(n);
			//comItem.setData(AssetsManager.getAssetItemOrPayByID(model.mItemId),ModelItem.getMyItemNum(model.mItemId));
		}
		

		private function updateUserData(re:Object):void{
			if(re.user && re.user.hasOwnProperty("arena")){
				if(mDarkIndex != ModelManager.instance.modelUser.arena.dark_index){
					playAni(true);
					mDarkIndex = ModelManager.instance.modelUser.arena.dark_index;
					var item:* = mItemArr[mDarkIndex];
					var _x:int = item.x + (item.width-this.imgBlack.width)/2;
					var _y:int = item.y + (item.height-this.imgBlack.height)/2;
					mTween = Tween.to(imgBlack,{x:_x,y:_y},500,null,new Handler(this,function():void{
						setData();
					}),0,true,true);
				}else{
					setData();
				}
			}
		}

		private function setData():void{
			// if(model.isOver()){
			// 	ViewManager.instance.closeScenes();
			// 	return;
			// }
			
			mJoinNum =model.joinNum();
			imgBlack.visible = mStatus == 2 && ModelManager.instance.modelUser.arena.dark_index == -1;

			var arr:Array = [];
			var a:Array = mCurArg == 0 ? model.getArenaGroup() : ((mCurArg>=1 && mCurArg <=4) ? [1,2,3,4] : [5,6,7,8]);

			for(var i:int=0;i<a.length;i++){
				if(arr.length<4){
					arr.push(a[i]);					
				}
			}

			Laya.timer.clear(this,setLabel);
			setLabel();

			for(var j:int=0;j<a.length;j++){
				if(mItemArr[j]) (mItemArr[j] as ItemArena).setData(a[j]);
				if(mItemArr[j]) (mItemArr[j] as ItemArena).imgDark0.visible = mStatus == 2 && ModelManager.instance.modelUser.arena.dark_index == j;
				if(mItemArr[j]) (mItemArr[j] as ItemArena).imgLight.visible = mStatus == 2 && ModelManager.instance.modelUser.arena.dark_index == j;
			}

			this.logBtn.visible = mStatus >= 3;
			this.tCount.visible = mStatus == 3;
			this.imgTextBg.visible = this.tCount.visible;

			
			
		}
		private function setAni():void{
			if(mStatus == 2 && ModelManager.instance.modelUser.arena.dark_index == -1){
				playAni();
			}
		}

		private function playAni(stop:Boolean = false):void{
			for(var i:int=0;i<4;i++){
				var itemArena:ItemArena = mItemArr[i];
				itemArena.imgLight.visible = false;
			}
			mSelectIndex += 1;
			if(mSelectIndex==4) mSelectIndex = 0; 
			var n:Number = mSelectIndex;
			if(n==2) n=3;
			else if(n==3) n=2;
			 mItemArr[n].imgLight.visible = true;
			
			Laya.timer.once(500,this,playAni,[stop]);
			if(stop){
				
				if(ModelManager.instance.modelUser.arena.dark_index == n){
					Laya.timer.clear(this,playAni);
				}
			}
		}


		private function setLabel():void{
			Laya.timer.once(1000,this,setLabel);
			if(mStatus!=model.status){
				mStatus = model.status;
				imgBlack.visible = mStatus == 2 && ModelManager.instance.modelUser.arena.dark_index == -1;
				mNextTime = model.nextOpenTime();
				if(mStatus==3){
					getArenaData();
				}else{
					setData();
				}
				
			}
			var n:Number = ConfigServer.getServerTimer();
			var m:Number = 0;
			var s:String = '';
			switch(mStatus){
				case 0:
				    m = mNextTime;
					s = "arena_text01";//"未开启";
					break;
				case 1:
					m = model.mTime1;
					s = "arena_text02";//"距离开始竞猜:";
					break;
				case 2://竞猜
					m = model.mTime2;
					s = "arena_text03";//"距离竞猜结束:";
					break;
				case 3://攻擂
					m = model.mTime3;
					s = "arena_text04";//"距离攻擂结束:";
					break;
				case 4://结束
					if(!ModelArena.instance.isOver()){
						m = 0;
						s = "arena_text31";
					}else{
						m = mNextTime;
						s = "arena_text05";//"攻擂结束...";
					}
					break;
			}
			this.text0.text = m==0 ? Tools.getMsgById(s) : Tools.getMsgById(s,[Tools.getTimeStyle(m-n)]);
			
			//
			var n1:Number = model.joinNum();
			var n2:Number = model.cfg.num[0];
			var s1:String = Tools.getMsgById("arena_text06",[n1,n2]);// "攻擂次数: "+n1+"/"+n2;
			var s2:String = "";
			if(n1<n2 && ModelManager.instance.modelUser.arena){
				var n3:Number = Tools.getTimeStamp(ModelManager.instance.modelUser.arena.join_time);
				var n4:Number = model.cfg.num[1] * Tools.oneMillis - (n - n3 - (n1 * model.cfg.num[1] * Tools.oneMillis));
				s2 = Tools.getTimeStyle(n4);
				s1 = Tools.getMsgById("arena_text07",[n1,n2,s2]);// "攻擂次数: "+n1+"/"+n2,{2}"后增加一次"
			}
			if(n1>mJoinNum){
				setData();
			}
			this.tCount.text = s1;

		}

		//为了刷新黑马擂台 dark_arena_index
		private function getArenaData():void{
			timer.once(1000,this,function():void{
				NetSocket.instance.send("get_pk_arena",{},Handler.create(null,function(np:NetPackage):void{
					ModelArena.instance.arena = np.receiveData;
					setData();
				}));
			});
		}




		private function click(obj:*):void{
			switch(obj){
				case this.shopBtn:
					GotoManager.boundForPanel(GotoManager.VIEW_SHOP,'arena_shop');
					break;

				case this.logBtn:
					NetSocket.instance.send("get_arena_log_list",{"arena_index":0},Handler.create(this,function(np:NetPackage):void{
						ViewManager.instance.showView(["ViewArenaLog",ViewArenaLog],{"0":np.receiveData});	
					}));
					break;

				case this.askBtn:
					ViewManager.instance.showTipsPanel(Tools.getMsgById("500120"));
					break;

				// case this.addBtn:
				// 	if(model.joinNum() == model.cfg.num[0]){
				// 		ViewManager.instance.showTipsTxt(Tools.getMsgById("arena_tips06"));//"次数已满");//"今天不能买了"
				// 		return;
				// 	}
				// 	var n:Number = ModelManager.instance.modelUser.arena.buy_times ? ModelManager.instance.modelUser.arena.buy_times : 0;
				// 	if(n>=model.cfg.num_buy.length){
				// 		ViewManager.instance.showTipsTxt(Tools.getMsgById("arena_tips07"));//"到达购买次数上限");
				// 		return;
				// 	}
				// 	var cost_num:Number = model.cfg.num_buy[n];
				// 	ViewManager.instance.showBuyTimes(5,1,1,cost_num);
				// 	break;
			}
		}


		override public function onRemoved():void{
			ModelManager.instance.modelUser.off(ModelUser.EVENT_USER_UPDATE,this,updateUserData);
			model.off(ModelArena.EVENT_UPDATE_ARENA,this,setData);
			model.off(ModelArena.EVENT_GET_ITEM,this,getItemCallBack);
			model.off(ModelArena.EVENT_FINAL_WINNER,this,finalCallBack);
			Laya.timer.clear(this,setLabel);

			for(var i:int=mItemArr.length-1;i>=0;i--){
				if(mItemArr[i]) mItemArr[i].destroy();
			}
			NetSocket.instance.send("unlive_pk_arena",{},Handler.create(null,function():void{
								
			}));
		}
	}

}
