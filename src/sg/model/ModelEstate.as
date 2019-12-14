package sg.model
{
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.map.utils.Vector2D;
	import sg.utils.Tools;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.manager.ViewManager;
	import sg.net.NetPackage;
	import sg.view.map.ViewEventTalk;
	import sg.view.map.ViewEstateQuickly;
	import sg.cfg.ConfigClass;
	import sg.view.map.ViewEstateHeroInfo;
	import sg.achievement.model.ModelAchievement;
	import sg.utils.StringUtil;

	/**
	 * ...
	 * @author
	 */
	public class ModelEstate extends ModelBase{

		public static const EVENT_ESTATE_UPDATE:String="event_estate_update";
		
		public static var estateModels:Object={};
		public static var myCountryEstates:Object={};
		//public var user_estate:Array=ModelManager.instance.modelUser.estate;

		//private var config_estate:Object=ConfigServer.estate;
		//private var config_city:Object=ConfigServer.city;	
		
		//private var config_harvest_time:Number=ConfigServer.estate.harvest_time * 60 * 1000;//单位收割时间
		private var config_harvest_time:Number=ConfigServer.system_simple.material_gift_cd[0] * 60 * 1000;//单位收割时间
		private var _drop_time:Number;
		private var _total_time:Number;
		
		//private var _cur_vacancy:Number;

		public var id:String;
		public var lv:Number;
		public var cData:Object;
		public var config_index:Number;
		public var city_id:String;

		public var next_harvest_time:Number;//下次收获时间



		private var _user_index:Number=-1;//-1表示还未占领
		private var _active_hid:String;
		private var _active_times:Number;//使用次数
		private var _harvest_time:Number;//被动收割时间
		private var _estate_event:String;//事件id
		private var _active_harvest_time:Number;//主动收割时间
		private var _active_time:Number;//每日首次时间

		private var _status:int=0;
		private var _is_can_harvest:Boolean=false;		
		private var _is_can_get:Boolean=false;
		private var _is_can_active:Boolean=false;
		private var _harvest_num:Number=0;

		private var _heroEstate:ModelMapHero;
		private var _showObj:Object;


		public function ModelEstate(cid:String,index:int){
			initData(cid,index);
		}

		public function initData(cid:String,index:int):void{
			var e_arr:Array=ConfigServer.city[cid].estate[index];
			this.id=e_arr[0];
			this.lv=e_arr[1];
			this.city_id=cid;
			this.cData=ConfigServer.estate.estate[id];//系统杂项里的
			this.config_index=index;
			_user_index=this.user_index;
			//total_time=ConfigServer.estate.frequency;
			getNextHarvestTime();
		}

		/**
		 * 每日最大挂机次数
		 */
		public function get total_time():Number{
			_total_time=ConfigServer.estate.frequency+ModelAchievement.getAchiAddNum(cData.effort_add);
			//if(cData.hasOwnProperty("effort_add")){	
			//	if(ModelAchievement.isGetAchi(cData.effort_add[0])){
			//		_total_time+=cData.effort_add[1];
			//	}
			//}

			return _total_time;
		}

		/**
		 * 获得本次挂机完成时间
		 */
		public function get active_time():Number{
			if(user_index==-1)
				return 0;
			var obj:Object=ModelManager.instance.modelUser.estate[user_index];				
			this._active_time=Tools.getTimeStamp(obj.active_time);
			return this._active_time;
		}

		/**
		 * 获得事件id
		 */
		public function get estate_event():String{
			if(user_index==-1)
				return "";
			var obj:Object=ModelManager.instance.modelUser.estate[user_index];				
			this._estate_event=obj["event"]?obj["event"]:"";
			return this._estate_event;
		}

		/**
		 * 到这个时间了才可以放弃
		 */
		public function get drop_time():Number{
			_drop_time=Tools.getTimeStamp(ModelManager.instance.modelUser.estate[user_index].drop_time);	
			return _drop_time;	
		}
		
		/**
		 * 是否可以放弃产业
		 */
		public function isCanDrop():Boolean{
			var now:Number=ConfigServer.getServerTimer();
			if(now>=this.drop_time){
				return true;
			}
			return false;
		}

		/**
		 * 获得主动收获时间
		 */
		public function get active_harvest_time():Number{
			if(user_index==-1)
				return 0;
			var obj:Object=ModelManager.instance.modelUser.estate[user_index];				
			this._active_harvest_time=Tools.getTimeStamp(obj.active_harvest_time);
			return this._active_harvest_time;
		}


		/**
		 * 
		 */
		public function getNextHarvestTime():void{
			if(user_index==-1)
				next_harvest_time=-1;
			else{
				var n:Number=ConfigServer.getServerTimer()-harvest_time;
				var times:Number=(ConfigServer.getServerTimer()-harvest_time)/config_harvest_time;
				times=Math.floor(times);//(times>ConfigServer.estate.harvest) ? ConfigServer.estate.harvest : Math.floor(times);
				
				next_harvest_time=harvest_time+config_harvest_time*(times+1);
			}
		}

		/**
		 * 获得被动收割时间
		 */
		public function get harvest_time():Number{
			if(user_index==-1)
				return 0;
			var obj:Object=ModelManager.instance.modelUser.estate[user_index];				
			this._harvest_time=Tools.getTimeStamp(obj.harvest_time);
			return this._harvest_time;
		}

		/**
		 * 获得今日已挂机次数
		 */
		public function get active_times():Number{
			if(user_index==-1)
				return 0;
			var obj:Object=ModelManager.instance.modelUser.estate[user_index];				
			this._active_times=Tools.isNewDay(obj.active_time)?0:obj.active_times;
			return this._active_times;
		}

		/**
		 * 获得事件id
		 */
		public function get active_hid():String{
			if(user_index==-1)
				return "";
			var obj:Object=ModelManager.instance.modelUser.estate[user_index];				
			this._active_hid=obj.active_hid?obj.active_hid:"";
			return this._active_hid;
		}

		public function get harvest_num():Number{
			var base_num:Number=Math.floor(this.cData.ratio*ConfigServer.estate.passive[this.lv-1]);
			var times:Number=(ConfigServer.getServerTimer()-harvest_time)/config_harvest_time;
			times=times>ConfigServer.system_simple.material_gift_limit[0]?ConfigServer.system_simple.material_gift_limit[0]:Math.floor(times);
			//times=(times>ConfigServer.estate.harvest) ? ConfigServer.estate.harvest : Math.floor(times);
			var n:Number=ModelUser.estate_produce_add(this.id);
			_harvest_num=Math.floor((base_num*times) *(1+n));
			return _harvest_num;
		}

		/**
		 * 获得用户产业的索引值
		 */
		public function get user_index():Number{
			_user_index=-1;
			for(var i:int=0;i<ModelManager.instance.modelUser.estate.length;i++){
				var obj:Object=ModelManager.instance.modelUser.estate[i];
				if(obj.city_id==this.city_id && obj.estate_index==this.config_index){
					_user_index=i;
					break;
				}
			}
			return _user_index;
		}


		/**
		 * 是否可收割
		 */
		public function get is_can_harvest():Boolean{
			if(user_index==-1 || this.harvest_time==0)
				return false;
			var n:Number=ConfigServer.getServerTimer()-this.harvest_time;
			_is_can_harvest=n>=config_harvest_time;
			return _is_can_harvest;
		}

		/**
		 * 是否可收获
		 */
		public function get is_can_get():Boolean{
			if(user_index==-1)
				return false;
			if(ConfigServer.getServerTimer()>=this.active_harvest_time)
				return true;
			return false;
		}

		
		/**
		 * 当前已占领个数
		*/
		public static function getCurVacancy():Number{
			return ModelManager.instance.modelUser.estate.length;
		}

		public static function getTotalVacancy():Number{
			return ConfigServer.estate.vacancy+ModelOffice.func_indcount();//总的占领个数;
		}

		/**
		 * 是否可挂机
		 */
		public function get is_can_active():Boolean{
			_is_can_active=false;
			if(this.active_times<total_time){
				if(cData.hasOwnProperty("active_prop")){
					//if(Tools.isCanBuy(cData["active_prop"][0],cData["active_prop"][1])){
						
					//}
					if(ModelManager.instance.modelProp.getItemProp(cData["active_prop"][0]).num>=cData["active_prop"][1]){
						_is_can_active = true;
					}
				}
			}
			return _is_can_active;
		}

		/**
		 * 获得当前产业状态 4未占领  1挂机  0可收割  2可主动  3空闲     
		 */
		public function get status():Number{
			if(user_index==-1){
				_status=4;//未占领
			}else{
				if(is_can_harvest){
					_status=0;//可收割 有钱币的。
				}else if(active_hid!=""){
					_status=1;//挂机中	//显示英雄
				}else if(is_can_active){
					_status=2;//可主动挂机	//显示道具图标
				}else{
					_status=3;//空闲
				}
			}

			return _status;
		}


		public function get showObj():Object{
			var item:ModelItem;
			switch(status){
				case 0:
					item=ModelManager.instance.modelProp.getItemProp(this.cData.produce);
					_showObj={icon:"ui/"+item.icon,num:harvest_num};
				break;
				case 1:
					_showObj = {hid:this.active_hid, rid:this.estateHero.getRidURL(), "event":this.estate_event!="", finish:this.is_can_get};
				break;
				case 2:
					_showObj={icon:ModelItem.getIconUrl(this.cData.active_prop[0])};
				break;
				case 3: 
					_showObj=null;
				break;
			}
			return _showObj;
		}

		/**
		 * 获得挂机中的英雄数据
		 */
		//public function getEstateHero():ModelMapHero{
		//	if(this.status==1){
		//		return new ModelMapHero(0,this.user_index);
		//	}
		//	return null;
		//}

		public function get estateHero():ModelMapHero{
			if(this.status==1){
				if(_heroEstate==null){
					_heroEstate = new ModelMapHero(0,this.user_index);
				}
			}
			return _heroEstate;
		}
		public function clearEstateHero():void{
			_heroEstate==null;
		}

		public function click(v:Vector2D):void{
			if(ModelGame.unlock(null,"estate").text!=""){
				ViewManager.instance.showTipsTxt(ModelGame.unlock(null,"estate").text);
				return;
			}
			var b:Boolean=this.is_can_active;
			if(this.status==0){
				NetSocket.instance.send("estate_harvest",{},new Handler(this,function(np:NetPackage):void{
					var arr:Array=[];
					for(var e:String in ModelEstate.myCountryEstates){
						if(ModelEstate.myCountryEstates[e].is_can_harvest){
							arr.push(ModelEstate.myCountryEstates[e]);
						}
					}
					ModelManager.instance.modelUser.updateData(np.receiveData);
					if(np.receiveData.gift_dict.length!=0){	
						ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
						for(var i:int=0;i<arr.length;i++){
							arr[i].event(ModelEstate.EVENT_ESTATE_UPDATE);
						}
					}
				}));
			}else if(this.status==1){
				if(this.estate_event==""){
					if(is_can_get){
						NetSocket.instance.send("estate_active_harvest",{estate_index:this.user_index},new Handler(this,function(np:NetPackage):void{
							ModelManager.instance.modelUser.updateData(np.receiveData);
							this.event(ModelEstate.EVENT_ESTATE_UPDATE);
							clearEstateHero();
							ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
						}));
					}else{
						//ViewManager.instance.showView(["ViewEstateQuickly",ViewEstateQuickly],this.user_index);
						ViewManager.instance.showView(["ViewEstateHeroInfo",ViewEstateHeroInfo],[0,this.city_id,this.user_index]);
					}
				}else{
					ViewManager.instance.showView(["ViewEventTalk",ViewEventTalk],[this.estate_event,0,this.user_index]);
				}
			}else{
				if(!ModelOfficial.checkCityIsMyCountry(this.city_id)){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_ftask_tips03"));//"非本国产业"
					return;
				}
				if(!ModelManager.instance.modelUser.isFinishFtask(this.city_id)){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_ftask_tips02",[ModelCityBuild.getCityName(this.city_id)]));
					//"请先完成"+ModelCityBuild.getCityName(this.city_id)+"民情"
					return;
				}
				var estate_total:Number=ConfigServer.estate.vacancy+ModelOffice.func_indcount();
				var estate_cur:Number=ModelManager.instance.modelUser.estate.length;
				//if(estate_cur>=estate_total){
				//	ViewManager.instance.showTipsTxt(Tools.getMsgById("_ftask_tips04"));//"占领数量已达上限"
				//	return;
				//}
				var arr:Array;
				if(this.user_index==-1){
					arr=[this.city_id,this.id,this.lv,active_times,total_time,this.config_index,false];
				}else{
					arr=[this.city_id,this.id,this.lv,active_times,total_time,this.user_index,true];
				}
				ViewManager.instance.showView(ConfigClass.VIEW_ESTATE_DETAILS,[arr,v]);//arr=[cid,eid,elv,act_times,total_times,e_index,is_me]
			}
		}

		public static function getEstateName(id:*):String{
			 if(ConfigServer.estate.estate[id+""]){
				 if(ConfigServer.estate.estate[id+""].active_name){
					 return Tools.getMsgById(ConfigServer.estate.estate[id].active_name);
				 }
			 }

			 return "";

		}

		/**
		 * 得到该产业的推荐战力
		 */
		public function getPower():int{
			var lvIndex:int = this.lv -1;
			var enemyLv:int = ConfigServer.estate.enemy_level[lvIndex] + cData.enemy_level_add;
			var power:int = ModelPrepare.getNPCPower(ConfigServer.estate.enemy_range, enemyLv, ConfigServer.estate.enemy_power);
			return power;
		}
		
		/**
		 * 得到该产业的主动挂机收益值
		 */
		public function getActiveNum():int{
			var lvIndex:int = this.lv -1;
			var activeValue:Number =  ConfigServer.estate.active[lvIndex];
			var value:int = Math.floor(activeValue * cData.active);
			return value;
		}
		
		/**
		 * 整理我的产业
		 */
		public static function recommandEstate():Object{
			var myPower:Number=0;//ModelManager.instance.modelUser.getPower();
			var a:Array=ModelManager.instance.modelUser.getMyHeroArr(true,"",null,true);
			myPower=(a[0] && a[0].sortPower) ? a[0].sortPower : 0;
			var o:Object={};//{"1":[power,cid,index,myPower-power]}
			for(var s:String in ModelEstate.myCountryEstates){
				var estate:ModelEstate=ModelEstate.myCountryEstates[s];
				if(estate.status==4){
					var power:Number = estate.getPower();
					var arr:Array=[power,estate.city_id,estate.config_index,Math.abs(myPower-power)];
					if(o.hasOwnProperty(estate.id)){
						var old_arr:Array=o[estate.id];
						if(arr[3]<old_arr[3]){
							o[estate.id]=arr;
						}
					}else{
						o[estate.id]=arr;
					}
				}
			}
			//trace("===================推荐的产业",o);
			return o;
		}


		/**
		 * 是否是黄金产业
		 */
		public function isGoldEstate():Boolean{
			var records:Object=ModelManager.instance.modelUser.records;
			var _estate_coin_get_time:Number = records.estate_coin_get_time ? Tools.getTimeStamp(records.estate_coin_get_time) : 0;
			if(_estate_coin_get_time==0) return false;
			
			var _estate_coin_get_num:Number  = records.estate_coin_get_num  ? records.estate_coin_get_num : 0;
			var config_coin_limit:Number     = ConfigServer.country_pvp.active_add.coin_add_limit;
			if(!Tools.isNewDay(_estate_coin_get_time) && _estate_coin_get_num>=config_coin_limit){
				return false;
			}
			var arr:Array=ModelOfficial.xyz_estate_add ? ModelOfficial.xyz_estate_add : [];
			for(var i:int=0;i<arr.length;i++){
				if(arr[i][0]==this.city_id && arr[i][1]==this.config_index){
					return true;
				}
			}
			return false;
		}

		/**
		 * 静态的  是否是黄金产业
		 */
		public static function isGold(cid:*,index:*):Boolean{
			var arr:Array=ModelOfficial.xyz_estate_add ? ModelOfficial.xyz_estate_add : [];
			for(var i:int=0;i<arr.length;i++){
				if(arr[i][0]==cid && arr[i][1]==index){
					return true;
				}
			}
			return false;

		}

	}

}