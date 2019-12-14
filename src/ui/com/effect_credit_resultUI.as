/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class effect_credit_resultUI extends ComPayType {
		public var img1:Image;
		public var pro:Panel;
		public var img0:Image;
		public var num0:Label;
		public var num1:Label;
		public var textLabel:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("com/effect_credit_result");

		}

	}
}