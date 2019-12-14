package sg.activities.view
{
	import laya.events.Event;
	import laya.utils.Handler;

	import sg.activities.model.ModelHappy;
	import sg.manager.AssetsManager;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.map.utils.ArrayUtils;
	import sg.net.NetPackage;
	import sg.net.NetSocket;
	import sg.utils.Tools;

	import ui.activities.carnival.happyAddupUI;

	/**
	 * ...
	 * @author
	 */
	public class pageHappyAddup extends happyAddupUI{
		private var cfg:Object;
		private var mDoubleTime:Number;
		public function pageHappyAddup(){
			this.text0.text=Tools.getMsgById("happy_text01");
			cfg=ModelHappy.instance.cfg.addup;
			//this.list.itemRender=renderHappy;
			this.list.itemRender=Item;
			this.list.renderHandler=new Handler(this,listRender);
			this.list.scrollBar.visible=false;

			Tools.textLayout(this.text0,this.timerLabel,this.timerImg);
			setData();
			setTimerLabel();
			tText.text=Tools.getMsgById("happy_text08");
			mDoubleTime=ModelHappy.instance.getDoubleTime();
			setTimeLabel();
		}

		public function setData():void{
			updateUI();
			this.btnCheck.label=Tools.getMsgById("happy_text06");
			this.btnCheck.off(Event.CLICK,this,checkClick);
			this.btnCheck.on(Event.CLICK,this,checkClick);
			
		}

		private function setTimeLabel():void{
			if(mDoubleTime>0){
				this.doubleBox.visible=true;
				this.tTime.text=Tools.getTimeStyle(mDoubleTime);
			}else{
				this.doubleBox.visible=false;
				return;
			}
			mDoubleTime-=1000;
			Laya.timer.once(1000,this,setTimeLabel);
		}

		public function updateUI():void{
			var userData:Array=ModelHappy.instance.userHappyAddup;
			var n:Number=userData[1]*10;
			this.numCom.setData(AssetsManager.getAssetItemOrPayByID("coin"),n);
			var arr:Array=[];
			for(var i:int=0;i<cfg.reward.length;i++){
				arr.push({"title":Tools.getMsgById("happy_text07",[cfg.reward[i][0]*10]),// "累计充值"+cfg.reward[i][0]*10+"黄金",
						  "reward":cfg.reward[i][1],
						  "value":n,
						  "max":cfg.reward[i][0]*10,
						  "sortKey":(i < userData[0] && userData[2].indexOf(i)==-1)?1:0,
						  "index":i,
						  "isGet":(i < userData[0] && userData[2].indexOf(i)==-1)});
			}

			ArrayUtils.sortOn(["sortKey","max"],arr,false);
			this.list.array=arr;
		}

		public function listRender(cell:Item,index:int):void{
			cell.setData(this.list.array[index]);
			cell.btnGet.off(Event.CLICK,this,itemClick);
			cell.btnGet.on(Event.CLICK,this,itemClick,[index]);
		}

		public function itemClick(index:int):void{
			NetSocket.instance.send("get_happy_addup_reward",{"reward_index":this.list.array[index].index},new Handler(this,function(np:NetPackage):void{
				ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
				ModelManager.instance.modelUser.updateData(np.receiveData);
				updateUI();
			}));
		}

		public function checkClick():void{
			ViewManager.instance.showView(["ViewEmboitement",ViewEmboitement],[ModelHappy.instance.cfg.addup.show,ModelHappy.instance.cfg.addup.info,Tools.getMsgById("happy_text05")]);
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

import sg.manager.ModelManager;
import sg.utils.Tools;

import ui.activities.carnival.item_addup1UI;
import ui.activities.carnival.item_emboUI;

class Item extends item_addup1UI{

	public function Item(){
		this.text0.text=Tools.getMsgById("happy_text03");//"进度";
		this.btnGet.label = Tools.getMsgById("_jia0035");
		this.list.renderHandler=new Handler(this,listRender);

	}

	public function setData(obj:Object):void{
		this.titleLabel.text=obj.title;
		var arr:Array=ModelManager.instance.modelProp.getCfgPropArr(obj.reward);
		this.list.repeatX=arr.length;
		this.list.array=arr;

		if(obj.isGet){
			this.imgGet.visible=true;
			this.proBox.visible=this.btnGet.visible=false;
		}else{
			this.imgGet.visible=false;
			var _max:Number=obj.max;
			var _value:Number=obj.value;
			if(_value>=_max){
				this.proBox.visible=false;
				this.btnGet.visible=true;
			}else{
				this.proBox.visible=true;
				this.btnGet.visible=false;
				this.textLabel1.text=_value>_max ? _max+"/"+_max : _value+"/"+_max;
				this.proBar.value=_value/_max;
			}
		}
		this.numImg.width=this.textLabel1.width + 12;
		this.numImg.width=this.numImg.width<105 ? 105 : this.numImg.width;
		this.textLabel1.x=this.numImg.x+(this.numImg.width-this.textLabel1.width)/2;
	}

	public function listRender(cell:item_emboUI,index:int):void{
		var arr:Array=this.list.array[index];
		cell.icon.setData(arr[0],arr[1],-1);
	}


}