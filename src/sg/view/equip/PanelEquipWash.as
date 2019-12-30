package sg.view.equip
{
	import ui.equip.panelEquipWashUI;
	import laya.events.Event;
	import laya.utils.Handler;
	import sg.model.ModelEquip;
	import sg.manager.ModelManager;
	import sg.utils.Tools;
	import sg.manager.ViewManager;
	import sg.model.ModelUser;
	import sg.cfg.ConfigServer;
	import sg.utils.SaveLocal;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.model.ModelScience;
	import sg.model.ModelItem;
	import sg.manager.AssetsManager;
	import sg.cfg.ConfigClass;

	/**
	 * ...
	 * @author
	 */
	public class PanelEquipWash extends panelEquipWashUI{

		private var mEquipMaxLv:int;
		private var mEmd:ModelEquip;

		private var config_wash_cost:Array=[];
		private var config_gold_finger_id:String="";
		private var config_equip_Reset_box:Object={};
		private var mLocalData:Object={};//本地存储的锁
		private var mUnlockArr:Array=[];
		private var mCostArr:Array=[];

		private var unlock_num:Number = 0;

		public function PanelEquipWash(){
			this.tText.text = Tools.getMsgById("_equip41");

			this.btnGiveUp.on(Event.CLICK,this,this.click,[this.btnGiveUp]);
			this.btnWash.on(Event.CLICK,this,this.click,[this.btnWash]);
			this.btnSave.on(Event.CLICK,this,this.click,[this.btnSave]);

			this.list0.itemRender=this.list1.itemRender=Item;
			this.list0.renderHandler=new Handler(this,this.list0_render);
			this.list1.renderHandler=new Handler(this,this.list1_render);

			ModelManager.instance.modelUser.on(ModelUser.EVENT_EQUIP_WASH,this,eventCallBack);
			this.comNum.on(Event.CLICK,this,function():void{
				ViewManager.instance.showItemTips(mCostArr[0]);
			});
			
			config_gold_finger_id  = ConfigServer.system_simple.equip_gold_finger;
			config_wash_cost       = ConfigServer.system_simple.equip_wash_cost;
			config_equip_Reset_box = ConfigServer.system_simple.equip_Reset_box;

			this.btnWash.label   = Tools.getMsgById("_public177");
			this.btnGiveUp.label = Tools.getMsgById("_ftask_text05");
			this.btnSave.label   = Tools.getMsgById("_public183");
		}

		public function eventCallBack():void{
			updateUI(mEmd.id);
		}

		private function updateUI(id:String):void{
			mEmd = ModelManager.instance.modelGame.getModelEquip(id);
			this.mEquipMaxLv = mEmd.getMaxLv();
			
			this.get_local();
			getUnlockArr();
			this.btnGiveUp.visible = this.btnSave.visible = mEmd.wash_temp.length!=0;
			this.btnWash.visible   = mEmd.wash_temp.length==0;
			var arr0:Array = getArr(mEmd.getLv(),mEmd.wash);
			var arr1:Array = getArr(mEmd.getLv(),mEmd.wash_temp);
			this.list0.array = arr0;
			this.list1.array = arr1;
			setBtn();
		}

		private function click(obj:*):void{
			switch(obj){
				case this.btnGiveUp:
					giveUpClick();
					break;
				case this.btnWash:
					washClick();
					break;
				case this.btnSave:
					saveClick();
					break;
			}
		}

		public function giveUpClick():void{
			var wash_temp:Array = mEmd.wash_temp;
			var wash:Array = mEmd.wash;
			var b:Boolean=false;
			var s:String="";
			for(var i:int=0;i<wash_temp.length;i++){
				if(wash_temp[i] && ConfigServer.equip_wash[wash_temp[i]].rarity==4){
					if(wash_temp[i]!=wash[i]){
						b=true;
						s=wash_temp[i];
						break;
					}
				}
			}
			if(b){
				s=Tools.getMsgById("_equip19",[ModelEquip.getWashInfo(s)]);//"是否放弃"+ModelEquip.getWashInfo(s)+"?";//是否放弃
				ViewManager.instance.showAlert(s,function(index:int):void{
					if(index==0){
						giveUpFunc();
					}else if(index==1){

					}
				});
				return;
			}
			giveUpFunc();
		}

		public function giveUpFunc():void{
			var sendData:Object={};
			sendData["equip_id"] = mEmd.id;			
			NetSocket.instance.send("equip_wash_drop",sendData,new Handler(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				updateUI(mEmd.id);
			}));
		}

		private function washClick():void{
			if(!Tools.isCanBuy(mCostArr[0],mCostArr[1])){
				return;
			}
			var sendData:Object={};
			sendData["equip_id"] = mEmd.id;
			sendData["block_list"] = mUnlockArr;
			NetSocket.instance.send("equip_wash",sendData,new Handler(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				updateUI(mEmd.id);
			}));
		}

		public function saveClick():void{
			var b:Boolean=false;
			var wash:Array = mEmd.wash;
			var wash_temp:Array = mEmd.wash_temp;
			var s:String="";
			for(var i:int=0;i<wash.length;i++){
				if(wash[i] && ConfigServer.equip_wash[wash[i]].rarity==4){
					if(wash[i] != wash_temp[i]){
						s = wash[i];
						b = true;
						break;
					}
				}
			}
			
			if(b){
				s=Tools.getMsgById("_equip20",[ModelEquip.getWashInfo(s)]);//"是否覆盖掉"+ModelEquip.getWashInfo(s)+"?";//是否覆盖掉
				ViewManager.instance.showAlert(s,function(index:int):void{
					if(index==0){
						saveFunc();
					}else if(index==1){

					}
				});
				return;
			}
			saveFunc();
		}

		public function saveFunc():void{
			var sendData:Object={};
			sendData["equip_id"]=mEmd.id;			
			NetSocket.instance.send("equip_wash_save",sendData,new Handler(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				updateUI(mEmd.id);
			}));
		}

		public function list0_render(cell:Item,index:int):void{
			var o:Object = this.list0.array[index];
			this.checkItemShow(cell, index);
			
			cell.setData(o);
			//trace("====================",o);
			cell.btnUnlock.off(Event.CLICK,this,this.unlockClick);
			cell.btnUnlock.on(Event.CLICK,this,this.unlockClick,[index]);
			cell.btnRe.off(Event.CLICK,this,this.fingerClick);
			cell.btnRe.on(Event.CLICK,this,this.fingerClick,[index]);
		}
		public function fingerClick(index:int):void{
			ViewManager.instance.showView(ConfigClass.VIEW_EQUIP_WASH_GF,[mEmd.id,index]);
		}

		public function unlockClick(index:int):void{
			if((this.list0.getCell(index) as Item).gray){
				return;
			}
			if(mEmd.wash_temp.length!=0){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_equip14"));//请先保存或者放弃后操作
				return;
			}
			if(unlock_num+1>mEmd.getLv() && list0.array[index].unlock==0){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_equip15"));//至少保留一个洗炼属性 无法锁定
				return;
			}
			if(this.list0.array[index].id==""){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_equip16"));//未洗炼，无法锁定
				return;
			}
			var b:Boolean=false;//t 锁  f 开
			if(mLocalData.hasOwnProperty(mEmd.id)){
				var a:Array=mLocalData[mEmd.id];
				if(a.indexOf(index)!=-1){
					var n:Number=a.indexOf(index);
					a.splice(n,1);
					b=false;
				}else{
					a.push(index);
					b=true;
				}
				if(a.length>=2){
					a.sort();
				}
			}else{
				b=true;
				mLocalData[mEmd.id]=[index];
			}
			getUnlockArr();
			this.list0.array[index].unlock=b ? 1 : 0;
			this.list0.refresh();
			setBtn();
			set_local();
		}

		public function getUnlockArr():void{
			mUnlockArr=[];
			if(mLocalData.hasOwnProperty(mEmd.id)){
				mUnlockArr=mLocalData[mEmd.id];
				for(var i:int=0;i<mUnlockArr.length;i++){
					if(ModelManager.instance.modelUser.equip[mEmd.id].wash[mUnlockArr[i]]==null){
						// trace("洗炼属性是null，把锁置为开");
						var n:Number=mUnlockArr.indexOf(i);
						mUnlockArr.splice(n,1);
					}
				}
			}
			unlock_num=mUnlockArr.length;
		}


		public function setBtn():void{
			var a:Array = config_wash_cost[mEmd.type];
			var itm:ModelItem = ModelManager.instance.modelProp.getItemProp(a[0]);
			var nn:Number = ModelScience.func_sum_type("equip_wa_consume");//科技百分比
			mCostArr = [itm.id,Math.round(a[1][unlock_num]*(1-nn))];
			var n:Number = itm.num >= mCostArr[1] ? 0 : 1;
			this.comNum.setData(AssetsManager.getAssetItemOrPayByID(itm.id),itm.num+"/"+mCostArr[1],n);
		}

		public function list1_render(cell:Item,index:int):void{
			var o:Object = this.list1.array[index];
			this.checkItemShow(cell, index);
			
			cell.setData(o);
			cell.btnRe.visible=false;
			cell.btnUnlock.visible=false;
		}

		public function getArr(lv:int,a:Array):Array{
			var arr:Array=[];
			for(var i:int=0;i<5;i++){
				var o:Object={};
				o["id"]          = "";
				o["gold_finger"] = 0;
				o["unlock"]      = -1;
				o["type"]        = 0;//0 空  1 有  2 等级不够
				if(i<=lv){
					if(a[i]!=null){
						o["gold_finger"] = (config_equip_Reset_box.hasOwnProperty(a[i])) ? 1 : 0;
						o["id"]     = a[i];
						o["unlock"] = (mUnlockArr.indexOf(i)!=-1) ? 1 : 0;
						o["type"]   = 1;
					}else{
						o["text"] = Tools.getMsgById("_equip17");//待洗炼
					}
				}else{
					//"宝物突破至"+ConfigColor.FONT_COLOR_STR[i]+"可解锁";//宝物突破至{}可解锁
					o["text"] = Tools.getMsgById("_equip18",[Tools.getColorInfo(i)]);
					o["lock"] = 1;
					o["type"] = 2;
				}
				arr.push(o);
			}
			return arr;
		}
		

		public function checkItemShow(cell:Item, index:int):void{
			if (index > this.mEquipMaxLv){
				cell.gray = true;
				cell.alpha = 0.8;
			}
			else{
				cell.gray = false;
				cell.alpha = 1;
			}
		}

		public function set_local():void{
			if(Tools.getDictLength(mLocalData)!=0){
				SaveLocal.save(SaveLocal.KEY_WASH_EQUIP+ModelManager.instance.modelUser.mUID,mLocalData,true);
			}
		}

		public function get_local():void{
			var o:Object=SaveLocal.getValue(SaveLocal.KEY_WASH_EQUIP+ModelManager.instance.modelUser.mUID,true);
			if(Tools.isNullString(o)){
				mLocalData={};
			}else{
				mLocalData=o;
			}
		}

		public function removeCostumeEvent():void{
			ModelManager.instance.modelUser.off(ModelUser.EVENT_EQUIP_WASH,this,eventCallBack);
		}


	}

}

