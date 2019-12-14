package sg.view.map
{
	import ui.map.creditResultUI;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import laya.events.Event;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.manager.AssetsManager;
	import ui.bag.bagItemUI;
	import sg.model.ModelItem;
	import sg.utils.Tools;

	/**
	 * 国战表彰  战功
	 * @author
	 */
	public class ViewCreditResult extends creditResultUI{
		public var arr:Array=[];
		public var reData:Object;
		public function ViewCreditResult(){
			this.btn0.on(Event.CLICK,this,btnClick);
			this.btn1.on(Event.CLICK,this,btnClick);
			this.list.renderHandler=new Handler(this,this.listRender);
			this.list.scrollBar.visible=false;
			this.comTitle.setViewTitle(Tools.getMsgById("_credit_text19"));
			this.label0.text=Tools.getMsgById("_credit_text20");
			this.label1.text=Tools.getMsgById("_credit_text21");
			this.label2.text=Tools.getMsgById("_credit_text22");
			this.label3.text=Tools.getMsgById("_credit_text23");
			this.label4.text=Tools.getMsgById("_credit_text24");

			this.btn0.label = Tools.getMsgById("_credit_text28");
			this.btn1.label = Tools.getMsgById("_credit_text29");

		}

		public override function onAdded():void{
			arr=ModelManager.instance.modelUser.credit_settle;
			if(arr==null || arr.length==0){
				this.closeSelf();
				return;
			}
			//this.mouseEnabled=false;
			this.isAutoClose=false;
			setData();
			
		}

		public function setData():void{
			var gift:Object=arr[1];
			this.com0.setData(AssetsManager.getAssetItemOrPayByID("item041"),arr[2]);
			this.text1.text=arr[3]+"";
			this.text2.text=arr[4]+"";
			this.text3.text=arr[5]+"";
			if(gift==null || Tools.getDictLength(gift) == 0){
				this.comIndex.setRankIndex(0,Tools.getMsgById("_public101"));
				this.list.visible=false;
				this.text5.text=Tools.getMsgById("_credit_text17");//"很遗憾，今年没有获得任何战功奖励";
				this.btn0.visible=false;
				this.btn1.visible=true;
			}else{
				this.comIndex.setRankIndex(arr[0],Tools.getMsgById("_public101"));
				this.text5.text="";
				this.list.visible=true;
				this.btn0.visible=true;
				this.btn1.visible=false;
				var listData:Array=ModelManager.instance.modelProp.getRewardProp(gift);
				this.list.array=listData;
			}
		}

		public function listRender(cell:bagItemUI,index:int):void{
			//trace(this.list.array[index]);
			var item:Array=this.list.array[index];
			//cell.setData(item.icon,item.ratity,"",item.addNum+"",item.type);
			cell.setData(item[0],item[1],-1);
		}

		public function btnClick():void{
			// ModelManager.instance.modelUser.updateData(reData);
			NetSocket.instance.send("del_credit_settle",{},new Handler(this,callBack));
		}

		private function callBack(np:NetPackage):void{
			reData=np.receiveData;
			ViewManager.instance.closePanel(this);
			ModelManager.instance.modelUser.updateData(reData);
			ViewManager.instance.showRewardPanel(reData.gift_dict);

		}

		public override function onRemoved():void{
			this.isAutoClose=true;
		}
	}

}