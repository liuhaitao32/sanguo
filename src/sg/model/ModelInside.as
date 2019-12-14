package sg.model
{
	import sg.model.ModelBase;
	import laya.utils.Utils;
	import sg.model.ModelBuiding;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.net.NetSocket;
	import sg.net.NetMethodCfg;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.utils.Tools;
	import ui.inside.pubHeroItemUI;
	import laya.ani.bone.Bone;
	import sg.home.model.entitys.EntityBuild;
	import sg.scene.view.entity.EntityClip;
	import laya.maths.Point;
	import sg.manager.AssetsManager;
	import sg.view.effect.EquipGet;
	import sg.view.effect.EquipUpgrade;
	import sg.view.effect.ArmyUpgrade;
	import sg.view.effect.EquipUpgradeLoser;
	import sg.boundFor.GotoManager;
	import sg.manager.EffectManager;
	import sg.utils.MusicManager;
	import sg.guide.view.GuideFocus;
	import sg.altar.legendAwaken.model.ModelLegendAwaken;

	/**
	 * ...
	 * @author
	 */
	public class ModelInside extends ModelBase{
		//
		public static const BUILDING_STATUS_CHANGE:String       = "building_status_change";//状态改变
		public static const BUILDING_SET:String                 = "building_set";
		public static const BUILDING_UPDATE_END:String          = "building_update_end";//建筑cd完成
		public static const BUILDING_UPDATE_CD:String           = "building_update_cd";//建筑cd更新
		public static const BUILDING_BUILDER_ADD:String         = "building_builder_add";
		public static const BUILDING_BUILDER_REMOVE:String      = "building_builder_remove";
		//
		public static const BUILDING_GIFT_PRODUCE_OK:String     = "building_gift_produce_ok";
		public static const BUILDING_GIFT_PRODUCE_READY:String  = "building_gift_produce_ready";
		//
		public static const EQUIP_BUILDER_ADD:String            = "equip_builder_add";
		public static const EQUIP_UPDATE_REMOVE:String          = "equip_update_remove";
		public static const EQUIP_UPDATE_GET:String             = "equip_update_get";
		public static const EQUIP_UPDATE_CD:String              = "equip_update_cd";
		//
		public static const SCIENCE_BUILDER_ADD:String          = "science_builder_add";
		public static const SCIENCE_UPDATE_CD:String            = "science_update_cd";
		public static const SCIENCE_UPDATE_REMOVE:String        = "science_update_remove";
		public static const SCIENCE_UPDATE_GET:String           = "science_update_get";		
		public static const SCIENCE_CHANGE_STATUS:String         = "science_change_status";		
		//
		public static const ARMY_BUILDING_TRAIN_UPDATE_CD:String = "army_building_train_update_cd";
		public static const ARMY_BUILDING_TRAIN_GET:String       = "army_building_train_get";
		//
		public static const CHANGE_AUTO_MK_ARMY:String           = "event_change_auto_mk_army";//补兵开关
		public static const ARMY_BUILDING_TRAIN_SPEED_UP:String  = "event_army_building_train_speed_up";//补兵手动加速

		public var mBuildingArr:Array;//建筑升级队列
		public var mArmyArr:Array;//产兵队列
		public var mScienceArr:Array;//科技队列
		public var mEquipArr:Array;//宝物队列

		public var mbuildArmyObj:Object;//造兵cd
		//
		public function ModelInside(){
			this.on(BUILDING_BUILDER_REMOVE,this,this.building_builder_remove);
			this.on(EQUIP_UPDATE_REMOVE,this,this.equip_update_remove);
			this.on(SCIENCE_UPDATE_REMOVE,this,this.science_update_remove);
			this.on(ARMY_BUILDING_TRAIN_SPEED_UP,this,this.eventCallBackForBuildArmy,["update_cd"]);
			this.on(CHANGE_AUTO_MK_ARMY,this,this.eventCallBackForBuildArmy,["auto"]);
			setArmyCdObj(2);
		}
		//
		/**
		 * 初始化 所有封地 model
		 */
		public function initCDlistener():void{
			this.initBuildingArr();
			this.initEquipArr();
			this.initScienceArr();
			//
			Laya.timer.clear(this,this.onTimer);
			Laya.timer.loop(1000,this,this.onTimer);
		}
		/**
		 * 获得 建筑 model
		 */
		public function getBuildingModel(bid:String):ModelBuiding{
            if(!ModelBuiding.buildingModels.hasOwnProperty(bid)){
                ModelBuiding.buildingModels[bid] = new ModelBuiding();
				(ModelBuiding.buildingModels[bid] as ModelBuiding).initData(bid,ConfigServer.home[bid]);
            }
            return ModelBuiding.buildingModels[bid] as ModelBuiding;			
		}
		/**
		 * 初始 建筑 升级 队列
		 */
		public function initBuildingArr():void{
			this.mBuildingArr = [];
			//
			var arr:Array = ModelManager.instance.modelUser.building_cd_arr;
			var len:int = arr.length;
			var serverNow:Number = ConfigServer.getServerTimer();
			var obj:Object;
			var md:ModelBuiding;
			for(var index:int = 0; index < len; index++)
			{
				obj = Tools.getObjValue(arr,index,null);
				if(obj){
					md = this.getBuildingModel(obj["id"]);
					if(md){
						// md.setCD(obj["cd"]);
						if(md.isUpgradeIng()){
							this.mBuildingArr.push(md);
						}
					}
				}
			}
			//
		}
		public function initEquipArr():void{
			this.mEquipArr = [];
			var equip:ModelEquip;
			var key:String = "";
			if(ModelManager.instance.modelUser.equip_cd.length>0)
			{
				key = ModelManager.instance.modelUser.equip_cd[2];
				equip = ModelManager.instance.modelGame.getModelEquip(key);
				//
				this.mEquipArr.push(equip);
			}
			
		}
		public function initScienceArr():void{
			this.mScienceArr = [];
			var smd:ModelScience;
			var key:String = "";
			if(ModelManager.instance.modelUser.records.hasOwnProperty("science_cd")){
				var arr:Array = ModelManager.instance.modelUser.records["science_cd"];
				if(arr.length>0){
					key = arr[0];
					smd = ModelManager.instance.modelGame.getModelScience(key);
					this.mScienceArr.push(smd);
				}
			}
		}
		/**
		 * 检查 建筑 功能 开启 [{visible,label,type},...]
		 */
		public function checkBuildingView(bmd:ModelBuiding,test:Boolean = false):Array{
			var status:int = this.checkBuildingStatus(bmd);
			//
			var v0:Object = {visible:false,label:"",type:0,gray:false,icon:"", name2: 0};
			var v1:Object = {visible:false,label:"",type:1,gray:false,icon:"", name2: 0};//AssetsManager.getAssetsUI("home_01.png")详细
			var v2:Object = {visible:false,label:"",type:2,gray:false,icon:"", name2: 0};
			var v3:Object = {visible:false,label:"",type:3,gray:false,icon:"",gray:false,text:"", name2: 0};
			var v4:Object = {visible:false,label:"",type:4,gray:false,icon:"", name2: 0};
			var v5:Object = {visible:false,label:"",type:5,gray:false,icon:"", name2: 0};
			//
			
			var sid:int = status%10;//状态类型
			var tid:int = Math.floor(status/10);//功能类型
			//
			if(status < 0){
				v0.visible = test;
				v0.label = test?Tools.getMsgById("_public172"):"";//"解锁"
				v0.name2 = 0;
				v1.visible = false;
			}
			else{
				if(sid==0){
					
					v0.visible = !bmd.checkIsMaxLv(bmd.lv+1);
					v0.label = Tools.getMsgById("_building23");//"升级";
					v0.name2 = 1;
					v0.icon = AssetsManager.getAssetsUI("home_04.png");//升级图标
					//
					if(tid == 3){
						v2.visible = true;
						v2.label = Tools.getMsgById("_public173");//"训练";
						v2.name2 = 2;
						v2.icon = AssetsManager.getAssetsUI(AssetsManager.army_icon_building_ui[ModelBuiding.army_type[bmd.id]]);//AssetsManager.getAssetsUI("home_03.png");
						//
						v3.visible = ModelGame.unlock(null,"army_upgrade").visible;
						v3.gray = ModelGame.unlock(null,"army_upgrade").gray;
						v3.text = ModelGame.unlock(null,"army_upgrade").text;
						v3.label = Tools.getMsgById("_public174");//"研究";
						v3.name2 = 3;
						v3.icon = AssetsManager.getAssetsUI("home_36.png");
					}
					else if(tid == 4){
						v2.visible = ModelGame.unlock(null,"equip_get").visible;
						v2.gray = ModelGame.unlock(null,"equip_get").gray;
						v2.label = Tools.getMsgById("_public175");//"锻造";
						v2.name2 = 4;
						v2.icon = AssetsManager.getAssetsUI("home_03.png");
						//
						v3.visible = ModelGame.unlock(null,"equip_up").visible;
						v3.gray = ModelGame.unlock(null,"equip_up").gray;
						v3.label = Tools.getMsgById("_public176");//"突破";
						v3.name2 = 5;
						v3.icon = AssetsManager.getAssetsUI("home_08.png");
						//
						v4.visible = ModelGame.unlock(null,"equip_wash").visible;
						v4.gray = ModelGame.unlock(null,"equip_wash").gray;
						v4.text = ModelGame.unlock(null,"equip_wash").text;
						v4.label = Tools.getMsgById("_public177");//"洗炼";
						v4.name2 = 6;
						v4.icon = AssetsManager.getAssetsUI("home_28.png");

						v5.visible = ModelGame.unlock(null,"equip_enhance").visible;
						v5.gray = ModelGame.unlock(null,"equip_enhance").gray;
						v5.text = ModelGame.unlock(null,"equip_enhance").text;
						v5.label = Tools.getMsgById("_enhance09");//"强化";
						v5.name2 = 7;
						v5.icon = AssetsManager.getAssetsUI("home_62.png");
						
					}
					else if(tid == 11){
						v2.visible = true;
						v2.label = Tools.getMsgById("_public48");//"科技";
						v2.name2 = 7;
						v2.icon = AssetsManager.getAssetsUI("home_07.png");
					}
				}	
				else if(sid==1){
					v0.visible = true;
					v0.label = Tools.getMsgById("_building21");//"加速";
					v0.name2 = 8;
					v0.icon = AssetsManager.getAssetsUI("home_02.png");
					if(bmd.isEquip()){
						v2.visible = ModelGame.unlock(null,"equip_wash").visible;
						v2.gray = ModelGame.unlock(null,"equip_wash").gray;
						v2.text = ModelGame.unlock(null,"equip_wash").text;
						v2.label = Tools.getMsgById("_public177");//"洗炼";
						v2.name2 = 6;
						v2.icon = AssetsManager.getAssetsUI("home_28.png");

						v3.visible = ModelGame.unlock(null,"equip_enhance").visible;
						v3.gray = ModelGame.unlock(null,"equip_enhance").gray;
						v3.text = ModelGame.unlock(null,"equip_enhance").text;
						v3.label = Tools.getMsgById("_enhance09");//"强化";
						v3.name2 = 7;
						v3.icon = AssetsManager.getAssetsUI("home_62.png");
					}
					else if(bmd.isArmy()){
						v2.visible = ModelGame.unlock(null,"army_upgrade").visible;
						v2.gray = ModelGame.unlock(null,"army_upgrade").gray;
						v2.text = ModelGame.unlock(null,"army_upgrade").text;
						v2.label = Tools.getMsgById("_public174");//"研究";
						v2.name2 = 3;
						v2.icon = AssetsManager.getAssetsUI("home_36.png");
					}
				}
				else if(sid == 2){
					v0.visible = true;
					v0.label = Tools.getMsgById("_public178");//"收获";	
					v0.name2 = 9;	
				}
				else if(sid == 3){//科技特殊
					v0.visible = !bmd.checkIsMaxLv(bmd.lv+1);
					v0.label = Tools.getMsgById("_building23");//"升级";
					v0.name2 = 1;
					v0.icon = AssetsManager.getAssetsUI("home_04.png");//升级图标
				}
				else if(sid == 4){//科技特殊
					v0.visible = true;
					v0.label = Tools.getMsgById("_building21");//"加速";
					v0.name2 = 8;
					v0.icon = AssetsManager.getAssetsUI("home_02.png");
				}				
				//

				//功能不冲突
				if(tid == 5){
					v2.visible = true;
					v2.label = Tools.getMsgById("_public179");//"招募";
					v2.name2 = 10;
					v2.icon = AssetsManager.getAssetsUI("home_24.png");
				}
				else if(tid == 6){
					v2.visible = true;
					v2.visible = ModelGame.unlock(null,"star_get").visible;
					v2.gray = ModelGame.unlock(null,"star_get").gray;
					v2.text = ModelGame.unlock(null,"star_get").text;
					v2.label = Tools.getMsgById("540159");//"观星"
					v2.name2 = 11;
					v2.icon = AssetsManager.getAssetsUI("home_29.png");

					v3.visible = true;
					v3.visible = ModelGame.unlock(null,"star_resolve").visible;
					v3.gray = ModelGame.unlock(null,"star_resolve").gray;
					v3.text = ModelGame.unlock(null,"star_resolve").text;
					v3.label = Tools.getMsgById("_public180");//"碎星";
					v3.name2 = 12;
					v3.icon = AssetsManager.getAssetsUI("home_30.png");

					v4.visible = true;
					v4.visible = ModelGame.unlock(null,"prop_resolve").visible;
					v4.gray = ModelGame.unlock(null,"prop_resolve").gray;
					v4.text = ModelGame.unlock(null,"prop_resolve").text;
					v4.label = Tools.getMsgById("add_resolve");//"问道";
					v4.name2 = 13;
					v4.icon = AssetsManager.getAssetsUI("home_35.png");
				}
				else if(tid == 7){
					v2.visible = true;
					v2.label = Tools.getMsgById("_public44");//"购买";
					v2.name2 = 14;
					v2.icon = AssetsManager.getAssetsUI("home_25.png");
				}	
				else if(tid == 8){
					v2.visible = ModelGame.unlock(null,"more_office").visible;
					v2.gray = ModelGame.unlock(null,"more_office").gray;
					v2.text = ModelGame.unlock(null,"more_office").text;
					v2.label = Tools.getMsgById("add_office");//"爵位";
					v2.name2 = 15;
					v2.icon = AssetsManager.getAssetsUI("home_09.png");
					//
					v3.visible = ModelGame.unlock(null,"shogun").visible;
					v3.gray=ModelGame.unlock(null,"shogun").gray;
					v3.text=ModelGame.unlock(null,"shogun").text;
					v3.label = Tools.getMsgById("lvup12_1_name");//"幕府";
					v3.name2 = 16;
					v3.icon = AssetsManager.getAssetsUI("home_33.png");
					//
					v4.visible = ModelGame.unlock(null,"effort").visible;
					v4.gray=ModelGame.unlock(null,"effort").gray;
					v4.text=ModelGame.unlock(null,"effort").text
					v4.label = Tools.getMsgById("_jia0015");//"史册";
					v4.name2 = 17;
					v4.icon = AssetsManager.getAssetsUI("home_51.png");					
				}	
				else if(tid == 9){
					v2.visible = ModelGame.unlock(null,"pve_climb").visible;
					v2.gray = ModelGame.unlock(null,"pve_climb").gray;
					v2.text=ModelGame.unlock(null,"pve_climb").text;
					v2.label = Tools.getMsgById("add_climb");//"过关斩将";//
					v2.name2 = 18;
					v2.icon = AssetsManager.getAssetsUI("home_32.png");
					//
					v3.visible = ModelGame.unlock(null,"pve_pve").visible;
					v3.gray = ModelGame.unlock(null,"pve_pve").gray;
					v3.text=ModelGame.unlock(null,"pve_pve").text;
					v3.label = Tools.getMsgById("add_pve");//"沙盘演绎";
					v3.name2 = 19;
					v3.icon = AssetsManager.getAssetsUI("home_34.png");
				}	
				else if(tid == 10){
					v2.visible = ModelGame.unlock(null,"pvp_pk").visible;
					v2.gray = ModelGame.unlock(null,"pvp_pk").gray;
					v2.text=ModelGame.unlock(null,"pvp_pk").text;
					v2.label = Tools.getMsgById("add_both");//"群雄逐鹿";//
					v2.name2 = 20;
					v2.icon = AssetsManager.getAssetsUI("home_31.png");
					//
					v3.visible = ModelGame.unlock(null,"pvp_champion").visible;
					v3.gray = ModelGame.unlock(null,"pvp_champion").gray;
					v3.text=ModelGame.unlock(null,"pvp_champion").text;
					v3.label = Tools.getMsgById("add_pk_yard");//"比武大会";
					v3.name2 = 21;
					v3.icon = AssetsManager.getAssetsUI("home_33.png");
				}	
				else if(tid == 12){
					v2.visible = ModelGame.unlock(null,"legend").visible;
					v2.gray=ModelGame.unlock(null,"legend").gray;
					v2.text=ModelGame.unlock(null,"legend").text;
					v2.label = Tools.getMsgById("_jia0118");//"见证传奇";
					v2.name2 = 22;
					v2.icon = AssetsManager.getAssetsUI("home_legend.png");
				}						
				else if(tid == 13){
					v2.visible = ModelLegendAwaken.instance.open;
					v2.gray=false;
					v2.text='';
					v2.label = Tools.getMsgById("500301");//"英雄冢";
					v2.name2 = 23;
					v2.icon = AssetsManager.getAssetsUI("home_63.png");
				}						
			}
			//
			return [v0,v1,v2,v3,v4,v5];
		}
		public function getBase():ModelBuiding{
			return this.getBuildingModel("building001");
		}
		public function updateBaseBuilding():void{
			if(ModelManager.instance.modelGame.isInside){
				this.getBase().event(BUILDING_STATUS_CHANGE);
			}
		}		

		/**
		 * 检查 建筑 状态 (每个功能建筑看注释)
		 */
		public function checkBuildingStatus(md:ModelBuiding,upgradeIng:Boolean = false):int{
			var status:int = -1;
			var ing:int = 1;
			if(md.lv<=0){
				//需要解锁
				status = -1;
			}
			else{
				if(this.checkBuildingIsIng(md)){
					status = 11;//建筑升级中,需要秒 cd
					ing = 1;
					if(upgradeIng){
						return status;
					}
				}
				else{
					ing = 0;
					status = 10;//标准建筑 正常模式
					//
					if(upgradeIng){
						return status;
					}
					if(md.produce>=0){
						//这里是产出型建筑
						var gifts:Number = md.getMyGift(md.lv);
						if(gifts>0){
							//有东西产出,准备收获
							status = 22;
						}
						else{
							status = 20;// 产出资源类建筑正常模式
						}
					}//非产出,非升级中
					else if(md.isArmy()){
						//是兵营
						if(md.getMakingArmyLastTimer()>0){
							//有 训练兵 需要秒 cd
							status = 31;
						}
						else{
							if(md.getArmyMakingNum()>0){
								status = 32;//准备收获
							}
							else{
								status = 30;//可以训练,兵营类正常模式
							}
						}
					}
					else if(md.isEquip()){//宝物
						var emd:ModelEquip = ModelEquip.getCDingModel();
						if(emd){//有宝物
							var isGet:Boolean = emd.getLastCDtimer()<=0;
							if(emd.isUpgradeIng()>-1){//宝物在锻造或升级中
								if(isGet){//
									status = 42;//准备收获宝物
								}
								else{
									status = 41;//需要秒 cd
								}
							}
							else{
								status = 40;//正常模式
							}
						}
						else{
							status = 40;//正常模式
						}
					}
					else if(md.isScience()){//科技
						var smd:ModelScience = ModelScience.getCDingModel();
						if(smd){
							var isUpOk:Boolean = smd.getLastCDtimer()<=0;
							if(smd.isUpgradeIng()>-1){
								if(ModelScience.check_science_day_get()){
									status = 113;//收获buff
								}
								else{
									if(isUpOk){
										status = 112;//收获
									}
									else{
										status = 111;//需要秒 cd
										if(ModelScience.check_science_day_get()){
											status = 114;
										}
									}
								}
							}
							else{
								status = 110;//正常模式
								if(ModelScience.check_science_day_get()){//有buff 收获物品
									status = 113;//收获buff
								}								
							}
						}
						else{
							status = 110;//正常模式
							if(ModelScience.check_science_day_get()){//有buff 收获物品
								status = 113;//收获buff
							}							
						}
						
					}					
					else{
						status = 10;//普通建筑正常模式
					}
				}
				//没!!!!是否升级中的限制,常态
				if(md.isPubHero()){
					status = 50+ing;//酒馆,可以抽取
				}
				else if(md.isStarRuneHero()){
					status = 60+ing;//问道,观星可以抽取
				}
				else if(md.isBagagage()){
					status = 70+ing;//辎重,可以抽取
				}
				else if(md.isBase()){
					status = 80+ing;//官邸
				}
				else if(md.isPVE()){//过关斩将
					status = 90+ing;
					if(ModelManager.instance.modelClimb.isGetAward()){
						status = 93;
					}
				}
				else if(md.isPVP()){
					status = 100+ing;
				}	
				else if(md.isAltar()){
					status = 120+ing;//祭坛
				}			
				else if(md.isAwaken()){
					status = 130+ing;//英雄冢
				}			
			}
			return status;
		}
		/**
		 * 检查 功能 运行,
		 * cType == -1,代表气泡,气泡如果是产出状态,跳过
		 */
		public function checkBuildingFunc(bmd:ModelBuiding,cType:int = 0):void{	
			var status:int = this.checkBuildingStatus(bmd);
			var sid:int = status%10;//状态类型
			var tid:int = Math.floor(status/10);//功能类型	
			var btnType:int = cType;

			if(btnType<0){
				if(sid==1 && bmd.isFreeCanUse()){
					bmd.netUpgrade({item_id:-2,item_num:1,bid:bmd.id},null);
					return;
				}				
				if(sid>=0 && sid<2){//非产出状态
					if(bmd.isPubHero()){
						GotoManager.boundForPanel(GotoManager.VIEW_PUB);
					}
					else if(bmd.isStarRuneHero()){
						ViewManager.instance.showView(ConfigClass.VIEW_STAR_GET);
					}
					else if(bmd.isScience()){
						//补丁
						var smd:ModelScience = ModelScience.getCDingModel();
						var b0:Boolean = smd && smd.isUpgradeIng()>-1 && smd.getLastCDtimer()<=0; //收获科技
						var b1:Boolean=ModelScience.check_science_day_get();                      //有buff 收获物品
						if(b0){
							this.checkScienceGet();
						}else if(b1){
							this.checkScienceDayGet();
						}else{
							ViewManager.instance.showView(ConfigClass.VIEW_SCIENCE_MAIN);
						}
					}
					else if(bmd.isBase()){
						if(ModelOffice.checkOfficeCanUp()){
							GotoManager.boundForPanel(GotoManager.VIEW_OFFICE_MAIN);
						}
						else if(ModelManager.instance.modelUser.isCanLvUpShogun()){
							GotoManager.boundForPanel(GotoManager.VIEW_SHOGUN_MAIN);
						}
						else if(ModelManager.instance.modelAchievement.hasNewAchieve()){
							GotoManager.boundForPanel(GotoManager.VIEW_ACHIEVEMENT);
						}
						else{

						}
					}
					else if(bmd.isBagagage()){
						if(ModelBuiding.isBaggageBubble() || ModelBuiding.isBaggageBubble1()){
							ViewManager.instance.showView(ConfigClass.VIEW_BAGAGAGE_MAIN);
						}
					}else if(bmd.isArmy()){
						ViewManager.instance.showView(ConfigClass.VIEW_ARMY_UPGRADE,bmd.id);
					}else if (bmd.isAltar()) {
						ViewManager.instance.showView(ConfigClass.VIEW_LEGEND);
					}else if (bmd.isAwaken()) {
						ViewManager.instance.showView(ConfigClass.VIEW_LEGEND_AWAKEN);
					}					
					return;
				}
				else{
					btnType = 0;//跳过
				}
			}
			if(btnType == 1){
				ViewManager.instance.showView(ConfigClass.VIEW_BUILDING_INFO,bmd);//信息
				return;
			}
			//
			if(status < 0){
				if(bmd.lv<=0){
					if(bmd.checkPay().length>0){
						GotoManager.boundForPanel(GotoManager.VIEW_BUILDING_UPGRADE,"",bmd);
					}
					else{
						this.building_lv_up(bmd,1,null);//直接解锁
					}
				}
			}
			else{
				if(sid==0){
					if(btnType==0){
						GotoManager.boundForPanel(GotoManager.VIEW_BUILDING_UPGRADE,"",bmd);
					}
					//
					if(tid == 3){
						if(btnType==2){
							
							if(bmd.getArmyNum()>=bmd.getArmyNumMax()){
								
								ViewManager.instance.showTipsTxt(Tools.getMsgById("_building60",[bmd.getArmyNumMax(),bmd.getArmyNum()]));//人员满了兵营住不下了
							}else{
								ViewManager.instance.showView(ConfigClass.VIEW_ARMY_MAKE,bmd);
							}
						}
						else if(btnType==3){
							ViewManager.instance.showView(ConfigClass.VIEW_ARMY_UPGRADE,bmd.id);
						}						
					}
					else if(tid == 4){
						if(btnType==2){
							//制造
							//ViewManager.instance.showView(ConfigClass.VIEW_EQUIP_MAKE);
							GotoManager.boundForPanel(GotoManager.VIEW_EQUIP_MAIN,"",[0,""]);
						}else if(btnType==3){
							//突破
							if(Tools.getDictLength(ModelManager.instance.modelUser.equip,true)>0)
								//GotoManager.boundForPanel(GotoManager.VIEW_EQUIP_UPGRADE);
								GotoManager.boundForPanel(GotoManager.VIEW_EQUIP_MAIN,"",[1,""]);
							else
								ViewManager.instance.showTipsTxt(Tools.getMsgById("_building61"));
						}else if(btnType==4){
							//洗炼
							if(Tools.getDictLength(ModelManager.instance.modelUser.equip,true)>0)
								//GotoManager.boundForPanel(GotoManager.VIEW_EQUIP_WASH);
								GotoManager.boundForPanel(GotoManager.VIEW_EQUIP_MAIN,"",[2,""]);
							else
								ViewManager.instance.showTipsTxt(Tools.getMsgById("_building61"));
						}else if(btnType==5){
							//强化
							if(Tools.getDictLength(ModelManager.instance.modelUser.equip,true)>0)
								GotoManager.boundForPanel(GotoManager.VIEW_EQUIP_MAIN,"",[3,""]);
							else 
								ViewManager.instance.showTipsTxt(Tools.getMsgById("_building61"));
						}
					}
					else if(tid == 11){
						if(btnType==2){
							ViewManager.instance.showView(ConfigClass.VIEW_SCIENCE_MAIN);
						}
					}
				}
				else if(sid==1){
					if(btnType==0){
						if(tid == 3){
							ViewManager.instance.showView(ConfigClass.VIEW_ARMY_QUICKLY,bmd);
						}else if(tid == 4){
							ViewManager.instance.showView(ConfigClass.VIEW_EQUIP_QUICKLY,ModelEquip.getCDingModel());
						}else if(tid == 11){
							//科技 加速
							ViewManager.instance.showView(ConfigClass.VIEW_SCIENCE_QUICKLY,ModelScience.getCDingModel());
						}else{
							ViewManager.instance.showView(ConfigClass.VIEW_BUILDING_QUICKLY,bmd);
						}
					}else if(btnType==2){
						//洗炼
						if(bmd.isEquip()){
							if(Tools.getDictLength(ModelManager.instance.modelUser.equip,true)>0)
								GotoManager.boundForPanel(GotoManager.VIEW_EQUIP_MAIN,"",[2,""]);
							else
								ViewManager.instance.showTipsTxt(Tools.getMsgById("_building61"));
						}else if(bmd.isArmy()){
							//容错的判断  有情况点训练的时候实际会触发这个研究
							if(ModelGame.unlock(null,"army_upgrade").stop) return;
							ViewManager.instance.showView(ConfigClass.VIEW_ARMY_UPGRADE,bmd.id);
						}
					}else if(btnType==3){
						//强化
						if(bmd.isEquip()){
							if(Tools.getDictLength(ModelManager.instance.modelUser.equip,true)>0)
								GotoManager.boundForPanel(GotoManager.VIEW_EQUIP_MAIN,"",[3,""]);
							else
								ViewManager.instance.showTipsTxt(Tools.getMsgById("_building61"));
						}
						
					}
				}
				else if(sid == 2){
					if(btnType==0){
						if(tid == 2){
							this.checkProduce(bmd.produce);
						}
						else if(tid == 3){
							this.checkArmyGetNum(bmd);
						}
						else if(tid == 4){
							this.checkEquipGet();
						}	
						else if(tid == 11){
							this.checkScienceGet();
						}					
					}		
				}
				else if(sid == 3){
					if(btnType==0){
						if(tid == 11){
							//科技每日收获
							this.checkScienceDayGet();
						}
					}
				}
				//功能不冲突
				if(tid == 5){
					if(btnType == 2){
						GotoManager.boundForPanel(GotoManager.VIEW_PUB);
					}
				}
				else if(tid == 6){
					//
					if(btnType == 2){
						ViewManager.instance.showView(ConfigClass.VIEW_STAR_GET);
					}
					else if(btnType == 3){
						ViewManager.instance.showView(ConfigClass.VIEW_STAR_RESOLVE);
					}
					else if(btnType == 4){
						ViewManager.instance.showView(ConfigClass.VIEW_PROP_RESOLVE);
						// 这里是问道问道
					}
				}
				else if(tid == 7){
					if(btnType == 2){
						ViewManager.instance.showView(ConfigClass.VIEW_BAGAGAGE_MAIN);
					}
				}	
				else if(tid == 8){
					if(btnType == 2){
						GotoManager.boundForPanel(GotoManager.VIEW_OFFICE_MAIN);
					}
					else if(btnType == 3){
						// var shogunStr:String=ModelUser.isOpenShogun();
						GotoManager.boundForPanel(GotoManager.VIEW_SHOGUN_MAIN);
					}
					else if(btnType == 4){
						GotoManager.boundForPanel(GotoManager.VIEW_ACHIEVEMENT);
					}
				}
				else if(tid == 9){//pve
					if(btnType == 2){
						GotoManager.boundForPanel(GotoManager.VIEW_CLIMB);
					}
					else if(btnType == 3){
						GotoManager.boundForPanel(GotoManager.VIEW_PVE);
					}
					else if(btnType == 0){
						if(ModelManager.instance.modelClimb.isGetAward()){
							ModelManager.instance.modelClimb.getClimbAwardToMe(null);
						}
					}
				}
				else if(tid == 10){//pvp
					if(btnType == 2){
						GotoManager.boundForPanel(GotoManager.VIEW_PK);
					}
					else if(btnType == 3){
						GotoManager.boundForPanel(GotoManager.VIEW_PK_YARD);
					}
				}
				else if(tid == 12){
					if(btnType == 2){
						// 传奇之路
						GotoManager.boundForPanel(GotoManager.VIEW_LEGEND);
					}
				}											
				else if(tid == 13){
					if(btnType == 2){
						// 英雄冢
						if (ModelLegendAwaken.instance.drawOpen) {
							GotoManager.boundForPanel(GotoManager.VIEW_LEGEND_AWAKEN);
						} else {
							ViewManager.instance.showTipsTxt(Tools.getMsgById('500310'));
						}
					}
				}											
			}
		}
		/**
		 * 建筑升级
		 * type 支付类型
		 */
		public function building_lv_up(bmd:ModelBuiding,type:int,callback:Handler):void{
			NetSocket.instance.send(NetMethodCfg.WS_SR_BUILDING_LV_UP,{bid:bmd.id,cost:type},Handler.create(this,this.ws_sr_building_lv_up),[bmd,callback]);
		}
		private function ws_sr_building_lv_up(re:NetPackage):void{
			var bmd:ModelBuiding = re.otherData[0];
			var callback:Handler = re.otherData[1];
			//
			if(re.receiveData == false){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_building62"));//"升级某个条件不满足"
				return;
			}
			var type:int = parseInt(re.sendData.cost);
			//
			//更新user数据
			var olv:Number = bmd.lv;
			ModelManager.instance.modelProp.buildUpGift=re.receiveData.gift_dict;
			ModelManager.instance.modelUser.updateData(re.receiveData);//建筑等级在这里同步更新到最终值
			ViewManager.instance.showReward(re.receiveData.gift_dict, false); // 刷新钱粮木铁等数据
			//
			if(bmd.isArmy() && olv>=1){//兵种 升级 特殊判断
				var cfgLvCurr:Array = ModelBuiding.getArmyBuildingLvCfg(bmd.id,olv);
				var cfgLvNext:Array = ModelBuiding.getArmyBuildingLvCfg(bmd.id,olv+1);
				if(cfgLvCurr && cfgLvNext){
					if(cfgLvNext[3]!=cfgLvCurr[3]){
						var armyCurrObj:Object = ModelPrepare.getArmyRankData(bmd.getArmyType(), cfgLvCurr[3]);
						var armyNextObj:Object = ModelPrepare.getArmyRankData(bmd.getArmyType(), cfgLvNext[3]);
						// bmd,armyCurrObj,armyNextObj,cfgLvNext[3]
						ViewManager.instance.showViewEffect(ArmyUpgrade.getEffect(bmd,armyCurrObj,armyNextObj,cfgLvNext[3]));
					}
				}
			}
			//
			bmd.upOneLv(olv);
			//
			var isUp:Boolean = false;
			if(bmd.isBase() && bmd.lv > olv){//官邸升级后,通知其他建筑,是否可以解锁
				isUp = true;
			}
			//
			if(type==0){//cd升级返回
				this.upgradeBuildingCD(bmd);
			}
			else{//花钱返回
				bmd.upgradeEnd(1);
			}			
			//
			if(bmd.isBase()){//官邸升级后,通知其他建筑,是否可以解锁
				var bmds:ModelBuiding;
				for(var key:String in ModelManager.instance.modelUser.home)
				{
					bmds = ModelManager.instance.modelInside.getBuildingModel(key);
					if(bmds.lv<1 && bmds.canUpgrade(1) && bmds.id!=bmd.id){
						bmds.updateStatus();
					}
					else if(bmds.lv>0 && bmds.canUpgrade(bmds.lv+1)){
						bmds.updateStatus();
					}
				}
			}else{
				this.updateBaseBuilding();
			}
			//
			if(callback){
				callback.run();
			}	
			var lock_arr:Array=ConfigServer.system_simple.func_open["map_visit"];
			if(lock_arr[0]>=0 && getBuildingModel(lock_arr[4]).lv==lock_arr[3]){
				ModelManager.instance.modelGame.getCityVisit();//如果刚好解锁了  就调一下拜访接口
			}
			//
			if(bmd.isBase() && isUp){
				Platform.uploadUserData(2,[bmd.lv]);
			}
		}	
		/**
		 * 收取 兵力
		 */	
		public function checkArmyGetNum(md:ModelBuiding):void{
			NetSocket.instance.send(NetMethodCfg.WS_SR_GET_BUILDING_ARMY,{bid:md.id},Handler.create(this,this.ws_sr_get_building_army));
		}
		private function ws_sr_get_building_army(re:NetPackage):void{
			MusicManager.playSoundUI(MusicManager.SOUND_ARMY_COMPLETE);
			var bmd:ModelBuiding = this.getBuildingModel(re.sendData.bid);
			if (ModelManager.instance.modelGame.isInside) {
				var p:Point = (ModelManager.instance.modelHome.builds[bmd.id] as EntityBuild).view.localToGlobal(new Point(0,0));
				EffectManager.textFlight(bmd.getArmyMakingNum() + "", "", p.x, p.y, ViewManager.instance.mLayerClip);
			}
			
			
			ModelManager.instance.modelUser.updateData(re.receiveData);
			//
			this.event(ARMY_BUILDING_TRAIN_GET,this.getBuildingModel(re.sendData.bid));
			this.getBuildingModel(re.sendData.bid).armyMakeOKreadyGet = false;
			this.getBuildingModel(re.sendData.bid).event(BUILDING_STATUS_CHANGE,this.getBuildingModel(re.sendData.bid));

			ModelManager.instance.modelInside.event(ModelInside.ARMY_BUILDING_TRAIN_SPEED_UP);
		}
		/**
		 * 收取 钱粮木铁
		 */
		public function checkProduce(pIndex:int):void{
			NetSocket.instance.send(NetMethodCfg.WS_SR_GET_BUILDING_MATERIAL,{produce:pIndex},Handler.create(this,this.ws_sr_get_building_material),pIndex);
		}
		private function ws_sr_get_building_material(re:NetPackage):void{
			MusicManager.playSoundUI(MusicManager.SOUND_GET_MATERIAL);
			var gift:Object = Tools.getObjValue(re.receiveData,"gift_dict",{});//奖励数据
			var obj:Object = ModelBuiding.check_produce_id[re.otherData];
			var md:ModelBuiding;
			var giftModel:Array = [];
			for(var key:String in obj)
			{
				md = this.getBuildingModel(key);
				var gifts:Number = md.getMyGift(md.lv);
				
				if(gifts>0 && !md.isUpgradeIng()){
					giftModel.push([md,gifts]);
				}
				// this.event(BUILDING_GIFT_PRODUCE_OK,md);
			}
			var gift_dict:Object = re.receiveData.gift_dict;
			//
			ModelManager.instance.modelUser.updateData(re.receiveData);//同步数据
			//
			var len:int = giftModel.length;
			var bmd:ModelBuiding;
			// var ett:EntityClip;
			var p:Point;
			var gt:Object;
			for(var index:int = 0; index < len; index++)
			{
				bmd = giftModel[index][0] as ModelBuiding;
				bmd.checkProduceTips();
				this.event(BUILDING_GIFT_PRODUCE_OK,bmd);
				bmd.event(BUILDING_STATUS_CHANGE,bmd);
				//
				// ViewManager.instance.showIcon(gift_dict,ett.stageX ,ett.stageY);
				gt = {};
				gt[ModelBuiding.material_type[bmd.produce+1]] = giftModel[index][1];
				if (ModelManager.instance.modelGame.isInside) {
					p = (ModelManager.instance.modelHome.builds[bmd.id] as EntityBuild).view.localToGlobal(new Point(0,0));
					ViewManager.instance.showIcon(gt,p.x,p.y-80);					
				}
			}
			
		}		
		public function checkEquipGet():void{
			//
			NetSocket.instance.send(NetMethodCfg.WS_SR_GET_EQUIP_CD,{},Handler.create(this,this.ws_sr_get_equip_cd));
		}
		private function ws_sr_get_equip_cd(re:NetPackage):void{
			var ecd:Array = ModelManager.instance.modelUser.equip_cd;
			var isOK:Boolean = ecd.length<4;
			var emd:ModelEquip = ModelEquip.getCDingModel();
			var isMine:Boolean = emd.isMine();
            ModelManager.instance.modelUser.updateData(re.receiveData);
			this.event(EQUIP_UPDATE_GET,emd);
			this.getBuilding002().event(BUILDING_STATUS_CHANGE,this.getBuilding002());
			//

			if(isMine){
				if(isOK){
					MusicManager.playSoundUI(MusicManager.SOUND_GET_MATERIAL);
					ViewManager.instance.showViewEffect(EquipUpgrade.getEffect(emd));
				}
				else{
					// ViewManager.instance.showTipsTxt("宝物"+emd.getName()+"突破失败");
					ViewManager.instance.showViewEffect(EquipUpgradeLoser.getEffect(emd,re.receiveData.gift));
				}
			}
			else{
				MusicManager.playSoundUI(MusicManager.SOUND_GET_MATERIAL);
				ViewManager.instance.showViewEffect(EquipGet.getEffect(emd));
			}
			GuideFocus.focusOut();
        }
		public function checkScienceDayGet():void{
			//
			NetSocket.instance.send(NetMethodCfg.WS_SR_GET_SCIENCE_REWARD,{},Handler.create(this,this.ws_sr_get_science_reward));
		}
		private function ws_sr_get_science_reward(re:NetPackage):void
		{
			ModelManager.instance.modelUser.updateData(re.receiveData);
			this.getBuilding003().event(BUILDING_STATUS_CHANGE,this.getBuilding003());
			//
			ViewManager.instance.showRewardPanel(re.receiveData.gift_dict);

		}		
		public function checkScienceGet(handler:Handler = null):void{
			//
			NetSocket.instance.send(NetMethodCfg.WS_SR_GET_SCIENCE,{},Handler.create(this,this.ws_sr_get_science),handler);
		}
		private function ws_sr_get_science(re:NetPackage):void
		{
			var smd:ModelScience =  ModelScience.getCDingModel();
			var sname:String = smd.getName();

			var science_cd:Array=ModelManager.instance.modelUser.records.science_cd;
			var science_id:String="";
			if(science_cd && science_cd.length!=0){
				science_id=science_cd[0];
			}
			ModelManager.instance.modelUser.updateData(re.receiveData);
			if(smd){
				smd.checkUpdateArmyBuilding();
			}			
			//
			this.event(SCIENCE_UPDATE_GET,smd);
			this.getBuilding003().event(BUILDING_STATUS_CHANGE,this.getBuilding003());
			//
			ModelManager.instance.modelGame.event(ModelInside.SCIENCE_CHANGE_STATUS);
			//
			ViewManager.instance.showTipsTxt(Tools.getMsgById("_building63",[sname]));//"科技研发提取成功"
			if(re.otherData && re.otherData === Handler){
				(re.otherData as Handler).run();
			}

			//科技升级成功之后觉得有必要刷新一下用户数据的科技id
			//91 访贤 增加切磋次数
			if(science_id=="91"){
				ModelManager.instance.modelUser.checkUserData(["science"]);
			}
		}
		public function getBuilding002():ModelBuiding{
			return this.getBuildingModel("building002");
		}
		public function getBuilding003():ModelBuiding{
			return this.getBuildingModel("building003");
		}		
		
		public function checkBuildingIsIng(md:ModelBuiding):Boolean{
			var b:Boolean = false;
			// var item:ModelBuiding;
			var now:Number = ConfigServer.getServerTimer();
			var item:Object;
			var arr:Array = ModelManager.instance.modelUser.building_cd_arr;
			var cd:Number = 0;
			var bid:String = "";
			for(var i:int = 0;i<arr.length;i++){
				// item = this.mBuildingArr[i] as ModelBuiding;
				item = arr[i];
				cd = Number(item.cd);
				bid = item.id+"";
				if(bid == md.id && cd>now){
					b = true;
					break;
				}
			}
			return b;
		}
		public function checkBuilderArrCanUse():Boolean{
			var b:Boolean = false;
			var item:ModelBuiding;
			var len:int = this.mBuildingArr.length;
			if(len<=0){
				return true;
			}
			for(var i:int = 0;i<len;i++){
				item = this.mBuildingArr[i] as ModelBuiding;
				if(!item.isUpgradeIng()){
					b = true;
					break;
				}
			}
			return b;
		}
		public function upgradeBuildingCD(bmd:ModelBuiding):Boolean{
			var b:Boolean = false;
			//
			this.mBuildingArr.push(bmd);
			this.event(BUILDING_BUILDER_ADD,bmd);
			bmd.event(BUILDING_STATUS_CHANGE);
			return b;
		}
		private function equip_update_remove():void{
			this.mEquipArr = [];
			this.getBuilding002().event(BUILDING_STATUS_CHANGE);
		}
		private function science_update_remove():void
		{
			this.mScienceArr = [];
			this.getBuilding003().event(BUILDING_STATUS_CHANGE);
		}
		public function upgradeEquipCDByArr():void{

            this.upgradeEquipCD(ModelEquip.getCDingModel());
		}
		public function upgradeScienceCDByArr():void{

            this.upgradeScienceCD(ModelScience.getCDingModel());
		}		
		public function upgradeEquipCD(md:ModelEquip):Boolean{
			var b:Boolean = false;
			//
			this.mEquipArr.push(md);
			this.event(EQUIP_BUILDER_ADD,md);
			this.getBuilding002().event(BUILDING_STATUS_CHANGE);
			return b;
		}
		public function upgradeScienceCD(smd:ModelScience):Boolean{
			var b:Boolean = false;
			this.mScienceArr.push(smd);
			this.event(SCIENCE_BUILDER_ADD,smd);
			this.getBuilding003().event(BUILDING_STATUS_CHANGE);
			return b;			
		}
		public function onTimer():void{
			if(this.mBuildingArr){
				var bmd:ModelBuiding;
				for each(var value:Object in this.mBuildingArr)
				{
					bmd = value as ModelBuiding;
					bmd.upgradeIng();
				}
				for (var key:String in ModelManager.instance.modelUser.home)
				{
					bmd = this.getBuildingModel(key);
					if(bmd.produce>=0 && bmd.lv>0){
						if(bmd.checkProduceTips()){
							this.event(BUILDING_GIFT_PRODUCE_READY,bmd);
							bmd.event(BUILDING_STATUS_CHANGE);
						}
					}
					else if(bmd.isArmy()){
						bmd.armyTrainMakeIng();
					}
					else{
						continue;
					}
				}
			}
			if(this.mEquipArr){
				var emd:ModelEquip;
				for each(var ev:Object in this.mEquipArr)
				{
					emd = ev as ModelEquip;
					if(emd){
						emd.upgradeIng();
					}
				}
			}
			if(this.mScienceArr){
				var smd:ModelScience;
				for each(var sv:Object in this.mScienceArr)
				{
					smd = sv as ModelScience;
					if(smd){
						smd.upgradeIng();
					}
				}				
			}
			var loginDate:Number = ModelManager.instance.modelUser.getGameDate();
			if(loginDate>ModelManager.instance.modelUser.loginDateNum){

				ModelManager.instance.modelUser.loginDateNum = loginDate;
				//
				ModelManager.instance.modelGame.getWorldLv();				
				
				ModelManager.instance.modelGame.updateNewVisit();

				// trace("新的一天啦");
				ModelManager.instance.modelUser.event(ModelUser.EVENT_IS_NEW_DAY);
				//重置战功
				ModelManager.instance.modelUser.resetCredit();

				ModelManager.instance.modelInside.getBuildingModel("building003").updateStatus();//军府刷新每天可领取
				ModelManager.instance.modelInside.getBuildingModel("building004").updateStatus();//辎重站免费次数更新

				ModelManager.instance.modelChat.initLocalMsgTime();

				//重新初始化襄阳战数据
				ModelManager.instance.modelCountryPvp.initData();
				//清理襄阳战相关数据
				ModelManager.instance.modelCountryPvp.clearXYZ();

				ModelManager.instance.modelCountryPvp.showTrbutaryView();

				ModelManager.instance.modelNewTask.getNewTaskData();
			}

			ModelManager.instance.modelGame.updateMyEstateStatus();
			ModelManager.instance.modelGame.updateMyVisitStatus();
			ModelManager.instance.modelGame.updateMyCityBuildStatus();
			ModelManager.instance.modelClub.checkFight();//异邦来访检查是否到开战时间
			ModelManager.instance.modelChat.checkLoacalMessage();//本地发送的系统消息
			ModelManager.instance.modelCountryPvp.checkShowPush();
			ModelArena.instance.showPushView();
			this.checkAutoArmy();//自动造兵
		}
		private function building_builder_remove(model:ModelBuiding):void{
			var item:ModelBuiding;
			var index:int = -1;
			for(var i:int = 0;i<this.mBuildingArr.length;i++){
				item = this.mBuildingArr[i];
				if(item.id == model.id){
					index = i;
					break;
				}
			}
			if(index>=0){
				this.mBuildingArr.splice(index,1);
			}
		}
		public function get_cd_list_building(key:String):Number{	
			return Tools.getTimeStamp(Tools.getObjValue(ModelManager.instance.modelUser.building_cd,key,null));
		}

		/**
		 * 当前最大建筑队列数
		 */
		public function buildingUpgradeMax():Number{
			return 1+ModelOffice.func_buildworkerNum();
		}

		/**
		 * 是否显示建筑可研究气泡（研究次数是否是最大值）
		 */
		public function isCanArmyUp(bid:String):Boolean{
			if(ModelManager.instance.modelUser.home.hasOwnProperty(bid) && !ModelGame.unlock(null,"army_upgrade").stop){
				if(isArmyScienceMax(bid)){//满级了
					return false;
				}
				var o:Object=ModelManager.instance.modelUser.home[bid];
				if(o.science){
					var time:Number=Tools.getTimeStamp(o.science[2]);
					var now:Number=ConfigServer.getServerTimer();
					var configHammer:Array=ConfigServer.army.hammer_times;
					var n:Number=configHammer[0];
					n=Math.floor((now-time)/(configHammer[1]*Tools.oneMinuteMilli));
					if(n>=configHammer[0]){
						return true;
					}
				}
			}
			return false;
		}

		/**
		 * 兵种科技是否满级
		 */
		public function isArmyScienceMax(bid:String):Boolean{
			var a:Array=ModelManager.instance.modelUser.home[bid].science;
			var arr:Array=ConfigServer.army.army_add_value;
			var max_lv:Number=arr[arr.length-1][0];
			var max_value:Number=Math.round(arr[arr.length-1][1]*3);
			var cur_lv:Number=a[0];
			var cur_value:Number=a[1];
			
			if(a && cur_lv==max_lv && cur_value>=max_value){//满级了
				return true;
			}

			var blv:int=ModelManager.instance.modelInside.getBuildingModel(bid)?ModelManager.instance.modelInside.getBuildingModel(bid).lv:0;
			var aa:Array=ConfigServer.army.army_add_limit;
			var limit_value:Number=0;
			var n:Number=0;
			for(var i:int=0;i<arr.length;i++){
				if(cur_lv<=arr[i][0]){
					n=i;
					break;
				}
			}
			limit_value=Math.round(arr[n][1]*3);
			if(aa && cur_lv==blv*aa[0]+aa[1] && cur_value>=limit_value){//兵种科技等级达到兵营等级限制
				return true;
			}
			return false;
		}


		/**
		*自动收兵
		*/
		private function autoGetArmy(_bid:String):void{			
			//收兵
			var bm:ModelBuiding=ModelManager.instance.modelInside.getBuildingModel(_bid);
			var n:Number = bm.getArmyMakingNum();
			var t:Number = bm.getMakingArmyLastTimer();

			if(n>0 && t<=0){
				setArmyCdObj(2);
				//trace(_bid+"自动收兵");
				NetSocket.instance.send(NetMethodCfg.WS_SR_GET_BUILDING_ARMY,{"bid":_bid},Handler.create(this,function(np:NetPackage):void{
					ws_sr_get_building_army(np);
					autoMakeArmy(_bid);
				}));
			}
			
		}

		private function autoMakeArmy(_bid:String):void{
			//造兵
			var bm:ModelBuiding=ModelManager.instance.modelInside.getBuildingModel(_bid);
			if(bm.getArmyBuildingStatus()==0){
				//trace(_bid+"自动造兵");
				setArmyCdObj(2);
				var _make:Number = bm.getArmyCanMakeNumMax();       	//单次可造最大数量
				NetSocket.instance.send(NetMethodCfg.WS_SR_BUILDING_MAKE_ARMY,{"bid":_bid,"if_cost":0,"army_mk_num":_make},Handler.create(this,function(np:NetPackage):void{
					ModelManager.instance.modelUser.updateData(np.receiveData);
            		bm.updateStatus(true);
					setArmyCdObj(0);
				}));
			}else{
				// trace(_bid+"自动造兵 不符合条件");
				setArmyCdObj(1,_bid,-1);
			}
		}

		/**
		 * 设置兵营倒计时数据
		 */
		public function setArmyCdObj(type:int=0,key:String="",num:Number=0):void{
			if(type==0){//初始化
				mbuildArmyObj={};
				var nn:Number=0;
				var b:Boolean=!ModelOffice.func_autotrain();
				for(var i:int=0;i<ModelBuiding.army_type_building.length;i++ ){
					var s:String = ModelBuiding.army_type_building[i];
					if( b || ModelManager.instance.modelUser.records.auto_mk_army==0){
						mbuildArmyObj[s]=-1;
					}else{
						var bm:ModelBuiding=ModelManager.instance.modelInside.getBuildingModel(s);
						var n:Number=bm.getArmyBuildingStatus();
						var t:Number     = bm.getMakingArmyLastTimer();
						//小于-1:可收获    -1:不满足任何状态     0:可造     大于0:收获cd
						mbuildArmyObj[s] = n==0 ? 0 : (n==1 || n==2 || n==5 ? -1 : (n==3 ? t : (n==4 ? -2 : -1)));
						
					}
					nn+= mbuildArmyObj[s]==-1 ? 1 : 0;
				}
				//trace("---初始化",mbuildArmyObj);
				if(nn==4 && ModelManager.instance.modelUser.records.auto_mk_army==1){
					// trace("---没有满足自动造兵的兵营  自动关闭");
					sendChangeAutoMkArmy();
				}
			}else if(type==1){//修改
				mbuildArmyObj[key]=num;
			}else{
				mbuildArmyObj={};
				for(var j:int=0;j<ModelBuiding.army_type_building.length;j++ ){
					var k:String = ModelBuiding.army_type_building[j];
					mbuildArmyObj[k]=-1;
				}	
				//trace("---清理",mbuildArmyObj);			
					
			}
			
		}

		/**
		 * 检查自动造兵（每秒调用）
		 */
		private function checkAutoArmy():void{
			for(var s:String in mbuildArmyObj){
				if(mbuildArmyObj[s]==0){
					autoMakeArmy(s);
					break;
				}else if(mbuildArmyObj[s]<-1){
					// trace(s+"自动收兵");
					autoGetArmy(s);
					break;
				}
			}

			for(var k:String in mbuildArmyObj){
				if(mbuildArmyObj[k]>=0){
					setArmyCdObj(1,k,ModelManager.instance.modelInside.getBuildingModel(k).getMakingArmyLastTimer());
				}
			}
		}

		/**
		 * 造兵相关 监听
		 */
		private function eventCallBackForBuildArmy(key:String):void{
			switch(key){
				case "update_cd":
					setArmyCdObj(0);
					break;
				case "auto":
					var n:Number=ModelManager.instance.modelUser.records.auto_mk_army;
					setArmyCdObj(n==0 ? 2 : 0);
					break;	
			}
		}

		public function sendChangeAutoMkArmy():void{
			var n:Number=ModelManager.instance.modelUser.records.auto_mk_army;
			var nnn:Number=0;
			if(n==0){
				
				for(var i:int=0;i<ModelBuiding.army_type_building.length;i++ ){
					var s:String = ModelBuiding.army_type_building[i];
					var bm:ModelBuiding=ModelManager.instance.modelInside.getBuildingModel(s);
					var nn:Number=bm.getArmyBuildingStatus();
					nnn+= (nn==-1 || nn==1 || nn==2 || nn==5) ? 1 : 0;
				}
				if(nnn==4){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("193010"));
					return;
				}
			}
			n = n==0 ? 1 : 0;
			NetSocket.instance.send("change_auto_mk_army",{"status":n},new Handler(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.records.auto_mk_army=n;
				ModelManager.instance.modelInside.event(ModelInside.CHANGE_AUTO_MK_ARMY);
				ViewManager.instance.showTipsTxt(Tools.getMsgById(n==1 ? "193015" : "193016"));
			}));
		}
		/**
		 * 测试接口  控制台直接输出
		 */
		public function testSocket(str:String,o:Object):void{
			NetSocket.instance.send(str,o);
		}

	}

}