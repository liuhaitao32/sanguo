package sg.view.menu
{
	import ui.menu.leftUI;
	import sg.view.ViewPanel;
	import laya.events.Event;
	import sg.activities.view.ActIconList;
	import laya.display.Sprite;

	/**
	 * ...
	 * @author
	 */
	public class ViewMenuLeft extends leftUI{
		private var actIconList:ActIconList;
		public function ViewMenuLeft(){
			
			this.mouseThrough = true;
		}

		public function initList():void {
			
			// 创建活动列表
			actIconList = new ActIconList();
			this.addChild(actIconList);
		}


		public function getSpriteByName(name:String):Sprite
		{
			return actIconList.getSpriteByName(name);
		}

		override public function onChange(type:* = null):void{
			if(type == 1){
				this.visible = true;
			}
			else if(type == 2){
				this.visible = true;
			}
			else if(type == 3){
				this.visible = false;
			}
		}
	}

}