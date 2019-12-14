package sg.achievement.model
{
    import laya.events.EventDispatcher;
    import laya.utils.Handler;

    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;
    import sg.manager.ViewManager;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.net.NetSocket;
    import sg.map.utils.ArrayUtils;
    import sg.utils.Tools;

    public class ModelAchievement extends EventDispatcher
    {
		public static const UPDATE_DATA:String = "update_data";	// 数据更新

        private var cfg:Object;
        private var efforts:Array;
        public var effortsProgress:Array = [];
        private var hasNew:Boolean = false;
        private var tabLabels:Array;

		// 单例
		public static var sModelAchievementr:ModelAchievement = null;
		
		public static function get instance():ModelAchievement {
			return sModelAchievementr ||= new ModelAchievement();
		}
		public static function clear():void{
            sModelAchievementr.clearEvents();
            sModelAchievementr = null;
        }
        public function ModelAchievement() {

        }

        public function initModelAchievement():void {
            this.efforts = [[], [], [], []];
            this.cfg = ConfigServer.effort;
            this.tabLabels = [
                {name: Tools.getMsgById('_jia0040'), progress: '(0/0)', flag: 0}, 
                {name: Tools.getMsgById('_jia0041'), progress: '(0/0)', flag: 0}, 
                {name: Tools.getMsgById('_jia0042'), progress: '(0/0)', flag: 0}, 
                {name: Tools.getMsgById('_jia0043'), progress: '(0)', flag: 0}
            ];

            // 读取配置
            for(var key:String in cfg) {
                if (!key.match(/ach/))  continue;
                var element:Object = cfg[key];
                var results:Array = element.index.match(/(\d)_(\d+)/);
                var index:int = parseInt(results[1]);
                if (index < 3) {
                    var obj:Object = {
                        id: key,
                        type: index,
                        time: 0,
                        state: 0
                    };
                    this.efforts[index].push(obj);
                }
            }            
            this.refreshData(ModelManager.instance.modelUser.effort);
        }

        /**
         * 刷新成就数据
         * efforts 从服务器获得的成就数据
         */
        public function refreshData(efforts:*):void {
            var tempArr:Array = [0, 0, 0, 0];
            this.hasNew = false;
            for(var i:int = 0; i < 4; i++)
            {
                this.tabLabels[i].flag = 0;
            }

            for(var key:String in efforts) {
                var effort:Object = efforts[key];
                
                // 刷新单个成就数据
                i = this.getIndexById(key);
                var array:Array = this.efforts[i];
                var tempEffort:* = this.getEffortById(array, key);
                if (tempEffort) {
                    tempEffort.time = Tools.getTimeStamp(effort[0]);
                    tempEffort.state = effort[1] + 1;
                }
                else if (tempEffort === null) {
                    tempEffort = {
                        id: key,
                        type: 3,
                        time: Tools.getTimeStamp(effort[0]),
                        state: effort[1] + 1
                    };
                    array.push(tempEffort);
                }
                tempArr[i]++;
                this.tabLabels[i].flag || (tempEffort.state === 1) && (this.tabLabels[i].flag = 1);
                this.hasNew || (tempEffort.state === 1) && (this.hasNew = true);
                this.hasNew && ModelManager.instance.modelInside.updateBaseBuilding();
            }

            // 排序
            var len:int = this.efforts.length
            for(i = 0; i < len; i++)
            {
                var achieves:Array = this.efforts[i];
                achieves.sort(function(a:*, b:*):Boolean { return b.time - a.time;});
                achieves.forEach(function(item:Object, index:int):void {item['index'] = index;});
            }
            this.tabLabels[0].progress = tempArr[0] + '/' + this.efforts[0].length;
            this.tabLabels[1].progress = tempArr[1] + '/' + this.efforts[1].length;
            this.tabLabels[2].progress = tempArr[2] + '/' + this.efforts[2].length;
            this.tabLabels[3].progress = tempArr[3];

            // 刷新界面
			this.event(ModelAchievement.UPDATE_DATA);
        }

        public function getEffortsByIndex(index:int):Array {
            return this.efforts[index];
        }

        /**
         * 根据ID获取曾就主索引（类别）
         */
        private function getIndexById(id:String):int {
            return parseInt(this.cfg[id]['index'].match(/\d/)[0]);
        }
        
        /**
         * 根据id获取成就的本地数据
         */
        private function getEffortById(array:Array, id:String):* {
            var len:int = array.length
            for(var index:int = 0; index < len; index++)
            {
                var element:Object = array[index];
                if (element.id === id)  return element;
            }
            return null;
        }

        /**
         * 根据id获取成就的配置数据
         */
        public function getEffortConfigById(id:String):* {
            return this.cfg[id];
        }

        public function getTabLabels():Array {
            return this.tabLabels;
        }

        /**
         * 检测是否存在未领奖史册
         */
        public function hasNewAchieve():Boolean {
            return this.hasNew;
        }

        /**
         * 领奖
         * effortId 成就ID
         */
        public function getReward(effortId:String):void
        {

			//领取奖励，告知服务器
			NetSocket.instance.send(NetMethodCfg.WS_SR_GET_EFFORT_REWARD, {'effort_id': effortId}, Handler.create(this, this.getRewardCB), this.getEffortConfigById(effortId)['reward']);
		}
		
		/**
		 * 领奖的回调
		 * @param	re
		 */
		private function getRewardCB(re:NetPackage):void
		{
			var gift_dict:* = re.otherData;
			ModelManager.instance.modelUser.updateData(re.receiveData);
			
			ViewManager.instance.showRewardPanel(gift_dict);
            ModelManager.instance.modelInside.updateBaseBuilding();
		}

        /**
         * 是否完成这个成就
         */
        public static function isGetAchi(eid:String):Boolean{
            var arr:Array=ModelManager.instance.modelUser.effort[eid];
            if(arr && arr[1]==1){
                return true;
            }
            return false;
        }

        public static function getAchiAddNum(arr:Array):Number{
            var n:Number=0;
            if(arr){
                for(var i:int=0;i<arr.length;i++){
                    if(ModelAchievement.isGetAchi(arr[i][0])){
                        n+=arr[i][1];
                    }
                }
            }
            
            return n;
        }
    }
}