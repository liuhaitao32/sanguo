package sg.manager
{
	import laya.events.EventDispatcher;
	import sg.guide.model.ModelGuide;
	import sg.cfg.ConfigClass;
	import sg.model.ModelOfficial;
	import sg.activities.model.ModelWeekCard;
	import sg.cfg.ConfigServer;
	import sg.activities.model.ModelPayRank;
	import sg.utils.SaveLocal;
	import sg.utils.Tools;
	import sg.cfg.ConfigApp;
	import sg.model.ModelFightTask;
	import sg.view.init.ViewHeroTalk;
	import sg.model.ModelGame;
	import sg.festival.model.ModelFestival;
	import sg.activities.model.ModelMemberCard;
	import sg.model.ModelSalePay;
	import sg.activities.view.ViewSalePayAlert;

	/**
	 * ...
	 * @author hw 弹窗队列
	 */
	public class QueueManager extends EventDispatcher{
		
		public static const EVENT_CLOSE_PANEL:String = "event_close_panel";//面板关闭

		public static var sViewManager:QueueManager = null;
		public static function get instance():QueueManager{
			return sViewManager ||= new QueueManager();
		}

		public var queueList:Array=[];
		public var mIndex:Number=0;
		public var mIsOver:Boolean=false;
		public var mIsGoto:Boolean=false;

		public function QueueManager(){
			
		}

		/**
		 * 刚进游戏就需要弹窗的列表
		 */
		public function checkInitQueue():void{
			mIsOver=false;
			mIndex=0;
			queueList=[];
			if(ModelGuide.forceGuide()){//新手引导
				return;
			}
			//不开充值就不弹
			if(ModelGame.unlock(null,"pay").stop){
				return;
			}

			//战功结算
			if(ModelManager.instance.modelUser.credit_settle && ModelManager.instance.modelUser.credit_settle.length!=0){
				queueList.push({"view":ConfigClass.VIEW_CREDITRESULT,"arg":null,"id":""});
			}

			//即将过期的抵扣券
			var saleArr:Array = ModelSalePay.getOverdueList();
			if(saleArr.length>0) queueList.push({"view":ConfigClass.VIEW_SALE_PAY_ALERT,"arg":saleArr,"id":""});

			//国王
			var arr1:Array=ModelOfficial.checkCountryKingTips();
			if(arr1!=null){
				queueList.push({"view":ConfigClass.VIEW_COUNTRY_KING_TIPS,"arg":arr1,"id":""});
			}

			// 永久卡
			ModelMemberCard.instance.needPop && queueList.push({"view":ConfigClass.VIEW_MEMBER_CARD,"id":""});    

			// 周卡
			ModelWeekCard.instance.needPop && queueList.push({"view":ConfigClass.VIEW_WEEK_CARD,"id":""});    
			
			//公告日期
			var arr2:Array=checkNoticePictureDay();
			for(var j:int=0;j<arr2.length;j++){
				queueList.push({"view":ConfigClass.VIEW_NOTICE_PICTURE,"arg":arr2[j],"id":"notice_picture_"+j}); 
			}

			//公告开服天数
			var arr3:Array=checkNoticePicture();
			for(var i:int=0;i<arr3.length;i++){
				queueList.push({"view":ConfigClass.VIEW_NOTICE_PICTURE,"arg":arr3[i],"id":"notice_picture_"+i}); 
			}

			//襄阳战开战
			if(ModelManager.instance.modelCountryPvp.checkShowBeginTips()){
				queueList.push({"view":ConfigClass.VIEW_COUNTRY_PVP_TIPS,"arg":null,"id":""}); 
			}
			//年度进贡报告
			if(ModelManager.instance.modelCountryPvp.showTrbutaryView(false)){
				queueList.push({"view":ConfigClass.VIEW_COUNTRY_TRIBUTARY_TIPS,"arg":null,"id":""}); 
			}
			
			//消费榜
			ModelPayRank.instance.canPop && queueList.push({"view":ConfigClass.VIEW_PAY_RANK_TIPS, "id":""}); 

			//君临天下
			showEmperorTips()!=null && queueList.push({"view":ConfigClass.VIEW_EMPEROR_TIPS,"arg":showEmperorTips(), "id":""}); 
			
			//购买宝物
			var s:String = showGetWeapen();
			s!="" && queueList.push({"view":ConfigClass.VIEW_FREE_BUY,"arg":s, "id":""}); 
			
			//节日活动
			var festArr:Array = showFestivalAD();
			festArr.length!=0 && queueList.push({"view":ConfigClass.VIEW_NOTICE_PICTURE,"arg":[festArr,"festival"],"id":"festival"}); 

			// 国战任务
			ModelFightTask.instance.needPush && queueList.push({"view": ["ViewHeroTalk",ViewHeroTalk], "arg":ModelFightTask.instance.talkArgs, "id":""}); 
		
		}


		public function showFirst():void{
			if(queueList.length>0){
				ViewManager.instance.showView(queueList[mIndex].view,queueList[mIndex].arg);
				mIndex++;
			}else{
				mIsOver=true;
			}
		}

		public function showNext(vid:String):void{
			if(mIsGoto){
				if(ViewManager.instance.mScenesArr.length==0 && ViewManager.instance.isNoPanel() && ViewManager.instance.isNoScence()){
					if(queueList[mIndex]){
						ViewManager.instance.showView(queueList[mIndex].view,queueList[mIndex].arg);
						mIndex++;
					}else{
						mIsOver=true;
					}
					mIsGoto=false;
				}
				return;
			}
			if(queueList[mIndex]){
				if(queueList[mIndex-1] && queueList[mIndex-1].view[0]==vid){
					ViewManager.instance.showView(queueList[mIndex].view,queueList[mIndex].arg);
					mIndex++;
				}
			}else{
				mIsOver=true;
			}
			
		}


		//======检查活动弹窗 开服天数
		private function checkNoticePicture():Array{
			var o:Object=ConfigServer.notice.notice_picture;
			var a:Array=[];
			if(o){
				var openDays:Number=ModelManager.instance.modelUser.loginDateNum;
				//var open:Array=ModelManager.instance.modelUser.isMerge ? o.open_day_merge : o.open_day;
				var mergeNum:Number=ModelManager.instance.modelUser.mergeNum;
				var open:Array=o["open_day_"+mergeNum];
				if(open){
					for(var i:int=0;i<open.length;i++){
						var s:String=open[i][0];
						var arr:Array=s.split('_');
						var n1:Number=Number(arr[0]);
						var n2:Number=Number(arr[1]);
						//trace("开服天数 ",openDays,"活动时间 ",n1,"天到",n2,"天");
						if(openDays>=n1 && openDays<=n2){
							//return [o[o.open_day[s]],"notice_picture"];
							a.push([o[open[i][1]],"notice_picture"]);
						}
					}
					
				}
			}
			return a;
		}
		//======检查活动弹窗 固定日期
		private function checkNoticePictureDay():Array{
			var obj:Object=ConfigServer.notice.notice_picture_day;
			var arr:Array=[];
			for(var s:String in obj){
				var o:Object=obj[s];
				if(o.open_day && o.close_day){
					var now:Number=ConfigServer.getServerTimer();
					var arr1:Array=o.open_day.split('-');
					var arr2:Array=o.close_day.split('-');

					var dt1:Date=new Date(arr1[0],Number(arr1[1])-1,arr1[2],arr1[3],arr1[4]);
					var dt2:Date=new Date(arr2[0],Number(arr2[1])-1,arr2[2],arr2[3],arr2[4]);

					var n1:Number=dt1.getTime();
					var n2:Number=dt2.getTime();

					var b1:Boolean = false;
					var b2:Boolean =false;
					if(now>=n1 && now<=n2){
						if(o.area){
							if(o.area[0].length==0 && o.area[1].length==0){
								b1 = true;
							}else if(o.area[0].length!=0){
								//可见的区
								if(o.area[0].indexOf(ModelManager.instance.modelUser.zone)!=-1 || o.area[0].indexOf(ModelManager.instance.modelUser.mergeZone)!=-1){
									//arr.push([o.group1,"notice_picture_day"]);
									b1 = true;
								}
							}else if(o.area[1].length!=0){
								//不可见的区
								if(o.area[1].indexOf(ModelManager.instance.modelUser.zone)==-1 || o.area[1].indexOf(ModelManager.instance.modelUser.mergeZone)==-1){
									//arr.push([o.group1,"notice_picture_day"]);
									b1 = true;
								}
							}	
						}else{
							b1 = true;
						}

						if(o.pf){
							if(o.pf[0].length==0 && o.pf[1].length==0){
								b2 = true;
							}else if(o.pf[0].length!=0){
								//可见的平台
								if(o.pf[0].indexOf(ConfigApp.pf)!=-1){
									b2 = true;
								}
							}else if(o.pf[1].length!=0){
								//不可见的平台
								if(o.pf[1].indexOf(ConfigApp.pf)==-1){
									b2 = true;
								}
							}
						}else{
							b2 = true;
						}
					}

					if(b1 && b2){
						arr.push([o.group1,"notice_picture_day"]);
					}
				}
			}
			return arr;
		}

		/**
		 * 君临天下
		 */
		public function showEmperorTips():Array{
			if(ModelManager.instance.modelCountryPvp.mIsToday==false){
				if([0,1,2].indexOf(ModelOfficial.cities["-1"].country)!=-1){
					var o:Object=SaveLocal.getValue(SaveLocal.KEY_EMPEROR_TIPS_TIME+ModelManager.instance.modelUser.mUID,true);
					if(o==null || (o.time && Tools.isNewDay(o.time))){
						var n:Number=ModelOfficial.cities["-1"].country;
						return [n,ModelOfficial.countries[n].official[0] ? ModelOfficial.countries[n].official[0][1] : ""];
					}
				}
			}
			return null;
		}

		/**
		 * 购买宝物
		 */
		public function showGetWeapen():String{
			var config:Object = ConfigServer.ploy.day_buy_weapon;
			var user:Object   = ModelManager.instance.modelUser.records.day_buy_weapon;
			var n:Number      = ModelManager.instance.modelUser.loginDateNum;
			if(config==null) return "";
			for(var s:String in config){
				//未领取 && 达到充值数额
				if(n>=config[s].open_day[0] && n<=config[s].open_day[1]){
					if(user.hasOwnProperty(s)==false) 
						return "day_buy_weapon_"+s;
					else{
						if(user[s][0]<config[s].need_pay)
							return "day_buy_weapon_"+s;
					}
				}
			}
			return "";
		}

		//======节日活动
		public function showFestivalAD():Array{
			return ModelFestival.instance.poster;
		}
		
	}

}