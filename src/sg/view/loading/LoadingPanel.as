package sg.view.loading
{
	import laya.ui.Box;

	import sg.cfg.ConfigApp;
	import sg.manager.LoadeManager;
	import sg.manager.ViewManager;
	import sg.utils.Tools;

	import ui.loading.LoadingPanelUI;
	import sg.utils.StringUtil;
	import sg.manager.AssetsManager;
	
	/**
	 * ...
	 * @author jiaxuyang
	 */
	public class LoadingPanel extends LoadingPanelUI
	{
		private var loader:LoadeManager;
		
		private var maskW:Number;
		private var oriX:Number;
		private var desX:Number;
		private var speed:Number;
		private var percentSpeed:Number = 1;
		private var fakePercent:Number = 0;
		private var mParent:Box;
		
		// 单例
		private static var sLoadingPanel:LoadingPanel = null;
		public  static function get instance():LoadingPanel{
			return sLoadingPanel ||= new LoadingPanel();
		}
		
		public function LoadingPanel()
		{
			this.maskW = this.sp_mask.width;
			this.oriX = this.maskW / -6;
			this.desX = 0;
			this.speed = 1.0;
			this.loader = LoadeManager.instance;
			this.loader.off(LoadeManager.SHOW_PANEL, this, this.showLoading);
			this.loader.off(LoadeManager.PROGRESS, this, this.setProgress);
			this.loader.off(LoadeManager.REMOVE_SELF, this, this.hideLoading);	
			//
			this.loader.on(LoadeManager.SHOW_PANEL, this, this.showLoading);
			this.loader.on(LoadeManager.PROGRESS, this, this.setProgress);
			this.loader.on(LoadeManager.REMOVE_SELF, this, this.hideLoading);
			//
			// 
			if(ConfigApp.lclip2 && ConfigApp.lclip2 != ""){
				this.hintTxt.text = "";
				this.sp_logo.skin = AssetsManager.getAssetsAD(ConfigApp.lclip2);
				this.sp_darkLogo.skin = "";
			}
			else{
				this.sp_logo.skin = "clip/loadingPanel/logo.png"
				this.sp_darkLogo.skin = "clip/loadingPanel/logoblack.png"; // clip/loadingPanel/logoblack.png
			}
		}
		private function init():void
		{
			this.setProgress(0);

			this.sp_mask.x = this.oriX;
			this.sp_mask.width = maskW;
			
			this.centerY = (Laya.stage.height - this.height) * 0.5;

		}
		private function clearAll():void
		{
			Laya.timer.clear(this, this._onFrameChange);
			Laya.timer.clear(this, this.animateTime);					
		}
		/**
		 * 显示加载界面
		 */
		private function showLoading(duration:int):void
		{
			this.mParent = ViewManager.instance.mLayerLoading as Box;
			this.clearAll();
			this.init();
			Laya.timer.frameLoop(1, this, this._onFrameChange);
			if (duration) {
				this.fakePercent = 0;
				this.percentSpeed = 100/(duration/30);
				Laya.timer.loop(30, this, this.animateTime);
			}
			this.mParent.visible = true;
			this.mParent.addChild(this);
		}

		private function animateTime(percent:Number):void {
			this.fakePercent+=this.percentSpeed;
			this.setProgress(this.fakePercent);
		}
		
		/**
		 * 设置进度
		 * @param	percent
		 */
		private function setProgress(percent:Number):void
		{
			percent = Math.round(percent);
			percent = percent>100?100:percent;
			// trace(percent);
			this.sp_mask.y = sp_darkLogo.height / 100 * percent * -1;
			if(ConfigApp.lclip2 && ConfigApp.lclip2 != ""){
				this.hintTxt.text = "";
				return;
			}
			this.hintTxt.text = "[" + percent  + "%]" + Tools.getMsgById('_jia0038');
		}
		
		/**
		 * 隐藏加载界面
		 */
		private function hideLoading():void
		{
			if(this.parent){
				(this.parent as Box).visible = false;
			}
			this.clearAll();
			this.removeSelf();
		}
		
		private function _onFrameChange():void
		{
			if (!this.parent) return;
			this.sp_mask.x += this.speed;
			if (this.sp_mask.x > this.desX)
			{
				this.sp_mask.x += this.oriX;
			}
		}
	}
}