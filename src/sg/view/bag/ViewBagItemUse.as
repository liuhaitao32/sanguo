package sg.view.bag
{

	import ui.bag.bagItemUseUI;
	import laya.events.Event;
	import laya.ui.Slider;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.manager.ModelManager;
	import sg.model.ModelItem;
	import sg.model.ModelProp;
	import ui.bag.bagItemUI;
	import sg.utils.ObjectSingle;
	import sg.utils.Tools;
	
	/**
	 * ...
	 * @author
	 */
	
	public class ViewBagItemUse extends bagItemUseUI{
		public var propModel:ModelProp=ModelManager.instance.modelProp;
		public var itemModel:ModelItem=null;
		public var itemId:String="";
		public function ViewBagItemUse(){
			btnAdd.on(Event.CLICK,this,this.onClick,[this.btnAdd]);
			btnReduse.on(Event.CLICK,this,this.onClick,[this.btnReduse]);
			btnUse.on(Event.CLICK,this,this.onClick,[this.btnUse]);
			btnBig.on(Event.CLICK,this,this.onClick,[this.btnBig]);
			slider.on(Event.CHANGE,this,this.sliderChange);
			slider.showLabel=false;
			this.text1.text = Tools.getMsgById("_bag_text22");
		}

		override public function onAdded():void{
			//itemModel=propModel.curProp;// propModel.getItemProp(propModel.itemID);
			itemId=this.currArg;
			itemModel=ModelManager.instance.modelProp.getItemProp(itemId);
			slider.max=itemModel.num;
			slider.value=itemModel.num;
			useNum.text=slider.value+"/"+slider.max;
			haveNum.text=itemModel.num+"";
			//this.title.text=Tools.getMsgById("_bag_text09");;//"使用道具";//itemModel.id;
			this.comTitle.setViewTitle(Tools.getMsgById("_bag_text09"));
			this._name.text=itemModel.name;
			this.haveNum.text=Tools.getMsgById("_public18",[itemModel.num+""]);
			this.btnUse.label=Tools.getMsgById("_bag_text04");
			this.btnBig.label=Tools.getMsgById("_bag_text10");
			(this.icon as bagItemUI).setData(itemModel.id,-1,-1);
			this.icon.mCanClick=false;
		}
		override public function onRemoved():void{

		}

		public function sliderChange():void{
			useNum.text=slider.value+"/"+slider.max;
		}

		public function onClick(obj:*=null):void{
			switch(obj)
			{
				case this.btnAdd:
					slider.value+=1;
				break;
				case this.btnReduse:
					slider.value-=1;
				break;
				case this.btnUse:
					useItemClick();
				break;
				case this.btnBig:
					slider.value=slider.max;
				break;
			
				default:
					break;
			}
		}

		public function useItemClick():void{
			//ViewManager.instance.closePanel();
			//ViewManager.instance.showView(ConfigClass.VIEW_GET_REWARD);
			if(itemModel.boxT=="awardid"){
				//Trace.log("点击使用道具");
				if(itemModel.isCanOpen(slider.value)==false){
					return;
				}
				var obj:Object={};
				obj["item_id"]=itemModel.id;
				obj["item_num"]=slider.value;
				obj["range_index"]=-1;
				NetSocket.instance.send("use_prop",obj,Handler.create(this,this.socketCallBack));
			}else{
				ViewManager.instance.showView(ConfigClass.VIEW_BAG_CHOOSE,[itemModel.id,slider.value]);
			}
			
		}

		public function socketCallBack(np:NetPackage):void{
			//Trace.log("-随机宝箱打开成功",np.receiveData);
			ModelManager.instance.modelUser.updateData(np.receiveData);
			ViewManager.instance.closePanel();
			//ViewManager.instance.showView(ConfigClass.VIEW_GET_REWARD);
			ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
			ModelManager.instance.modelProp.event(ModelProp.event_updateprop);
		}
		
	}

}
