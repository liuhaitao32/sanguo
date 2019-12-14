package sg.task.model
{
	import sg.utils.StringUtil;
	import sg.utils.Tools;
	import sg.utils.ObjectUtil;
	import sg.task.TaskHelper;
	
	/**
	 * ...
	 * @author jiaxuyang
	 */
	public class ModelTaskDaily extends ModelTaskBase
	{		
		// 单例
		private static var sModelTask:ModelTaskDaily = null;
		
		public static function get instance():ModelTaskDaily
		{
			return sModelTask ||= new ModelTaskDaily();
		}
		
		public function ModelTaskDaily()
		{
			super();
			this.type = ModelTaskBase.TASK_DAILY;
			this.unlock_type = 'easy_get_daily';
			this.chineseName = Tools.getMsgById('_jia0026');
			this._initTask();
		}
		
		override protected function _initTask():void
		{
			var cfg:* = this.getTaskConfig();
			var taskName:String = '';
			var obj:* = null;
			var tem:* = null;
			
			for (taskName in cfg) {
				obj = ObjectUtil.clone(cfg[taskName]);
				obj.task_id = taskName;
				obj.value = 0;
				obj.index = Number(obj.index.substr(2));
				obj.taskState = 0;	// 任务状态 0：未达成，1：未领取，2：已领取
				this.data.push(obj);
			}
			this.data.sort(function(a:*, b:*):int { return a.index - b.index });
		}
		
		override public function getHTMLByData(data:Object):String 
		{
			var html:String = this.formatHtmlStr(this.getInfo(data.info), data);
			return html;
		}
		
		override protected function formatHtmlStr(html:String, data:*):String {
			var value:int = data.value;
			var progressStr:String = StringUtil.substitute("({0}/{1})", value, data.need[0]);
			html = StringUtil.substitute(html, '[' + progressStr + ']');
			return StringUtil.substituteWithColor(html, value >= data.need[0] ? '#5ff9a0': '#ff973b');
		}
		
		override public function refreshTaskData(tem:*):void {
			var item:* = null;
			var cfg:* = this.getTaskConfig();
			for (var name:String in cfg)
			{
				var index:int = parseInt(cfg[name].index.substr(2));
				item = this.data[index];
				item.value = tem[name] is Number ? tem[name] : 0;
				item.taskState = 0;
				item.value === -1 && (item.taskState = 2); // 已领取
				var total:int = item.need[0];
				if (item.value >= total || item.value === -1)
				{
					item.value = total;
					item.taskState === 0 && (item.taskState = 1); // 可领取
				}
			}
			this.event(ModelTaskBase.UPDATE_DATA);
		}
		
		private function _onGetAll():void {
			for each (var item:* in this.data) {
				if (item.taskState === 1) {
					item.taskState = 2;
				}
			}
			this.event(ModelTaskBase.UPDATE_DATA);
		}
		
		/**
		 * 获取已完成任务个数
		 */
		public function getFinishedNum():int {
			return getTaskData().filter(function(item:*):Boolean {
				return unlocked(item) && item.taskState > 0;
			}).length;
		}	
	}
}