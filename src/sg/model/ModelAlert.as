package sg.model
{
	import laya.utils.Handler;
	import sg.manager.ModelManager;
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;
    import sg.task.model.ModelTaskDaily;
    import sg.task.model.ModelTaskTrain;
    import sg.task.model.ModelTaskBuild;
    import sg.task.model.ModelTaskOrder;
    import sg.task.model.ModelTaskPromote;
    import sg.task.model.ModelTaskCountry;
    import sg.activities.model.ModelHappy;
    import sg.explore.model.ModelExplore;
    import sg.altar.legend.model.ModelLegend;
    import sg.view.init.ViewAffiche;

	/**
	 * ...
	 * @author
	 */
	public class ModelAlert extends ModelBase{		
		public static const EVENT_RED_CHANGE:String = "event_red_change";
		public var text:String="";
		public var cost_arr:Array=[];
		public var text2:String="";
		public var only:Boolean = false;
		public var force_btn:Boolean = false;
		public var isWarn:Boolean = false;
		public var fun:*=null;
		public var repeat_key:String="";

		public function ModelAlert(){
			
		}

		public function execute(index:int):void{
			if(this.fun){
				if(this.fun is Handler){
					(this.fun as Handler).runWith(index);
				}
				else{
					var handler:Handler = Handler.create(this,this.fun,[index]);
					handler && handler.runWith(index);
				}
			}
		}
		/**
		 * 英雄,检查所有,
		 */
		public static function red_hero_all():Boolean{
			var i:int = 0
			var arr:Array = [1,2,3,4,5,6,7,8];
			var len:Number = arr.length;
			for(i = 0;i < len;i++){
				if(red_hero_once(arr[i],arr)){
					return true;
				}
			}
			return false;
		}
		public static function red_hero_once(type:Number,arr:Array = null,chmd:ModelHero = null):Boolean{
			var len:Number = 0;
			var i:Number = 0;
			if(chmd){
				if(arr){
					len = arr.length;
					for(i = 0;i < len;i++){
						if(red_hero_check(arr[i],chmd)){
							return true;
						}
					}
					return false;
				}
				return red_hero_check(type,chmd);
			}
			var hmd:ModelHero;
			var heros:*;
			if(type == 1){
				heros = ConfigServer.hero;
			}
			else{
				heros = ModelManager.instance.modelUser.hero;
			}
			for(var key:String in heros){
				hmd = ModelManager.instance.modelGame.getModelHero(key);
				if(arr){
					len = arr.length;
					for(i = 0;i < len;i++){
						if(red_hero_check(arr[i],hmd)){
							return true;
						}
					}				
				}
				else{
					if(red_hero_check(type,hmd)){
						return true;
					}
				}
			}
			return false;
		}	
		private static function red_hero_check(type:Number, hmd:ModelHero):Boolean
		{
			var b:Boolean = false;
			if(hmd.isOpenState){
				switch(type)
				{
					case 1://检查英雄解锁状态
						if(!hmd.isMine() && hmd.isReadyGetMine()){
							b = true;
							break;
						}						
						break;
					case 2://检查英雄可以安装宝物
						if(hmd.isMine() && hmd.checkEquipWill()){
							b = true;
							break;
						}						
						break;	
					case 3://检查英雄技能学习
						if(hmd.isMine() && hmd.checkSkillWill(false)){
							b = true;
							break;
						}						
						break;
					case 4://检查英雄技能升级
						if(hmd.isMine() && hmd.checkSkillWill(true)){
							b = true;
							break;
						}						
						break;	
					case 5://检查英雄宿命
						if(hmd.isMine() && hmd.checkFateWillOpen()){
							b = true;
							break;
						}						
						break;		
					case 6://检查英雄有星辰可以装
						if(hmd.isMine() && hmd.checkRuneWill2()){
							b = true;
							break;
						}						
						break;	
					case 7://检查英雄有无可安装的副将
						b = hmd.isMine() && (hmd.checkAdjutantCanInstallByType(0) || hmd.checkAdjutantCanInstallByType(1));					
						break;	
					case 8://检查英雄是否有可操作的阵法
						b = hmd.isMine() && hmd.checkFormationRed(2);		
						break;																				
					default:
						break;
				}
			}
			return b;			
		}
	
		
		public static function red_pve_pvp_all():Boolean{
			var arr:Array = [0, 1, 2, 3, 4];
			var len:int = arr.length;
			for(var i:int = 0; i < len; i++)
			{
				if(red_pve_pvp_check(arr[i])){
					return true;
				}
			}
			return false;
		}
		public static function red_pve_pvp_check(type:Number):Boolean{
			switch(type)
			{
				case 0:					
					return !ModelGame.unlock(null,"pve_climb").stop && ModelClimb.checkClimbWill();
				case 1:
					return !ModelGame.unlock(null,"pve_pve").stop && red_pve_check();		
				case 2:
					return !ModelGame.unlock(null,"pvp_pk").stop && ModelClimb.checkPkWill();		
				case 3:
					return !ModelGame.unlock(null,"pvp_champion").stop && ModelClimb.checkChampionWill();																
				case 4:
					return ModelExplore.instance.redPoint || ModelLegend.instance.redPoint;														
			}
			return false;
		}
		/**
		 * pve红点
		 */
		public static function red_pve_check():Boolean{
			if(ModelGame.unlock(null,"pve_pve").stop){//功能没开
				return false;
			}
			var arr:Array=ModelManager.instance.modelUser.pveTimes();
			if(arr[0]>0){//有剩余次数
				return true;
			}
			var obj:Object=ModelManager.instance.modelUser.pve_records.chapter;
			for(var s:String in obj){//有未领奖的章节
				var b:Boolean=red_pve_reward(s);
				if(b){
					return true;
				}
			}
			return false;
			
		}


		/**
		 * pve没领奖的红点
		 */
		public static function red_pve_reward(chapter_id:String):Boolean{
			var obj:Object=ModelManager.instance.modelUser.pve_records.chapter;
			var chapter_reward_limit:Array=ConfigServer.pve.chapter_reward_limit;
			var starNum:Number=0;//获得星数
			var getNum:Number=0;//可领奖个数
			var getedNum:Number=0;;//已领奖个数
			if(obj[chapter_id]){
				getedNum=obj[chapter_id].reward.length;
				for(var s:String in obj[chapter_id].star){
					var arr:Array=obj[chapter_id].star[s];
					for(var i:int=0;i<arr.length;i++){
						if(arr[i]==1){
							starNum+=1;
						}
					}
				}
				for(var j:int=0;j<chapter_reward_limit.length;j++){
					if(starNum>=chapter_reward_limit[j]){
						getNum+=1;
					}
				}
				return getNum>getedNum;

			} 
			
			
			return false;
		}

		/**
		 * 背包红点
		 */
		public static function red_bag_check():Boolean{
			var prop:Object=ModelManager.instance.modelUser.property;
			for(var s:String in prop){
				 if(red_bag_item(s)){
					 return true;
				 }
			}
			return false;
		}

		/**
		 * 道具id判断红点
		 */
		public static function red_bag_item(item_id:String):Boolean{
			var prop:Object=ModelManager.instance.modelUser.property;
			if(prop.hasOwnProperty(item_id) && prop[item_id]!=0 ){
				if(ModelManager.instance.modelProp.getItemProp(item_id)){
					return ModelManager.instance.modelProp.getItemProp(item_id).boxT!=null;
				}
			}
			return false;
		}

		public static function red_guild_all():Boolean{
			if(ModelManager.instance.modelGuild.isShowRedPoint){
				return true;
			}
			for(var i:int=0;i<ModelGuild.tab_key.length;i++){
				if(red_guild_check(ModelGuild.tab_key[i])){
					return true;
				}
			}
			return false;
		}

		public static function red_guild_check(key:String):Boolean{
			if(ModelManager.instance.modelUser.guild_id==null){//无军团
				return false;	
			}
			var uid:String=ModelManager.instance.modelUser.mUID;
			if(ModelManager.instance.modelGuild.name==null){
				return false;
			}
			if(key=="guild_info"){//信息
				var recharge:Array=ModelManager.instance.modelGuild.recharge;//宝藏
				for(var k:int=0;k<recharge.length;k++){
					var a:Array=recharge[k][3];
					if(a.indexOf(Number(uid))!=-1){
						return true;
					}
				}
				var redBag:Array=ModelManager.instance.modelGuild.redbag;//红包
				for(var l:int=0;l<redBag.length;l++){
					if(redBag[l][4].hasOwnProperty(uid) && redBag[l][4][uid] > 0){
						return true;
					}
				}

			}else if(key=="guild_member"){//成员
				if(ModelManager.instance.modelGuild.isLeadOrVice(uid)){
					if(Tools.getDictLength(ModelManager.instance.modelGuild.application)>0){
						return true;
					}
				}
			}else if(key=="guild_res"){//资源
				var arr:Array=ModelManager.instance.modelGuild.depot_reward;
				var n:Number=0;
				for(var i:int=0;i<arr[0].length;i++){
					n+=arr[0][i];
				}
				if(n>0){
					if(arr[1].indexOf(Number(uid))!=-1){
						return true;
					}
				}
			}else if(key=="guild_alien"){//异邦
				var alien_reward:Array=ModelManager.instance.modelUser.alien_reward;
				var now:Number=ConfigServer.getServerTimer();
				for(var j:int=0;j<alien_reward.length;j++){
					var time:Number=Tools.getTimeStamp(alien_reward[j][1]);
					if(time<=now){
						return true;
					}
				}
			}
			
			return false;
		}
		public static function red_more_all():Boolean{
			var arr:Array = /*["country",[ 'country2',*/[ "mail","office", "servier","notice"];
			var len:int = arr.length;
			for(var i:int = 0; i < len; i++)
			{
				if(red_more_check(arr[i])){
					return true;
				}
				
			}
			return false;
		}
		public static function red_more_check(id:String):Boolean{
			var b:Boolean=false;
			switch(id){
				case "mail":
					return red_more_mail();
				case "office":
					return ModelGame.unlock(null,"more_office").visible && (ModelOffice.checkLocalRedPoint() || ModelOffice.checkOfficeWill());		
				case "country":
					return ModelOfficial.checkInvadeWill();	
				case "country2":
					return ModelGame.unlock(null,"more_country").visible && ModelTaskCountry.instance.redCheck();	
				case "servier":
					return red_more_servier();
				case "notice"://公告
					return ModelGame.unlock(null,"more_notice").visible && ViewAffiche.redCheck();
			}
			return false;
		}
		/**
		 * 邮件
		 */
		public static function red_more_mail():Boolean{
			if(ModelManager.instance.modelChat.isNewMail){
				return true;
			}
			var sys:Array=ModelManager.instance.modelUser.msg.sys;
			for(var i:int=0;i<sys.length;i++){
				if(sys[i][4]==0){
					return true;
				}
			}
			var psnData:Array=ModelManager.instance.modelUser.getChatArr();
			for(var j:int=0;j<psnData.length;j++){
				if(psnData[j].data.read==false){
					return true;
				}
			}
			return false;
		}
		
		/**
		 * 客服消息
		 */
		public static function red_more_servier():Boolean{
			return ModelManager.instance.modelChat.isNewBugMSG;
		}
	
		/**
		 * 任务
		 */
		public static function red_task_all():Boolean{
			var arr:Array = [0, 1, 2, 3, 4, 5];
			var len:int = arr.length;
			for(var i:int = 0; i < len; i++)
			{
				if(red_task_check(arr[i])){
					return true;
				}
			}
			return false;
		}
		/**
		 * 任务
		 */		
		public static function red_task_check(id:Number):Boolean{
			switch(id){
				case 0:
					return ModelTask.checkWorkWill();
				case 1:
					return ModelTaskDaily.instance.redCheck();
				case 2:
					return ModelTaskTrain.instance.redCheck();
				case 3:
					return ModelTaskBuild.instance.redCheck();
				case 4:
					return ModelTaskOrder.instance.redCheck();
				case 5:
					return ModelTaskPromote.instance.redCheck();
			}
			return false;
		}

		/**
		 * 英雄管理（产业 拜访 建造）
		 */
		public static function red_hero_task():Boolean{
			var arr:Array=ModelManager.instance.modelUser.getEstateManagerArr();
			for(var i:int=0;i<arr.length;i++){
				if(arr[i]["estateFinish"]){
					return true;
				}
			}
			return false;
		}

		/**
		 * 战功奖励
		 */
		public static function red_credit_gift():Boolean{
			var config:Object=ModelManager.instance.modelUser.isMerge ? ConfigServer.credit['merge_'+ModelManager.instance.modelUser.mergeNum] : ConfigServer.credit;
			var lv:Number=ModelManager.instance.modelUser.credit_lv;
			var num:Number=ModelManager.instance.modelUser.year_credit;
			var add_max:Number=config.clv_added[lv]*config.clv_added_ratio[config.clv_added_ratio.length-1];
			if(num>add_max){//大于额外战功
				var rool_num:Number=config.clv_rool_reward[lv][1];
				var rool:Number=Math.floor((num-add_max)/rool_num);//可以获得几个循环奖励
				if(rool>ModelManager.instance.modelUser.credit_rool_gifts_num){
					return true;
				}
			}

			var n:Number=ModelManager.instance.modelUser.credit_get_gifts.length;//本年度已领取的奖励个数
			var m:Number=0;//可领奖的个数
			var max:Number=config.clv_first[lv]*config.clv_first_ratio[config.clv_first_ratio.length-1];
			if(num>max){				
				for(var i:int=config.clv_added_ratio.length-1;i>=0;i--){
					var nn:Number=config.clv_added[lv]*config.clv_added_ratio[i];
					if(num>=nn){
						m=i+1;
						break;
					}
				}
				m+=config.clv_first_ratio.length;
			}else{
				for(var j:int=config.clv_first_ratio.length-1;j>=0;j--){
					var nnn:Number=config.clv_first[lv]*config.clv_first_ratio[j];
					if(num>=nnn){
						m=j+1;
						break;
					}
				}
			}
			//trace("========",m,n);
			
			return m>n;
		}

		/**
		 * 七日嘉年华
		 */
		public static function red_happy_all():Boolean{
			for(var i:int;i<ModelHappy.instance.tabData.length;i++){
				if(ModelAlert.red_happy_by_key(ModelHappy.instance.tabData[i])){
					return true;
				}
			}
			return false;
		}

		public static function red_happy_by_key(key:String):Boolean{
			var obj:Object=ModelManager.instance.modelUser.records.happy_buy;
			if(!obj){
				return false;
			}
			switch(key){
				case "login":
					var _login:Array=obj.login;
					if(_login[2].length>0){
						return true;
					}
					break;
				case "sparta":
					for(var i:int=1;i<=5;i++){
						if(red_happy_sparta_by_index(i)){
							return true;
						}
					}
					if(red_happy_sparta_big_reward()){
						return true;
					}
					break;
				case "purchase":
					var _purchase:Array=obj.purchase;
					if(_purchase){
						var n:Number=_purchase[2]==ModelManager.instance.modelUser.loginDateNum?_purchase[1]:-1;
						var m:Number=_purchase[2] ? _purchase[2]-1 : 0;
						if(n>=0 && _purchase[0]==0 && n>=ConfigServer.ploy.happy_buy.purchase.need_pay_money[m]){
							return true;
						}
					}
					
					break;
				case "addup":
					var _addup:Array=obj.addup;
					if(_addup[2].length>0){
						return true;
					}
					break;
				case "once":
					var _once:Array=ModelManager.instance.modelUser.records.happy_buy.once;
					if(_once[3].length>0 || _once[0]==1){
						return true;
					}
					break;
			}
			return false;
		}

		public static function red_happy_sparta_by_index(index:int):Boolean{
			var obj:Object=ModelHappy.instance.getSpartaTaskByType(index);
			var b:Boolean=index<=ModelHappy.instance.openDays;
			if(b && obj){
				for(var s:String in obj){
					if(ModelAlert.red_happy_sparta_by_key(obj[s].id)){
						return true;
					}
				}
			}
			
			return false;
		}
		
		public static function red_happy_sparta_by_key(key:String):Boolean{
			var obj:Object=ModelManager.instance.modelUser.records.happy_buy.sparta;
			var cfg:Array=ConfigServer.ploy.happy_buy.sparta.task[key].target;
			if(obj && obj.hasOwnProperty(key)){
				for(var s:String in obj[key]){
					var arr:Array=obj[key][s];
					var n:Number=cfg[Number(s)][0][0];
					if(arr[0]>=n && arr[1]==0){
						return true;
					}
				}
			}
			return false;
		}

		public static function red_happy_sparta_big_reward():Boolean{			
			if(ModelHappy.instance.openDays>7 && ModelHappy.instance.getSpartaScore()>0){
				return true;
			}
			return false;
		}

		/**
		 * 新的国家红点
		 */
		public static function red_country_all():Boolean{
			var arr:Array=["country_task","country_bag","country_alien","country_impeach"];
			for(var i:int=0;i<arr.length;i++){
				var b:Boolean=ModelAlert.red_country_check(arr[i]);
				if(b)
					return true;
				
			}
			return false;
		}

		
		public static function red_country_check(key:String):Boolean{
			if(ModelGame.unlock(null,"more_country").stop){
				return false;
			}
			switch(key){
				case "country_task":
					return ModelTaskCountry.instance.redCheck();
				case "country_bag":
					if(ModelManager.instance.modelClub.u_redbag_num<ModelManager.instance.modelClub.redbag_num){
						return true;
					}
					if(ModelManager.instance.modelUser.quota_gift!=null){
						return true;
					}
					return false;
				case "country_alien":
					var alien_reward:Array=ModelManager.instance.modelUser.alien_reward;
					var now:Number=ConfigServer.getServerTimer();
					for(var j:int=0;j<alien_reward.length;j++){
						var time:Number=Tools.getTimeStamp(alien_reward[j][1]);
						if(time<=now){
							return true;
						}
					}
					if(alien_reward.length<3){
						if(!ModelManager.instance.modelClub.isInTeam()){
							//trace("======宝箱不满 且未在组队中");
							return true;
						}
					}
					return false;
				case "country_impeach":
					return red_country_impeach();
			}
			return false;
			
		}

		/**
		 * 弹劾 可投票 
		 */
		public static function red_country_impeach():Boolean{
			var n:Number = ModelOfficial.getImpeachStatus();
			if(n==1){
				return true;
			}
			return false;
		}

		

	}


	
}