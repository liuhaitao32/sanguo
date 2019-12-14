package sg.activities.view
{
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Label;
	import laya.ui.ProgressBar;
	import laya.utils.Handler;

	import sg.activities.model.ModelHappy;
	import sg.boundFor.GotoManager;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.model.ModelItem;
	import sg.net.NetPackage;
	import sg.net.NetSocket;
	import sg.utils.StringUtil;
	import sg.utils.Tools;

	import ui.activities.carnival.happyOnceUI;
	import ui.bag.bagItemUI;

	/**
	 * ...
	 * @author
	 */
	public class pageHappyOnce extends happyOnceUI{
		private var cfg:Object;
		private var mPayDays:Number=0;
		private var userData:Array=[];
		public function pageHappyOnce(){
			this.text0.text=Tools.getMsgById("happy_text01");
			cfg=ModelHappy.instance.cfg.once;
			this.btn.off(Event.CLICK,this,btnClick);
			this.btn.on(Event.CLICK,this,btnClick);
			this.list.renderHandler=new Handler(this,this.listRender);

			Tools.textLayout(this.text0,this.timerLabel,this.timerImg);
			setData();
			setTimerLabel();
		}


		public function setData():void{
			updateUI();
			var arr:Array=ModelManager.instance.modelProp.getRewardProp(cfg.reward_every);
			this.list.repeatX=arr.length;
			this.list.array=arr;
			
		}

		public function updateUI():void{
			userData=ModelHappy.instance.userHappyOnce;
			mPayDays=userData[1];
			this.numLabel.text=mPayDays+"";//已经充值多少天
			if(userData[0]==1){
				this.btn.label=Tools.getMsgById("_public138");//"领取"
				this.btn.labelColors="#fffbc1";
				this.btn.skin="ui/btn_ok.png";
				this.btn.gray=false;
			}else{
				if(userData[2]==ModelManager.instance.modelUser.loginDateNum){
					this.btn.label=Tools.getMsgById("_jia0034");//已领取
					this.btn.skin="ui/btn_ok.png";
					this.btn.gray=true;
					this.btn.labelColors="#fffbc1";
				}else{
					this.btn.label=Tools.getMsgById("_public105");//"去充值"
					this.btn.labelColors="#9ff3ff";
					this.btn.skin="ui/btn_no.png";
					this.btn.gray=false;
				}
			}
			setPro();
			setTopCom();
		}
		

		public function setTopCom():void{
			var arr:Array=[];
			//for(var s:String in cfg.need_days){
			//	arr.push({"index":Number(s),"reward":ModelManager.instance.modelProp.getRewardProp(cfg.need_days[s])});
			//}
			//arr.sort(MathUtil.sortByKey("index",false,false));
			for(var i:int=0;i<cfg.need_days.length;i++){
				arr.push({"index":cfg.need_days[i][0],"reward":ModelManager.instance.modelProp.getRewardProp(cfg.need_days[i][1])});
			}
			//if(arr[0].reward.length>1){
			//	this.com0.setData(ModelProp.boxImg,-1,-1);
			//}else{
				this.com0.setData(arr[0].reward[0][0],arr[0].reward[0][1],-1);
			//}

			//if(arr[1].reward.length>1){
			//	this.com1.setData(ModelProp.boxImg,-1,-1);
			//}else{
				this.com1.setData(arr[1].reward[0][0],arr[1].reward[0][1],-1);
			//}
			this.com0.setSpecial(false);
			this.com1.setSpecial(false);

			this.com0.off(Event.CLICK,this,boxClick);
			this.com1.off(Event.CLICK,this,boxClick);

			if(userData[3].indexOf(0)!=-1){
				this.com0.on(Event.CLICK,this,boxClick,[0]);
				this.com0.setSpecial(true);
			}
			if(userData[3].indexOf(1)!=-1){
				this.com1.on(Event.CLICK,this,boxClick,[1]);
				this.com1.setSpecial(true);
			}
			this.rewardLabel0.text=ModelItem.getItemName(arr[0].reward[0][0])+"x"+arr[0].reward[0][1];
			this.rewardLabel1.text=ModelItem.getItemName(arr[1].reward[0][0])+"x"+arr[1].reward[0][1];
		}

		public function setPro():void{
			for(var i:int=0;i<5;i++){
				var box:Box=this["pro"+i];
				if(box){
					(box.getChildByName("pro") as ProgressBar).value=mPayDays>i ? 1 : 0;
					(box.getChildByName("txt") as Label).text=Tools.getMsgById("_jia0046",[StringUtil.numberToChinese(i+1)]);
				}
			}
		}

		public function boxClick(index:int):void{
			NetSocket.instance.send("get_happy_catena_reward",{"reward_index":index},new Handler(this,function(np:NetPackage):void{
				ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
				ModelManager.instance.modelUser.updateData(np.receiveData);
				userData=ModelHappy.instance.userHappyOnce;
				setTopCom();
			}));
		}


		public function listRender(cell:bagItemUI,index:int):void{
			var arr:Array=this.list.array[index];
			cell.setData(arr[0],arr[1],-1);
		}

		public function btnClick():void{
			if(userData[0]==1){
				//"领取"
				NetSocket.instance.send("get_happy_once_reward",{},new Handler(this,function(np:NetPackage):void{
					ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
					ModelManager.instance.modelUser.updateData(np.receiveData);
					updateUI();
				}));	
			}else{
				if(userData[2]==ModelManager.instance.modelUser.loginDateNum){
				    //已领取
					ViewManager.instance.showTipsTxt(Tools.getMsgById("happy_tips01"));
				}else{
					//"去充值"
					GotoManager.boundForPanel(GotoManager.VIEW_PAY_TEST);
				}
			}
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