import sg.utils.Tools;
import ui.inside.itemWashUI;
import sg.cfg.ConfigColor;
import sg.model.ModelEquip;
import sg.manager.AssetsManager;
import sg.manager.ModelManager;
import sg.model.ModelGame;
import ui.equip.itemWash1UI;

class Item extends itemWash1UI{

	public function Item(){
		
	}

	public function setData(obj:Object):void{
		this.btnUnlock.visible = this.btnUnlock.mouseEnabled = true;
		this.btnUnlock.gray = false;
		this.tName.color = '#C0EEF0';
		if(obj.id!=""){
			var o:Object=ModelEquip.getWashData(obj.id);
			if(o){
				this.tName.text=ModelEquip.getWashInfo(obj.id) ;
				this.tName.color=o.color;
				this.btnUnlock.visible=true;
				this.setUnlock(obj.unlock==1);
			}
			else{
				//不存在的洗炼属性
				this.tName.text = Tools.getMsgById('_science7') + obj.id;
				this.tName.color='#DD0000';
			}
		}else{
			this.tName.text = obj.text;
			if(obj.lock)
				this.tName.color = '#999999';
		}
		if(obj.unlock==-1){
			this.setUnlock(false);
		}
		this.btnRe.visible=obj.gold_finger==1;
		if(this.btnRe.visible){
			ModelGame.unlock(this.btnRe,"gold_finger");
		}

		if(obj.type==2){//等级不足时 这条洗练的锁置灰
			this.btnUnlock.gray = true;
		}
		
	}

	public function setUnlock(b:Boolean):void{
		this.btnUnlock.skin= AssetsManager.getAssetsUI(b?"btn_suo.png":"btn_suo1.png");
	}

}