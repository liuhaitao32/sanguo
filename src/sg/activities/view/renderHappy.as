package sg.activities.view
{
	import laya.events.Event;

	import sg.boundFor.GotoManager;
	import sg.manager.ModelManager;
	import sg.utils.Tools;

	import ui.activities.carnival.item_addupUI;

	/**
	 * ...
	 * @author
	 */
	public class renderHappy extends item_addupUI{
		public function renderHappy(){
			Tools.textLayout(this.text0,this.textLabel1,this.numImg);
		}

		public function setData(obj:Object):void{
			var _max:Number=obj.max;
			var _value:Number=obj.value;
			this.text0.text=Tools.getMsgById("happy_text03");//"进度";
			this.textLabel0.text=obj.title;
			this.textLabel1.text=_value>_max ? _max+"/"+_max : _value+"/"+_max;
			this.proBar.value=_value/_max;
			this.imgGet.visible=obj.isGet;
			this.btnGet.visible=!obj.isGet;	
			this.btnGet.gray=this.proBar.value!=1;
			this.btnGet.mouseEnabled=!this.btnGet.gray;
			this.btnGet.label = Tools.getMsgById("_jia0035");
			this.numImg.width=this.textLabel1.width+12;
			this.numImg.width=this.numImg.width<105 ? 105 : this.numImg.width;
			this.textLabel1.x=this.numImg.x+(this.numImg.width-this.textLabel1.width)/2;
			setRewardCom(obj.reward);	
		}

		public function setRewardCom(obj:Object):void{
			var arr:Array=ModelManager.instance.modelProp.getRewardProp(obj);
			this.rewardCom.off(Event.CLICK,this,itemClick);
			if(arr.length>1){
				//this.rewardCom.setData(ModelProp.boxImg,-1,-1);
				this.rewardCom.on(Event.CLICK,this,itemClick,[obj]);
			}//else{
				this.rewardCom.setData(arr[0][0],arr[0][1],-1);
			//}
		}

		public function itemClick(obj:Object):void{
			GotoManager.boundForPanel(GotoManager.VIEW_REWARD_PREVIEW, '', obj);
		}
	}

}