package sg.model
{
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.utils.Tools;
	import sg.utils.StringUtil;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;

	/**
	 * ...
	 * 朝廷密旨
	 * @author
	 */
	public class ModelNewTask extends ModelBase{
		

		public static const EVENT_NEW_TASK_UPDATE:String = "event_new_task_update";//领取奖励/刷新任务时派发
		public static const EVENT_TALK_TYPE_CHANGE:String = "event_talk_type_change";//对话类型发生变化

		public static const countryArr:Array = [Tools.getMsgById('country_0'),Tools.getMsgById('country_1'),Tools.getMsgById('country_2')];
		
		private var _talkType:int = 0;//0 初始化状态  1 可领奖  2 使用打点之后  3 领奖后  4 无任务时

		public function get talkType():int{
			return _talkType;
		}

		public function set talkType(n:int):void{
			if(_talkType != n){
				_talkType = n;
				this.event(EVENT_TALK_TYPE_CHANGE);
			}
		}

		public function ModelNewTask(){
			
		}

		/**
		 * 二次合服后开启
		 */
		public function isOpen():Boolean{
			if(ConfigServer.new_task){
				var n1:Number = ConfigServer.new_task["switch"] != null ?  ConfigServer.new_task["switch"] : -1;
				var n2:Number = ModelManager.instance.modelUser.mergeNum;
				return n1>=0 && n1 <= n2;
			}
			return false;
		}

		/**
		 * 获得任务数据
		 */
		public function getTaskData():Array{
			var arr:Array = [];
			var cfg:Object = ConfigServer.new_task;
			var num:Number = cfg.task_num[0] + cfg.task_num[1];
			var userData:Object = ModelManager.instance.modelUser.new_task.task_dict;
			var userNum:int = Tools.getDictLength(userData);
			for(var s:String in userData){
				var taskId:String = s;
				var task:Object = cfg.task_box1[taskId] ? cfg.task_box1[taskId] : cfg.task_box2[taskId];
				var _type:String = task["type"];
				var _need:Array = task["need"];

				var _season:Number = ModelManager.instance.modelUser.getGameSeason();
				
				var n:Number = userData[s][2]==-1 || userData[s][2]>=_need[0] ? _need[0] : userData[s][2];
				var countryName:String = userData[s][3]!=null ? (userData[s][3]=='all' ? Tools.getMsgById('new_task_text6') : countryArr[userData[s][3]]) : '';
				var countryName_info:String = userData[s][3]!=null ? (userData[s][3]=='all' ? Tools.getMsgById('new_task_text7') : countryArr[userData[s][3]]) : '';
				var _info:String = StringUtil.substituteWithColor(Tools.getMsgById(task['info'],['[('+n+'/'+_need[0]+')]',countryName_info]),'#E7B818','#abc9ff');
				
				var o:Object = {'id':taskId,
								'type':_type,
								'finish':userData[s][2]>=_need[0],
								'get':userData[s][2]==-1,
								'pro':userData[s][2],
								'name':Tools.getMsgById(task["name"],[countryName]),
								'reward':task["reward"][_season],
								'info':_info,
								'rarity':task["rarity"],
								'icon':task["icon"] ? 'bg_mz_gongji' : 'bg_mz_fangyu',
								'fast_finish':task["fast_finish"]};
				
				
				//if(userNum == num){
					if(o.get==false){
						arr.push(o);//只显示还没领过的
					}
				//}else{
				//	arr.push(o);
				//}
				
			}
			
			return arr;
		}

		/**
		 * 红点
		 */
		public function redPoint():Boolean{
			if(this.isOpen()){
				var a:Array = this.getTaskData();
				return a.length>0;
			}
			return false;
		}

		public function getNewTaskData():void{
			NetSocket.instance.send('get_new_task',{},new Handler(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				ModelManager.instance.modelGame.event(ModelNewTask.EVENT_NEW_TASK_UPDATE);
			}));
		}

	}



}