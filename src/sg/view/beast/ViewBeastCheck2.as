package sg.view.beast
{
	import ui.beast.beastCheck2UI;
	import sg.utils.Tools;
	import laya.events.Event;
	import sg.manager.ModelManager;
	import sg.model.ModelBeast;

	/**
	 * ...
	 * @author
	 * @选择位置 pos
	 */
	public class ViewBeastCheck2 extends beastCheck2UI{

		private var mPos:int;
		public function ViewBeastCheck2(){
			this.tName.text = Tools.getMsgById('_beast_text24');//"选择位置";
			Tools.textLayout2(this.tName,this.imgName,340,245);
			for(var i:int=0;i<=7;i++){
				this["pos"+i].on(Event.CLICK,this,posClick,[i]);
			}
		}

		override public function onAdded():void{
			mPos = this.currArg == null ? -1 : this.currArg;
			for(var i:int=0;i<=7;i++){
				this["imgPos"+i].visible = mPos == i;
			}
		}

		private function posClick(index:int):void{
			if(mPos == index){
				mPos = -1;
			}else{
				mPos = index;
			}

			for(var i:int=0;i<=7;i++){
				this["imgPos"+i].visible = mPos == i;
			}
			ModelManager.instance.modelUser.event(ModelBeast.EVENT_BEAST_FILTER,{"pos":mPos});
			closeSelf();
		}

		override public function onRemoved():void{
			
		}
	}

}