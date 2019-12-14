package sg.view.arena
{
	import ui.arena.itemArenaUI;
	import sg.manager.AssetsManager;
	import sg.model.ModelArena;
	import sg.model.ModelItem;
	import sg.manager.LoadeManager;
	import laya.events.Event;
	import sg.manager.ModelManager;
	import sg.utils.Tools;
	import sg.net.NetSocket;
	import sg.fight.FightMain;
	import sg.manager.ViewManager;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.cfg.ConfigServer;
	import sg.model.ModelUser;
	import laya.ui.Label;
	import sg.manager.EffectManager;
	import laya.utils.Tween;
	import laya.utils.Ease;
	import laya.display.Animation;
	import sg.model.ModelPrepare;
	import sg.model.ModelHero;

	/**
	 * ...
	 * @author
	 */
	public class ItemArena extends itemArenaUI{

		private var mModel:ModelArena;//
		private var mStatus:int;//
		private var mIndex:int;

		private var mData:Object;//
		private var mTopData:Object;//擂主信息
		private var mUserList:Array;//排队uid
		private var mArenaId:String;
		
		private var mTime:Number;//下一次增加奖池的时间
		private var mItemAdd:Number = 0;//奖池数量增加
		private var mBuffNum:Number = 0;//buff数值
		private var mCount:Number = 0;

		private var mArenaStatus:Number = 0;//擂台状态  0 我不攻也不守时  1 我攻擂中  2 我守擂中
		private var pointArr:Array = ['','.','..','...'];

		public function ItemArena(index:int){
			mModel = ModelArena.instance;
			mIndex = index;
			mStatus = -1;
			this.imgLight.visible = false;
			this.imgDark0.visible = false;
			this.comHero.visible = false;
			
		}

		public function setData(id:String):void{
			this.tFight.text = "";
			mArenaId = id;
			mData = mModel.arena.arena_list[mIndex];
			mTopData = mData.user_list[0];
			mUserList = mData.user_list[1];
			
			mBuffNum = mModel.challengerBuff(mIndex);

			mItemAdd = 0;
			mTime = mModel.getItemTime() + mModel.cfg.pool_add[0]*1000;
			setUI();
			mCount = 0;
			Laya.timer.clear(this,updateUI);
			updateUI();

		}

		private function updateUI():void{
			Laya.timer.once(1000,this,updateUI);

			var now:Number = ConfigServer.getServerTimer();

			if(now>=mTime && mStatus==3){//增加了奖池数
				mItemAdd++;
				mTime += mModel.cfg.pool_add[0]*1000;
				setUI();
				var darkNum:Number = mModel.arena.dark_arena_index == mIndex ? mModel.cfg.dark_horse[1] : 1;
				var s:String = mModel.cfg.pool_add[1]*darkNum +"";
				tweenLabel(s);
			}

			var n:Number = mModel.challengerBuff(mIndex);
			if(n != mBuffNum){//增加buff
				if(mBuffNum>n){
					buffAni();
				}
				mBuffNum = n;
				setUI();
			}

			setTimeLabel();

		}

		private function tweenLabel(s:String):void{
			var startX:Number = 250;
			var startY:Number = 22;
			var time:Number = 2000;
			var label:Label = new Label();
			label.pos(startX, startY);
			label.stroke = 1;
			label.color = "#3dff00";
			label.fontSize = 18;
			label.text = "+"+s;
			label.align = 'center';
			label.valign = 'middle';
			label.height = 28;
			label.anchorX = 0.5;
			label.anchorY = 0.5;
			label.scaleX = 0.5;
			label.scaleY = 0.5;
			Tween.to(label, {scaleX: 1, scaleY: 1}, 300, Ease.backOut);
			Tween.to(label, {y: startY - 40}, time, Ease.sineIn);
			Tween.to(label, {alpha: 0, scaleX: 1.5, scaleY: 1.5}, 300, Ease.sineIn, Handler.create(null, Tools.destroy, [label]), time - 300);
			this.addChild(label);
		}

		private function buffAni():void{
			var ani:Animation = EffectManager.loadAnimation("glow011","",1);  
			this.buffBox.addChild(ani);
		}

		private function setUI():void{
			var n:Number = mModel.status;
			if(n!=mStatus){
				mStatus = n;
			}

			this.comHero.visible = mStatus!=2;
			if(mTopData && mTopData.uid == ModelManager.instance.modelUser.mUID){
				if(mStatus >= 4 && mUserList.length == 0){//到时间了并且无人攻擂
					mArenaStatus = 0;
				}else{
					mArenaStatus = 2;	
				}
			}else if(mUserList.indexOf(Number(ModelManager.instance.modelUser.mUID))!=-1){
				mArenaStatus = 1;
			}else{
				mArenaStatus = 0;
			}
			
			var num:Number = mUserList.length;
			this.box.visible = mStatus!=2;
			this.tNum.text = mStatus==3 ? (num==0 ? "" : Tools.getMsgById("arena_text08",[num])) : "";// "当前"+num+"人攻擂中" : "";
			//this.txtImg.visible = num != 0;

			this.imgAwaken.visible = false;
			
			if(mTopData){
				this.comFlag.setCountryFlag(mTopData.country);
				this.comFlag.visible = true;
				this.tName.text = mTopData.uname;
				var arr:Array = mTopData.troop;
				var topPower:Number = 0;
				var topHid:String = '';
				var awaken:String = '';
				var star:int = 0;
				for(var i:int=0;i<arr.length;i++){
					var temp:Number = (new ModelPrepare(arr[i])).getData().power;
					if(temp > topPower){
						topPower = temp;
						topHid = arr[i].hid;
						awaken = arr[i].awaken ? arr[i].awaken : '';
						star = arr[i].hero_star;
					}
				}
				this.comHero.setHeroIcon(topHid);
				this.imgAwaken.visible = awaken != '';
				if(topHid != '') this.imgAwaken.skin = ModelHero.awakenImgUrl(topHid);
				if(this.imgAwaken.visible){
					if(ModelManager.instance.modelGame.getModelHero(topHid).rarity < 4) EffectManager.changeSprColor(imgAwaken,ModelHero.getHeroStarGradeColor(star));
					else EffectManager.changeSprColorFilter(imgAwaken, null);
				} 
			}else{
				this.comHero.setHeroIcon("hero000");
				this.tName.text = Tools.getMsgById("_country2");//"虚位以待";
				this.comFlag.visible = false;
				this.imgAwaken.visible = false;
			}
			this.tName.color=(mTopData && mTopData.uid+""==ModelManager.instance.modelUser.mUID)?this.text0.color:"#FFFFFF";

			var user_dark_index:Number = ModelManager.instance.modelUser.arena.dark_index;
			this.imgDark1.visible = (mStatus==3 || mStatus==4) && mModel.arena.dark_arena_index!=null && mModel.arena.dark_arena_index == mIndex;
			this.imgDark1.off(Event.CLICK,this,itemClick);
			this.imgDark1.on(Event.CLICK,this,itemClick,[6]);
			this.tArena.text = Tools.getMsgById(ModelArena.textArr_S[mArenaId]);
			this.btn.label = Tools.getMsgById("arena_text09");//"攻擂";
			this.text0.text = Tools.getMsgById("arena_text11");//"擂主:";
			
			this.askBtn.visible = num != 0;

			this.btn.offAll(Event.CLICK);
			this.btn.visible = false;
			this.tGuess.text = "";
			this.tGuessTips.text = "";
			switch(mStatus){
				case 0:
				case 1:
					this.text0.text = Tools.getMsgById("arena_text25");//"上期擂主:";
					if(ModelArena.instance.arena.top_one && ModelArena.instance.arena.top_one[mArenaId]){
						var o:Object = ModelArena.instance.arena.top_one[mArenaId];
						this.comHero.setHeroIcon(ModelUser.getUserHead(o.head));
						this.imgAwaken.visible = o.head && o.head.indexOf('_1')!=-1;
						this.tName.text = o.uname;
						this.comFlag.setCountryFlag(o.country);
						this.comFlag.visible = true;
					}else{
						this.comHero.setHeroIcon("hero000");
						this.tName.text = Tools.getMsgById("_country2");//"虚位以待";
						this.comFlag.visible = false;
						this.imgAwaken.visible = false;
					}
					
					break;
				case 2://竞猜
					
					this.tGuess.text = user_dark_index==mIndex ? Tools.getMsgById("arena_text13") : "";
					this.btn.label = Tools.getMsgById("arena_text12");
					
					var itemNum:Number = mModel.cfg.dark_horse[0];
					var itemName:String = ModelItem.getItemName(mModel.mItemId);
					this.tGuessTips.text = user_dark_index==mIndex ? Tools.getMsgById('500124',[itemNum,itemName]) : "";
					this.tNum.text = "";
					this.askBtn.visible = false;
					this.btn.visible = user_dark_index == -1;
					this.btn.on(Event.CLICK,this,itemClick,[0]);
					break;
				case 3://攻擂
					this.btn.label = Tools.getMsgById("arena_text09");//"攻擂";
					var b1:Boolean = (mTopData == null || mTopData.uid != ModelManager.instance.modelUser.mUID);
					var b2:Boolean = true;
					for(var j:int=0;j<mUserList.length;j++){
						if(mUserList[j] == ModelManager.instance.modelUser.mUID){
							b2 = false;
							break;
						}
					}
					var b3:Boolean = mModel.joinNum() != 0;
					if(b1 && b2 && b3){//
						this.btn.visible = true;	
						this.btn.on(Event.CLICK,this,itemClick,[1]);
					}else{
						if(!b3){//
							if(mArenaStatus==0){
								this.btn.visible = true;
								this.btn.label = Tools.getMsgById("arena_text26");//"购买次数";
								this.btn.on(Event.CLICK,this,itemClick,[4]);
							}
						}
					}

					break;
				case 4://结束
					//this.btn.label = "结束";
					this.btn.visible = false;
				 	break;
			}

			this.askBtn.off(Event.CLICK,this,itemClick);
			this.askBtn.on(Event.CLICK,this,itemClick,[2]);

			this.itemBox.off(Event.CLICK,this,itemClick);
			this.itemBox.on(Event.CLICK,this,itemClick,[3]);	

			this.comHero.off(Event.CLICK,this,itemClick);
			this.comHero.on(Event.CLICK,this,itemClick,[5]);	

			itemBox.visible = mStatus == 3;
			buffBox.visible = mStatus == 3;
			if(itemBox.visible){
				var darkNum:Number = mModel.arena.dark_arena_index == mIndex ? mModel.cfg.dark_horse[1] : 1;
				this.tNum0.text = mData.item_num + mItemAdd*mModel.cfg.pool_add[1]*darkNum +"";
				this.itemIcon.skin = AssetsManager.getAssetItemOrPayByID(mModel.mItemId);
			}
			
			if(buffBox.visible){
				var nBuff:Number = mBuffNum;
				this.tNum1.text = nBuff==0 ? "0" : Math.round(nBuff*100)+"%";
				if(nBuff==0) this.buffBox.visible = false;
			}

			this.txtImg3.visible = this.tGuess.text != "";

			this.txtImg1.visible = true;
			if(buffBox.visible == false  && itemBox.visible == false){
				this.txtImg1.visible = false;
			}
			
		}

		private function setTimeLabel():void{
			// if(mFightCount<0) return;
			// this.tFight.text = mFightCount<=0 ? "" : Tools.getMsgById("arena_text32",[mFightCount]);
			// this.txtImg2.visible = this.tFight.text != "";
			// mFightCount--;
			var s:String = "";
			if(mArenaStatus==1){
				s = Tools.getMsgById('arena_text38');
			}else if(mArenaStatus==2){
				s = Tools.getMsgById('arena_text39');
			}
			if(s!=""){
				if(pointArr[mCount]){
					this.tFight.text = s + pointArr[mCount];
				}else{
					this.tFight.text = s;
					mCount = 0;
				}
				mCount++;
			}
			
		}

		private function itemClick(type:int):void{
			switch(type){
				case 0://竞猜
					if(ModelManager.instance.modelUser.arena.dark_index>-1){
						ViewManager.instance.showTipsTxt(Tools.getMsgById("arena_tips01"));
						return;
					}
					var s:String = Tools.getMsgById(ModelArena.textArr[mArenaId]);
					// "是否竞猜 "+s+" 为黑马擂台?"
					ViewManager.instance.showAlert(Tools.getMsgById("arena_tips02",[s]),function(yesOrNo:int):void{
						if(yesOrNo==0){
							NetSocket.instance.send("guess_arena_dark",{"arena_index":mIndex},Handler.create(this,function(np:NetPackage):void{
								ModelManager.instance.modelUser.updateData(np.receiveData);
								ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
								setUI();
							}));
						}
					});
					break;
				case 1://攻擂
					// var user_list:Array = mModel.arena.arena_list[index].user_list;
					// if(user_list[0]!=null){
					// 	if(user_list[0].uid == ModelManager.instance.modelUser.mUID){
					// 		ViewManager.instance.showTipsTxt(Tools.getMsgById("arena_tips03"));//"你是当前擂主");
					// 		return;
					// 	} 
					// 	for(var i:int=0;i<user_list[1].length;i++){
					// 		if(user_list[1][i] == ModelManager.instance.modelUser.mUID){
					// 			ViewManager.instance.showTipsTxt(Tools.getMsgById("arena_tips04"));//"已在队列中");
					// 			return;
					// 		}
					// 	}
					// }
					if(mModel.joinNum() == 0){
						ViewManager.instance.showTipsTxt(Tools.getMsgById("arena_tips05"));//"攻擂次数不足");//"今天不能买了"
						return;
					}
					ViewManager.instance.showView(["ViewArenaDeploy",ViewArenaDeploy],mIndex);
					break;
				case 2://查看 当前擂台最新一场战斗
					var _this:* = this;
					NetSocket.instance.send("get_arena_log",{"arena_index":mIndex,"log_index":0},Handler.create(_this,function(np:NetPackage):void{
						if(np.receiveData["pk_data"]){
							np.receiveData["pk_data"]["is_mine"] = false;
						}
						FightMain.startBattle(np.receiveData, _this, null);
					}));
					break;
				case 3:
					ViewManager.instance.showItemTips(mModel.mItemId);
					break;
				case 4:
					var n:Number = ModelManager.instance.modelUser.arena.buy_times ? ModelManager.instance.modelUser.arena.buy_times : 0;
					var cost_num:Number = mModel.cfg.num_buy[n];
					if(n>=mModel.cfg.num_buy.length){
						ViewManager.instance.showTipsTxt(Tools.getMsgById("arena_tips07"));//"到达购买次数上限");
						return;
					}
					ViewManager.instance.showBuyTimes(5,1,1,cost_num);
					break;
				case 5:
					if(mTopData){
						ModelManager.instance.modelUser.selectUserInfo(mTopData.uid);
					}
					break;
				case 6:
					ViewManager.instance.showTipsPanel(Tools.getMsgById('500123'));	
					break;

			}
		}
	}

}