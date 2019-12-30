package sg.activities.view
{
	import laya.events.Event;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;

	import sg.activities.model.ModelActivities;
	import sg.activities.model.ModelDial;
	import sg.boundFor.GotoManager;
	import sg.manager.AssetsManager;
	import sg.manager.EffectManager;
	import sg.manager.LoadeManager;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.net.NetPackage;
	import sg.net.NetSocket;
	import sg.utils.Tools;

	import ui.activities.dial.dialMainUI;
	import ui.activities.dial.item_dialUI;
	import ui.activities.treasure.item_treasureUI;
	import sg.activities.model.ModelDialBse;



	/**
	 * ...
	 * @author
	 */
	public class DialMain extends dialMainUI{

		private var tween:Tween;
		private var mIndex:int;
		private var mAngle:Number=0;
		protected var mModel:ModelDialBse;
		private var drawGift:*;
		private var listData:Array=[];
		private var mIsScroll:Boolean=false;
		public function DialMain(){
			mIsScroll=false;
			Laya.stage.mouseEnabled=true;
			LoadeManager.loadTemp(this.tempImg,"ui/bg_19.png");
			this.text0.text=Tools.getMsgById("dial_text01");//"活动倒计时";
			this.text1.text=Tools.getMsgById("dial_text06");//"已充值";
			this.text2.text=Tools.getMsgById("dial_text02");//"可抽奖次数";
			this.text3.text=Tools.getMsgById("dial_text03");//"本次活动累计抽奖次数";
			this.text4.text=Tools.getMsgById("dial_text04");//"自定义转盘奖励 多种搭配任你选择";
			this.btnPay.label=Tools.getMsgById("_public104");//"充值";
			this.btnRecord.label=Tools.getMsgById("dial_text05");//"抽奖记录";
			this.btnPay.on(Event.CLICK, this, GotoManager.boundForPanel, [GotoManager.VIEW_PAY_TEST]);
			mIndex=0;
			mAngle=0;
			//setTween();
			this.btnGet.on(Event.CLICK,this,getClick);
			this.btnChoose.on(Event.CLICK,this,chooseClick);
			this.btnChange.on(Event.CLICK,this,chooseClick);
			this.btnChange.label = Tools.getMsgById("dial_text15");
			this.btnRecord.on(Event.CLICK, this, this._showRecord);
			this.btnAsk.on(Event.CLICK, this, this._onClickHelp);
			this.list.renderHandler=new Handler(this,listRender);

			Tools.textLayout(text0,timerLabel,timeImg,timeBox);
			Tools.textLayout(text1,comNum,comImg,boxCom);
			Tools.textLayout(text2,numLabel1,text2Img,boxLeft);
			Tools.textLayout(text3,numLabel2,text3Img,boxRight);

			this.btnPay.visible = ModelManager.instance.modelUser.canPay;
			this.boxTips.visible = this.btnPay.visible;
            this.on(Event.DISPLAY, this, this.onDisplay);
		}

		public function onDisplay():void {
			setModel(ModelDial.instance);
		}

		public function setModel(m:ModelDialBse):void {
			mModel = m;
			this.mModel.on(ModelActivities.UPDATE_DATA, this, this.updateUI);
			this.buyNum.text = String(mModel.buyNum);
			setTimerLabel();
			updateUI();
		}

		public function setCom():void{
            for(var i:int=0;i<10;i++){
				var item:item_treasureUI = (this["com"+i] as item_treasureUI);
				if(item){
					
					item.img.visible=false;
					if(listData[i]){
						var arr:Array=listData[i][0];
						var b:Boolean=listData[i][1];
						item.com.setData(arr[0],arr[1],-1);
						item.boxAdd.visible=false;
						item.img.visible=b;
					}else{
						item.boxAdd.visible=true;
					}
					item.com.visible=!item.boxAdd.visible
					EffectManager.changeSprColor(item.imgKuang,0);
				}				
			}
		}


		public function updateUI():void{
			listData=mModel.giftArr;
			setCom();
			this.box1.visible=mModel.getTimes==0;
			this.box2.visible=listData.length==0;
			this.btnChoose.visible=listData.length==0;
			this.btnGet.visible=!this.btnChoose.visible;
			this.imgArrow.visible=this.btnGet.visible;
			this.btnChange.visible=mModel.getTimes==0 && !this.box2.visible;
			this.bgBox.gray=listData.length==0;
			this.numLabel1.text=(mModel.canGetTimes-mModel.getTimes)+"";
			this.numLabel2.text=mModel.getTimes+"";
			this.comNum.setData(AssetsManager.getAssetItemOrPayByID("coin"), mModel.payMoney * 10);
			this.list.array=mModel.addList;
			this.btnGet.gray=(mModel.canGetTimes<=mModel.getTimes);
			this.imgArrow.gray=(mModel.canGetTimes<=mModel.getTimes);
		}

		public function setTween():void{
			if(tween){
				tween.complete();
			}
			mIsScroll=true;
			Laya.stage.mouseEnabled=false;
			var time:Number=1000+36*mIndex;
			mAngle=36*mIndex+360*3;

			tween=Tween.to(imgArrow,{"rotation":mAngle},time,Ease.quadOut,new Handler(this,function():void{
				Laya.stage.mouseEnabled=true;
				mAngle = mAngle>360 ? mAngle%360 : mAngle;
				imgArrow.rotation=mAngle;
				mIsScroll=false;
				ViewManager.instance.showRewardPanel(drawGift);
			}));
		}

		private function listRender(cell:item_dialUI,index:int):void{
			var arr:Array=this.list.array[index];
			cell.com.setMoreData(arr[1]);
			cell.nameLabel.text=mModel.getTimes>=arr[0]? arr[0]+"/"+arr[0] : mModel.getTimes+"/"+arr[0];
			cell.imgGet.visible=mModel.getTimes>=arr[0];
			//cell.off(Event.CLICK,this,itemClick);
			//var b:Boolean=false;
			//if(b){
			//	cell.on(Event.CLICK,this,itemClick,[index]);
			//}
		}
		private function setTimerLabel():void{
			this.timerLabel.text=mModel.remainTime;
			timer.once(1000,this,setTimerLabel);
		}

		private function getClick():void{
			if(mIsScroll){
				if(tween){
					tween.complete();
				}
				return;
			}
			if(mModel.canGetTimes<=mModel.getTimes){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("dial_tips02"));
				return;
			}			
			mModel.drawReward(Handler.create(this, function(data:*):void {
				drawGift = data.gift_dict;
				mIndex = data.mIndex;
				setTween();
			}));	
		}

		protected function chooseClick():void{
			ViewManager.instance.showView(["ViewDialChoose",ViewDialChoose], mModel.awardCfg);
		}

		public function _showRecord():void {
			ViewManager.instance.showView(["ViewDialRecord",ViewDialRecord], mModel.getRecrodsList());
		}

		public function _onClickHelp():void {
			ViewManager.instance.showTipsPanel(Tools.getMsgById(mModel.tips));
		}

		public function removeCostumeEvent():void {
			this.mModel.off(ModelActivities.UPDATE_DATA, this, this.updateUI);
		}	
	}

}