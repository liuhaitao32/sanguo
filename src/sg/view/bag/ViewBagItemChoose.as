package sg.view.bag
{
	import ui.bag.bagItemChooseUI;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import ui.bag.getRewardUI;
	import sg.cfg.ConfigClass;
	import ui.bag.bagItemUI;
	import laya.utils.Handler;
	import sg.model.ModelItem;
	import sg.manager.ModelManager;
	import sg.model.ModelProp;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.utils.ObjectSingle;
	import sg.utils.Tools;
	import sg.view.hero.ViewAwakenHero;
	import sg.model.ModelHero;

	/**
	 * ...
	 * @author
	 */
	public class ViewBagItemChoose extends bagItemChooseUI{
		private var listData:Array;
		private var curIndex:int;
		private var curLine:int;
		private var numArr:Array;
		//public static var getNum:int=1;
		private var itemId:String;
		private var itemNum:Number;
		private var itemModel:ModelItem;

		public function ViewBagItemChoose(){
			//this.list.itemRender=bagItemUI;
			this.list.renderHandler=new Handler(this,updateItem);
			this.list.selectHandler=new Handler(this,listOnSelect);
			this.list.scrollBar.visible=false;

			this.list2.renderHandler=new Handler(this,updateItem2);
			this.list2.selectHandler=new Handler(this,listOnSelect);
			this.list2.scrollBar.visible=false;

			this.btnUse.on(Event.CLICK,this,this.onClick,[this.btnUse]);
			//this.titleImg.width=this.title.width+100;
			this.tLabel.text=Tools.getMsgById("_bag_text21");
			this.btnUse.label = Tools.getMsgById("_bag_text04");
		}

		override public function onAdded():void{
			this.btnUse.gray=true;
			curIndex = -1;
			curLine = -1;
			itemId=this.currArg[0];
			itemNum=this.currArg[1];
			itemModel=ModelManager.instance.modelProp.getItemProp(itemId);//ModelManager.instance.modelProp.curProp;
			//this.title.text=itemModel.name;
			this.comTitle.setViewTitle(itemModel.name);
			listData=[];
			numArr=[];
			for(var i:int = 0; i < itemModel.boxT.length; i++)
			{
				var value:Array=itemModel.boxT[i];
				if(value[0]=="awaken"){
					listData.push({"id":value[1]});
					numArr.push(-1);
				}else{
					listData.push(ModelManager.instance.modelProp.getItemProp(value[0]));
					numArr.push(value[1]*itemNum);
				}
			}

			var arr1:Array = [];
			var arr2:Array = [];
			for(var j:int=0;j<listData.length;j++){
				listData[j]["selectIndex"] = j;
				if(j<4) arr1.push(listData[j]);
				else    arr2.push(listData[j]);
			}

			this.list.repeatX = arr1.length;
			this.list.centerX = 0;
			this.list.array   = arr1;

			this.list2.repeatX = arr2.length;
			this.list2.centerX = 0;
			this.list2.array   = arr2;

			this.list2.visible = listData.length>4;
			this.allBox.height = listData.length>4 ? 546 + 5 : 546 - 150;//this.list.height;
			
		}

		public function updateItem(cell:bagItemUI,index:int):void{
			//if(index>listData.length) return;
			var data:ModelItem=this.list.array[index];
			cell.setData(data.id,numArr[index]);			
			
			cell.gray=false;
			var line:Number = data["selectIndex"]<4 ? 0 : 1;
			cell.setSelection(index == curIndex && line == curLine);
			if(data.id.indexOf("hero")!=-1){
				cell.gray=(ModelManager.instance.modelGame.getModelHero(this.list.array[index].id).getAwaken()==1);
			}
			cell.off(Event.CLICK,this,this.listItemClick);
			cell.on(Event.CLICK,this,this.listItemClick,[index,0]);
		}

		public function updateItem2(cell:bagItemUI,index:int):void{
			//if(index>listData.length) return;
			var data:ModelItem=this.list2.array[index];
			cell.setData(data.id,numArr[index]);			
			cell.gray=false;
			var line:Number = data["selectIndex"]<4 ? 0 : 1;
			cell.setSelection(index == curIndex && line == curLine);
			if(data.id.indexOf("hero")!=-1){
				cell.gray=(ModelManager.instance.modelGame.getModelHero(this.list2.array[index].id).getAwaken()==1);		
			}
			cell.off(Event.CLICK,this,this.listItemClick);
			cell.on(Event.CLICK,this,this.listItemClick,[index,1]);
		}


		public function listOnSelect(index:int):void{

		}

		public function listItemClick(index:int,line:Number):void{

			if(curIndex == index && curLine == line) return;
			var arr:Array = line == 0 ? this.list.array : this.list2.array;
			if(ModelManager.instance.modelGame.getModelHero(arr[index].id).getAwaken()==1){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("193011"));
				return;
			}
			curIndex = index;
			curLine  = line;
			this.list.selectedIndex=curLine == 0 ? index : -1;
			this.list2.selectedIndex=curLine == 1 ? index : -1;

			this.btnUse.gray = false;

		}


		override public function onRemoved():void{

			this.list.selectedIndex=-1;
			this.list2.selectedIndex=-1;
		} 

		public function onClick(obj:*=null):void{
			if(curIndex==-1) return;
			var index : int = curLine == 0 ? curIndex : 4 - curIndex;
			var obj:Object     = {};
			obj["item_id"]     = itemModel.id;
			obj["item_num"]    = itemNum;
			obj["range_index"] = index;
			NetSocket.instance.send("use_prop",obj,Handler.create(this,this.socketCallBack));
		}
		public function socketCallBack(np:NetPackage):void{
			ModelManager.instance.modelUser.updateData(np.receiveData);
			ViewManager.instance.closePanel();
			if(np.receiveData.gift_dict.hasOwnProperty("awaken")){
				ViewAwakenHero.awakenHero(np.receiveData.gift_dict.awaken);
			}else{
				ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
			}
			ModelManager.instance.modelProp.event(ModelProp.event_updateprop);
		}
	}

}