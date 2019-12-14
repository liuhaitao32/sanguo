/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.fight.itemPKheroUI;

	public class pkResultUI extends ViewPanel {

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.fight.itemPKheroUI",itemPKheroUI);
			super.createChildren();
			loadUI("fight/pkResult");

		}

	}
}