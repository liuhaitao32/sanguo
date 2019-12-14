package sg.task.view 
{
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.ui.Button;
	import laya.ui.Label;

	import sg.task.model.ModelTaskBase;
	import sg.task.model.ModelTaskDaily;
	import sg.utils.Tools;

	import ui.task.task_listUI;
	import sg.cfg.ConfigServer;
	import sg.model.ModelGame;
	import sg.manager.ViewManager;
	
	/**
	 * ...
	 * @author jiaxuyang
	 */
	public class ViewTask extends task_listUI 
	{
		public static var model:ModelTaskBase = null;
		
		private var modelTask:ModelTaskBase;
		private var htmlPattern:String;
		public function ViewTask(model:ModelTaskBase) 
		{
			ViewTask.model = this.modelTask = model;
			this.list.itemRender = TaskBase;
			this.list.selectEnable = true;
			this.list.scrollBar.hide = true;
            this.on(Event.REMOVED, this, this.onRemove);
            this.on(Event.ADDED, this, this._adaptHeight);
			this.initModel();
		}
		
		/**
		 * 适配高度
		 */
		private function _adaptHeight():void {
			this.imgBg.height = this.height = Laya.stage.height - 225;
		}
		
		/**
		 * 需要在此方法中初始化 modelTask 属性
		 */
		public function initModel():void {
			this.modelTask.on(ModelTaskBase.UPDATE_DATA, this, this._onUpdateData);
			var lockData:Object = ModelGame.unlock('', modelTask.unlock_type);
			if (lockData.visible) {
				list.top = 70;
				topBar.visible = true;
			} else {
				list.top = 5;
				topBar.visible = false;
			}

			box_tips.visible = this.modelTask is ModelTaskDaily;
			btn_get.gray = lockData.gray;
			btn_get.on(Event.CLICK, this, this._onClickBtnGet);

			this._initData();
			this.list.scrollTo(0);
			this.visible = true;
		}

		private function refreshTopBar():void {
			hint_progress.text = Tools.getMsgById('_jia0031');
			btn_get.label = Tools.getMsgById('_jia0036');
			var model:ModelTaskDaily = this.modelTask as ModelTaskDaily;
			
			
			//已完成任务数量
			var completeNum:int = model.getFinishedNum();
			txt_progress.text = completeNum + "/" + this.list.array.length;
		}
		
		
		private function _initData():void {
			this.list.array = this.modelTask.getTaskData();
			this.modelTask is ModelTaskDaily && this.refreshTopBar();
			var lockData:Object = ModelGame.unlock('', modelTask.unlock_type);
			btn_get.gray = !model.onKeyGetActive || lockData.gray;
		}
		
		/**
		 * 服务器数据更新, 重新获取数据
		 */
		private function _onUpdateData(data:*):void {
			this._initData();
		}
				
		/**
		 * 格式化html字符串
		 * @param	html
		 * @param	value
		 * @param	need
		 * @return
		 */
		private function formatHtmlStr(html:String, value:int, source:*):String {return ''; }
		
		private function onSelect(index:int):void {
			if (this.list.selectedIndex != index) {
				this.list.selectedIndex = index;
			}
		}

		private function _onClickBtnGet():void {
			var lockData:Object = ModelGame.unlock('', modelTask.unlock_type);
			if (lockData.gray) {
				ViewManager.instance.showTipsTxt(lockData.text);
			} else if (!btn_get.gray) {
				modelTask._onceGetAll();
			}
		}
		
		override public function onRemove():void {
			super.onRemove();
			this.modelTask.off(ModelTaskBase.UPDATE_DATA, this, this._onUpdateData);
		}
	
	}

}