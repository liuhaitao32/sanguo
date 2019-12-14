package sg.view.bag
{
	import ui.bag.bagItemInfoUI;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.model.ModelProp;
	import sg.manager.ModelManager;
	import sg.model.ModelItem;
	import sg.utils.Tools;
	import avmplus.factoryXml;
	import ui.bag.bagItemUI;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.utils.ObjectSingle;
	import sg.model.ModelUser;

	/**
	 * ...
	 * @author
	 */
	
	public class ViewBagItemInfo extends bagItemInfoUI{
			    
		public static var itemID:String="";
		public var itemProp:ModelItem=null;
		public var itemId:String;
		public function ViewBagItemInfo(){
			ModelManager.instance.modelUser.on(ModelUser.EVENT_USER_UPDATE,this,function():void{
				this.num.text=Tools.getMsgById("_public18",[itemProp.num+""]);
			});
			btnUse.on(Event.CLICK,this,this.onclick,[this.btnUse]);
			btnDet.on(Event.CLICK,this,this.onclick,[this.btnDet]);
		}
		override public function onAdded():void{
			//this.title.text=Tools.getMsgById("_bag_text08");
			this.comTitle.setViewTitle(Tools.getMsgById("_bag_text08"));
			this.btnUse.label=Tools.getMsgById("_bag_text04");
			this.btnDet.label=Tools.getMsgById("_bag_text07");
			itemId=this.currArg;
			//itemProp=propModel.curProp;
			itemProp=ModelManager.instance.modelProp.getItemProp(itemId);
			this.info.text = itemProp.info;
			this._name.text = itemProp.getName(true);
			this._name.color = itemProp.getColor();
			
			this.num.text=Tools.getMsgById("_public18",[itemProp.num+""]);

			btnDet.centerX=-175;
			btnUse.centerX=175;
			btnDet.visible=btnUse.visible=true;

			var n:Number=0;
			if(!itemProp.boxT){
				btnUse.visible=false;
				n+=1;
			}
			
			if(itemProp.type!=3 && itemProp.source==null){
				btnDet.visible=false;
				n+=1;
				
			}
			if(n==1){
				btnDet.centerX=btnUse.centerX=0;
			}
			(this.icon as bagItemUI).setData(itemProp.id,-1,-1);
			this.icon.mCanClick=false;
		}
		override public function onRemoved():void{
			//btnDet.visible=btnUse.visible=true;
			//btnDet.left=btnUse.right=30;
			//btnDet.centerX=NaN;
		}

		public function onclick(btn:*=null):void{
			switch(btn)
			{
				case this.btnUse:
					//自选箱
					if(itemProp.boxT is Array){
						var b:Boolean=false;//觉醒自选箱
						for(var i:int=0;i<itemProp.boxT.length;i++){
							if(itemProp.boxT[i][0]=="awaken"){
								b=true;
								break;
							}
						}
						if(itemProp.num==1 || b){
							ViewManager.instance.showView(ConfigClass.VIEW_BAG_CHOOSE,[itemProp.id,1]);
						}else{
							ViewManager.instance.showView(ConfigClass.VIEW_BAG_USE,itemProp.id);
						}
					}else{//普通箱子
						if(itemProp.num==1){
							useItem();
						}else{
							ViewManager.instance.showView(ConfigClass.VIEW_BAG_USE,itemProp.id);
						}
					}
					break;
				case this.btnDet:
					ViewManager.instance.showView(ConfigClass.VIEW_BAG_SOURSE,itemProp.id);
					break;
				default:
					break;
			}
		}

		public function useItem():void{
			//Trace.log("点击使用道具");
			if(itemProp.isCanOpen(1)==false){
				return;
			}
			var obj:Object={};
			obj["item_id"]=itemProp.id;
			obj["item_num"]=1;
			obj["range_index"]=-1;
			
			NetSocket.instance.send("use_prop",obj,Handler.create(this,this.socketCallBack));
		}
		public function socketCallBack(np:NetPackage):void{
			//Trace.log("-随机宝箱打开成功",np.receiveData);
			ModelManager.instance.modelUser.updateData(np.receiveData);
			ViewManager.instance.closePanel();
			//ModelManager.instance.modelProp.getRewardProp(np.receiveData.gift_dict.prop);
			//ViewManager.instance.showView(ConfigClass.VIEW_GET_REWARD);
			ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
			ModelManager.instance.modelProp.event(ModelProp.event_updateprop);
		}
		
	}

}
