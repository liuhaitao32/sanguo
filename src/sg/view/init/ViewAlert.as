package sg.view.init
{
	import ui.init.viewAlertUI;
	import sg.model.ModelAlert;
	import sg.manager.ModelManager;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import sg.manager.AssetsManager;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.display.Sprite;
	import sg.utils.Tools;
	import sg.utils.SaveLocal;
	import sg.cfg.ConfigServer;

	/**
	 * ...
	 * @author
	 */
	public class ViewAlert extends viewAlertUI{
		public var md:ModelAlert;
		private var mArr:Array;
		public function ViewAlert(){
			this.btn0.on(Event.CLICK,this,this.onClick,[btn0]);
			this.btn1.on(Event.CLICK,this,this.onClick,[btn1]);
			this.btnCheck.on(Event.CLICK,this,this.checkClick);
		}
		override public function initData():void{
			this.comTitle.setViewTitle(Tools.getMsgById("_public203"));
			this.btn0.label=Tools.getMsgById("_public183");
			this.btn1.label=Tools.getMsgById("_shogun_text03");
			this.ttt.text=Tools.getMsgById("treasure_text03");
			md = ModelManager.instance.modelAlert;
			this.onlyCloseByBtn(md.force_btn);
			this.text1.text = this.text2.text = "";

			this.text1.valign = "top";
			this.text1.wordWrap = true;
			this.text1.text = md.text;
			this.text1.height = this.text1.textField.textHeight;
			
			this.text2.text = md.text2;

			if(md.cost_arr){			
				this.comtype.setData(AssetsManager.getAssetItemOrPayByID(md.cost_arr[0]),md.cost_arr[1]);
			}

			this.box0.visible = md.cost_arr != null;
			this.box1.visible = md.repeat_key != "";
			this.text2.visible = md.text2 != "";
			
			this.btn1.visible = !md.only;
			if(md.only){
				this.btn0.centerX = 0;
			}
			else{
				this.btn0.centerX = 145;
				this.btn1.centerX = -145;
			}

			
			this.btnCheck.selected=false;
			if(md.repeat_key!=""){
				this.text3.text=Tools.getMsgById("193006");
				this.text3.width = this.text3.textField.textWidth;
				this.btnCheck.x = this.text3.width+10;
				this.box1.width = this.btnCheck.x+this.btnCheck.width;
				this.box1.centerX = 0;
			}

			mArr = [text1,box0,text2,box1];
			var mSort:Array = [];
			var _height:Number = 0;
			var _num:Number = 0;
			for(var i:int=0;i<mArr.length;i++){
				_height += mArr[i].visible ? mArr[i].height : 0;
				_num += mArr[i].visible ? 1 : 0;
				if(mArr[i].visible) mSort.push(mArr[i]);
			}
			var _gap:Number = 14;
			_height = _height + (_gap*_num);
			contentBox.height = _height;
			contentBox.centerY = 0;

			var _y:Number = 0;
			for(var j:int=0;j<mSort.length;j++){
				mSort[j].y = _y;
				_y = _y + (mSort[j].height+_gap);
			}

		}
		override public function onAdded():void{
			(this.bg.getChildByName("btn_close") as Sprite).visible = false;
		}
		public function onClick(obj:*):void {
			if(this.md.isWarn){
				ViewManager.instance.clearWarn();
			}
			else{
				ViewManager.instance.closePanel(this);
			}
			switch(obj){
				case this.btn0:
					md.execute(0);
					setLocal();
				break;
				case this.btn1:
					md.execute(1);
				break;
			}
			
		}

		public function checkClick():void{
			this.btnCheck.selected=!this.btnCheck.selected;
		}

		public function setLocal():void{
			if(md.repeat_key!="" && this.btnCheck.selected){
				Tools.setAlertIsDel(md.repeat_key);
			}
		}

		override public function onRemoved():void{
			
		}
	}

}