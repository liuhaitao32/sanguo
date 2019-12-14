package sg.model
{
	import sg.cfg.ConfigServer;
	import sg.net.NetSocket;
	import sg.utils.Tools;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.map.utils.ArrayUtils;
	import sg.guide.model.ModelGuide;
	import sg.view.countryPvp.ViewCountryEmperorTips;
	import sg.utils.SaveLocal;
	import sg.view.countryPvp.ViewCountryPvpTips;
	import sg.net.NetMethodCfg;
	import sg.view.countryPvp.ViewCountryTributaryTips;
	import sg.cfg.ConfigClass;
	import sg.map.model.MapModel;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.utils.MusicManager;
	import sg.activities.model.ModelAfficheMerge;


	/**
	 * ...
	 * @author
	 */
	public class ModelCountryPvp  extends ModelBase{
		

		private var isLock:Boolean=false;
		public static const EVENT_UPDATE_MENU_USER_BTN:String = "event_update_menu_user_btn"; //刷新主界面按钮
		public static const EVENT_UPDATE_BALLISTA:String      = "event_update_ballista";      //攻城器械进度刷新

		public static const EVENT_XYZ_START:String            = "event_xyz_start";            //襄阳战开始
		public static const EVENT_XYZ_TIME_OUT:String         = "event_xyz_time_out";         //襄阳战到时间了
		public static const EVENT_XYZ_OVER:String             = "event_xyz_over";             //襄阳战结束

		public static const EVENT_XYZ_MOVE_SPEED:String       = "event_xyz_move_speed";       //襄阳战行军加速
		
		public static const carObj:Object={"car":"hero826","big_car":"hero827"};//霹雳车、重弩车的模型id

		private var cfg:Object;
		public  var mSunrise:Number;//开始时间
		public  var mSunset:Number;//结束时间
		public  var mLast:Number;//强制结束时间
		private var mPushTime:Number;//推送弹板时间
		public  var mBtnTime:Number;//显示按钮的时间 开战前：还有xx时间开战   战中：还有xx时间结束
		public  var mIsToday:Boolean;//今天是否是襄阳战
		public  var mSeasonNum:Number;//襄阳战是开服第几天
		public  var mCycleTime:Number;//限时比拼结算时间点
		public  var mPushSunrised:Boolean;//是否推送过开始信息
		public  var mPushSunseted:Boolean;//是否推送过结束信息
		public  var mPushSpeeded:Boolean;//是否推送加速信息

		public  var mMoveSpeed:Number;//开始加速时间

		public var mNextOpenDay:Number;//下次开启天数
		
		public var buildInfoArr:Array=[];//建造信息
		
		
		////////////服务器数据
		public  var xyz:Object;
		//我的战功
		public var myCredit:Number=0;
		//我的阶段战功
		public var myCreditRound:Number=0;

		public function ModelCountryPvp(){
			this.init();
			//"status":0 今天开始  1 进行中  2 结束时间到结算时间 
			//"w.get_xyz"//襄阳战接口
			//"w.get_user_list" -uids:[]
			//"w.xyz_over"襄阳战结束
		}

        private function init():void{
            NetSocket.instance.on(NetSocket.EVENT_SOCKET_RECEIVE_TO,this,this.event_socket_receive_to);
        }

		/**
		 * 更新襄阳战数据
		 */
		public function updateXYZ(re:Object):void{
			if(re==null) return;
			if(re.hasOwnProperty("xyz")){
				this.xyz=re.xyz;
			}else{
				this.xyz=re;
			}
		}

		/**
		 * 检查是否是襄阳战期间
		 */
		public function checkActive():Boolean{
			if(isOpen || (xyz && xyz.status>0)){
				return true;
			}
			return false;
		}

		/**
		 * 检查合服公告
		 */
		public function checkAfficheMerge(tips:Boolean = false):Boolean{
			var b:Boolean = false;
			var n:Number = ModelAfficheMerge.instance.mergeday;
			if(n){
				if(n == mNextOpenDay){
					if(tips) trace("开服第"+mNextOpenDay+"天合服 没有襄阳战了");
					b = true;
				}
			}
			return b;
		}

		/**
		 * 检查是否需要显示主界面上的襄阳战倒计时按钮
		 */
		public function get active():Boolean{
			return mBtnTime > 0;
		}

		/**
		 * 主界面襄阳站按钮上的文字
		 */
		public function getTxt():String {
			this.updateBtnTime();
			// 0 未开始  1 开始到结束时间  2  结束到强制结束时间
			var msgIdArr:Array = ['_countrypvp_text41', '_countrypvp_text42', '_countrypvp_text43'];
			return Tools.getMsgById(msgIdArr[this.getStatus()], [Tools.getTimeStyle(mBtnTime)]);
		}

		/**
		 * 是否是强制结束时间内
		 */
		public function isLast():Boolean{
			if(mSunset!=0){
				var n:Number=ConfigServer.getServerTimer();
				if(n>=mSunset && n<mLast){
					return true;
				}
			}
			return false;
		}

		/**
		 * 获得当前襄阳战状态  0 没到时间  1 进行中  2 结束时间到强制
		 */
		public function getStatus():Number{
			var n:Number=ConfigServer.getServerTimer();
			if(mSunrise!=0 && n<mSunrise){
				return 0;
			}else if(mSunset!=0 && n<mSunset){
				return 1;
			}else if(mLast!=0 && n<mLast){
				return 2;
			}
			return 0;
		}

		/**
		 * 襄阳战是否开启时间(开始时间到结束时间)
		 */
		public function get isOpen():Boolean{
			if(isLock) return false;
			/*
			cfg=ConfigServer.country_pvp;
			var open_days:Number = ModelManager.instance.modelUser.loginDateNum;
			var isMerge:Boolean  = ModelManager.instance.modelUser.isMerge;
			var first_day:Number = isMerge ? cfg.merge_ini   : cfg.gap_ini;
			var cycle_num:Number = isMerge ? cfg.merge_cycle : cfg.gap;
			var is_today:Boolean = false;
			if(open_days==first_day){//第一次襄阳战开始时间
				is_today=true;
			}else if(open_days>first_day){
				if((open_days-first_day)%cycle_num==0){//第n次襄阳战是gap_ini之后每隔gap天开启
					is_today=true;
				};
			}

			if(is_today){
				var now:Date       = new Date(ConfigServer.getServerTimer());
				var n:Number       = now.getHours() * Tools.oneHourMilli + now.getMinutes() * Tools.oneMinuteMilli;
				var sunrise:Number = cfg.sunrise[0] * Tools.oneHourMilli + cfg.sunrise[1]   * Tools.oneMinuteMilli;
				var sunset:Number  = cfg.sunset[0]  * Tools.oneHourMilli + cfg.sunset[1]    * Tools.oneMinuteMilli;
				if(n>=sunrise && n<sunset) return true;
					
			}
			*/

			var n:Number=ConfigServer.getServerTimer();
			if(n>=mSunrise && n<mSunset){
				return true;
			}
			return false;
		}
		

		public function initData(nnn:Number = 0):void{
			mBtnTime=mPushTime=mSunrise=mSunset=mLast=mMoveSpeed=0;
			mPushSunrised = mPushSunseted = true;
			mIsToday      = false;
			mPushSpeeded  = false;

			if(isLock) return;
			cfg=ConfigServer.country_pvp;
			var isMerge:Boolean=ModelManager.instance.modelUser.isMerge;

			//表示合服后才有襄阳战
			if(isMerge==false && cfg.merge==1 ){
				trace("====未合服 且未开启");
				return;
			} 

			var open_days:Number=ModelManager.instance.modelUser.loginDateNum;
			var n:Number=nnn ? nnn : ConfigServer.getServerTimer();
			var dt:Date;

			var first_day:Number=isMerge?cfg.merge_ini:cfg.gap_ini;
			var cycle_num:Number=isMerge?cfg.merge_cycle:cfg.gap;

			if(open_days<=first_day){//第一次襄阳战开始时间
				dt=new Date(n+(first_day-open_days)*Tools.oneDayMilli);
				mNextOpenDay = first_day;
			}else{
				var nn:Number=0;	
				var n1:Number=(open_days-first_day)%cycle_num;
				if(n1 != 0){
					nn = cycle_num-n1;
				}else{
					var _hour:Number = new Date(n).getHours();
					var _min:Number = new Date(n).getMinutes();
					var _dev:Number = ConfigServer.system_simple.deviation ? ConfigServer.system_simple.deviation : 0;
					if(_hour*60 + _min < _dev){
						nn = cycle_num-1;
					}
				}
				dt=new Date(n+nn*Tools.oneDayMilli);

				for(var i:int=1;i<365;i++){
					var num0:Number = first_day + i*cycle_num;
					var num1:Number = first_day + (i-1)*cycle_num;
					if(num0 >= open_days && num1<open_days){
						mNextOpenDay = num0;
						break;
					}
				}
			}

			if(this.checkAfficheMerge(true)){
				return;
			}
			
			mSeasonNum = open_days-1;
			
			mSunrise   = (new Date(dt.getFullYear(),dt.getMonth(),dt.getDate(),cfg.sunrise[0]             ,cfg.sunrise[1]             )).getTime();
			mSunset    = (new Date(dt.getFullYear(),dt.getMonth(),dt.getDate(),cfg.sunset[0]              ,cfg.sunset[1]              )).getTime();
			mLast      = (new Date(dt.getFullYear(),dt.getMonth(),dt.getDate(),cfg.latest_time[0]         ,cfg.latest_time[1]         )).getTime();
			mMoveSpeed = (new Date(dt.getFullYear(),dt.getMonth(),dt.getDate(),cfg.special_time.move[0][0],cfg.special_time.move[0][1])).getTime();
			if(n>mLast) mMoveSpeed = 0;
			
			if(open_days==first_day){
				mIsToday = true;
			}else if(open_days>first_day){
				if((open_days-first_day)%cycle_num==0){
					mIsToday = true;					
				}
			}
			
			trace("====襄阳战开始时间",Tools.dateFormat(mSunrise));
			trace("====襄阳战结束时间",Tools.dateFormat(mSunset));
			trace("====襄阳战强制结束时间",Tools.dateFormat(mLast));
			trace("====开始加速时间",Tools.dateFormat(mMoveSpeed));

			updatePushTime();
			updateBtnTime();
			if(mIsToday){
				if(n>mSunset) mPushSunrised=true;
				else mPushSunrised=n>mSunrise;
				mPushSunseted=n>mSunset;
			}
		}

        private function event_socket_receive_to(re:Object,isMe:Boolean):void
        {
            var method:String = re.method;
            var receiveData:Object = re.data;
            if(Tools.isNullObj(receiveData)){
                return;
            }
            if(receiveData.hasOwnProperty("msg")){
                return;
            }

			switch(method){
				case NetMethodCfg.WS_SR_GET_INFO:
					updateXYZ(receiveData.xyz);
					this.initData();
				break;
				case "w.build_ballista_push"://攻城器械建造推送
					updateXYZ(receiveData[0]);//[xyz,进度,名字,官职]
					buildInfoArr.push([receiveData[1],receiveData[2],receiveData[3]]);
					this.event(EVENT_UPDATE_BALLISTA);
					break;
				case "w.xyz_over"://襄阳战结束
					this.event(EVENT_XYZ_OVER);
					xyz=null;
					if(ModelGuide.forceGuide()){
						return;
					}
					//receiveData.victor_country 如果是黄巾军就是数字  魏蜀吴是对象
					if(receiveData.victor_country && (receiveData.victor_country is Number)){
						trace("====襄阳战结束  魏蜀吴都没有打下来");
					}else{
						//在线推送  不在线的不用管
						showEmperorTips(receiveData);
					}
					ModelManager.instance.modelOfficel.event(ModelOfficial.EVENT_SHOW_XYZ);
					break;	

			}
		}

		public function showEmperorTips(receiveData:Object):void{
			ViewManager.instance.showHeroTalk([[cfg.push_show[0],cfg.push_show[1],cfg.push_text[3]]],function():void{
				var n:Number=receiveData.victor_country.tid;
				var arr:Array=[n,receiveData.victor_country.official[0][1]];
				ViewManager.instance.showView(["ViewCountryEmperorTips",ViewCountryEmperorTips],arr);
				MusicManager.playSoundUI(MusicManager.SOUND_XYZ_8);
			});
		}



		/**
		 * 距离开启时间（毫秒）
		 */
		public function get openTime():Number{
			var n:Number=ConfigServer.getServerTimer();
			if(mSunset!=0 && n>mSunset){
				//今天的襄阳战已经结束
				var isMerge:Boolean=ModelManager.instance.modelUser.isMerge;
				var cycle_num:Number=isMerge?cfg.merge_cycle:cfg.gap;
				return this.mSunrise + cycle_num*Tools.oneDayMilli - n;
			}else if(mSunrise!=0 && n<mSunrise){
				return this.mSunrise - n;
			}
			return -1;
		}

		

		/**
		 * 刷新推送时间mPushTime
		 */
		public function updatePushTime():void{
			if(isLock) return;
			var now:Number=ConfigServer.getServerTimer();
			mPushTime=0;
			var n:Number=1;
			var nn:Number=0;
			if(!mIsToday) return;
			if(now<mSunrise){//未开始
				if(now<mSunrise-cfg.push_count*Tools.oneMinuteMilli){
					mPushTime=mSunrise-cfg.push_count*Tools.oneMinuteMilli;
				}else{
					for(var i:int=0;i<99;i++){
						nn=cfg.push_count-(n*cfg.push_gap);
						nn=nn<0?0:nn;
						if(now<mSunrise-nn*Tools.oneMinuteMilli){
							mPushTime=mSunrise-nn*Tools.oneMinuteMilli;
							break;
						}
						n++;
					}
				}
			}else if(now>=mSunrise && now<mSunset){//即将结束
				if(now<mSunset-cfg.push_count*Tools.oneMinuteMilli){
					mPushTime=mSunset-cfg.push_count*Tools.oneMinuteMilli;
				}else{
					for(var j:int=0;j<99;j++){
						nn=cfg.push_count-(n*cfg.push_gap);
						nn=nn<0?0:nn;
						if(now<mSunset-nn*Tools.oneMinuteMilli){
							mPushTime=mSunset-nn*Tools.oneMinuteMilli;
							break;
						}
						n++;
					}
				}
			}
			
			trace("====襄阳战推送消息时间",mPushTime==0 ? "---" : Tools.dateFormat(mPushTime));
		}
		/**
		 * 刷新主界面的按钮时间
		 */
		public function updateBtnTime():void{
			if(isLock) return;
			var n:Number=ConfigServer.getServerTimer();

			if(n>mLast) mBtnTime=0;
			else if(n>mSunset){
				mBtnTime = mLast-n;
				if(xyz==null) mBtnTime = 0;
			}else if(n>=mSunrise) mBtnTime = mSunset-n;
			else if(n>mSunrise-cfg.entrance2*Tools.oneHourMilli) mBtnTime = mSunrise-n;
			else mBtnTime = 0;
			if(mBtnTime<0) mBtnTime=0;
			//trace("=====襄阳战按钮显示时间",Tools.getTimeStyle(mBtnTime));
		}
		/**
		 * 检测是否显示推送 每秒调用
		 */
		public function checkShowPush():void{
			if(isLock) return;
			var n:Number=ConfigServer.getServerTimer();
			if(mPushTime!=0){
				if(n>mPushTime){
					showPushView();
					updatePushTime();
				}
			}

			if(!mPushSunrised){
				if(n>mSunrise){
					trace("====襄阳战开始了");
					updateBtnTime();
					this.event(EVENT_XYZ_START);
					ModelManager.instance.modelOfficel.event(ModelOfficial.EVENT_HIDE_XYZ); 
					mPushSunrised=true;
					if(ModelGuide.forceGuide()) return;
					ViewManager.instance.showView(["ViewCountryPvpTips",ViewCountryPvpTips]);
				}
			}

			if(!mPushSunseted){
				if(n>mSunset){
					trace("====襄阳战时间到了");
					updateBtnTime();
					this.event(EVENT_XYZ_TIME_OUT);
					mPushSunseted=true;
				}
			}

			if(mMoveSpeed!=0 && !mPushSpeeded){
				if(n>mMoveSpeed){
					mPushSpeeded=true;
					this.event(EVENT_XYZ_MOVE_SPEED,cfg.special_time.move[1]);
					trace("===派发加速消息");
				}
			}

		}

		/**
		 * 获得加速的值
		 */
		public function getSpeedNum():Number{
			var now:Number=ConfigServer.getServerTimer();
			if(checkActive() && mMoveSpeed!=0 && now>=mMoveSpeed){	
				return cfg.special_time.move[1];
			}	
			return 1;
		}

		/**
		 * 显示推送面板
		 */
		public function showPushView():void{
			if(isLock) return;

			if(ModelGuide.forceGuide()) return;

			var now:Number=ConfigServer.getServerTimer();
			var n:Number=0;
			var content:String;
			if(mPushTime==mSunrise){//开始了
				content=cfg.push_text[2];
				ViewManager.instance.showHeroTalk([[cfg.push_show[0],cfg.push_show[1],content]],null);
			}else{
				if(now<mSunrise){//未开始
					n=Math.round((mSunrise-now)/Tools.oneMinuteMilli);
					content=cfg.push_text[0];
				}else if(now>mSunrise && now<mSunset){//即将结束
					n=Math.round((mSunset-now)/Tools.oneMinuteMilli);
					content=cfg.push_text[1];
				}	
				n>0 && MusicManager.playSoundUI(MusicManager.SOUND_XYZ_2);
				n>0 && ViewManager.instance.showHeroTalk([[cfg.push_show[0],cfg.push_show[1],content,[n]]],null);
			}
			
		}

		/**
		 * 检查是否要弹出襄阳战开战提示板
		 */
		public function checkShowBeginTips():Boolean{
			var o:Object=SaveLocal.getValue(SaveLocal.KEY_XYZ_BEGIN + ModelManager.instance.modelUser.mUID,true);
			if(isOpen){
				if(o==null || o.season_num!=this.mSeasonNum){
					return true;
				}
			}
			return false;
		}

		/**
		 * 限时比拼倒计时
		 */
		public function updateCycleTime():void{
			mCycleTime=0;
			if(isLock) return;
			var n:Number=ConfigServer.getServerTimer();
			var cfgTime:Number=cfg.personal.ranking.cycle*Tools.oneMinuteMilli;
			if(this.isOpen){
				var nn:Number=Math.ceil((n-this.mSunrise)/cfgTime);
				nn=nn<1?1:nn;
				mCycleTime=this.mSunrise+cfgTime*nn;
			}
		}

		/**
		 * 组装列表
		 * obj{"uid":num} arr返回的uids列表
		 */
		public function getUserList(obj:Object,arr:Array):Array{
			var re:Array=[];
			if(obj){
				for(var i:int=0;i<arr.length;i++){
					if(obj.hasOwnProperty(arr[i][0])){
						re.push({"num":obj[arr[i][0]],"data":arr[i]});
					}
				}
				//应该不用再排一次了
				//re=ArrayUtils.sortOn(["num"],re,true);
			}
			return re;
		}

		/**
		 * 获得襄阳城归属国
		 */
		public function getXYCountry():Number{
			return ModelOfficial.cities[-1].country;
		}
		/**
		 * 获得指定国家的占领城门
		 */
		public function getDoorByCountry(_country:Number):Array{
			var a:Array=[-2,-3,-4,-5];//东南西北门id
			var arr:Array=[];
			for(var i:int=0;i<a.length;i++){
				if(ModelOfficial.cities[a[i]].country==_country){
					arr.push(a[i]);
				}
			}
			return arr;
		}

		/**
		 * 获得城门加成
		 */
		public function getDoorAdd(_country:Number):Number{
			var arr:Array=getDoorByCountry(_country);
			var n:Number=0;
			for(var i:int=0;i<arr.length;i++){
				n+=ConfigServer.country_pvp.effect_door[Math.abs(arr[i])-2];
			}
			return n;
		}


		/**
		 * 显示进贡面板
		 */
		public function showTrbutaryView(b:Boolean=true):Boolean{

			if(isLock) return false;

			if(ModelGuide.forceGuide()) return false;

			if(this.checkActive()) return false;

			if(ModelManager.instance.modelUser.getGameSeason()==ConfigServer.country.warehouse.tribute[0]){
				var o:Object=SaveLocal.getValue(SaveLocal.KEY_COUNTRY_TRUBUTR + ModelManager.instance.modelUser.mUID,true);
				if(o==null || (o.login_num!=ModelManager.instance.modelUser.loginDateNum)){
					if(getXYCountry()>=0 && getXYCountry()<=2){
						if(b) ViewManager.instance.showView(ConfigClass.VIEW_COUNTRY_TRIBUTARY_TIPS);
						else return true;
					}
					
				}
			}
			return false;
			
		}

		/**
		 * 新的一天  重置襄阳战相关数据
		 */
		public function clearXYZ():void{
			if(mIsToday && ConfigServer.getServerTimer()<mSunrise){
				trace("===新的一天  检查襄阳战数据 ");
				//清理太守数据
				ModelOfficial.updateCityMayor(2,{"city":{"cid":-1,"country":ConfigServer.city[-1].country}});

				var xyzCitys:Array = [ -1, -2, -3, -4, -5];
				for (var i:int = 0, len:int = xyzCitys.length; i < len; i++) {
					var cid:int=xyzCitys[i];
					//重置城市归属
					ModelOfficial.cities[cid].country = ConfigServer.city[cid].country;
					//重置城市太守
					ModelOfficial.cities[cid].mayor   = null;
					//重置守军数量
					ModelOfficial.cities[cid].troop   = ConfigServer.city[cid].troop[0];
					//大地图视图刷新
					MapModel.instance.onFightEndHandler({city:{cid:cid, country:ConfigServer.city[cid].country}}, false);
				} 

				//清理黄金矿
				ModelOfficial.xyz_estate_add=null;
				ModelManager.instance.modelOfficel.event(ModelOfficial.EVENT_HIDE_GOLD_ESTATE);
			}

		}

		/**
		 * 500043：任意城门归属 变 为本国时
		 * 500044：襄阳城归属 变 为本国时
		 * 500045：襄阳当前归属本国，且刷新出黄巾军时
		 * 500046：襄阳当前归属不是本国，且刷新出黄巾军时
		 */
		public function showHeroTalk(key:String,arr:Array=null):void{
			arr=arr==null?[]:arr;
			switch(key){
				case "500043":
					MusicManager.playSoundUI(MusicManager.SOUND_XYZ_6);
					break;
				case "500044":
					MusicManager.playSoundUI(MusicManager.SOUND_XYZ_7);
					break;
			}
			ViewManager.instance.showHeroTalk([[cfg.push_show[0],cfg.push_show[1],key,arr]],null);
		}

	}

}