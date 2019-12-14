package sg.view.bag
{
	import ui.bag.bagItemSourceUI;
	import sg.model.ModelItem;
	import sg.manager.ModelManager;
	import ui.bag.bagItemUI;
	import sg.model.ModelUser;
	import ui.bag.item_source_pveUI;
	import laya.utils.Handler;
	import sg.model.ModelProp;
	import laya.maths.MathUtil;
	import sg.cfg.ConfigServer;
	import sg.manager.ViewManager;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import laya.events.Event;
	import sg.boundFor.GotoManager;
	import sg.utils.Tools;
	import sg.map.utils.ArrayUtils;

	/**
	 * ...
	 * @author
	 */
	public class ViewbagItemSource extends bagItemSourceUI{

		public var item_id:String="";
		public var it:ModelItem;
		public var sourceObj:Object={};

		public function ViewbagItemSource(){
			this.list.scrollBar.visible=false;
			//this.title.text=Tools.getMsgById("_bag_text18");//"道具信息";
			this.comTitle.setViewTitle(Tools.getMsgById("_bag_text18"));
			ModelManager.instance.modelUser.on(ModelUser.EVENT_USER_UPDATE,this,function():void{
				this.num.text=Tools.getMsgById("_public18",[it.num+""]);
				list.refresh();
			});
			
		}

		override public function onAdded():void{
			//var data:ModelItem=ModelManager.instance.modelProp.curProp;
			item_id=this.currArg;
			it=ModelManager.instance.modelProp.getItemProp(item_id);
			this._name.text=it.name;
			this.num.text=Tools.getMsgById("_public18",[it.num+""]);
			//this.info.text=it.info;
			(this.icon as bagItemUI).setData(it.id,-1,-1);
			this.icon.mCanClick=false;
			var arr:Array=[];
			if(ModelProp.pve_gift_dict && ModelProp.pve_gift_dict.hasOwnProperty(item_id)){
				var o:Object=ModelProp.pve_gift_dict[item_id];
				for(var s:String in o){
					var battlId:String=s;
					var chpterId:String=ConfigServer.pve.battle[battlId].chapter_belong;
					var b:Boolean=false;
					if(ModelManager.instance.modelUser.pve_records.chapter[chpterId]){
						b=!ModelManager.instance.modelUser.pve_records.chapter[chpterId].star.hasOwnProperty(battlId);		
					}else{
						b=true;
					}
					var sort1:Number=b?1:0;
					var sort2:Number=Number(battlId.substr(6,3));
					arr.push({"id":s,"num":o[s],"gray":b,"sort1":sort1,"sort2":sort2});
				}
				//arr.sort(MathUtil.sortByKey("sort",true,true));
				//arr.sort(MathUtil.sortByKey("num",true,true));
				ArrayUtils.sortOn(["sort1","sort2"],arr,true);
				setUI(Item_Pve,new Handler(this,listRender0),arr);
				
			}else{
				sourceObj=it.source;
				for(var key:String in sourceObj){
					var obj:Object=sourceObj[key];
					var new_obj:Object={};
					new_obj["index"]=Number(key);
					new_obj["title"]=obj.getway;
					new_obj["gotoArr"]=obj.gotoArr;
					new_obj["icon"]="ui/"+obj.icon+".png";
					new_obj["show"]=obj.show!=null?obj.show:1;
					arr.push(new_obj);
				}
				arr.sort(MathUtil.sortByKey("index",false,true));
				setUI(Item_Source,new Handler(this,listRender1),arr);
				
			}

			
		}

		public function setUI(item:*,handler:Handler,arr:Array):void{
			if(this.list.renderHandler){
				this.list.renderHandler.clear();
			}
			this.list.renderHandler=handler;
			this.list.itemRender=item;
			this.list.array=arr;
			this.list.repeatY=arr.length>4?4:arr.length;
			this.box.height=this.list.top+this.list.height+15;
		}

		public function listRender0(item:Item_Pve,index:int):void{
			item.setData(this.list.array[index]);
			item.btn.off(Event.CLICK,this,this.itemClick0);
			item.btn.on(Event.CLICK,this,this.itemClick0,[item]);
		}

		public function listRender1(item:Item_Source,index:int):void{
			item.setData(this.list.array[index]);
			item.btn.off(Event.CLICK,this,this.itemClick1);
			item.btn.on(Event.CLICK,this,this.itemClick1,[index]);	
		}

		public function itemClick0(item:Item_Pve):void{
			if(item.btn.gray){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_bag_text17"));
				return;
			}
			if(item.times==0){
				var arr:Array=ModelManager.instance.modelUser.pveBuyArr();
				if(arr[1]==0){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_pve_tips01"));
					return;
				}
				ViewManager.instance.showBuyTimes(2,arr[0],arr[1],arr[2]);
			}else{
				var sendData:Object={};
				sendData["battle_id"]=item.battlId;
				sendData["repeat"]=1;
				NetSocket.instance.send("pve_combat",sendData,Handler.create(this,function(np:NetPackage):void{
					ModelManager.instance.modelUser.updateData(np.receiveData);
					ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
					ModelManager.instance.modelUser.event(ModelUser.EVENT_UPDATE_ARMY_ITEM);
					list.refresh();
				}));
			}
		}

		public function itemClick1(index:int):void{
			//ViewManager.instance.closePanel();
			this.list.array[index].gotoArr["state"]=1;
			if(Tools.getDictLength(this.list.array[index].gotoArr)==0){
				return;
			}
			GotoManager.boundFor(this.list.array[index].gotoArr);
			ViewManager.instance.closePanel();
		}


		override public function onRemoved():void{
			this.list.scrollBar.value=0;
			this.list.array=[];
		}
		
	}

}



