/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class country_rank_powerUI extends ItemBase {
		public var list:List;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("map/country_rank_power");

		}

	}
}