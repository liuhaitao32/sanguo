/**Created by the LayaAirIDE,do not modify.*/
package ui.init {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class view_real_nameUI extends ViewPanel {
		public var btn:Button;
		public var t1:Label;
		public var t2:Label;
		public var tName:TextInput;
		public var tNum:TextInput;
		public var tReal:TextInput;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("init/view_real_name");

		}

	}
}