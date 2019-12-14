package sg.model
{
	import sg.manager.ModelManager;
	import sg.utils.Tools;
	import sg.cfg.ConfigServer;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.view.map.ViewEstateHeroInfo;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.view.map.ViewEventTalk;
	import sg.achievement.model.ModelAchievement;

	/**
	 * ...
	 * @author
	 */
	public class ModelVisit extends ModelBase{//拜访
		
		public static var EVENT_UPDATE_VISIT:String="event_update_visit";
		public static var EVENT_REMOVE_VISIT:String="event_remove_visit";	
		public static var visitModels:Object={};
		//private var user_visit:Object=ModelManager.instance.modelUser.visit;

		public var visit_hid:String;//被拜访的英雄id
		public var city_id:String;
		public function get total_time():Number{
			var n:Number=ConfigServer.visit.frequency+ModelAchievement.getAchiAddNum(ConfigServer.visit.effort_add);
			//if(ConfigServer.visit.effort_add){
			//	if(ModelAchievement.isGetAchi(ConfigServer.visit.effort_add[0])){
			//		n+=ConfigServer.visit.effort_add[1];
			//	}
			//}
			return n;//总的拜访次数  //成就(视财如命)
		};
		
		private var _cur_time:int=0;//今日拜访次数
		private var _event_id:String;//拜访时发生的事件id
		private var _hid:String;//
		private var _status:int;//当前状态
		private var _mapHero:ModelMapHero;
		private var _showObj:Object;
		public var nextTime:Number;
		public var isSendMSG:Boolean=false;
		public static const EVENT_INIT_VISIT:String = "eventInitVisit";
		public var cleared:Boolean=false;

		public function ModelVisit(cid:String,city_hid:String){
			this.initData(cid,city_hid);
		}

		public function initData(cid:String,city_hid:String):void{
			this.visit_hid=city_hid;
			this.city_id=cid;
		}


		public static function updateData(cid:String):void{
			if(ModelVisit.visitModels.hasOwnProperty(cid)){
				var vmd:ModelVisit=ModelVisit.visitModels[cid];
				vmd.event(ModelVisit.EVENT_UPDATE_VISIT);
				//trace("==================visit更新",vmd);
			}
		}

		/**
		 * 获得 前去拜访的英雄id
		 */
		public function get hid():String{
			_hid="";
			if(ModelManager.instance.modelUser.visit.hasOwnProperty(this.city_id)){
				var arr:Array=ModelManager.instance.modelUser.visit[this.city_id];
				_hid=arr[0]?arr[0]:"";
			}			
			return _hid;
		}

		/**
		 * 获得 拜访发生的事件
		 */
		public function get event_id():String{
			_event_id="";
			if(ModelManager.instance.modelUser.visit.hasOwnProperty(this.city_id)){
				var arr:Array=ModelManager.instance.modelUser.visit[this.city_id];
				_event_id=arr[3]?arr[3]:"";
			}			
			return _event_id;
		}

		/**
		 * 拜访是否完成
		 */
		public function isFinish():Boolean{
			if(ModelManager.instance.modelUser.visit.hasOwnProperty(this.city_id)){
				var arr:Array=ModelManager.instance.modelUser.visit[this.city_id];
				var n:Number=Tools.getTimeStamp(arr[2]);
				if(ConfigServer.getServerTimer()>=n){
					return true;
				}
			}			
			return false;
		}


		/**
		 * 获得今日已拜访次数
		 */
		public function get cur_time():Number{
			_cur_time=0;
			if(ModelManager.instance.modelUser.visit.hasOwnProperty(this.city_id)){
				var arr:Array=ModelManager.instance.modelUser.visit[this.city_id];
				_cur_time=Tools.isNewDay(arr[4])?0:arr[5];
			}
			return _cur_time;
		}

		public function getNextTime():Number{

			return nextTime;
		}
		
		public function get visitHero():ModelMapHero{
			if(status==0 || status==3){
				_mapHero ||= new ModelMapHero(1,this.city_id);
			}
			return _mapHero;
		}

		public function get showObj():Object{
			if(status==0 || status==3){
				_showObj = {hid:visitHero.hid, rid:this.visitHero.getRidURL(), "event":this.event_id!="", finish:this.isFinish()};
				//_showObj = {hid:"hero701", rid:"", "event":false, finish:false};
			}
			return _showObj;
		}


		/**
		 * 获得当前状态
		 */
		public function get status():Number{
			if(!cleared && hid!=""){
				if(ModelOfficial.visit.hasOwnProperty(this.city_id)){
					_status=0;//拜访中
				}else{
					_status=3;//前一日的拜访
				}
			}else{
				if(cur_time<total_time){
					_status=1;//可拜访
				}else{
					_status=2;//不可拜访
				}
			}
			return _status;
		}
		

		public function click():void{
			if(ModelGame.unlock(null,"map_visit",true).stop){
				return;
			}
			if(!ModelManager.instance.modelUser.isFinishFtask(this.city_id)){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_ftask_tips01"));
				return;
			}
			if(status==0 || status==3){
				if(this.event_id!=""){
					var arr:Array=[this.event_id,1,this.city_id];
					ViewManager.instance.showView(["ViewEventTalk",ViewEventTalk],arr);
				}else if(isFinish()){//拜访完成
					var sendData:Object={};
					sendData["city_id"]=this.city_id;
					NetSocket.instance.send("hero_city_visit_reward",sendData,new Handler(this,function(np:NetPackage):void{
						showFinishView(np);
						ModelManager.instance.modelUser.updateData(np.receiveData);
					}));
				}else{//拜访中
					ViewManager.instance.showView(["ViewEstateHeroInfo",ViewEstateHeroInfo],[1,this.city_id,this.city_id]);
				}
			}else if(status==1){
				if(ModelOfficial.checkCityIsMyCountry(city_id)){
					ViewManager.instance.showView(ConfigClass.VIEW_ESTATE_HERO,[0,{"cid":city_id,"hid":this.visit_hid},1]);
				}else{
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_visit_text02"));//"非本国 不可拜访"
				}
			}else if(status==2){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_visit_text03"));//"今日拜访次数用尽  请明天再来"
			}
		}

		public function click2():void{
			if(!ModelManager.instance.modelUser.isFinishFtask(this.city_id)){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_ftask_tips01"));
				return;
			}
			if(ModelOfficial.checkCityIsMyCountry(city_id)){
				if(this.hid==""){
					if(cur_time>=this.total_time){
						ViewManager.instance.showTipsTxt(Tools.getMsgById("_visit_text05"));//"已达今日拜访次数上线"
					}else{
						ViewManager.instance.showView(ConfigClass.VIEW_ESTATE_HERO,[0,{"cid":city_id,"hid":this.visit_hid},1]);
					}
				}else{
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_visit_text04"));//"拜访中"
				}
			}else{
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_visit_text02"));//"非本国 不可拜访"
			}
		}

		public function showFinishView(obj:*,show:Boolean=true):void{
			var o:Object={};
			o["hid"]=visit_hid;
			o["my_hid"]=hid;
			o["get_num"]=obj.receiveData.gift_dict[o["hid"]];
			o["gift_dict"]=obj.receiveData.gift_dict;
			if(show){
				ViewManager.instance.showView(ConfigClass.VIEW_VISIT_FINISH,o);
			}
			if(this.status==3){
				//ModelManager.instance.modelUser.updateData(obj.receiveData);
				ModelManager.instance.modelUser.visit=obj.receiveData.user.visit;
				this.clear();
			}else{
				//ModelManager.instance.modelUser.updateData(obj.receiveData);
				ModelManager.instance.modelUser.visit=obj.receiveData.user.visit;
				ModelVisit.updateData(this.city_id);
			}
		}

		
		public function clear():void{
			cleared=true;
			event(ModelVisit.EVENT_REMOVE_VISIT);
			delete ModelVisit.visitModels[city_id];
			offAll();
		}

		/**
		 * 是否显示拜访按钮
		 */
		public static function isShowVisitBtn(cid:String):Boolean{
			return ModelOfficial.visit && ModelOfficial.visit.hasOwnProperty(cid);
		}

		
	}

}