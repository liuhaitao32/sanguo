package sg.activities.model
{
	import sg.model.ModelBase;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.utils.Tools;
	import laya.maths.MathUtil;
	import sg.cfg.ConfigColor;
	import sg.model.ModelHero;
	import sg.model.ModelAlert;

	/**
	 * ...
	 * @author
	 */
	public class ModelHappy extends ModelBase{
		
		public static const EVENT_UPDATE_SPARTA:String="event_update_sparta";//试炼进度发生变化		
		private static var sModel:ModelHappy = null;
		
		public static function get instance():ModelHappy
		{
			return sModel ||= new ModelHappy();
		}

		public var cfg:Object;
		public var tabData:Array=["login","sparta","purchase","addup","once"];

		public function ModelHappy(){
			cfg=ConfigServer.ploy.happy_buy;
		}

		/**
		 * 试炼标题
		 */
		public function getTaskProById(id:String,need:Array):String{
			var s:String="";
			switch(id){
				//case "hero_rarity":
				//	s=Tools.getMsgById("happy_"+id,[need[0],ModelHero.rarity_name[need[1]]]);
				//break;
				//case "equip_lv":
				//	s=Tools.getMsgById("happy_"+id,[need[0],ConfigColor.FONT_COLOR_STR[need[1]]]);
				//break;
				default:
					s=Tools.getMsgById("happy_"+id,need);
				break;
			}
			return s;
		}

		/**
		 * 获得新服试炼的任务列表
		 */
		public function getSpartaTaskByType(index:int):Array{
			var task:Object=cfg.sparta.task;
			var arr:Array=[];
			for(var s:String in task){
				var o:Object=task[s];
				if(o.index[0]==index+""){
					o["id"]=s;
					arr.push(o);
				}
			}
			arr.sort(MathUtil.sortByKey("index",false,true));
			return arr;
		}

		/**
		 * 活动结束时间
		 */
		public function get endTime():Number{
			var n:Number=ModelManager.instance.modelUser.gameServerStartTimer+7*Tools.oneDayMilli - ConfigServer.getServerTimer();
			return n;
		}

		/**
		 * 开服第几天
		 */
		public function get openDays():Number{
			return ModelManager.instance.modelUser.loginDateNum;
		}

		public function get userHappyLogin():Array{
			return ModelManager.instance.modelUser.records.happy_buy.login;
		}

		public function get userHappyAddup():Array{
			return ModelManager.instance.modelUser.records.happy_buy.addup;
		}

		public function get userHappyOnce():Array{
			return ModelManager.instance.modelUser.records.happy_buy.once;
		}
		
		public function get userHappyPurchase():Array{
			return ModelManager.instance.modelUser.records.happy_buy.purchase;
		}

		public function get userHappySparta():Object{
			return ModelManager.instance.modelUser.records.happy_buy.sparta;
		}

		/**
		 * 七日试炼的得分
		 */
		public function getSpartaScore():Number{
			var n:Number=0;
			var u_sparta:Object=this.userHappySparta;
			var c_sparta:Object=this.cfg.sparta.task;
			for(var s:String in u_sparta){
				var obj:Object=u_sparta[s];
				for(var os:String in obj){
					if(obj[os][0]>=c_sparta[s].target[Number(os)][0][0]){
						n+=1;
					}
				}
			}			
			return n;
		}

		/**
		 * 检测活动是否开启
		 */
		public function checkActive():Boolean{
			if(ConfigServer.ploy.happy_buy){
				return ModelAlert.red_happy_all() || this.openDays<=7;
			}
			return false;
		}

		/**
		 * 获得累计充值双倍积分的时间
		 */
		public function getDoubleTime():Number{
			var n:Number=0;
			var arr:Array=cfg.addup.double_days;
			var now:Number=ConfigServer.getServerTimer();
			if(arr){
				//开服时间
				var openTime:Number=Tools.getTimeStamp(ConfigServer.zone[""+ModelManager.instance.modelUser.zone][2]);
				n=Tools.gameDay0hourMs(openTime)+arr[0]*Tools.oneDayMilli;
				if(now>n) n=0;
				else n=n-now;
			}
			return n;
		}





	}

}