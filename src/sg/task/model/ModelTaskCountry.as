package sg.task.model
{	
	import sg.utils.ObjectUtil;
	import sg.cfg.ConfigServer;
	import sg.model.ModelUser;
	import sg.model.ModelCityBuild;

	/**
	 * ...
	 * @author jiaxuyang
	 */
	public class ModelTaskCountry extends ModelTaskBase
	{
		
		// 单例
		private static var sModelTask:ModelTaskCountry = null;
		public var currentTaskIndex:int = 1;
		public var rewardIndex:int = 1;
		public var miracleArr:Array = [];
		public var allFinished:Boolean = false;
		
		public static function get instance():ModelTaskCountry
		{
			return sModelTask ||= new ModelTaskCountry();
		}
		
		public function ModelTaskCountry()
		{
			super();
			this.type = ModelTaskBase.TASK_COUNTRY;
			this._initTask();
		}

		private function getBuildPrecondition():Object
		{
			var obj:Object = {};
			var buildall:Object = ConfigServer.city_build['buildall'];
			for(var key:String in buildall)
			{
				var element:Object = buildall[key];
				var index:int = element['precondition']['country_task'];
				index && (obj['country_' + index] = key);
			}
			return obj;
		}

		override protected function _initTask():void {
			var cfg:* = this.getTaskConfig();
			var taskName:String = '';
			var obj:* = null;
			var tem:* = null;
			var precondition:* = this.getBuildPrecondition();
			
			//根据用户数据，初始化英雄任务数据
			for (taskName in cfg)
			{
				tem = cfg[taskName];
				obj = ObjectUtil.clone(tem);
				obj.task_id = taskName;
				obj.value = 0;
				obj.index = Number(tem.index.substr(2));
				obj.taskState = 0;	// 任务状态 0：未达成，1：未领取，2：已领取
				this.data.push(obj);
				if (precondition[taskName]) {
					obj['precondition'] = precondition[taskName];
				}
				if (obj.miracle_info) {
					this.miracleArr.push(parseInt(taskName.match(/\d+/)[0]));
				}
			}
			this.data.sort(function(a:*, b:*):int
			{
				return a.index - b.index;
			});
			this.miracleArr.sort(function(a:*, b:*):int
			{
				return a - b;
			});		
		}
		
		/**
		 * 刷新国家任务
		 * @param	task
		 */
		override public function refreshTaskData(task:*):void
		{
			var cfg:* = this.getTaskConfig();
			var task_person:* = task['country'];
			var task_country:* = task['country_task'];
			if (!task_country)	return;
			var taskNum:int = ObjectUtil.keys(cfg).length;
			allFinished = task_person[0] === -1 && task_country[0] === -1;
			if (task_person[0] === -1) { // 所有任务个人的部分已完成
				task_person[0] = taskNum;
			}
			if (task_country[0] === -1) {// 所有任务中国家的部分已完成
				task_country[0] = taskNum;
			}
			currentTaskIndex = Math.min(task_person[0], task_country[0]); // 任务进度
			rewardIndex = task_person[2];	// 领奖进度
			var taskProgress:int = task_person[0] === currentTaskIndex ? task_person[1] : task_country[1];	// 任务完成度
			var task_id:String = "country_" + currentTaskIndex;
			var currentTask:* = cfg[task_id];
			var dataArr:Array = this.data;

			// 更新当前任务进度
			if (currentTask) {
				currentTask.value = taskProgress;
				dataArr[currentTaskIndex - 1].value = taskProgress;
				// console.log('%c 国家任务进度变化， 索引：' + taskIndex + '  进度: ' + taskProgress,'color:green;font-size:16px');
			}
			
			// 更新任务状态
			for(var i:int = 1; i < currentTaskIndex; i++)
			{
				var element:Object = dataArr[i - 1];
				element.value = element.need[0];
				element.taskState = (i < rewardIndex) ? 2 : 1;
			}
			this.event(ModelTaskBase.UPDATE_DATA);
		}
		
		/**
		 * 获取任务数据
		 */
		override public function getTaskData():* {
			return this.data;
		}
		
		/**
		 * 获取任务数据
		 */
		override public function redCheck():Boolean {
			return this.currentTaskIndex > this.rewardIndex;
		}
		
		/**
		 * 获取任务数据
		 */
		public function get needGuide():Boolean {
			return this.rewardIndex <= 1;
		}
		
		/**
		 * 获取城市Id数组
		 */
		public function getCityArray(index:int):Array {
			var taskData:* = this.getTaskData()[index - 1];
			var tempArr:Array = taskData['need'][1];
			var country:int = ModelUser.getCountryID();
			var i:int = 0;
			var len:int = 0;
			var cityArr:Array = null;

			// 城市建设
			if (tempArr is Array && tempArr.length === 3) {
				cityArr = tempArr[country];	// 获取城市数组
				if (cityArr is Array) cityArr = ObjectUtil.clone(cityArr) as Array;
				else cityArr = [cityArr];
			}

			// 国家建设
			if (taskData['type'] === 'country_build') {
				var bId:String = taskData['need'][2];
				cityArr = ModelCityBuild.getCityArrById(bId);
			}
			return cityArr || [];
		}
		
		/**
		 * 获取国家任务中需要建造的建筑
		 * @param	cId 城市ID
		 * @return Array eg: ['b01', 'b02']
		 */
		public static function getTaskBuild(cId:int):Array {
			if (cId is String && cId['length']) cId = +cId;
			else if (!cId is Number) return [];
			var self:ModelTaskCountry = ModelTaskCountry.instance;
			var data:Object = self.getTaskData()[self.currentTaskIndex - 1];
			if (!data)	return []; // 当前没国家任务
			var needArr:Array = data['need'];
			var type:String = data['type'];
			var buildArr:Array = [];
			buildArr = buildArr.concat(needArr[2]);
			if (!buildArr.length) return [];

			var cityArr:Array = self.getCityArray(self.currentTaskIndex);
			cityArr = cityArr.map(function(item:*):int{return +item});
			if (cityArr.indexOf(cId) === -1) return [];

			var needValue:int = type === 'country_build' ? needArr[1] : (type === 'city_build_up' ? needArr[3] : 1);
			return buildArr.filter(function(bId:String):Boolean { return ModelCityBuild.getBuildLv(String(cId), bId) < needValue });
		}
	}

}