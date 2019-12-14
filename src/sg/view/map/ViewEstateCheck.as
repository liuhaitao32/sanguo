package sg.view.map
{
	import ui.map.estateCheckUI;
	import ui.com.estate_btn_labelUI;
	import laya.events.Event;
	import laya.utils.Handler;
	import sg.manager.ModelManager;
	import sg.model.ModelUser;
	import sg.utils.Tools;

	/**
	 * ...
	 * @author
	 */
	public class ViewEstateCheck extends estateCheckUI{

		private var type_arr:Array=["520050","520053","520056","520059","520062","520065"];
		private var lv_arr:Array=[1,2,3,4,5,6,7,8,9];
		private var select_arr:Array=[-1,-1];
		public function ViewEstateCheck(){
			this.list1.itemRender=Item;
			this.list2.itemRender=Item;
			this.list1.renderHandler=new Handler(this,this.listRender1);
			this.list2.renderHandler=new Handler(this,this.listRender2);
			this.list1.selectHandler=new Handler(this,this.listSelect);
			this.list2.selectHandler=new Handler(this,this.listSelect);
			this.comTitle.setViewTitle(Tools.getMsgById("_star_text20"));
			this.text0.text=Tools.getMsgById("_estate_text32");
			this.text1.text=Tools.getMsgById("_estate_text33");
		}

		override public function onAdded():void{
			select_arr=this.currArg;
			this.list1.selectedIndex=select_arr[0];
			this.list2.selectedIndex=select_arr[1];

			this.list1.array=type_arr;
			this.list2.array=lv_arr;			
		}

		public function listRender1(cell:Item,index:int):void{
			cell.setData(Tools.getMsgById(type_arr[index]));
			cell.setSelection(select_arr[0]==index);
			cell.off(Event.CLICK,this,this.itemClick);
			cell.on(Event.CLICK,this,this.itemClick,[index]);
		}

		public function listRender2(cell:Item,index:int):void{
			cell.setData(Tools.getMsgById("100001",[lv_arr[index]]));
			cell.setSelection(select_arr[1]==index);
			cell.off(Event.CLICK,this,this.itemClick2);
			cell.on(Event.CLICK,this,this.itemClick2,[index]);
		}

		public function itemClick(index:int):void{
			if(index==select_arr[0]){
				select_arr[0]=-1;
				this.list1.selectedIndex=-1;
			}else{
				select_arr[0]=index;
				this.list1.selectedIndex=index;
			}
		}

		public function itemClick2(index:int):void{
			if(index==select_arr[1]){
				select_arr[1]=-1;
				this.list2.selectedIndex=-1;
			}else{
				select_arr[1]=index;
				this.list2.selectedIndex=index;
			}
			
		}

		public function listSelect(index:int):void{
			ModelManager.instance.modelUser.event(ModelUser.EVNET_ESTATE_MAIN,[select_arr]);
		}

		override public function onRemoved():void{
			
		}
	}

}

import ui.com.estate_btn_labelUI;

class Item extends estate_btn_labelUI{
	public function Item(){

	}

	public function setData(obj:*):void{
		this.btn.label=obj;
	}

	public function setSelection(b:Boolean):void{
		this.btn.selected=b;
		this.img.visible=b;
	}
}