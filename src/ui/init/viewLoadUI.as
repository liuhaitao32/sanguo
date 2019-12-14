/**Created by the LayaAirIDE,do not modify.*/
package ui.init {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import laya.display.Text;

	public class viewLoadUI extends ViewScenes {
		public var bgBox:Box;
		public var combox:Box;
		public var btn_login:Button;
		public var tuid:TextInput;
		public var btn_server:Image;
		public var tZone:Label;
		public var xuanqu:Label;
		public var tAll:TextInput;
		public var btn_clear1:Button;
		public var yybBox:Box;
		public var btnQQ:Button;
		public var btnWX:Button;
		public var googleBox:Box;
		public var btnFB:Button;
		public var btnGG:Button;
		public var btnReserve:Button;
		public var twBox:Box;
		public var twFB:Button;
		public var twReserve:Button;
		public var btn_register:Button;
		public var txt_register:Text;
		public var tCopyright:Label;
		public var btn_affiche:Image;
		public var txt_affiche:Text;
		public var progressBox:Box;
		public var adImg:Image;
		public var progressBarbg:Image;
		public var img0:Image;
		public var img1:Image;
		public var progressBar:Panel;
		public var imgProgressBar:Image;
		public var progressTxt:Label;
		public var txtShow:Label;
		public var tVersion:Label;
		public var yybOut:Button;
		public var txt_out:Text;
		public var btn_tel:Image;
		public var txt_tel:Text;

		override protected function createChildren():void {
			View.regComponent("Text",Text);
			super.createChildren();
			loadUI("init/viewLoad");

		}

	}
}