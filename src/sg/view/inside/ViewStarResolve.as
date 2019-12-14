package sg.view.inside
{
	import ui.inside.starResolveUI;
	import ui.bag.bagItemUI;
	import laya.utils.Handler;
	import sg.manager.ModelManager;
	import laya.events.Event;
	import sg.cfg.ConfigServer;
	import sg.model.ModelItem;
	import laya.maths.MathUtil;
	import sg.utils.Tools;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.model.ModelUser;
	import sg.manager.AssetsManager;

	/**
	 * ...
	 * @author
	 */
	public class ViewStarResolve extends starResolveUI{
		
		public var listData:Array=[];
		public var getListData:Array=[];
		public var curIndex:int=-1;
		public var curObj:Object={};
		public var configData:Object=ConfigServer.system_simple.star_exp;
		
		public function ViewStarResolve(){
			this.list1.scrollBar.visible=false;
			this.list2.scrollBar.visible=false;
			this.list2.scrollBar.touchScrollEnable=false;
			this.list1.itemRender=Item;
			//this.list2.itemRender=bagItemUI;
			this.list1.renderHandler=new Handler(this,listRender);
			this.list2.renderHandler=new Handler(this,listRender2);

			ttab.labels= Tools.getMsgById("540163")+","+Tools.getMsgById("_public64");//"星辰,神纹";
			this.ttab.on(Event.CHANGE,this,this.tabChange);
			this.btnResolve.on(Event.CLICK,this,this.resolveClick);
			this.list1.selectHandler=new Handler(this,listSelect);
			this.btnQuick.on(Event.CLICK,this,quickClick);

			

			
		}

		private function eventCallBack(re:Object):void{
			if(re.user){
				if(re.user.hasOwnProperty("star"))
					tabChange();
			}
		}


		override public function onAdded():void{
			ModelManager.instance.modelUser.on(ModelUser.EVENT_USER_UPDATE,this,eventCallBack);
			this.comTitle.setViewTitle(Tools.getMsgById("_public180"));
			this.text1.text=Tools.getMsgById("_star_text12");
			this.text2.text=Tools.getMsgById("_hero14");
			this.btnResolve.label=Tools.getMsgById("_star_text09");
			this.btnQuick.label=Tools.getMsgById("_star_text10");
			this.btnAsk.visible=false;
			curIndex=-1;
			this.ttab.selectedIndex=0;
			setData();
			if(listData.length==0){
				this.ttab.selectedIndex=1;
			}
		}

		public function quickClick():void{
			ViewManager.instance.showView(ConfigClass.VIEW_STAR_RESOLVE_QUICK,ttab.selectedIndex);
		}

		public function tabChange():void{
			this.setSelection(false);
			curIndex=this.list1.selectedIndex=-1;
			setData();
			if(ttab.selectedIndex==0){
				this.btnResolve.x=400;
				this.btnQuick.visible=true;
				this.btnQuick.x=20;
			}else{
				this.btnQuick.visible=false;
				this.btnResolve.x=210;
			}
		}

		public function setData():void{
			listData=ModelManager.instance.modelUser.getStarList()[ttab.selectedIndex];
			list1.array=listData;
			list1.scrollBar.value=0;
			if(listData.length==0){
				this.btnResolve.gray=true;
				this.iconImg.visible=false;
				this.nameLabel.visible=false;
				this.boxNum.visible=false;
				this.bg0.visible=this.bg1.visible=false;
				curIndex=-1;
				getListData=[];
				var n:Number=ttab.selectedIndex==0?1:0;
				var a:Array=ConfigServer.system_simple["star_default"][n];
				for(var index:int = 0; index < a.length; index++)
				{
					//var o:Object={};
					//o["id"]=a[index];
					//o["addNum"]=1;
					var o:ModelItem=ModelManager.instance.modelProp.getItemProp(a[index]);
					o.addNum=0;
					getListData.push(o);
				}
				
				this.list2.array=getListData;
				this.list2.repeatX=this.list2.array.length;
				this.list2.centerX=0;
			}else{
				this.iconImg.visible=this.nameLabel.visible=this.boxNum.visible=true;
				this.bg0.visible=this.bg1.visible=true;
				this.btnResolve.gray=false;
				itemClick(0);
			}
			var s:String=ttab.selectedIndex==1 ? Tools.getMsgById("_public64") : Tools.getMsgById("540163");
			this.text0.text= Tools.getMsgById("_building46",[s,s,s]);//"选择放入的"+s+"，分解获得相应的1级"+s+"和"+s+"精粹";
		}

		public function listRender(cell:Item,index:int):void{
			cell.setData(listData[index]);
			cell.setListSelect(this.list1.selectedIndex==index);
			cell.off(Event.CLICK,this,this.itemClick);
			cell.on(Event.CLICK,this,this.itemClick,[index]);
		}
		public function listSelect(index:int):void{
			 if(index>=0){
                this.setSelection(true);
            }
		}

		public function setSelection(b:Boolean):void{//弃用
			return;
			if(this.list1.selection){
                var item:Item = this.list1.selection as Item;
                item.setListSelect(b);
            }
		}

		public function itemClick(index:int):void{
			if(curIndex==index){
				return;
			}
			curIndex=index;
			//this.setSelection(false);
			this.setCenterCom(index);
			this.list1.selectedIndex=index;

			getListData=[];
			curObj={};
			curObj=listData[index];
			var arr:Array=configData[curObj.exp_type];
			if(curObj.lv==1 && curObj.exp==0){
				var itemProp:ModelItem=ModelManager.instance.modelProp.getItemProp(arr[2]);
				itemProp.addNum=1;
				getListData.push(itemProp);
			}else{
				var arr0:Array=arr[0];
				var exp:Number=0;
				for(var i:int = 0; i < curObj.lv-1; i++)
				{
					exp+=arr0[i];
				}
				exp+=curObj.exp;

				var expList:Array=[];
				
				for (var value:String in arr[1])
				{
					var o:Object={};
					o["id"]=value;
					o["num"]=arr[1][value];
					expList.push(o);
				}
				expList.sort(MathUtil.sortByKey("num",true,true));
				for(var j:int = 0; j < expList.length; j++)
				{
					var v:Object=expList[j];
					var n:Number=0;
					while(exp>=v.num)
					{
						exp-=v.num;
						n+=1;
					}
					var it:ModelItem=ModelManager.instance.modelProp.getItemProp(v.id);
					it.addNum=n;
					if(n!=0){
						getListData.push(it);
					}
					n=0;
				}
				getListData.unshift({'id':this.curObj.id,'num':1});
			}
			
			this.list2.array=getListData;
			this.list2.repeatX=this.list2.array.length;
			this.list2.centerX=0;
		}

		public function setCenterCom(index:int):void{
			if(index==-1){
				return;
			}
			this.iconImg.skin=AssetsManager.getAssetsICON(listData[index].icon);;
			this.nameLabel.text=Tools.getMsgById(listData[index].name);

			//this.nameLabel.width=this.nameLabel.textField.textWidth;
			//this.nameLabel.x=this.iconImg.width/2+this.iconImg.x-this.nameLabel.width/2;
			this.numLabel.text=listData[index].lv+"";
			//this.numLabel.x=this.nameLabel.x+this.nameLabel.width;
		}


		public function listRender2(cell:bagItemUI,index:int):void{
			var d:ModelItem=getListData[index];
			//cell.setData(d.icon,d.ratity,d.name,d.addNum+"");
			cell.setData(d.id,d.addNum);
		}

		public function resolveClick():void{
			if(curIndex==-1) return;
			var sendData:Object={};
			sendData["star_id"]=listData[curIndex].cid;
			NetSocket.instance.send("star_recover",sendData,Handler.create(this,this.socektCallBack));
		}

		public function socektCallBack(np:NetPackage):void{
			ModelManager.instance.modelUser.updateData(np.receiveData);
			ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
			setData();
		}

		override public function onRemoved():void{
			ModelManager.instance.modelUser.off(ModelUser.EVENT_USER_UPDATE,this,eventCallBack);
			this.setSelection(false);
		}
	}
}

import ui.inside.starResolveItemUI;
import sg.utils.Tools;
import sg.manager.AssetsManager;

class Item extends starResolveItemUI
{
	public function Item()
	{
		
	}

	public function setData(obj:Object):void{
		this.lvLabel.text= Tools.getMsgById("_public61",[obj.lv,""]);//obj.lv+"级";
		this.nameLabel.text=Tools.getMsgById(obj.name);
		this.numLabel.text="";//"x1";
		this.iconImg.skin=AssetsManager.getAssetsICON(obj.icon);
	}

	public function setListSelect(b:Boolean):void{
		//this.iconImg.alpha=b?0.5:1;
		this.imgSelect.visible=b;
	}
}