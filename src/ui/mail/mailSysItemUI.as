/**Created by the LayaAirIDE,do not modify.*/
package ui.mail {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class mailSysItemUI extends ItemBase {
		public var boxImg:Image;
		public var titleLabel:Label;
		public var timeLabel:Label;
		public var mailImg:Image;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("mail/mailSysItem");

		}

	}
}