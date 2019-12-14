/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class hero_icon2UI extends ComPayType {
		public var mParticlesBottom:Box;
		public var mParticles:Box;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("com/hero_icon2");

		}

	}
}