package sg.view.inside
{
	import ui.inside.starResolveQuickUI;
	import ui.inside.starQuickItemUI;
	import ui.bag.bagItemUI;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import laya.events.Event;
	import laya.utils.Handler;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.manager.ViewManager;
	import sg.model.ModelItem;
	import sg.utils.Tools;
	import laya.maths.MathUtil;
	import sg.model.ModelRune;

	/**
	 * ...
	 * @author
	 */
	public class ViewStarResolveQuick extends starResolveQuickUI{


		public var configData:Object=ConfigServer.star;
		public var userData:Object={};
		public var starListData:Array=[];
		public var star_text:Array=[
			Tools.getMsgById("_public65"),
			Tools.getMsgById("_public66"),Tools.getMsgById("_public67"),Tools.getMsgById("_public68"),
			Tools.getMsgById("_public69"),Tools.getMsgById("_public70"),Tools.getMsgById("_public71"),Tools.getMsgById("_public72")
			];
		public var star_icon_arr:Array=["star001.png","star005.png","star006.png","star007.png","","","",""];
		public var resolveType:int=0;
		public var idList:Array=[]; 
		public var rewardListData:Array=[];
		public function ViewStarResolveQuick(){
			this.starList.scrollBar.visible=false;
			this.rewardList.scrollBar.visible=false;
			this.starList.renderHandler=new Handler(this,this.starListRender);
			this.rewardList.renderHandler=new Handler(this,this.rewardListRender);
			this.btnQuick.on(Event.CLICK, this, quickClick);
			this.btnQuick.label = Tools.getMsgById("_star_text10");
			starList.itemRender=Item;
			//rewardList.itemRender=bagItemUI;
		}

		override public function onAdded():void{
			
			var s:String=resolveType==0?Tools.getMsgById("_star_text07"):Tools.getMsgById("_star_text08");
			//this.titleLabel.text=Tools.getMsgById("_star_text11",[s]);
			this.comTitle.setViewTitle(Tools.getMsgById("_star_text11",[s]));
			this.text0.text=Tools.getMsgById("_star_text12");
			this.text1.text=Tools.getMsgById("_star_text13",[s]);
			setData();
		}

		public function setData():void{
			userData=ModelManager.instance.modelUser.star;
			this.btnQuick.gray=true;
			idList=[];
			resolveType=this.currArg;
			getStarData();
			this.rewardList.array=[];
		}


		public function getStarData():void{
			starListData=[];
			var n:int=resolveType==0?0:4;
			for(var i:int=n;i<n+4;i++){
				var o:Object={};
				o["name"]=star_text[i];
				o["icon"]=star_icon_arr[i];
				o["num"]=0;
				for(var v:String in userData)
				{
					if(userData[v].lv==1 && userData[v].hid==null){
						var cid:String="";
						var temp:int = v.indexOf("|");
           	 			if(temp>-1){
                			cid = v.substring(0,temp);
            			}
						var d:Object=configData[cid];
						if(d.fix_type==i){
							o["num"]+=1;
						}
					}
				}
				starListData.push(o);
			}
			this.starList.array=starListData;
			
		}



		
		public function setStarIDList(index:int,type:int):void{
			var n:int=index;
			if(resolveType==1){
				n+=4;
			}
			if(type==0){//加
					idList.push(n);
				}else{
					var nn:int=idList.indexOf(n);
					if(nn!=-1){
						idList.splice(nn,1);
					}
				}
			//trace(type,idList);
			this.btnQuick.gray=idList.length==0;
			getRewardData();
		}

		public function starListRender(cell:Item,index:int):void{
			var d:Object=starListData[index];
			cell.setData(d);			
			cell.on(Event.CLICK,this,itemClick,[cell,index]);
		}

		public function itemClick(cell:Item,index:int):void{
			if(cell.num==0){
				return;
			}
			if(!cell.selected){
				setStarIDList(index,0);
			}else{
				setStarIDList(index,1);
			}
			cell.setSelection(!cell.selected);
		}

		public function getRewardData():void{
			rewardListData=[];
			var n:int=0;
			var star_exp:Object=ConfigServer.system_simple.star_exp;
			var obj:Object={};
			for(var j:int=0;j<idList.length;j++){
				n=idList[j];
				for(var i:String in userData){
					if(userData[i].lv==1 && userData[i].hid==null){
						var obj_num:Number=0;
						var cid:String="";
						var temp:int = i.indexOf("|");
						if(temp>-1){
							cid = i.substring(0,temp);
						}
						var itemStar:Object=configData[cid];
						if(itemStar.fix_type==n){
							//var v:Array=getCfgItem(star_exp[itemStar.exp_type][1]);//star_exp[itemStar.exp_type][1];
							//var minNum:Number=v[0].exp;
							var minId:String=star_exp[itemStar.exp_type][2];//v[0].id;
							if(obj.hasOwnProperty(minId)){
								obj[minId]+=1;
							}else{
								obj[minId]=1;
							}
						}
					}
					
				}
			}
			if(Tools.getDictLength(obj)!=0){
				rewardListData.push(obj);
			}
			
			this.rewardList.array=rewardListData;
		}


		public function getCfgItem(obj:Object):Array{
			var arr:Array=[];
			for(var s:String in obj){
				arr.push({"id":s,"exp":obj[s]});
			}
			arr.sort(MathUtil.sortByKey("exp",false,false));
			return arr;
		}

		public function quickClick():void{
			if(idList.length==0){
				return;
			}
			var sendData:Object={};
			sendData["fix_type_list"]=idList;
			NetSocket.instance.send("star_recover_by_type",sendData,Handler.create(this,socketCallBack));
		}

		public function socketCallBack(np:NetPackage):void{
			idList=[];
			for(var i:int=0;i<starList.length;i++){
				(starList.getCell(i) as Item).setSelection(false);
			}
			ModelManager.instance.modelUser.updateData(np.receiveData);
			ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
			setData();
		}

		public function rewardListRender(cell:bagItemUI,index:int):void{
			if(index>=rewardListData.length)
				return;
			var o:Object=rewardList.array[index];
			var s:String="";
			var ss:int=0;
			for(var v:String in o)
			{
				s=v;
				ss=o[v];
			}
			var itemModel:ModelItem=ModelManager.instance.modelProp.getItemProp(s);
			//cell.setData(itemModel.icon,itemModel.ratity,itemModel.name,ss+"");
			cell.setData(itemModel.id,ss);
		}

		override public function onRemoved():void{
			idList=[];
			this.starList.selectedIndex=-1;
			for(var i:int=0;i<4;i++){
				var it:Item=this.starList.getCell(i) as Item;
				if(it){
					it.setSelection(false);
				}
			}
		}
	}

}

import ui.inside.starQuickItemUI;
import sg.manager.AssetsManager;
import sg.utils.Tools;

class Item extends starQuickItemUI{

	public var selected:Boolean=false;
	public var num:Number=0;
	public function Item(){

	}

	public function setData(obj:*):void{
		this.text0.text=Tools.getMsgById("100001",["1"]);
		this.btnCheck.mouseEnabled=false;
		selected=false;
		this.num=obj.num;
		this.nameLabel.text=obj.name;
		this.numLabel.text=Tools.getMsgById("_public73",[obj.num]);//"数量："+obj.num;
		this.imgIcon.skin=AssetsManager.getAssetsICON(obj.icon);
	}

	public function setSelection(b:Boolean):void{
		selected=b;
		//this.alpha=b?0.5:1;
		this.btnCheck.selected=b;
		this.imgSelect.visible=b;
	}
}
