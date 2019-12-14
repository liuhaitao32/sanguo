package sg.task.model 
{
	import sg.utils.StringUtil;
	import sg.utils.Tools;
	/**
	 * ...
	 * @author jiaxuyang
	 */
	public class ModelTaskBuild extends ModelTaskBase 
	{
		
		// 单例
		private static var sModelTask:ModelTaskBuild = null;
		public  static function get instance():ModelTaskBuild{
			return sModelTask ||= new ModelTaskBuild();
		}
		
		public function ModelTaskBuild() 
		{
			super();
			this.type = ModelTaskBase.TASK_COMMON;
			this.unlock_type = 'easy_get_build';
			this.chineseName = Tools.getMsgById('_jia0028');
			this._initTask();
		}
		
		override public function getHTMLByData(data:Object):String {
			var html:String = this.formatHtmlStr(this.getInfo(data.info), data);
			return html;
		}
		
		override protected function formatHtmlStr(html:String, data:*):String
		{
			var value:int = data.value;
			var needArr:Array = data.need;
			var newArr:Array = [];
			var item:String = '';
			for (var i:int = 0, len:int = needArr.length; i < len; i++)
			{
				item = String(needArr[i]);
				(/\d+/).test(item) && newArr.push('[' + Number(item.match(/\d+/)[0]) + ']');
			}
			html = StringUtil.substitute(html, newArr);
			html += StringUtil.substitute("[({0}/{1})]", value, needArr[0]);
			return StringUtil.substituteWithColor(html, value >= needArr[0] ? '#5ff9a0': '#E7B818');
		}
	}

}