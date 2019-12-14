package sg.task.model 
{
	import sg.cfg.ConfigColor;
	import sg.model.ModelHero;
	import sg.utils.StringUtil;
	import sg.utils.Tools;
	/**
	 * ...
	 * @author jiaxuyang
	 */
	public class ModelTaskTrain extends ModelTaskBase 
	{
		
		// 单例
		private static var sModelTask:ModelTaskTrain = null;
		public  static function get instance():ModelTaskTrain{
			return sModelTask ||= new ModelTaskTrain();
		}
		
		public function ModelTaskTrain() 
		{
			super();
			this.type = ModelTaskBase.TASK_COMMON;
			this.unlock_type = 'easy_get_train';
			this.chineseName = Tools.getMsgById('_jia0027');
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
			if(!needArr){
				return "";
			}
			var i:int = 0;
			var len:int = 0;
			var index:int = 0;
			var result:Array = null;
			switch (data.type)
			{
			case "equip_quality": // 宝物品质 
			case "mag_quality":	  // 神兵品质
			case "mount_quality": // 坐骑品质
				result = html.match(/{(\d+)}/);
				index = (result && result.length >= 2) ? result[1] : 1;
				html = html.replace('{' + index + '}', '[' + Tools.getColorInfo(needArr[index]) + ']');
				break;
			case "hero_quality": // 英雄品质
				result = html.match(/{(\d+)}/);
				index = (result && result.length >= 2) ? result[1] : 1;
				var starNum:int = needArr[index];
				html = html.replace('{' + index + '}', '[' + ModelHero.getHeroStarColorName(starNum) + (starNum % 6) + ']');
				break;
			case "have_hero": // 英雄数量
				var heroArr:Array = needArr[1];
				var nameArr:Array = [];
				for (i = 0, len = heroArr.length; i < len; i++) 
				{
					nameArr.push(ModelHero.rarity_name[heroArr[i]]);
				}
				
				html = StringUtil.substitute(html,'[' + needArr[0] + ']', '[' + nameArr.join(Tools.getMsgById('_jia0140')) + ']');
				break;
			default:
				var newArr:Array = [];
				var item:String = '';
				for (i = 0, len = needArr.length; i < len; i++) {
					item = String(needArr[i]);
					(/\d+/).test(item) && newArr.push('[' + Number(item.match(/\d+/)[0]) + ']');
				}
				html = StringUtil.substitute(html, newArr);
				break;
			}
			html += StringUtil.substitute("[({0}/{1})]", value, needArr[0]);
			return StringUtil.substituteWithColor(html, value >= needArr[0] ? '#5ff9a0': '#E7B818');
		}
	}

}