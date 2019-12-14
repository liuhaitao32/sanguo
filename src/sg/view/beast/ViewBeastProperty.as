package sg.view.beast
{
	import ui.beast.beastPropertyUI;
	import sg.model.ModelHero;
	import sg.model.ModelBeast;
	import sg.utils.Tools;
	import sg.cfg.ConfigColor;

	/**
	 * ...
	 * @author
	 */
	public class ViewBeastProperty extends beastPropertyUI{

		private var mHmd:ModelHero;
		
		public function ViewBeastProperty(){
			this.comTitle.setViewTitle(Tools.getMsgById('_beast_text12'));
			this.pPanel.vScrollBar.visible = false;
			com1.tText2.text = "";
			com2.tText2.text = "";
			this.text0.text = Tools.getMsgById('_beast_text36');
			Tools.textLayout2(this.text0,this.img0,340,245);
		}

		override public function onAdded():void{
			if(this.currArg == null) return;
			mHmd = this.currArg;
			this.tLabel.text = mHmd.getBeastInfo();
			this.tLabel.height = this.tLabel.textField.textHeight;
			this.pPanel.height = this.tLabel.height;
			if(pPanel.height< 200){
				pPanel.height = 200;
			}else if(pPanel.height > 472){
				pPanel.height = 472;
			}
			this.imgBG.height =  (this.pPanel.top - this.imgBG.top) + this.pPanel.height + 10;

			var arr:Array = mHmd.getBeastResonanceArr();

			com1.visible = com2.visible = false;
			
			
			if(arr[0]){
				com1.tText0.text = Tools.getMsgById('_beast_text10',[ModelBeast.getTypeName(arr[0][0])]); //ModelBeast.getTypeName(arr[0][0]) + "四件套装效果";
				var arr1:Array = ModelBeast.getResonanceInfoArr(arr[0][0],arr[0][1],arr[0][2]);
				com1.tText1.text = arr1.join('\n');
				com1.visible = true;
				com1.tText0.color = ConfigColor.FONT_COLORS[arr[0][2]+1];
			} 
			if(arr[1]){
				com2.tText0.text = Tools.getMsgById((arr[1][1] == 4 ? '_beast_text10' : '_beast_text11'),[ModelBeast.getTypeName(arr[1][0])]);//ModelBeast.getTypeName(arr[1][0]) + (arr[1][1] == 4 ? "四件套装效果" : "八件套效果");
				var arr2:Array = ModelBeast.getResonanceInfoArr(arr[1][0],arr[1][1],arr[1][2]);
				com2.tText1.text = arr2.join('\n');
				com2.visible = true;
				com2.tText0.color = ConfigColor.FONT_COLORS[arr[1][2]+1];
			} 

			com1.tText1.height = com1.tText1.textField.textHeight;
			com1.height = com1.tText1.height + com1.tText1.y;

			com2.tText1.height = com2.tText1.textField.textHeight;
			com2.height = com2.tText1.height + com2.tText1.y;

			com1.y = this.imgBG.top + this.imgBG.height + 10;
			com2.y = com1.y + com1.height + 6;
			
			var n1:Number = com1.visible ? com1.height : 0;
			var n2:Number = com2.visible ? com2.height : 0;
			this.allBox.height = this.imgBG.top + this.imgBG.height + n1 + n2 + 26;
		}

		override public function onRemoved():void{
			
		}
	}

}