package sg.view.init
{
	import ui.init.noticePictureUI;
	import sg.manager.AssetsManager;
	import laya.events.Event;
	import sg.boundFor.GotoManager;
	import sg.manager.LoadeManager;
	import sg.manager.QueueManager;

	/**
	 * ...
	 * @author
	 */
	public class ViewNoticePicture extends noticePictureUI{
		private var mArr:Array;
		private var mKey:String;
		public function ViewNoticePicture(){
			img.on(Event.CLICK,this,imgClick);
		}


		override public function onAdded():void{
			//this.currArg=[["图id",跳转],key]
			mArr=this.currArg[0];
			mKey=this.currArg[1];
			this.allBox.centerX=0;
			this.allBox.centerY=0;
			this.img.skin=AssetsManager.getAssetsAD(mArr[0]);
		}


		private function imgClick():void{
			if(mArr[1]){
				QueueManager.instance.mIsGoto=true;
				GotoManager.boundFor(mArr[1]);
				this.closeSelf();
			}
			
		}


		override public function onRemoved():void{
			
		}
	}

}