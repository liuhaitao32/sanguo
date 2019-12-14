/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class itemOfficeUI extends ItemBase {
		public var cb:CheckBox;
		public var tName:Label;
		public var tStatus:Label;
		public var bar:ProgressBar;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("inside/itemOffice");

		}

	}
}