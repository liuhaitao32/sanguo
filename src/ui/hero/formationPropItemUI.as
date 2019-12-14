/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class formationPropItemUI extends ItemBase {
		public var img:Image;
		public var info:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("hero/formationPropItem");

		}

	}
}