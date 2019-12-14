package sg.activities.view
{
	import laya.events.Event;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;

	import sg.activities.model.ModelActivities;
	import sg.activities.model.ModelTreasure;
	import sg.manager.AssetsManager;
	import sg.manager.LoadeManager;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.model.ModelGame;
	import sg.net.NetPackage;
	import sg.net.NetSocket;
	import sg.utils.Tools;

	import ui.activities.dial.item_dialUI;
	import ui.activities.treasure.item_treasureUI;
	import ui.activities.treasure.treasureMainUI;

	/**
	 * ...
	 * @author
	 */
	public class TreasureMain extends treasureMainUI{

		private var mLapsNum:Number=0;
		private var mIndex:int=0;
		private var mTween:Tween;
		private var mModel:ModelTreasure;
		private var mArr1:Array=[];
		private var mArr2:Array=[];
		private var mFreeTimes1:Number=0;//单抽免费次数
		private var mFreeTimes5:Number=0;//五抽免费次数
		private var mGetArr:Array=[];
		private var mReData:*;
		//private var mFirstGet:Boolean=false;
		private var mIsScroll:Boolean=false;
		private var isDone:Boolean=false;
		public function TreasureMain(){
			this.btnShop.label=Tools.getMsgById("treasure_text05");
			setData();
			this.text0.text=Tools.getMsgById("dial_text01");
			this.btnShop.on(Event.CLICK,this,shopClick);
			this.comCenter0.btn.on(Event.CLICK,this,getClick,[0]);
			this.comCenter1.btn.on(Event.CLICK,this,getClick,[1]);
			this.list.renderHandler=new Handler(this,listRender);
			LoadeManager.loadTemp(this.tempImg,"ui/bg_19.png");
			this.mModel.on(ModelActivities.UPDATE_DATA, this, this.updateUI);
			Tools.textLayout(this.text0,this.timerLabel,timeImg);
		}

		public function setData():void{
			//mFirstGet=true;
			mModel=ModelTreasure.instance;
			mArr1=mModel.cfg.buy_one;
			mArr2=mModel.cfg.buy_five;
			comCenter0.btn.skin="ui/btn_25.png";
			comCenter0.text1.text=Tools.getMsgById("treasure_text02",[mArr1[2]]);//"获得"+mArr1[3]+"银两";
			comCenter0.comNum.setData(AssetsManager.getAssetItemOrPayByID("coin"),mArr1[1]);

			comCenter1.btn.skin="ui/btn_26.png";
			comCenter1.text1.text=Tools.getMsgById("treasure_text02",[mArr2[2]]);//"获得"+mArr2[3]+"银两";
			comCenter1.comNum.setData(AssetsManager.getAssetItemOrPayByID("coin"),mArr2[1]);
			
			comCenter0.text0.text=comCenter1.text0.text=Tools.getMsgById("treasure_text03");//"消耗";
			comCenter0.text2.text=comCenter1.text2.text=Tools.getMsgById("treasure_text04");//"首次免费";
			updateUI();

			var arr:Array=mModel.getAwradList();
			for(var i:int=0;i<8;i++){
				var com:item_treasureUI=this["com"+i];
				com.com.setData(arr[i][0],arr[i][1],-1);
				com.boxAdd.visible=false;
				com.img.visible=arr[i][2];
			}
			setTimerLabel();
			this.btnAsk.on(Event.CLICK,this,function():void{
				ViewManager.instance.showTipsPanel(Tools.getMsgById(mModel.cfg.tips));
			});
		}

		private function setTimerLabel():void{
			this.timerLabel.text=mModel.time;
			timer.once(1000,this,setTimerLabel);
		}

		public function getClick(type:int):void{
			if(mIsScroll){
				tweenComplete(mGetArr);
				ViewManager.instance.showRewardPanel(mReData.gift_dict_list);
				return;
			}
			clearTween();
			var o:Object={};
			o["buy_key"]=type==0?"buy_one":"buy_five";
			var costNum:Number= 0;
			if(type==0){
				if(mFreeTimes1<=0){
					costNum = mModel.cfg.buy_one[1];
				}
			}else{
				if(mFreeTimes5<=0){
					costNum = mModel.cfg.buy_five[1];
				}
			}
			if(!Tools.isCanBuy("coin",costNum)){
				return;
			}
			NetSocket.instance.send("buy_treasure",o,new Handler(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				mReData=np.receiveData;
				mGetArr=np.receiveData.award_index_list;
				//if(mFirstGet){
					mIsScroll=true;
					isDone=false;
					setTween(0,mGetArr);
				//}else{
				//	clearTween();
				//	tweenComplete(mGetArr);
				//	ViewManager.instance.showRewardPanel(mReData.gift_dict_list);
				//}
				//mFirstGet=false;
			}));
		}

		public function updateUI():void{
			this.numLabel.text=mModel.mScore+"";
			mFreeTimes1=mModel.cfg.buy_one[0]-mModel.mBuyTimesOne;
			mFreeTimes5=mModel.cfg.buy_five[0]-mModel.mBuyTimesFive;
			this.list.array=mModel.getAddList();
			comCenter0.text0.visible=comCenter0.comNum.visible=mFreeTimes1<=0;
			comCenter0.text2.visible=mFreeTimes1>0;

			comCenter1.text0.visible=comCenter1.comNum.visible=mFreeTimes5<=0;
			comCenter1.text2.visible=mFreeTimes5>0;

			ModelGame.redCheckOnce(this.btnShop,mModel.red_point_shop());
		}

		private function listRender(cell:item_dialUI,index:int):void{
			var arr:Array=this.list.array[index];
			cell.com.setMoreData(arr[1]);
			var n:Number=mModel.mBuyTimesFive*5+mModel.mBuyTimesOne;
			cell.nameLabel.text=n>=arr[0]? arr[0]+"/"+arr[0] : n+"/"+arr[0];
			cell.imgGet.visible=n>=arr[0];
			//cell.off(Event.CLICK,this,itemClick);
			//var b:Boolean=false;
			//if(b){
			//	cell.on(Event.CLICK,this,itemClick,[index]);
			//}
		}


		public function setTween(begin:int,end_arr:Array):void{			
			if(isDone){
				//trace("提前结束");
				return;
			}
			mLapsNum += ( begin == 8 ) ? 1 : 0;
			begin=begin==8 ? 0 : begin;
			var com:item_treasureUI=this["com"+begin];
			if(!com){
				trace("error begin",begin);
				Laya.stage.mouseEnabled=true;
				return;
			}
			if(mIndex>=end_arr.length){
				//trace("over");
				Laya.stage.mouseEnabled=true;
				timer.once(200,this,timerCallBack);
				return;
			}
			Laya.stage.mouseEnabled=false;
			com.select.visible=true;
			var end:Number=end_arr[mIndex];
			mTween=Tween.to(this,{x:this.x},100,null,new Handler(this,function():void{
				com.select.visible=false;
				if(mLapsNum>=2){
					if(mLapsNum==mIndex+2 && end==begin){
						com.com.setSelecImg(false);
						mTween=Tween.to(com,{alpha:1},100,Ease.quadOut,new Handler(this,function():void{
							com.com.setSelecImg(true);
							mIndex+=1;
							setTween(begin+1,end_arr);
						}));
					}else{
						setTween(begin+1,end_arr);
					}
				}else{
					setTween(begin+1,end_arr);
				}
			}));
		}

		private function timerCallBack():void{
			mIsScroll=false;
			ViewManager.instance.showRewardPanel(mReData.gift_dict_list);
		}

		public function tweenComplete(end_arr:Array):void{
			if(mTween){
				mTween.complete();
			}
			for(var i:int=0;i<10;i++){
				var com:item_treasureUI=this["com"+i];
				if(com){
					if(end_arr.indexOf(i)!=-1){
						com.com.setSelecImg(true);
					}else{
						com.com.setSelecImg(false);
					}
				}else{
					
				}
			}
			mIsScroll=false;
			isDone=true;
			timer.clear(this,timerCallBack);
		}

		public function clearTween():void{
			for(var i:int=0;i<10;i++){
				var com:item_treasureUI=this["com"+i];
				if(com){
					com.com.setSelecImg(false);
				}else{
					break;
				}
			}
			mIndex=mLapsNum=0;
			
		}

		public function shopClick():void{
			ViewManager.instance.showView(["ViewTreasureShop",ViewTreasureShop]);
		}

		public function removeCostumeEvent():void 
		{
			this.mModel.off(ModelActivities.UPDATE_DATA, this, this.updateUI);
		}
	}

}