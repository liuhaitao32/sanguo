package sg.task.model
{
	import sg.utils.StringUtil;
	import sg.utils.Tools;
	
	/**
	 * ...
	 * @author jiaxuyang
	 */
	public class ModelTaskOrder extends ModelTaskBase
	{
		
		// 单例
		private static var sModelTask:ModelTaskOrder = null;
		
		public static function get instance():ModelTaskOrder
		{
			return sModelTask ||= new ModelTaskOrder();
		}
		
		public function ModelTaskOrder()
		{
			super();
			this.type = ModelTaskBase.TASK_COMMON;
			this.unlock_type = 'easy_get_order';
			this.chineseName = Tools.getMsgById('_jia0029');
			this._initTask();
		}
		
		override public function getHTMLByData(data:Object):String
		{
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
			var updateIndex:int = 2;
			switch (data.type){
				case 'com_sand':
					var chapter:int = newArr[updateIndex].match(/\d+/)[0];
					chapter = chapter % 12;
					chapter ||= 12;
					newArr[updateIndex] = '[' + chapter + ']';
					break;
			}
			html = StringUtil.substitute(html, newArr);
			html += StringUtil.substitute("[({0}/{1})]", value, needArr[0]);
			return StringUtil.substituteWithColor(html, value >= needArr[0] ? '#5ff9a0': '#E7B818');
		}
	}

}