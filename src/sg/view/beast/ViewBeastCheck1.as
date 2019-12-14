package sg.view.beast
{
	import ui.beast.beastCheck1UI;
	import sg.utils.Tools;
	import laya.ui.Button;
	import laya.utils.Handler;
	import sg.model.ModelBeast;
	import laya.events.Event;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import laya.ui.Image;
	import sg.manager.AssetsManager;

	/**
	 * ...
	 * @author
	 * @选择类型 type
	 */
	public class ViewBeastCheck1 extends beastCheck1UI{

		private var mType:String;//选中的类型
		public function ViewBeastCheck1(){
			this.tName.text = Tools.getMsgById('_beast_text23');//"选择类型";
			Tools.textLayout2(this.tName,this.imgName,340,245);

			this.list.renderHandler = new Handler(this,listRender);
		}

		override public function onAdded():void{
			mType = this.currArg ? this.currArg : "";
			var data:Array = ModelBeast.getAllTypeArr();
			this.list.array = data;
		}

		private function listRender(cell:Button,index:int):void{
			var o:Object = this.list.array[index];
			cell.label = o.text;
			cell.selected = mType == o.key;
			var img:Image = cell.getChildByName('beastImg') as Image;
			img.skin = AssetsManager.getAssetLater(ModelBeast.getIconByType(o.key));

			cell.off(Event.CLICK,this,cellClick);
			cell.on(Event.CLICK,this,cellClick,[index]);
		}


		private function cellClick(index:int):void{
			if(mType == this.list.array[index].key){
				mType = "";
			}else{
				mType = this.list.array[index].key;
			}
			
			ModelManager.instance.modelUser.event(ModelBeast.EVENT_BEAST_FILTER,{"type":mType});
			closeSelf();
		}

		override public function onRemoved():void{
			
		}
	}

}