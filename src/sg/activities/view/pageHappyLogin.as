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

	import ui.activities.carnival.happyLoginUI;

	/**
	 * ...
	 * @author
	 */
	public class pageHappyLogin extends happyLoginUI{
		public var cfg:Object=ModelHappy.instance.cfg.login;
		public function pageHappyLogin(){
			this.text0.text=Tools.getMsgById("happy_text01");

			Tools.textLayout(this.text0,this.timerLabel,this.timerImg);
			setData();
			setTimerLabel();
		}



		public function setData():void{
			this.list.itemRender=Item;
			this.list.renderHandler=new Handler(this,listRender);
			this.list.scrollBar.visible=false;
			var arr:Array=[];
			for(var i:int=0;i<cfg.reward.length;i++){
				arr.push({"index":i,"reward":ModelManager.instance.modelProp.getCfgPropArr(cfg.reward[i])});
			}
			this.list.array=arr;
		}

		public function updateUI():void{
			list.refresh();
		}

		public function listRender(cell:Item,index:int):void{
			cell.setData(this.list.array[index]);
			cell.btnGet.off(Event.CLICK,this,itemClick);
			cell.btnGet.on(Event.CLICK,this,itemClick,[index]);
		}

		public function itemClick(index:int):void{
			NetSocket.instance.send("get_happy_login_reward",{"reward_index":index},new Handler(this,function(np:NetPackage):void{
				ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
				ModelManager.instance.modelUser.updateData(np.receiveData);
				list.refresh();
			}));
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

import laya.utils.Handler;

import sg.activities.model.ModelHappy;
import sg.manager.ModelManager;
import sg.utils.StringUtil;
import sg.utils.Tools;

import ui.activities.carnival.item_happyUI;
import ui.bag.bagItemUI;

class Item extends item_happyUI{
	public function Item(){
		this.rewardList.itemRender=bagItemUI;
		this.rewardList.renderHandler=new Handler(this,rewardListRender);
	}

	public function setData(obj:Object):void{
		
		this.dayLabel.text=Tools.getMsgById("_jia0046",[StringUtil.numberToChinese(obj.index+1)]);//"第"+StringUtil.numberToChinese(obj.index+1)+"天";
		var b:Boolean=(ModelHappy.instance.openDays-1)==obj.index;
		this.img0.skin=b?"ui/bar_16_1.png":"ui/bar_16.png";
		this.img1.skin=b?"ui/bar_11.png":"ui/bar_11_1.png";
		var arr:Array=ModelHappy.instance.userHappyLogin;
		this.imgGet.visible=(obj.index < arr[0] && arr[2].indexOf(obj.index)==-1);		
		this.btnGet.visible=!this.imgGet.visible;
		this.btnGet.gray=obj.index >= arr[0];
		this.btnGet.mouseEnabled=!this.btnGet.gray;
		this.rewardList.repeatX=obj.reward.length;
		this.rewardList.array=obj.reward;

		this.btnGet.label = Tools.getMsgById("_jia0035");
		
	}

	public function rewardListRender(cell:bagItemUI,index:int):void{
		var arr:Array=this.rewardList.array[index];
		cell.setData(arr[0],arr[1],-1);
	}

}