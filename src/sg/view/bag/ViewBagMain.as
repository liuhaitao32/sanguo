package sg.view.bag
{
	import ui.bag.bagMainUI;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import laya.ui.Box;
	import laya.display.Sprite;
	import laya.display.Node;
	import laya.events.Event;
	import laya.ui.Button;
	import avmplus.factoryXml;
	import sg.model.*;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigServer;
	import sg.cfg.ConfigClass;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.view.com.comIcon;
	import sg.model.ModelItem;
	import ui.bag.bagItemUI;
	import sg.model.ModelProp;
	import sg.utils.ObjectSingle;
	import laya.maths.MathUtil;
	import sg.model.ModelSkill;
	import laya.ui.Image;
	import sg.utils.Tools;
	import sg.model.ModelGame;
	import sg.model.ModelAlert;
	
	/**
	 * ...
	 * @author
	 */
	
	public class ViewBagMain extends bagMainUI{
		public var mouseX1:Number=0;
		public var mouseX2:Number=0;
		private var propModel:ModelProp=ModelManager.instance.modelProp;
		private var listdata:Array=[];
		public function ViewBagMain(){
			this.list.itemRender=bagItemUI;
			this.list.scrollBar.visible=false;
			this.list.selectEnable=true;
			this.list.mouseEnabled=true;
			//this.list.selectHandler=new Handler(this,onSelect);	
			this.list.renderHandler=new Handler(this,updateItem);
			this.useBtn.on(Event.CLICK,this,this.useClick,[this.useBtn]);
			ModelManager.instance.modelProp.on(ModelProp.event_updateprop,this,this.updateListener);
			//this.on(Event.DRAG_START,this,function())
			this.tab.on(Event.CHANGE,this,this.tabChange,[this.tab]);
			tab.labels=Tools.getMsgById("_bag_text11")+","+Tools.getMsgById("_bag_text12")+","+Tools.getMsgById("_bag_text13")+","+Tools.getMsgById("_bag_text14")+"";
			ModelManager.instance.modelProp.on(ModelProp.EVENT_GET_NEW_PROP,this,function():void{
				this.useBtn.gray=!propModel.hasOpenBox;
				tabChange();
			});
		}

		public function updateListener():void{
			//Trace.log("监听到刷新的消息");
			//setUp();
			tabChange();
		}
		
		override public function onAdded():void{
			this.useBtn.label=Tools.getMsgById("_bag_text05");
			this.useBtn.gray=!propModel.hasOpenBox;
			this.setTitle(Tools.getMsgById("_bag_text01"));
			this.list.repeatY=Math.ceil(this.list.height/150);
			tab.selectedIndex=0;
			this.list.height=this.height-160;
			//setUp();
			//this.list.on(Event.MOUSE_DOWN,this,mouse_down_handle);
			//this.list.on(Event.MOUSE_UP,this,mouse_up_handle);
		}

		override public function onRemoved():void{
			propModel.clearRewardProp();
			this.tab.selectedIndex=-1;
			this.list.scrollBar.value=0;
		}

		public function mouse_down_handle():void{
			mouseX1=this.mouseX;
			//Trace.log("mouse down "+mouseX1);
		}
		public function mouse_up_handle():void{
			
			mouseX2=list.mouseX;
			if(mouseX1-mouseX2>=100){//&&tab.selectedIndex<tab.items.length-1
				//Tween.to(this.list,{x:list.x+100},0.5);
				//tab.selectedIndex+=1;
				//Trace.log("tab.selected: "+tab.selectedIndex);
			}else if(mouseX1-mouseX2<=100){//&&tab.selectedIndex>0
				//Tween.to(this.list,{x:list.x-100},0.5);
				//tab.selectedIndex-=1;
				//Trace.log("tab.selected: "+tab.selectedIndex);
			}
			//Trace.log("mouse up "+mouseX2);
		}

		public function tabChange():void{
			//Trace.log("tab change "+tab.selectedIndex);
			if(tab.selectedIndex==-1){
				return;
			}
			listdata=propModel.getPropType(tab.selectedIndex);
			this.list.scrollBar.value=0;
			this.list.array=listdata;
			this.text0.text=this.list.array.length==0?Tools.getMsgById("_public200"):"";
		}

		public function useClick(obj:*):void{
			if(!propModel.hasOpenBox){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_bag_text19"));//"没有可以开的随机宝箱了");
				return;
			} 
				
			//Trace.log("点击使用所有道具");
			var obj:Object={};
			obj["item_id"]=-1;
			obj["item_num"]=1;
			obj["range_index"]=-1;
			NetSocket.instance.send("use_prop",obj,Handler.create(this,this.socketCallBack));

		}

		public function onSelect(index:int):void{
			
		}
		public function updateItem(cell:bagItemUI,index:int):void{
			var data:ModelItem=this.list.array[index];						
			cell.setData(data.id,data.num);
			ModelGame.redCheckOnce(cell,ModelAlert.red_bag_item(data.id),[cell.width-30,12]);
			cell.off(Event.CLICK,this,this.itemClick);
			cell.on(Event.CLICK,this,this.itemClick,[index]);
			//if(cell.getChildByName("xin")){
			//	(cell.getChildByName("xin") as Image).visible=data.isNew==0;
			//}
			cell.setNewIcon(data.isNew==0);
		}
		public function itemClick(index:int):void{
			ViewManager.instance.showView(ConfigClass.VIEW_BAG_INFO,this.list.array[index].id);
		}

		public function socketCallBack(np:NetPackage):void{
			//Trace.log("----------------",np.receiveData);
			ModelManager.instance.modelUser.updateData(np.receiveData);
			tabChange();
			this.useBtn.gray=!propModel.hasOpenBox;
			//setUp();
			ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
		}

		public function setUp():void{
			return;
			/*
			propModel.getUserProp(ModelManager.instance.modelUser.property);
			listdata=propModel.getPropType(tab.selectedIndex);
			listdata.sort(MathUtil.sortByKey("index",true,false));
			if(propModel.rewardProp!=null && propModel.rewardProp.length>0){
				listdata.sort(MathUtil.sortByKey("isNew",true,false));
			}
			this.list.array=listdata;
			//this.list.repeatY=Math.ceil(this.list.height/150);
			*/
		}
		
	}

}

