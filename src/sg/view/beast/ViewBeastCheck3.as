package sg.view.beast
{
	import ui.beast.beastCheck3UI;
	import sg.utils.Tools;
	import laya.ui.Button;
	import laya.events.Event;
	import sg.manager.ModelManager;
	import sg.model.ModelBeast;
	import laya.utils.Handler;

	/**
	 * ...
	 * @author
	 * 选择排序
	 */
	public class ViewBeastCheck3 extends beastCheck3UI{

		private var mSortArr:Array;
		private var mData:Array = [{text:Tools.getMsgById('_beast_text26'),sortKey:"sortLv",bigFirst:1},  {text:Tools.getMsgById('_beast_text27'),sortKey:"sortLv",bigFirst:0},
								   {text:Tools.getMsgById('_beast_text28'),sortKey:"sortStar",bigFirst:1},{text:Tools.getMsgById('_beast_text29'),sortKey:"sortStar",bigFirst:0},
								   {text:Tools.getMsgById('_beast_text30'),sortKey:"sortPos",bigFirst:1}, {text:Tools.getMsgById('_beast_text31'),sortKey:"sortPos",bigFirst:0},
								   {text:Tools.getMsgById('_beast_text32'),sortKey:"sortId",bigFirst:1},  {text:Tools.getMsgById('_beast_text33'),sortKey:"sortId",bigFirst:0}];
		
		public function ViewBeastCheck3(){
			this.tName.text = Tools.getMsgById('_beast_text25');// "选择排序";
			Tools.textLayout2(this.tName,this.imgName,340,245);
			this.list.renderHandler = new Handler(this,listRender);
		}

		override public function onAdded():void{
			mSortArr = this.currArg ? this.currArg : [-1,-1];
			this.list.array = mData;
		}

		private function listRender(cell:Button,index:int):void{
			var o:Object = this.list.array[index];
			cell.label = o.text;
			cell.selected = mSortArr[0]==o.sortKey && mSortArr[1]==o.bigFirst;

			cell.off(Event.CLICK,this,btnClick);
			cell.on(Event.CLICK,this,btnClick,[index]);
		}


		private function btnClick(index:int):void{
			var o:Object = this.list.array[index];
			if(mSortArr[0]==o.sortKey && mSortArr[0]==o.bigFirst){
				mSortArr = ["",1];
			}else{
				mSortArr = [o.sortKey,o.bigFirst];
			}
			ModelManager.instance.modelUser.event(ModelBeast.EVENT_BEAST_SORT,{"sortKey":mSortArr[0],"bigFirst":mSortArr[1]});
			closeSelf();
		}


		override public function onRemoved():void{
			
		}
	}

}