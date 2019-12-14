/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class achievement_baseUI extends ItemBase {
		public var namePanel:Image;
		public var frame:Image;
		public var difficultyList:List;
		public var indexTxt:Label;
		public var achieveDate:Label;
		public var achieveName:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("inside/achievement_base");

		}

	}
}