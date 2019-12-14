package sg.task.model
{
	import sg.manager.ModelManager;
	import sg.model.ModelOffice;
	import sg.task.TaskHelper;
	import sg.utils.StringUtil;
	import sg.utils.Tools;
	import sg.model.ModelUser;
	import sg.model.ModelCityBuild;
	
	/**
	 * ...
	 * @author jiaxuyang
	 */
	public class ModelTaskMain extends ModelTaskBase
	{
		
		// 单例
		private static var sModelTask:ModelTaskMain = null;
		
		public static function get instance():ModelTaskMain
		{
			return sModelTask ||= new ModelTaskMain();
		}
		
		public function ModelTaskMain()
		{
			super();
			this.type = ModelTaskBase.TASK_MAIN;
			this.chineseName = Tools.getMsgById('_jia0037');
			this._initTask();
		}
		
		override protected function _initTask():void
		{
			var obj:* = {};
			obj.task_id = null;
			obj.type = null;
			obj.name = null;
			obj.info = null;
			obj.value = 0;
			obj.need = null;
			obj.reward = null;
			obj.taskState = 0;	// 任务状态 0：未达成，1：未领取
			this.data = obj;
		}

		public function checkMainTaskReward():Boolean
		{
			return this.data['taskState'] === 1;
		}
		
		/**
		 * 刷新剧情任务
		 * @param	tem
		 */
		override public function refreshTaskData(tem:*):void
		{
			var cfg:* = this.getTaskConfig();
			var taskIndex:int = tem[0];	// 任务进度
			var taskProgress:int = tem[1];	// 任务完成度
			var task_id:String = "main_" + taskIndex;
			var taskObj:* = cfg[task_id];
			var obj:* = this.data;
			
			if (!taskObj) {
				
				// todo 主线任务全部完成
				obj.task_id = null;
				obj.type = null;
				obj.taskState = 0;
				TaskHelper.instance.refreshMainTask();
				return;
			}
			
			obj.task_id = task_id;
			obj.type = taskObj.type;
			obj.name = taskObj.name;
			obj.info = taskObj.info;
			obj.value = taskProgress;
			obj.need = taskObj.need;
			obj.goto_cfg = taskObj.goto_cfg;
			if (taskObj.need[0] is Array) { // 有三个对应的配置
				obj.need = taskObj.need[0];
			}
			obj.reward = taskObj.reward;
			if (obj.value >= obj.need[0])
			{
				obj.value = obj.need[0];
				obj.taskState = 1;	// 未领取
			}
			else
			{
				obj.taskState = 0;	// 未达成
				
			}
			// console.log('%c 主线任务进度变化， 索引：' + taskIndex + '  进度: ' + taskProgress,'color:green;font-size:16px');
			this.event(ModelTaskBase.UPDATE_DATA);
		}

		public function getCurrentID():String
		{
			return this.data['task_id'];
		}
		
		override public function getTaskData():* 
		{
			return this.data;
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
			var tempItem:*;
			var country:int = ModelUser.getCountryID();
			for (var i:int = 0, len:int = needArr.length; i < len; i++)
			{
				tempItem = needArr[i];
				//检测类型
				if (tempItem is Array && tempItem.length === 3 && (data.type === 'com_people' || data.type === 'mobile_hero' || data.type === 'ts_build')) {
					var cid:* = tempItem[country];
					if ((/^b\d+$/).test(cid)) { // ts_build 建筑
						newArr.push('[' + Tools.getMsgById(cid) + ']');
					}
					else {
						if (cid is Array) cid = cid[0];
						newArr.push('[' + Tools.getMsgById('c_' + cid) + ']'); // 城市
					}
				}
				else {
					item = String(needArr[i]);
					if ((/skill/).test(data.type)) { // 技能
						newArr.push(item);
					}
					else if ((/^building\d+$/).test(item)) { // 建筑
						newArr.push('[' + ModelManager.instance.modelInside.getBuildingModel(item).getName() + ']');
					}
					else if ((/^b\d+$/).test(item)) { // 建筑
						newArr.push('[' + Tools.getMsgById(item) + ']');
					}
					else {
						(/\d+/).test(item) && newArr.push('[' + Number(item.match(/\d+/)[0]) + ']');
					}
				}
			}
			var updateIndex:int = newArr.length - 1;
			switch (data.type){
				case 'get_office':
					newArr[updateIndex] = '[' + ModelOffice.getOfficeName(newArr[updateIndex].match(/\d+/)[0]) + ']';
					break;
				case 'learn_fskill':
					newArr[updateIndex] = '[' + ModelManager.instance.modelGame.getModelSkill(newArr[updateIndex]).getName() + ']';
					break;
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