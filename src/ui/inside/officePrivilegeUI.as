/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class officePrivilegeUI extends ItemBase {
		public var btn:Button;
		public var mLock:Image;
		public var clipBox:Box;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("inside/officePrivilege");

		}

	}
}