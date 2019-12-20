package sg.view.qqdt {
	import laya.ui.Label;
	import sg.cfg.ConfigApp;
	import ui.com.LanZuanIconUI;
	
	/**
	 * ...
	 * @author light
	 */
	public class LanZuanIcon extends LanZuanIconUI {
		
		public function LanZuanIcon() {
			
		}
		
		public static function getLanZuan(icon:LanZuanIcon, label:Label, text:String):String {
			text = text.toString();
			if (ConfigApp.pf != ConfigApp.PF_qqdt_h5 || text.indexOf("qqdt") != 0)  {
				if (label.lanzuan) {
					label.lanzuan.destroy();
					label.lanzuan = null;
				}		
				//label.pivot(0, 0);
				return text;
			} else {
				var result:LanZuanIcon = new LanZuanIcon();
				label.lanzuan = result;
				return result.parseData(label, text);
			}
		}
		
		public function  parseData(label:Label, text:String):String {		
			
			var temp:String = text.substr(0, 11);
			
			var arr:Array = temp.split("_");
			
			//0代表 是否年费 有效值01
			//1代表 是否是年费 有效值01
			//6代表 蓝钻等级。有效值0-8 0级我不知道干嘛用的。。。默认应该都是
			//qqdt_0_1_6_name
			var isNian:Boolean = arr[1] == "1";
			var isHao:Boolean = arr[2] == "1";
			var level:int = parseInt(arr[3]);
			
			if (isNian) {
				label.pivotX = -this.nian_img.width * 2;
				this.nian_img.visible = true;				
			} else {
				label.pivotX = -this.nian_img.width * 1;
				this.nian_img.visible = false;
			}
			
			if (isHao) {
				this.lanzuan_img.skin = "lanzuan/nianl_2_" + level + ".png";
			} else {
				this.lanzuan_img.skin = "lanzuan/nianl_1_" + level + ".png";
			}
			label.addChild(this);
			this.x = label.pivotX;
			this.y = (label.height - this.lanzuan_img.height) / 2;
			return text.replace(temp, "");
		}
		
	}

}