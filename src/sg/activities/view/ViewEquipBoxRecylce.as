package sg.activities.view
{
	import ui.activities.equipBox.equipBoxRecylceUI;
	import ui.bag.bagItemUI;
	import sg.activities.model.ModelEquipBox;
	import sg.manager.ModelManager;
	import laya.utils.Handler;
	import sg.manager.AssetsManager;
	import sg.cfg.ConfigServer;
	import laya.events.Event;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.manager.ViewManager;
	import sg.utils.Tools;
	import sg.activities.model.ModelActivities;
	import sg.model.ModelInside;
	import sg.model.ModelUser;

	/**
	 * ...
	 * @author
	 */
	public class ViewEquipBoxRecylce extends equipBoxRecylceUI{
		
		
		public function ViewEquipBoxRecylce(){
			this.list.renderHandler=new Handler(this,listRender);
			this.list.scrollBar.visible=false;
			this.btn.on(Event.CLICK,this,btnClick);
			this.cCom.on(Event.CLICK,this,function():void{
				ViewManager.instance.showItemTips(ModelEquipBox.instance.cfg.item_id);
			});
			this.tTitle.text = Tools.getMsgById('equip_box8');
			Tools.textLayout2(tTitle,imgTitle,400,150);
			
		}

		private function callBack():void{
			//新的一天 活动结束  关闭面板
			if(ModelEquipBox.instance.active==false){
				this.closeSelf();
			}
		}


		override public function onAdded():void{
			ModelManager.instance.modelInside.on(ModelUser.EVENT_IS_NEW_DAY,this,callBack);

			var o:Object=ModelEquipBox.instance.getRecoverItem();
			var arr:Array=ModelManager.instance.modelProp.getRewardProp(o);
			this.list.array=arr;
			this.list.repeatX=arr.length>4 ? 4 : arr.length;
			this.list.centerX=0;

			var obj:Object=ModelEquipBox.instance.getGoods()["recover"];
			var n:Number=0;
			for(var s:String in o){
				if(obj[s]) n+=obj[s][1]*o[s];
			}
			this.cCom.setData(AssetsManager.getAssetItemOrPayByID(ModelEquipBox.instance.cfg.item_id),n);

			this.btn.label=Tools.getMsgById("equip_box4");
		}

		private function listRender(cell:bagItemUI,index:int):void{
			var arr:Array=this.list.array[index];
			cell.setData(arr[0],arr[1],-1);
		}

		private function btnClick():void{
			NetSocket.instance.send("equip_recover",{},new Handler(this,function(np:NetPackage):void{
				closeSelf();
				ModelManager.instance.modelUser.updateData(np.receiveData);
				ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
				ModelEquipBox.instance.event(ModelActivities.UPDATE_DATA);
			}));
		}

		override public function onRemoved():void{
			ModelManager.instance.modelInside.off(ModelUser.EVENT_IS_NEW_DAY,this,callBack);
			this.list.scrollBar.value=0;
		}
	}

}