package sg.view.inside
{
	import ui.inside.equipWashGFUI;
	import laya.events.Event;
	import sg.net.NetSocket;
	import sg.manager.ModelManager;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.model.ModelEquip;
	import sg.cfg.ConfigColor;
	import sg.cfg.ConfigServer;
	import sg.manager.AssetsManager;
	import sg.model.ModelUser;
	import sg.utils.Tools;
	import sg.manager.ViewManager;
	import sg.model.ModelItem;

	/**
	 * ...
	 * @author
	 */
	public class ViewEquipWashGF extends equipWashGFUI{

		private var mData:Array=[];

		private var cost_arr:Array=[];
		private var isSave:Boolean=false;
		private var washId:String;
		private var new_washID:String="";
		public function ViewEquipWashGF(){
			this.comTitle.setViewTitle(Tools.getMsgById("_equip32"));
			text3.text=Tools.getMsgById("_public195");
			this.text6.text=Tools.getMsgById("_public222");
			this.btnGiveUp.on(Event.CLICK,this,this.giveUpClick);
			this.btnWash.on(Event.CLICK,this,this.washCLick);
			this.btnSave.on(Event.CLICK,this,this.saveClick);
		}

		override public function onAdded():void{
			this.text4.text=Tools.getMsgById("_equip34");
			this.text5.text=Tools.getMsgById("_equip35");
			mData=this.currArg;//[curEid,index]
			setData();
		}


		public function setData():void{
			new_washID="";
			isSave=false;
			var wash_reset:Object=ModelManager.instance.modelUser.equip[mData[0]].wash_reset;
			washId=ModelManager.instance.modelUser.equip[mData[0]].wash[mData[1]];
			var finger_id:String=ConfigServer.system_simple.equip_gold_finger;
			cost_arr=[finger_id,1];
			var o:Object=ModelEquip.getWashData(washId);
			this.text1.color = this.text2.color = ConfigColor.FONT_COLORS[0];
			this.text1.text=ModelEquip.getWashInfo(washId);
			//this.text1.text="原属性："+washId;
			this.text1.color=o.color;
			this.btnGiveUp.visible=this.btnSave.visible=this.btnWash.visible=false;	
			if(wash_reset.hasOwnProperty(mData[1]+"")){
				var o2:Object=ModelEquip.getWashData(wash_reset[mData[1]+""]);
				//this.text2.text = "新属性：" + o2.id;
				this.text2.text = ModelEquip.getWashInfo(o2.id);
				this.text2.color=o2.color;
				this.btnGiveUp.visible=this.btnSave.visible=true;
				new_washID=o2.id;
			}else{
				this.text2.text="";
				this.btnWash.visible=true;
			}
			var n:Number=ModelManager.instance.modelProp.isHaveItemProp(finger_id,1)?-1:1;
			this.btnWash.setData(AssetsManager.getAssetItemOrPayByID(finger_id),1+"",n);
			this.numLabel.text=ModelItem.getMyItemNum(finger_id)+"";
			this.numLabel.x=this.imgNum.x=this.text6.width;
			this.numLabel.width=this.imgNum.width;
			this.numBox.centerX=0;
		}

		public function giveUpClick():void{
			var sendData:Object={};
			sendData["equip_id"]=mData[0];
			sendData["reset_index"]=mData[1];			
			NetSocket.instance.send("equip_wash_reset_drop",sendData,new Handler(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				setData();
			}));
		}

		public function saveClick():void{
			//var wash_reset:Object=ModelManager.instance.modelUser.equip[mData[0]].wash_reset;
			var wash_old:Array=ModelManager.instance.modelUser.equip[mData[0]].wash;
			var s:String=Tools.getMsgById("_equip20",[" "+ModelEquip.getWashInfo(wash_old[mData[1]])]);//"是否覆盖掉"+ModelEquip.getWashInfo(wash_old[mData[1]])+"?";//是否覆盖掉	
			ViewManager.instance.showAlert(s,function(index:int):void{
				if(index==0){
					saveFunc();
				}else if(index==1){
					
				}
			});
		}

		public function saveFunc():void{
			var wash_old:Array=ModelManager.instance.modelUser.equip[mData[0]].wash;
			var ss:String="";
			for(var i:int=0;i<wash_old.length;i++){
				if(wash_old[i] && ConfigServer.equip_wash[wash_old[i]].type==ConfigServer.equip_wash[new_washID].type){
					ss=Tools.getMsgById("_equip23",[" "+ModelEquip.getWashInfo(wash_old[i])]);
					break;
				}
			}
			if(ss==""){
				saveFunc2();
			}else{
				ViewManager.instance.showAlert(ss,function(index:int):void{
					if(index==0){
						saveFunc2();
					}else if(index==1){
						
					}
				});
			}
			

		}

		public function saveFunc2():void{
			var sendData:Object={};
			sendData["equip_id"]=mData[0];	
			sendData["reset_index"]=mData[1];
			NetSocket.instance.send("equip_wash_reset_save",sendData,new Handler(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				ModelManager.instance.modelUser.event(ModelUser.EVENT_EQUIP_WASH);
				setData();
			}));
		}



		public function washCLick():void{
			if(!Tools.isCanBuy(cost_arr[0],cost_arr[1])){
				return;
			}
			var sendData:Object={};
			sendData["equip_id"]=mData[0];
			sendData["reset_index"]=mData[1];
			NetSocket.instance.send("equip_wash_reset",sendData,new Handler(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				setData();
			}));
		}

		override public function onRemoved():void{
			
		}
	}

}