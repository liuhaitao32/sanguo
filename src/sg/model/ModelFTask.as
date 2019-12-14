package sg.model
{
	import sg.manager.ModelManager;
	import sg.cfg.ConfigServer;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.map.utils.Vector2D;
	import sg.utils.Tools;
	import laya.utils.Handler;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.view.task.ViewFTaskArmy2;
	import sg.manager.AssetsManager;
	import sg.view.task.viewFtaskConquest;
	import sg.map.model.entitys.EntityCity;
	import sg.map.model.MapModel;
	import sg.view.task.ViewFTaskOpen;

	/**
	 * ...
	 * @author
	 */
	public class ModelFTask extends ModelBase{//民情


		public static const EVENT_INIT_FTASK:String="event_init_ftask";
		public static const EVENT_UPDATE_FTASK:String="event_update_ftask";
		public static const EVENT_REMOVE_FTASK:String="event_remove_ftask";
		public static const EVENT_ADD_FTASK:String="event_add_ftask";

		public static var ftaskModels:Object={};
		public var city_id:String;
		public var limit_lv:Number=0;//爵位限制是否能进行民情
		public static var max_get_num:Number=ConfigServer.ftask.people_recvnum;//最大接取数

		private var _is_get:Boolean=false;
		private var _is_done:Boolean=false;
		private var _is_finish:Boolean=false;
		private var _is_have_task:Boolean=false;
		private var _is_can_do:Boolean=false; 
		private var _task_id:String="";//当前进行的民情id		
		private var _showObj:Object={};
		private var _itemIcon:Array;

		private var _get_num:Number;//接取任务数
		
		public function ModelFTask(cid:String){
			this.initData(cid);
		}

		public function initData(cid:String):void{
			this.city_id=cid;
			if(ConfigServer.city[this.city_id].office_lv){
				limit_lv=ConfigServer.city[this.city_id].office_lv[ModelUser.getCountryID()];
			}
		}

		/**
		 * 是否可进行民情
		 */
		public function get is_can_do():Boolean{
			_is_can_do = is_have_task && ModelManager.instance.modelUser.office >= limit_lv;
			return _is_can_do;
		}


		/**
		 * 是否有民情
		 */
		public function get is_have_task():Boolean{
			_is_have_task=ModelManager.instance.modelUser.ftask.hasOwnProperty(this.city_id);
			return _is_have_task;
		}	

		/**
		 * 是否领取任务
		 */
		public function get is_get():Boolean{
			_is_get=false;
			if(ModelManager.instance.modelUser.ftask.hasOwnProperty(this.city_id)){
				_is_get=ModelManager.instance.modelUser.ftask[this.city_id][1]==1;
			}
			return _is_get;
		}

		/**
		 * 民情全部完成
		 */
		public function get is_done():Boolean{
			_is_done=false;
			if(ModelManager.instance.modelUser.ftask.hasOwnProperty(this.city_id)){
				_is_done=ModelManager.instance.modelUser.ftask[this.city_id][0]==-1;
			}			
			return _is_done;
		}

		/**
		 * 完成（待领奖）
		 */
		public function get is_finish():Boolean{
			_is_finish=false;
			if(ModelManager.instance.modelUser.ftask.hasOwnProperty(this.city_id)){
				_is_finish=ModelManager.instance.modelUser.ftask[this.city_id][2]==1;
			}			
			return _is_finish;
		}


		/**
		 * 当前任务id
		 */
		public function get task_id():String{
			_task_id="";
			if(ModelManager.instance.modelUser.ftask[this.city_id]){
				var n:Number=ModelManager.instance.modelUser.ftask[this.city_id][0];
				if(n>=0){
					if(ConfigServer.city[this.city_id].pctask_id){
						_task_id=ConfigServer.city[this.city_id].pctask_id[ModelUser.getCountryID()][n];
					}
				}
			}
			return _task_id;
		}

		public function get get_num():Number{
			_get_num=0;
			for(var s:String in ModelManager.instance.modelUser.ftask){
				var a:Array=ModelManager.instance.modelUser.ftask[s];
				if(a[1]==1){
					_get_num+=1;
				}
			}
			return _get_num;
		}



		/**
		 * 获取当前民情的状态
		 */
		public function get status():Number{//0 待接取（新民情） 1 领取(...)   2 完成（？）  3 全部完成/没有民情呢（空）
			var n:Number=0;
			if(is_done || !is_have_task){
				n=3;
			}else if(is_finish){
				n=2;
			}else if(is_get){
				n=1;
			}else{
				n=0;
			}
			return n;
		}

		public function get itemIcon():Array{
			if(is_finish){
				var arr:Array=ConfigServer.ftask.people_task[this.task_id].pctask_rew;
				_itemIcon=[AssetsManager.getAssetItemOrPayByID(arr[0]),arr[1]];
			}
			return _itemIcon;
		}

		public function get showObj():Object{
			var obj:Object=ConfigServer.ftask.people_task[this.task_id];
			switch(parseInt(obj.type)){
				case 0:				
				break;
				case 1:
					var _lv:Number=Number(ConfigServer.city[this.city_id].rebel_army[ModelUser.getCountryID()][0]);
					var _item:String="";
					var o:Object=ConfigServer.ftask.rebel_army_rew[_lv+""];
					var arr:Array=ModelManager.instance.modelProp.getRewardProp(o);
					_showObj={lv:_lv,item:ModelItem.getIconUrl(arr[0][0])};
				break;
			}
			return _showObj;
		}


		public function click():void{
			//补丁 2次合服之后  快速完成民情
			if(ConfigServer.ftask.merge){
				if(ConfigServer.ftask.merge[ModelManager.instance.modelUser.mergeNum]){
					//快速完成民情
					var ftaskModel:ModelFTask = ModelManager.instance.modelGame.getModelFtask(this.city_id);
					NetSocket.instance.send("get_ftask_city_open_reward",{"city_id":this.city_id},new Handler(this,function(np:NetPackage):void{
						var re:*=np.receiveData;
						ModelManager.instance.modelUser.updateData(re);
						ViewManager.instance.showView(["ViewFTaskOpen",ViewFTaskOpen],[ftaskModel.city_id,re.gift_dict]);
						ModelManager.instance.modelGame.removeFtask(ftaskModel.city_id);
						ftaskModel.event(ModelFTask.EVENT_UPDATE_FTASK);
					}));
					
					return;
				}
			}


			if(this.status==0){
				if(!ModelOfficial.checkCityIsMyCountry(this.city_id)){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_estate_text21"));//"非我国城市 无法进行民情"
					return;
				}

				if(this.get_num>=ModelFTask.max_get_num){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_estate_text22",[ModelFTask.max_get_num]));//"最多同时接取"+ModelFTask.max_get_num+"个民情");
					return;
				}
			}
			
			if(!is_can_do){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_estate_text23",[ModelOffice.getOfficeName(limit_lv)]));//"爵位达到"+ModelOffice.getOfficeName(limit_lv)+"时开启民情");
				return;
			}

			if(is_get && !is_finish){
				ViewManager.instance.showView(ConfigClass.VIEW_FTASK_MAIN,this.city_id);
			}else{
				var n:Number=(!is_get)?0:(is_finish)?1:0;
				var tid:String=ConfigServer.city[this.city_id].pctask_id[ModelUser.getCountryID()][ModelManager.instance.modelUser.ftask[this.city_id][0]];
				var talk_arr:Array=[ConfigServer.ftask.people_task[tid].pc_talk_npc,
								ConfigServer.ftask.people_task[tid].pc_talk[0],
								ConfigServer.ftask.people_task[tid].pc_talk[1][n]];
				ViewManager.instance.showHeroTalk([talk_arr],function():void{
					ViewManager.instance.showView(ConfigClass.VIEW_FTASK_MAIN,city_id);
				});
			}			
		}

		/**
		 * 点击山贼或者叛军
		 */
		public function clickOther(v:Vector2D):void{
			var city:EntityCity = MapModel.instance.citys[parseInt(this.city_id)];
			if(city.fire){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_ftask_tips04"));
				return;
			}
			var obj:Object=ConfigServer.ftask.people_task[this.task_id];
			if(Number(obj.type)==0){
				NetSocket.instance.send("do_ftask", {"city_id":this.city_id,"fight":0}, new Handler(this, function(np:NetPackage):void{
					//var mTroops:Array=ModelManager.instance.modelTroopManager.getMoveCityTroop(Number(city_id));
					ViewManager.instance.showView(["viewFtaskConquest",viewFtaskConquest],[this.city_id,np.receiveData.team[1].troop[0],v]);	
				}));
			}else if(Number(obj.type)==1){
				ViewManager.instance.showView(["ViewFTaskArmy2",ViewFTaskArmy2],[city_id,v]);
			}
		}

	}

}