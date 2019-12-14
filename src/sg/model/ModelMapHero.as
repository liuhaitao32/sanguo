package sg.model
{
	import sg.manager.ModelManager;
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;

	/**
	 * ...
	 * @author
	 */
	public class ModelMapHero extends ModelBase{

		public static var icon_arr:Object={gold:"ui/icon_paopao27.png",
											food:"ui/icon_paopao20.png",
											wood:"ui/icon_paopao22.png",
											iron:"ui/icon_paopao23.png",
											hero:"ui/icon_paopao24.png",
											build:"ui/icon_paopao21.png",
											visit:"ui/icon_paopao25.png"};

		private var work_type:int;//工作类型   0 产业挂机   1 拜访   2 建造
		private var _event_id:String;//事件id
		public var hid:String;//英雄id
		private var cid:String;//城市id
		private var rid:String;//奖励id 用来显示头顶的图标（暂时不知道用不用）
		private var time:*;//完成时间
		//private var total_times:Number=0;//每日可进行次数
		//private var cur_times:Number=0;//今日已进行次数
		private var _is_finish:Boolean=false;

		
		private var estate_index:int;//_other_para
		public var visit_hid:String;//_other_para
		private var bid:String;//_other_para

		//private var userModel:ModelUser;
		private var user_data:*;
		private var _status:Number;
		public var is_send_event:Boolean=false;

		public function ModelMapHero(_work_type:int,_other_para:*){
			initData(_work_type,_other_para);
		}
		
		public function initData(_work_type:int,_other_para:*):void{
			is_send_event=false;
			//total_times=-1;
			//cur_times=0;
			work_type=_work_type;
			if(work_type==0){
				estate_index=_other_para;
				user_data=ModelManager.instance.modelUser.estate[estate_index];
				hid=user_data.active_hid;
				cid=user_data.city_id;
				var estate_id:String=ConfigServer.city[user_data.city_id].estate[user_data.estate_index][0];
				if(estate_id == "6"){
					rid = "hero";
				}else{
					rid=ConfigServer.estate.estate[estate_id].produce;
				}
				time=user_data.active_harvest_time;
				//event_id=user_data.event?user_data.event:"";
				//total_times=ConfigServer.estate.frequency;
				//cur_times=Tools.isNewDay(user_data.active_time)?0:user_data.active_times;
			}else if(work_type==1){
				cid=_other_para;
				user_data=ModelManager.instance.modelUser.visit[cid];
				hid=user_data[0];
				rid="visit";
				visit_hid=user_data[1];
				time=user_data[2];
				//event_id=user_data[3]?user_data[3]:"";
			}else if(work_type==2){
				bid=_other_para.bid;
				cid=_other_para.cid;
				user_data=ModelManager.instance.modelUser.city_build[cid][bid];
				hid=user_data?user_data[0]:"";
				time=user_data?user_data[1]:0;
				//event_id=user_data[2]?user_data[2]:"";
				rid="build";
			}
		}


		/**
		 * 是否完成
		 */
		public function get isFinish():Boolean{
			switch(work_type){
				case 0:
					_is_finish=ModelManager.instance.modelUser.isEstateFinish(this.estate_index);
				break;
				case 1:
					_is_finish=ModelManager.instance.modelUser.isVisitFinish(this.cid);
				break;
				case 2:
					_is_finish=ModelManager.instance.modelUser.isCityBuildFinish({cid:this.cid,bid:this.bid});
				break;
			}
			return _is_finish;
		}

		/**
		 * 获得工作名字
		 */
		public function getWorkName():String{
			var s:String="";
			switch(work_type){
				case 0:
					var user_estate:Object=ModelManager.instance.modelUser.estate[estate_index];
					var estate_id:String = ConfigServer.city[user_estate.city_id].estate[user_estate.estate_index][0];
					s=Tools.getMsgById(ConfigServer.estate.estate[estate_id].active_name);
					break;
				case 1:
					s=Tools.getMsgById("_visit_text01")//"拜访";
					break;
				case 2:
					s=Tools.getMsgById("_city_build_text01")//"建造";
					break;
			}

			return s;
		}

		/**
		 * 获得距离完成时间
		 */
		public function getTimeDis():Number{
			var now:Number=ConfigServer.getServerTimer();
			var t:Number=Tools.getTimeStamp(this.time);
			if(now>t)
				return 0;
			else
				return t-now;
		}

		public function getTime():Number{
			return Tools.getTimeStamp(this.time);
		}


		/**
		 * 获得事件id  空字符串表示没有事件
		 */
		public function get event_id():String{
			switch(work_type){
				case 0:
					user_data=ModelManager.instance.modelUser.estate[estate_index];
					_event_id=user_data.event?user_data.event:"";
					break;
				case 1:
					user_data=ModelManager.instance.modelUser.visit[cid];
					_event_id=user_data[3]?user_data[3]:"";
					break;
				case 2:
					user_data=ModelManager.instance.modelUser.city_build[cid][bid];
					_event_id=(user_data && user_data[2])?user_data[2]:"";
					break;
				
			}
			return _event_id;
		}

		/**
		 * 英雄状态 可收获/不可收获
		 */
		public function get status():Number{
			if(isFinish){
				_status=0;
			}else{
				_status=1;
			}
			return _status;
		}


		public function getRidURL():String{
			return ModelMapHero.icon_arr[this.rid];
		}

	}

}