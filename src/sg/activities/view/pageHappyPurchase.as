package sg.activities.view
{
	import laya.events.Event;
	import laya.utils.Handler;

	import sg.activities.model.ModelHappy;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.net.NetPackage;
	import sg.net.NetSocket;
	import sg.utils.Tools;

	import ui.activities.carnival.happyPurchaseUI;
	import ui.bag.bagItemUI;

	/**
	 * @author
	 */
	public class pageHappyPurchase extends happyPurchaseUI{
		public var cfg:Object;
		public var userData:Array;
		public var mPayMoney:Number;
		public var mOpenDays:Number=0;
		public var mIndex:int=0;
		public function pageHappyPurchase(){
			this.text0.text=Tools.getMsgById("happy_text01");
			cfg=ModelHappy.instance.cfg.purchase;
			this.btn.on(Event.CLICK,this,function():void{
				if(ModelHappy.instance.userHappyPurchase[0]==1){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("happy_tips02"));//"今日已购买");
					return;
				}
				if(mOpenDays>7){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("happy_tips07"));
					return;
				}
				if(mPayMoney<cfg.need_pay_money[mIndex]){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("happy_tips03",[cfg.need_pay_money[mIndex]*10]));//"今日还未充值");
					return;
				}else{
					if(!Tools.isCanBuy("coin",cfg.buy[mIndex])){
						return;
					}
					NetSocket.instance.send("buy_happy_purchase",{},new Handler(this,function(np:NetPackage):void{
						ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
						ModelManager.instance.modelUser.updateData(np.receiveData);		
						updateUI();		
					}));
				}
			});
			this.btn.visible = true;

			Tools.textLayout(this.text0,this.timerLabel,this.timerImg);
			setData();
			setTimerLabel();
		}

		public function setData():void{
			updateUI();
			this.payLabel.text=cfg.need_pay_money[mIndex]*10+"";
			this.btn.setDoubleTxt(cfg.buy_show[mIndex],cfg.buy[mIndex]);
			this.infoLabel.text=Tools.getMsgById(cfg.info);
			var arr:Array=ModelManager.instance.modelProp.getRewardProp(cfg.reward[mIndex]);
			this.rewardList.renderHandler=new Handler(this,listRender);
			this.rewardList.repeatX=arr.length;
			this.rewardList.array=arr;
			
		}

		public function updateUI():void{
			userData=ModelHappy.instance.userHappyPurchase;
			mOpenDays=ModelManager.instance.modelUser.loginDateNum;
			mIndex=(mOpenDays-1)>6?6:(mOpenDays-1);
			mPayMoney=userData[2]==mOpenDays?userData[1]:0;
			this.numLabel.text=(mPayMoney*10)+"/"+(cfg.need_pay_money[mIndex]*10);
			this.btn.gray=(userData[0]==1)||(mPayMoney<cfg.need_pay_money[mIndex]);

			//已购买就隐藏
			if(userData[0]==1) this.btn.visible = false;
		}

		public function listRender(cell:bagItemUI,index:int):void{
			var arr:Array=this.rewardList.array[index];
			cell.setData(arr[0],arr[1],-1);
		}

		public function setTimerLabel():void{
			var n:Number=ModelHappy.instance.endTime;
			if(n<=0){
				this.timerLabel.text=Tools.getMsgById("happy_text02");//"已经结束";	
				return;
			}else{
				this.timerLabel.text=Tools.getTimeStyle(n);
			}
			timer.once(1000,this,setTimerLabel);
		}
	}

}