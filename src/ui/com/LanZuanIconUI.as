/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class LanZuanIconUI extends ItemBase {
		public var nian_img:Image;
		public var lanzuan_img:Image;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("com/LanZuanIcon");

		}

	}
}