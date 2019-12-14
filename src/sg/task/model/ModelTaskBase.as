package sg.task.model
{
	import laya.events.Event;
	import laya.events.EventDispatcher;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.task.TaskHelper;
	import sg.utils.Tools;
	import sg.manager.ViewManager;
	import sg.utils.MusicManager;
	
	/**
	 * ...
	 * @author jiaxuyang
	 */
	public class ModelTaskBase extends EventDispatcher
	{
		public static const UPDATE_DATA:String = "update_data";	// 数据更新
		
		//任务类型
		public static const TASK_MAIN:String = "main";			//主线任务
		public static const TASK_DAILY:String = "daily";		//日常任务
		public static const TASK_COMMON:String = "common"; 		//普通任务
		public static const TASK_COUNTRY:String = "country"; 	//国家任务
		
		protected var data:Array = [];
		protected var type:String = null;
		public var unlock_type:String = '';
		public var chineseName:String = Tools.getMsgById('add_task');
		public var typeIndex:int = 0;
		
		/**
		 * 初始化任务数据和配置
		 */
		protected function _initTask():void {
			var cfg:* = this.getTaskConfig();
			var taskName:String = '';
			var obj:* = null;
			var tem:* = null;
			
			//根据用户数据，初始化英雄任务数据
			for (taskName in cfg) {
				tem = cfg[taskName];
				if (tem['index'].match(/\d/)[0] !== (this is ModelTaskTrain ? '2' : (this is ModelTaskBuild ? '3' : (this is ModelTaskOrder ? '4' : '5')))) {
					continue;
				}
				obj = {};
				obj.task_id = taskName;
				obj.type = tem.type;
				obj.name = tem.name;
				obj.info = tem.info;
				obj.explain = tem.explain_info;
				obj.value = 0;
				obj.index = Number(tem.index.substr(2));
				obj.task = tem.task;
				obj.taskState = 0;	// 任务状态 0：未达成，1：未领取，2：已领取
				this.data.push(obj);
			}
			this.data.sort(function(a:*, b:*):int
			{
				return a.index - b.index
			});
		}
		
		/**
		 * 检测任务是否已经全部结束
		 * @return
		 */
		public function isTaskOver():Boolean {
			for (var i:int = 0, len:int = this.data.length; i < len; i++) 
			{
				var obj:* = this.data[i];
				if (obj.taskState < 2)	return false;
			}
			return true;
		}
		
		/**
		 * 获取当前任务的状态信息
		 * @return
		 */
		public function getCurrentTaskState():int {
			if (this.data is Array) {
				return this.data[0].taskState;
			}
			else {
				return this.data.taskState;
			}
		}
		
		/**
		 * 获取info
		 * @param	infoId
		 * @return
		 */
		protected function getInfo(infoId:String):String {
			return Tools.getMsgById(infoId);
		}
		
		/**
		 * 根据任务数据获取HTML文本信息
		 * @param	data
		 */
		public function getHTMLByData(data:Object):String {return '';}
		
		/**
		 * 格式化html字符串
		 * @param	html
		 * @param	value
		 * @param	need
		 * @return
		 */
		protected function formatHtmlStr(html:String, data:*):String {return '';}
		/**
		 * 获取当前任务类型信息
		 * @return
		 */
		public function getSingleTaskConfig(taskID:String):Object {
			return this.getTaskConfig()[taskID];
		}
		
		/**
		 * 获取当前任务描述信息
		 * @return
		 */
		public function getCurrentTaskInfo():String {return '';}
		
		/**
		 * 任务进度改变，刷新任务数据
		 * @param	data
		 */		
		public function refreshTaskData(tem:*):void
		{
			for each (var item:* in this.data) 
			{
				var taskIndex:int = tem[item.task_id][0];	// 任务进度
				var taskProgress:int = tem[item.task_id][1];	// 任务完成度
				var task:* = item.task[taskIndex];
				if (!task) {
					task = item.task[taskIndex - 1]
					item.value = -1;
				}
				else {
					item.value = taskProgress;
				}
				item.need = task.need;
				item.reward = task.reward;
				item.value === -1 && (item.taskState = 2); // 已领取
				var total:int = item.need[0];
				if (item.value >= total || item.value === -1)
				{
					item.value = total;
					item.taskState === 0 && (item.taskState = 1); // 可领取
				}
				else {
					item.taskState = 0;
				}
			}
			
			this.event(ModelTaskBase.UPDATE_DATA);
		}
	
		/**
		 * 获取任务的配置信息
		 * @return
		 */
		public function getTaskConfig():* {
			return ConfigServer.task[this.type];
		}
		
		/**
		 * 获取任务数据
		 * @return
		 */
		public function getTaskData():*
		{
			var data:Array = [];
			var currentLv:int = ModelManager.instance.modelUser.getLv();
			
			for (var i:int = 0, len:int = this.data.length; i < len; i++) {
				var singleData:* = this.data[i];
				if (singleData.unlock_level && singleData.unlock_level > currentLv)
				{ // 等级解锁制
					continue;
				}
				data.push(singleData);
			}
			data = this.sortData(data);
			return data;
		}
		
		/**
		 * 对任务数据进行排序，(未领取、未完成、已领取)
		 * @param	data
		 * @return
		 */
		protected function sortData(data: Array):Array {
			var canReceivedArr:Array = [];
			var alreadyReceivedArr:Array = [];
			var others:Array = [];
			
			for each (var item:* in data) {
				if (item.taskState === 2) alreadyReceivedArr.push(item);
				else if (canReward(item)) canReceivedArr.push(item);
				else others.push(item);
			}
			return canReceivedArr.concat(others, alreadyReceivedArr);
		}
		
		/**
		 * 获取第一个可领取奖励的任务数据
		 * @return
		 */
		public function getFirstData():Object {
			var data:Object = this.data is Array ? this.getTaskData()[0] : this.data;
			return data;
		}

		public function redCheck():Boolean {
			return canReward(this.getFirstData());
		}

		protected function canReward(item:Object):Boolean {
			return item && unlocked(item) && item.taskState === 1;
		}

		protected function unlocked(item:Object):Boolean {
			if (item && item.unlock_level && ModelManager.instance.modelUser.getLv() < item.unlock_level) {
				return false;
			}
			return true;
		}
		
		/**
		 * 领奖
		 * @param	kind
		 * @param	task_id
		 * @param	gift_dict
		 */
		public function getTaskReward(kind:String, task_id:String, gift_dict:*):void {
			this.event(TaskHelper.GET_REWARD, {kind:kind, task_id:task_id, gift_dict: gift_dict});
		}

		public function get onKeyGetActive():Boolean {
			return this.data.some(canReward, this);
		}
		
		/**
		 * 点击一键获取
		 * @param	event
		 */
		public function _onceGetAll():void {
			var gift_dict:Array = [];
			for (var i:int = 0, len:int = data.length; i < len; i++) {
				if (canReward(data[i])) {
					gift_dict.push(this.data[i].reward);
				}
			}
			if (this is ModelTaskDaily) {
				this.event(TaskHelper.GET_REWARD, {kind:ModelTaskBase.TASK_DAILY, gift_dict: gift_dict});
			}
			else if (this.type === ModelTaskBase.TASK_COMMON) {
				this.event(TaskHelper.GET_REWARD, {kind:ModelTaskBase.TASK_COMMON, task_id: 'index' + this.typeIndex, gift_dict: gift_dict});
			}
		}
	}

}