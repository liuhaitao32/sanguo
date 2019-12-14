/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.country_flag1UI;

	public class citySendItemUI extends ItemBase {
		public var box:Box;
		public var imgFrame:Image;
		public var sprDir:Sprite;
		public var imgDir:Image;
		public var flag:country_flag1UI;
		public var txtName:Label;
		public var txtType:Label;
		public var txtNum_:Label;
		public var txtUser_:Label;
		public var txtLv_:Label;
		public var txtNum:Label;
		public var txtUser:Label;
		public var txtLv:Label;
		public var select:Image;
		public var txtInfo:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.country_flag1UI",country_flag1UI);
			super.createChildren();
			loadUI("map/citySendItem");

		}

	}
}