package sg.view.inside
{
	import ui.inside.equipWashUI;
	import ui.inside.itemWashUI;
	import laya.utils.Handler;
	import laya.maths.MathUtil;
	import sg.manager.ModelManager;
	import sg.cfg.ConfigServer;
	import sg.model.ModelEquip;
	import laya.events.Event;
	import sg.utils.Tools;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.manager.EffectManager;
	import sg.manager.AssetsManager;
	import sg.model.ModelItem;
	import sg.utils.SaveLocal;
	import sg.cfg.ConfigColor;
	import sg.model.ModelUser;
	import sg.manager.LoadeManager;
	import sg.model.ModelScience;
	import sg.boundFor.GotoManager;

	/**
	 * ...
	 * @author
	 */
	public class ViewEquipWash extends equipWashUI{

		public var equip_type_arr:Array=[];
		//private var mTabNames:Array = [];
		private var mType:int = -1;
		private var allEquipData:Array=[];
		private var config_equip:Object={};
		private var user_equip:Object={};

		private var curEid:String="";
		private var config_wash_cost:Array=[];
		private var config_gold_finger_id:String="";
		private var config_equip_Reset_box:Object={};
		private var unlock_num:Number = 0;
		private var equipMaxLv:int;
		private var local_data:Object={};//本地存储的锁
		private var unlock_arr:Array=[];

		private var cost_arr:Array=[];		

		private var isSave:Boolean=false;
		private var isGiveUp:Boolean=false;
		//private var cur_wash_num:Number=0;
		private var mModel:ModelEquip;
		private var mEid:String;
		public function ViewEquipWash(){
			this.comTitle.setViewTitle(Tools.getMsgById("_equip31"));
			this.tab.selectHandler = new Handler(this,this.tab_select);
            this.list.itemRender = ItemEquip;
            this.list.scrollBar.visible = false;
			
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.selectEnable = true;
            this.list.selectHandler = new Handler(this,this.list_select);

			this.btnGiveUp.on(Event.CLICK,this,this.giveUpClick);
			this.btnWash.on(Event.CLICK,this,this.washCLick);
			this.btnSave.on(Event.CLICK,this,this.saveClick);
			this.btnTest.on(Event.CLICK,this,this.testClick);

			this.list1.scrollBar.visible=this.list2.scrollBar.visible = false;
			this.list1.selectEnable=this.list2.selectEnable = true;
			this.list1.scrollBar.touchScrollEnable = this.list2.scrollBar.touchScrollEnable = false;
			this.list1.itemRender=Item;
			this.list2.itemRender=Item;
			this.list1.renderHandler=new Handler(this,this.list1_render);
			this.list2.renderHandler=new Handler(this,this.list2_render);

			ModelManager.instance.modelUser.on(ModelUser.EVENT_EQUIP_WASH,this,eventCallBack);
			this.comNum.on(Event.CLICK,this,function():void{
				ViewManager.instance.showItemTips(cost_arr[0]);
			});
		}

		public function eventCallBack():void{
			setWash();
		}

		public function testClick():void{
			ViewManager.instance.showTipsTxt(Tools.getMsgById("msg_ViewEquipWash_0"));
			SaveLocal.deleteObj(SaveLocal.KEY_WASH_EQUIP+ModelManager.instance.modelUser.mUID,true);
			local_data={};
		}
		override public function initData():void{
			LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsUI("bg_19.png"));
		}
		override public function onAdded():void{
			this.label2.text=Tools.getMsgById("_city_build_text04",[""]);
			this.btnWash.setData("",Tools.getMsgById("_public177"),-1,1);
			this.btnGiveUp.label=Tools.getMsgById("_ftask_text05");
			this.btnSave.label=Tools.getMsgById("_public183");


			this.btnTest.visible=false;
			if(Tools.getDictLength(ModelManager.instance.modelUser.equip)==0){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_equip13"));//没有宝物可以洗炼
				ViewManager.instance.closePanel();
				return;
			}
			user_equip=ModelManager.instance.modelUser.equip;
			config_equip=ConfigServer.equip;
			setTab();
			config_gold_finger_id=ConfigServer.system_simple.equip_gold_finger;
			config_wash_cost=ConfigServer.system_simple.equip_wash_cost;
			config_equip_Reset_box=ConfigServer.system_simple.equip_Reset_box;
			this.get_local();

			mEid=this.currArg?this.currArg:"";
            this.mType = mEid==""?-1:ModelManager.instance.modelGame.getModelEquip(mEid).type;
			//this.mType = this.currArg?this.currArg:-1;
			
			allEquipData=[];
			for(var s:String in user_equip){
				var emd:ModelEquip=ModelManager.instance.modelGame.getModelEquip(s);
				allEquipData.push(emd);
			}
            if(this.mType>=0){
				this.mType = (this.mType==2)?3:(this.mType==3?2:this.mType);
                this.tab.selectedIndex = this.mType>=equip_type_arr.length ? equip_type_arr.length-1 : this.mType;
            }
            else{
                this.tab.selectedIndex = this.tab.selectedIndex<0?0:this.tab.selectedIndex;
            }

			//this.setEquipList(0);
		}


		public function setTab():void{
			equip_type_arr=[];			
			for(var s:String in user_equip){
				var n:Number=config_equip[s].type;
				n=(n==2)?3:(n==3)?2:n;
				if(equip_type_arr.indexOf(n)==-1){
					equip_type_arr.push(n);
				}
			}
			equip_type_arr.sort();
			var ss:String="";
			for(var i:int=0;i<equip_type_arr.length;i++){
				ss+=ModelEquip.equip_type_name_tab[equip_type_arr[i]];
				ss+=i==equip_type_arr.length-1?"":",";
			}
			this.tab.labels = ss;
		}


		public function setWash():void{
			isSave=isGiveUp=false;
			this.btnGiveUp.visible=this.btnSave.visible=this.btnWash.visible=false;
			this.list1.visible=this.list2.visible=true;
			this.imgEquip.visible=this.labelEquip.visible=true;
			if(curEid==""){
				this.list1.visible=this.list2.visible=false;
				this.imgEquip.visible=this.labelEquip.visible=false;
				return;
			}
			user_equip=ModelManager.instance.modelUser.equip;
			var d:Object=user_equip[curEid];
			if(d.wash_temp.length!=0){
				this.btnGiveUp.visible=this.btnSave.visible=true;
			}else{
				this.btnWash.visible=true;
			}
			mModel=ModelManager.instance.modelGame.getModelEquip(curEid);
			this.imgEquip.skin=AssetsManager.getAssetsICON(ModelEquip.getIcon(mModel.id));
			this.labelEquip.text=mModel.getName();
			this.labelEquip.color=ConfigColor.FONT_COLORS[mModel.getLv()];
			this.getUnlockArr();
			//cur_wash_num=0;
			this.equipMaxLv = mModel.getMaxLv();
			var arr1:Array=getArr(d.lv,d.wash);
			var arr2:Array=getArr(d.lv,d.wash_temp);
			this.list1.array=arr1;
			this.list2.array=arr2;
			setBtn();
		}

		public function getUnlockArr():void{
			unlock_arr=[];
			if(local_data.hasOwnProperty(curEid)){
				unlock_arr=local_data[curEid];
				for(var i:int=0;i<unlock_arr.length;i++){
					if(ModelManager.instance.modelUser.equip[curEid].wash[unlock_arr[i]]==null){
						// trace("洗炼属性是null，把锁置为开");
						var n:Number=unlock_arr.indexOf(i);
						unlock_arr.splice(n,1);
					}
				}
			}
			unlock_num=unlock_arr.length;
		}

		public function unlockClick(index:int):void{
			if((this.list1.getCell(index) as Item).gray){
				return;
			}
			if(user_equip[curEid].wash_temp.length!=0){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_equip14"));//请先保存或者放弃后操作
				return;
			}
			//if(unlock_num+1>=cur_wash_num && list1.array[index].unlock==0){
			if(unlock_num+1>user_equip[curEid].lv && list1.array[index].unlock==0){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_equip15"));//至少保留一个洗炼属性 无法锁定
				return;
			}
			if(this.list1.array[index].id==""){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_equip16"));//未洗炼，无法锁定
				return;
			}
			var b:Boolean=false;//t 锁  f 开
			//trace("-----------------",local_data);
			if(local_data.hasOwnProperty(curEid)){
				var a:Array=local_data[curEid];
				if(a.indexOf(index)!=-1){// && a.indexOf(index)==index
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
				local_data[curEid]=[index];
			}
			getUnlockArr();
			this.list1.array[index].unlock=b?1:0;
			//this.list1.array=this.list1.array;
			this.list1.refresh();
			setBtn();
		}

		public function setBtn():void{
			var a:Array=config_wash_cost[mModel.type];
			var itm:ModelItem=ModelManager.instance.modelProp.getItemProp(a[0]);
			var nn:Number=ModelScience.func_sum_type("equip_wa_consume");//科技百分比
			cost_arr=[itm.id,Math.round(a[1][unlock_num]*(1-nn))];
			var n:Number=itm.num>0?0:1;
			//this.btnWash.setData(AssetsManager.getAssetItemOrPayByID(itm.id),itm.num+"/"+cost_arr[1],n);
			this.comNum.setData(AssetsManager.getAssetItemOrPayByID(itm.id),itm.num+"/"+cost_arr[1],n);
		}

		public function getArr(lv:int,a:Array):Array{
			var arr:Array=[];
			for(var i:int=0;i<5;i++){
				var o:Object={};
				//var _status:Number=0;//0 待洗炼   1 未解锁   2 有内容的
				o["id"]="";
				o["gold_finger"]=0;
				o["unlock"]=-1;
				if(i<=lv){
					if(a[i]!=null){
						//cur_wash_num+=1;
						if(config_equip_Reset_box.hasOwnProperty(a[i])){
							o["gold_finger"]=1;
						}
						o["id"]=a[i];
						if(unlock_arr.indexOf(i)!=-1){
							o["unlock"]=1;
						}else{
							o["unlock"]=0;
						}
					}else{
						o["text"]=Tools.getMsgById("_equip17");//待洗炼
					}
				}else{
					o["text"]=Tools.getMsgById("_equip18",[Tools.getColorInfo(i)]);//"宝物突破至"+ConfigColor.FONT_COLOR_STR[i]+"可解锁";//宝物突破至{}可解锁
					o["lock"] = 1;
				}
				arr.push(o);
			}
			return arr;
		}

		public function list1_render(cell:Item,index:int):void{
			var o:Object = this.list1.array[index];
			this.checkItemShow(cell, index);
			
			cell.setData(o);
			//trace("====================",o);
			cell.btnUnlock.off(Event.CLICK,this,this.unlockClick);
			cell.btnUnlock.on(Event.CLICK,this,this.unlockClick,[index]);
			cell.btnRe.off(Event.CLICK,this,this.fingerClick);
			cell.btnRe.on(Event.CLICK,this,this.fingerClick,[index]);
		}
		public function list2_render(cell:Item,index:int):void{
			var o:Object = this.list2.array[index];
			this.checkItemShow(cell, index);
			
			cell.setData(o);
			cell.btnRe.visible=false;
			cell.btnUnlock.visible=false;
		}
		
		public function checkItemShow(cell:Item, index:int):void{
			if (index > this.equipMaxLv){
				cell.gray = true;
				cell.alpha = 0.8;
			}
			else{
				cell.gray = false;
				cell.alpha = 1;
			}
		}


		public function fingerClick(index:int):void{
			ViewManager.instance.showView(ConfigClass.VIEW_EQUIP_WASH_GF,[curEid,index]);
		}

		public function giveUpClick():void{
			var wash_temp:Array=user_equip[curEid].wash_temp;
			var b:Boolean=false;
			var s:String="";
			for(var i:int=0;i<wash_temp.length;i++){
				if(config_equip_Reset_box.hasOwnProperty(wash_temp[i])){
					if(this.list1.array[i].unlock==0){
						b=true;
						s=wash_temp[i];
						break;
					}
				}
			}
			if(!isGiveUp && b){
				s=Tools.getMsgById("_equip19",[ModelEquip.getWashInfo(s)]);//"是否放弃"+ModelEquip.getWashInfo(s)+"?";//是否放弃
				ViewManager.instance.showAlert(s,function(index:int):void{
					if(index==0){
						giveUpFunc();
					}else if(index==1){

					}
					isGiveUp=true;
				});
				return;
			}
			giveUpFunc();
		}

		public function giveUpFunc():void{
			var sendData:Object={};
			sendData["equip_id"]=curEid;			
			NetSocket.instance.send("equip_wash_drop",sendData,new Handler(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				setWash();
			}));
		}

		public function saveClick():void{
			var b:Boolean=false;
			var wash:Array=user_equip[curEid].wash;
			var wash_temp:Array=user_equip[curEid].wash_temp;
			var s:String="";
			for(var i:int=0;i<wash.length;i++){
				if(config_equip_Reset_box.hasOwnProperty(wash[i])){
					if(wash[i]!=wash_temp[i]){
						s=wash[i];
						b=true;
						break;
					}
				}
			}
			
			if(!isSave && b){
				s=Tools.getMsgById("_equip20",[ModelEquip.getWashInfo(s)]);//"是否覆盖掉"+ModelEquip.getWashInfo(s)+"?";//是否覆盖掉
				ViewManager.instance.showAlert(s,function(index:int):void{
					if(index==0){
						saveFunc();
					}else if(index==1){

					}
					isSave=true;
				});
				return;
			}
			saveFunc();
		}

		public function saveFunc():void{
			var sendData:Object={};
			sendData["equip_id"]=curEid;			
			NetSocket.instance.send("equip_wash_save",sendData,new Handler(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				setWash();
			}));
		}

		public function washCLick():void{
			if(!Tools.isCanBuy(cost_arr[0],cost_arr[1])){
				return;
			}
			var sendData:Object={};
			sendData["equip_id"]=curEid;
			sendData["block_list"]=unlock_arr;
			NetSocket.instance.send("equip_wash",sendData,new Handler(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				setWash();
			}));
		}


        private function tab_select(index:int):void{
            if(index>-1){
				var n:int=equip_type_arr[index];
                this.setEquipList(n);
            }
        }

		private function setEquipList(type:int):void{
			type=(type==2)?3:(type==3)?2:type;
			var arr:Array=[];
			for(var i:int=0;i<allEquipData.length;i++){
				var emd:ModelEquip=allEquipData[i];
				if(emd.type==type){
					arr.push(emd);
				}
			}
			arr.sort(MathUtil.sortByKey("index",true,false));
            //this.tList.text = "";//num+"/"+arr.length;
            //
			var select:Number=0;
			if(mEid!=""){
				for(var j:int=0;j<arr.length;j++){
					if(arr[j].id==mEid){
						select=j;
						break;
					}
				}
			}
			this.list.scrollBar.value=0;
            this.list.array = arr;
			this.list.selectedIndex = -1;
            click_item(select);
			if(mEid!=""){
				if(select>5){
					this.list.scrollTo(select);
				}
			}
			mEid="";
			label0.text=ModelEquip.equip_type_name_tab[tab.selectedIndex];

			var obj:Object = type<5?ConfigServer.system_simple.equip_make_list[type]:ConfigServer.equip_make_special;
            //
            var eArr:Array = obj[1];
			label1.text=this.list.array.length+"";//+"/"+eArr.length;
        }

		private function list_render(item:ItemEquip,index:int):void{
            var emd:ModelEquip = this.list.array[index];
            item.setData(emd,this.tab.selectedIndex);
            item.showSelect((this.list.selectedIndex == index));
            item.off(Event.CLICK,this,this.click_item);
            item.on(Event.CLICK,this,this.click_item,[index]);
        }

		private function click_item(index:int):void{
            if(index!=this.list.selectedIndex){
                //if(this.list.selection){
                //   var item2:ItemEquip = this.list.selection as ItemEquip;
                //    item2.showSelect(true);
                //}
				this.list.selectedIndex = index;
				curEid=(this.list.array.length==0)?"":this.list.array[index].id;
				setWash();
			}else{
				ViewManager.instance.showView(ConfigClass.VIEW_EQUIP_MAKE_INFO,ModelManager.instance.modelGame.getModelEquip(this.list.array[index].id));
			}
            
        }

		 private function list_select(index:int):void{
            //Trace.log("list_select",index,this.tab.selectedIndex,this.list.selection);
            if(index>=0){
                if(this.list.selection){
                    var emd:ModelEquip = this.list.array[index];
                    var item:ItemEquip = this.list.selection as ItemEquip;
                    item.showSelect(true);
                }
            }
        }

		public function set_local():void{
			if(Tools.getDictLength(local_data)!=0){
				SaveLocal.save(SaveLocal.KEY_WASH_EQUIP+ModelManager.instance.modelUser.mUID,local_data,true);
			}
		}

		public function get_local():void{
			var o:Object=SaveLocal.getValue(SaveLocal.KEY_WASH_EQUIP+ModelManager.instance.modelUser.mUID,true);
			if(Tools.isNullString(o)){
				local_data={};
			}else{
				local_data=o;
			}
		}


		override public function onRemoved():void{
			set_local();
			this.mType = this.currArg = -1;
            this.tab.selectedIndex = -1;
            this.list.selectedIndex = -1;

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

class Item extends itemWashUI{

	public function Item(){
		
	}

	public function setData(obj:Object):void{
		this.btnUnlock.visible=true;
		this.btnUnlock.mouseEnabled=true;
		//this.btnUnlock.label="开";
		this.nameLabel.color = '#C0EEF0';
		if(obj.id!=""){
			var o:Object=ModelEquip.getWashData(obj.id);
			if(o){
				this.nameLabel.text=ModelEquip.getWashInfo(obj.id) ;
				this.nameLabel.color=o.color;
				this.btnUnlock.visible=true;
				this.setUnlock(obj.unlock==1);
			}
			else{
				//不存在的洗炼属性
				this.nameLabel.text = Tools.getMsgById('_science7') + obj.id;
				this.nameLabel.color='#DD0000';
			}
		}else{
			this.nameLabel.text = obj.text;
			if(obj.lock)
				this.nameLabel.color = '#999999';
		}
		if(obj.unlock==-1){
			//this.btnUnlock.mouseEnabled=false;
			this.setUnlock(false);
		}
		this.btnRe.visible=obj.gold_finger==1;
		if(this.btnRe.visible){
			ModelGame.unlock(this.btnRe,"gold_finger");
		}
		
	}

	public function setUnlock(b:Boolean):void{
		//this.btnUnlock.label=b?"锁":"开";		
		//trace("=============",b);
		//this.btnUnlock.selected=!b;
		this.btnUnlock.skin= AssetsManager.getAssetsUI(b?"btn_suo.png":"btn_suo1.png");
	}

}