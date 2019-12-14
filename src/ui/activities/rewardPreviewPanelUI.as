/**Created by the LayaAirIDE,do not modify.*/
package ui.activities {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class rewardPreviewPanelUI extends ViewPanel {
		public var mc:Box;
		public var panel:Image;
		public var previewTxt:Label;
		public var closehint:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("activities/rewardPreviewPanel");

		}

	}
}