/**Created by the LayaAirIDE,do not modify.*/
package ui {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class EditPropertyUI extends View {
		public var city_container:Box;
		public var id_txt:TextInput;
		public var cityType_combox:ComboBox;
		public var del_btn:Button;
		public var shudi_btn:Button;
		public var yeguai_btn:Button;
		public var chanye_btn:Button;
		public var qiecuo_btn:Button;
		public var midao_btn:Button;
		public var xianhe_btn:Button;
		public var daolu_container:Box;
		public var name_txt:Label;
		public var type_com:ComboBox;
		public var daolu_input:TextInput;
		public var close_btn:Button;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("EditProperty");

		}

	}
}