import ui.bag.item_source_pveUI;
import ui.bag.item_sourceUI;
import laya.events.Event;
import sg.manager.ModelManager;
import sg.cfg.ConfigServer;
import sg.manager.ViewManager;
import sg.net.NetSocket;
import laya.utils.Handler;
import sg.net.NetPackage;
import sg.utils.Tools;


class Item_Source extends item_sourceUI{
	public function Item_Source(){
		this.btn.on(Event.CLICK,this,function():void{

		});
		this.btn.label = Tools.getMsgById("_jia0032");
	}

	public function setData(obj:Object):void{
		this.img.skin=obj.icon;
		this.titleLabel.text=Tools.getMsgById(obj.title);
		if(obj.title=="add_visit"){
			this.info.text=Tools.getMsgById("visit_info");
			this.info.centerY=3;
		}else{
			this.info.text="";
		}
		
		this.btn.visible=obj.show==1;
	}
}


class Item_Pve extends item_source_pveUI{
	

	public var times:Number=0;
	public var battlId:String;
	public function Item_Pve(){
		//this.btn.on(Event.CLICK,this,this.click);
	}

	public function setData(obj:Object):void{
		//trace("====================",obj);
		battlId=obj.id;
		//this.img.skin="";
		var chpterId:String=ConfigServer.pve.battle[battlId].chapter_belong;
		var n:Number=Number(chpterId.substr(7,3));
		var m:Number=Number(battlId.substr(6,3));
		this.titleLabel.text=Tools.getMsgById("_bag_text15",[n+""," "+Tools.getMsgById(battlId)]);// "沙盘演义 第"+n+"章 关卡"+m;
		this.infoLabel.text=Tools.getMsgById("_bag_text03",[obj.num]);// "可获得："+obj.num;
		this.btn.gray=obj.gray;
		this.gray=false;
		times=ModelManager.instance.modelUser.pveTimes()[0];
		this.btn.label=Tools.getMsgById("_bag_text16",[times+""]);//"扫荡("+times+")";
	}

	public function click():void{

	}
}