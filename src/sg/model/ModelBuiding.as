package sg.model
{
	import laya.display.Animation;
	import sg.cfg.ConfigServer;
	import sg.manager.AssetsManager;
	import sg.manager.EffectManager;
	import sg.manager.ModelManager;
	import sg.model.ModelBase;
	import sg.model.ModelInside;
	import sg.utils.Tools;
	import ui.com.building_tips0UI;
	import ui.com.building_tips1UI;
	import ui.com.building_tips2UI;
	import ui.com.building_tips3UI;
	import sg.manager.ViewManager;
	import sg.view.effect.BuildingUpgrade;
	import sg.scene.constant.ConfigConstant;
	import sg.fight.logic.utils.FightUtils;
	import sg.utils.StringUtil;
	import laya.utils.Handler;
	import sg.net.NetMethodCfg;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.achievement.model.ModelAchievement;
	import sg.altar.legend.model.ModelLegend;
	import sg.altar.legendAwaken.model.ModelLegendAwaken;

	/**
	 * ...
	 * @author
	 */
	public class ModelBuiding extends ModelBase{
		
		/**
		 * 数字 == 基础材料 str
		 */
		public static const material_type:Array = [
			"merit",
			"gold",
			"food",
			"wood",
			"iron",
			"coin"
		];	
		/**
		 * [功勋，银币，粮草，木材，铁锭，元宝]
		 */
		public static const material_type_name:Object = {//弃用 lhw
			merit:Tools.getMsgById("190006"),
			gold:Tools.getMsgById("190001"),
			food:Tools.getMsgById("190002"),
			wood:Tools.getMsgById("190003"),
			iron:Tools.getMsgById("190004"),
			coin:Tools.getMsgById("190005")
		};			
		/**
		 * 钱粮木铁,的数字类型 == 建筑id
		 */
		public static const check_produce_id:Array = [
			{building013:0,building014:0,building015:0},
			{building022:1,building023:1,building024:1},
			{building019:2,building020:2,building021:2},
			{building016:3,building017:3,building018:3},
		];
		/**
		 * 钱粮木铁,id == 的数字类型
		 */		
		public static const check_produce_type:Object = {
			building013:0,building014:0,building015:0,
			building022:1,building023:1,building024:1,
			building019:2,building020:2,building021:2,
			building016:3,building017:3,building018:3
		};
		public static const NAME_HEAD:String = "building";
		public static const TYPE_BUILDER:int = 0;
		public static var buildingModels:Object = {};
		public function ModelBuiding(){
			this.mClassType = 1;
		}
		public var produce:int = -1;
		public var index:int;
		public var id:String;//id
		public var info:String;//信息
		// public var cd:int;//如果开始升级,需要赋值
		public var name:String;
		public var cfg:Object;//配置
		public var introduce:Array;
		//
		public var preIsAllOK:int = 0;//前置是否全部满足
		public var payIsAllEnough:int = 0;//支付类的是否全部满足
		public var produceTipsTimer:Number = -1;
		public var freeCDtipsTimer:Number = -1;
		/**
		 * 产量建筑的,生产开始时间
		 */
		public function get giftTimer():Number{
			if(ModelManager.instance.modelUser.home.hasOwnProperty(this.id)){
				if(ModelManager.instance.modelUser.home[this.id].hasOwnProperty("material_time")){
					return Tools.getTimeStamp(ModelManager.instance.modelUser.home[this.id]["material_time"]);
				}
			}
			return 0;
		}	
		/**
		 * 升级的 cd 毫秒
		 */
		public function get cd():Number{
			var n:Number = 0;
			if(ModelManager.instance.modelUser.building_cd[this.id]){
				n = Tools.getTimeStamp(ModelManager.instance.modelUser.building_cd[this.id]);
			}
			return n;
		}
		public function get lv():int{
			if(ModelManager.instance.modelUser.home[this.id]==null) {
				//trace("11111111111111   ",this.id);
				return 0;
			}
				
			return ModelManager.instance.modelUser.home[this.id].lv;
		}
		public function set lv(v:int):void{
			ModelManager.instance.modelUser.home[this.id].lv = v;
			ModelManager.instance.modelUser.updateData({user:{home:ModelManager.instance.modelUser.home}});
		}
		public function initData(key:String,obj:Object):void{
			this.cfg = obj;
			this.id = key;
			//
			this.name = this.cfg["name"];
			this.info = this.cfg["info"];
			//
			if(this.cfg.hasOwnProperty("produce")){
				this.produce =this.cfg["produce"];
			}
			else{
				this.produce = -1;	
			}
			if(this.cfg["introduce"]){
				this.introduce = this.cfg["introduce"];
			}
			else{
				this.introduce = null;		
			}
		}
		/**
		 * 建筑模型动画
		 */
		public function getAnimation():Animation{
			// {building013:0,building014:0,building015:0},
			// {building022:1,building023:1,building024:1},
			// {building019:2,building020:2,building021:2},
			// {building016:3,building017:3,building018:3},
			var img:String = this.id;
			if(this.produce>=0){
				if(this.produce == 0){
					img = "building013";
				}
				else if(this.produce == 1){
					img = "building022";
				}	
				else if(this.produce == 2){
					img = "building019";
				}	
				else if(this.produce == 3){
					img = "building016";
				}												
			}
			else{
				if(this.isBase()){
					img = this.id+"_M";
				}
			}
			var ani:Animation = EffectManager.loadAnimation(img);
			var scale:Number = this.cfg.front_scale || 1;
			scale = 0.9 / Math.pow(scale,0.6);
			ani.scale(scale,scale);
			return ani;
		}
		/**
		 * 是否是科技建筑
		 */
		public function isScience():Boolean{
			return (this.id == "building003");
		}
		/**
		 * 兵营
		 */
		public function isArmy():Boolean{
			if(this.id=="building009" || this.id=="building010" || this.id=="building011" || this.id=="building012"){
				return true;
			}
			else{
				return false;
			}
		}
		/**
		 * 宝物
		 */
		public function isEquip():Boolean{
			if(this.id=="building002"){
				return true;
			}
			else{
				return false;
			}			
		}
		/**
		 * 酒馆
		 */
		public function isPubHero():Boolean{
			if(this.id=="building005"){
				return true;
			}
			else{
				return false;
			}				
		}
		/**
		 * 星辰
		 */
		public function isStarRuneHero():Boolean{
			if(this.id=="building006"){
				return true;
			}
			else{
				return false;
			}			
		}
		/**
		 * 辎重站
		 */
		public function isBagagage():Boolean{
			if(this.id=="building004"){
				return true;
			}
			else{
				return false;
			}			
		}
		public function isPVE():Boolean{
			if(this.id=="building007"){
				return true;
			}
			else{
				return false;
			}			
		}
		public function isPVP():Boolean{
			if(this.id=="building008"){
				return true;
			}
			else{
				return false;
			}			
		}	
		public function isAltar():Boolean{
			if(this.id=="building025"){
				return true;
			}
			else{
				return false;
			}			
		}

		public function isAwaken():Boolean{
			return this.id == 'building026';
		}	

		/**
		 * 是否是官邸
		 */
		public function isBase():Boolean{
			if(this.id=="building001"){
				return true;
			}
			else{
				return false;
			}				
		}
		/**
		 * 兵营 id == 类型数字
		 */
		public static const army_type:Object = {
			building009:0,
			building010:1,
			building011:2,
			building012:3
		};
		/**
		 * 兵营 类型数字 == id
		 */		
		public static const army_type_building:Array = [
			"building009",
			"building010",
			"building011",
			"building012"
		];
		/**
		 * 通过 兵种类型 0,1,2,3获取 建筑model
		 */
		public static function getArmyBuildingByType(type:int):ModelBuiding{
			return ModelManager.instance.modelInside.getBuildingModel(army_type_building[type]);
		}
		/**
		 * 根据 建筑 id ,获取兵种 的 类型 
		 */
		public function getArmyType():Number{
			return army_type[this.id];
		}
		public function getArmyTypeName():String{
			return ModelHero.army_type_name[this.getArmyType()];
		}
		/**
		 * 兵种 等级 配置,?阶, ?前/后军
		 */
		public static function getArmyMakeCfgByGrade(grade:int,type:int):Array{
			var cfg:Array = ConfigServer.army.army_ability[grade];
			return cfg[type];
		}
		/**
		 * 兵种 type = 0,1,2,3
		 */
		public static function getArmyMakeCfgByGradeByType(type:int):Array{
			var bmd:ModelBuiding = ModelBuiding.getArmyBuildingByType(type);
			return ModelBuiding.getArmyMakeCfgByGrade(bmd.getArmyCurrGrade(),bmd.getArmyType());
		}
		/**
		 * 兵种 等级 训练 消耗 的材料 基础值 10个人的消耗
		 */
		public function getArmyMakePay(num:Number,coinB:Boolean = false):Array{
			var cfg:Array = getArmyMakeCfgByGrade(this.getArmyCurrGrade(),this.getArmyType());
			//
			var a:Number = ModelOffice.func_traincost();
			var b:Number = ModelScience.func_sum_type(ModelScience.army_consume);
			var c:Number = (num/10)*(1-a-b) * (coinB?ConfigServer.system_simple.fast_num[this.lv - 1]:1);
			var food:Number = Math.floor(cfg[5]*c);
			var wood:Number = Math.floor(cfg[6]*c);
			var iron:Number = Math.floor(cfg[7]*c);
			//
			return [food,wood,iron];
		}
		/**
		 * 改成粮草了，方法名先不改了
		 * 具体消耗啥走配置
		 */
		public function getArmyMakePayCoin(num:Number):Number{
			var arr:Array = this.getArmyMakePay(num,true);
			// trace("getArmyMakePayCoin----",arr);
			var cfg:Array = ConfigServer.system_simple.fast_train_cost;
			var a:Number = arr[0]/cfg[0];
			var b:Number = arr[1]/cfg[1];
			var c:Number = arr[2]/cfg[2];
			// trace("getArmyMakePayCoin--abc--",a,b,c,a+b+c);
            var troop_add:Object = ModelManager.instance.modelUser.records.troop_add;
            var costNum:int = troop_add.food; // 这里food不一定代表粮食，具体消耗啥走配置 fast_train_type
            var season_num:int = troop_add.season_num;
			if ((ModelManager.instance.modelUser.getGameDate() - 1) != season_num) {
				costNum = 0;
			}
			var fast_level:Array = ConfigServer.system_simple.fast_level;
			var ratio:Number = 1;
			var len:int = fast_level.length;
			while(len) {
				len--;
				if (costNum >= fast_level[len][0]){
					ratio = fast_level[len][1];
					break;
				}
			}
			// console.log('补兵数量: ', num);
			// console.log('今日消耗: ', costNum);
			// console.log('系数: ', ratio);
			// console.log('粮: ' + a + '\n木: '+b+'\n铁: '+c+'\n总: '+(a+b+c) * ratio);
			return (a+b+c) * ratio;
		}
		/**
		 * 训练兵 ,已有 材料 能够训练上限 人数
		 */
		public function getArmyMakeMaxNum():Number{
			var cfg:Array = getArmyMakePay(10);
			var food:Number = cfg[0] ? Math.floor(ModelManager.instance.modelUser.food/cfg[0]) : -1;
			var wood:Number = cfg[1] ? Math.floor(ModelManager.instance.modelUser.wood/cfg[1]) : -1;
			var iron:Number = cfg[2] ? Math.floor(ModelManager.instance.modelUser.iron/cfg[2]) : -1;
			//
			var min:Number = food;
			if(wood>=0 && wood<food) min = wood;
			if(iron>=0 && iron<min) min = wood;
			//min = Math.min(food,wood);
			//min = Math.min(min,iron);
			
			return min*10;
		}
		/**
		 * 训练 n数量 的兵需要 材料状态
		 */
		public function getArmyMakePayCheck(num:Number):Array{
			var payArr:Array = this.getArmyMakePay(num);
			var food:Number = payArr[0];
			var wood:Number = payArr[1];
			var iron:Number = payArr[2];
			var isAllOK:int = 0;
			if(ModelManager.instance.modelUser.food<food){
				isAllOK = -1;
				food *=isAllOK;
			}
			if(ModelManager.instance.modelUser.wood<wood){
				isAllOK = -1;
				wood *=isAllOK;
			}
			if(ModelManager.instance.modelUser.iron<iron){
				isAllOK = -1;
				iron *=isAllOK;
			}
			return [["food",food],["wood",wood],["iron",iron],isAllOK];
		}
		/**
		 * 获取 每次训练 的 上限,
		 */
		public function getArmyCanMakeNumMax(clv:Number = -1):Number{
            var currLvCfg:Array = getArmyBuildingLvCfg(this.id,(clv>-1)?clv:this.lv);
            // var cfgMax:Number = currLvCfg[2];
            // var myMax:Number = this.getArmyNum();
            var makeMax:Number = currLvCfg[1];
			var payMax:Number = this.getArmyMakeMaxNum();
			//
            var max:Number = Math.min(makeMax,payMax);
			var s:Number = ModelScience.func_sum_type(ModelScience.army_add,this.id);
			var v:Number = max *(1+ s);
			return Math.floor(Math.ceil(v*1000)*0.001);
		}
		/**
		 * 获取 兵种 当前建筑等级 对应的 兵种等级
		 */
		public function getArmyCurrGrade():Number{
            return getArmyBuildingLvCfg(this.id,this.lv)[3];
		}
		/**
		 * 建筑等级,对应的 兵种 等级获取
		 */
		public static function getArmyCurrGradeByType(armyType:int):int{
			var bmd:ModelBuiding = getArmyBuildingByType(armyType);
			// if(bmd>0){
			return getArmyBuildingLvCfg(bmd.id,bmd.lv)[3];
		}
		/**
		 * 建筑等级,对应的 兵种下一个等级  最高级则返回当前等级
		 */
		public static function getArmyNextGradeByType(armyType:int):int{
			var bmd:ModelBuiding = getArmyBuildingByType(armyType);
			var cur:int = getArmyBuildingLvCfg(bmd.id,bmd.lv)[3];
			var arr:Array = ConfigServer.system_simple.barracks[bmd.id];
			//该等级解锁新的兵种等级时  显示当前兵种等级
			if((arr[bmd.lv-2] && arr[bmd.lv-2][3] != cur)){
				return getArmyCurrGradeByType(armyType);
			}
			var len:int = arr.length;
			for(var i:int = bmd.lv; i < len; i++){
				if(cur!=arr[i][3]){
					return arr[i][3];
				}
			}
			return getArmyCurrGradeByType(armyType);
		}
		/**
		 * 兵营建筑的科技,
		 * armyType == 步骑弓方
		 * byPower == 只用来计算hero power
		 */
		public static function getArmyCurrScienceByType(armyType:int,byPower:Boolean = false):Array{
			var bmd:ModelBuiding = getArmyBuildingByType(armyType);
			// if(bmd>0){
			var arr:Array = bmd.getArmyScience();
			if(byPower){
				return [arr[0],arr[6]];
			}
			return arr;
		}	
		/**
		 * 兵营建筑的科技
		 */
		public function getArmyScience():Array{
			var arr:Array = [];
			if(this.isArmy()){
				arr = ModelManager.instance.modelUser.home[this.id].science;
			}
			return arr;
		}			
		/**
		 * 获取 兵种 当前建筑等级 对应的 库存上限
		 */		
		public function getArmyNumMax(clv:Number = -1):Number{
            return Math.floor(getArmyBuildingLvCfg(this.id,(clv>-1)?clv:this.lv)[2]*(1+ModelScience.func_sum_type(ModelScience.army_stock,this.id)));
		}
		/**
		 * 兵营 库存
		 */
		public function getArmyNum():Number{
			var num:Number = -1;
			if(this.isArmy()){
				num = ModelManager.instance.modelUser.home[this.id].army_num;
			}
			return num;
		}
		/**
		 * 兵营 正在造兵 数量
		 */
		public function getArmyMakingNum():Number{
			var num:Number = -1;
			if(this.isArmy()){
				num = ModelManager.instance.modelUser.home[this.id].army_mk_num;
			}
			return num;
		}
		/**
		 * 获得兵营的状态  0 可训练   1 满营   2 资源不够  3 训练中   4 可收获   5 升级中
		 */
		public function getArmyBuildingStatus():Number{
			if(this.isArmy()){
				var _cur:Number   = this.getArmyNum();                  						//当前兵力
				var _make:Number  = this.getArmyCanMakeNumMax();           						//单次可造最大数量(受资源限制)
				var _max:Number   = this.getArmyNumMax();               					    //库存上限
				var t:Number      = this.getMakingArmyLastTimer();		   						//训练倒计时
				var n:Number      = this.getArmyMakingNum();                					//训练中的兵力
				var b1:Boolean    = _make<100 ? false : this.getArmyMakePayCheck(_make)[3]==0;  //制造最大兵力需要的材料是否足够
				var isIng:Boolean = ModelManager.instance.modelInside.checkBuildingIsIng(this); //是否升级中
				if(isIng) return 5;
				if(b1==false) return 2;
				if(_cur >= _max) return 1;
				if(n>0) return (t<=0 ? 4 : 3);
				return 0;
			}
			return -1;
		}
		/**
		 * 兵营 造兵 剩余 timer
		 */
		public function getMakingArmyLastTimer():Number{
			var cd:Number = -1;
			if(this.isArmy()){
				var f:Number = Tools.getTimeStamp(ModelManager.instance.modelUser.home[this.id].army_time);
				cd = f - ConfigServer.getServerTimer();
			}
			return cd;
		}
		/**
		 * 判断,兵营建筑是否在训练中
		 */
		public var armyMakeOKreadyGet:Boolean = false;
		public function armyTrainMakeIng():void{
			if(this.isArmy()){
				if(this.getArmyMakingNum()>0 && this.getMakingArmyLastTimer()>0){
					this.armyMakeOKreadyGet = false;
					ModelManager.instance.modelInside.event(ModelInside.ARMY_BUILDING_TRAIN_UPDATE_CD,this);
				}
				else if(this.getArmyMakingNum()>0 && this.getMakingArmyLastTimer()<=0){
					ModelManager.instance.modelInside.event(ModelInside.ARMY_BUILDING_TRAIN_GET,this);
					if(!this.armyMakeOKreadyGet){
						this.armyMakeOKreadyGet = true;
						this.updateStatus(true);
					}
				}
			}
		}
		/**
		 * 建筑能否升级
		 */
		public function canUpgrade(lv:int,check2:Boolean = true):Boolean{
			var b:Boolean = true;
			var t1:Array = this.checkPrecondition(null,lv);
			var error1:Boolean = t1.length>0;
			var t2:Array = this.checkPay(null,lv);
			var error2:Boolean = false;
			var len:int = t2.length;
			for(var i:int = 0; i < len; i++)
			{
				if(!t2[i][2] && check2){
					error2 = true;
					break;
				}
			}
			//已满级
			var error3:Boolean = this.lv>0 && this.checkIsMaxLv(this.lv+1);

			if(error1 || error2 || error3){
				b = false;
			}
			return b;
		}
		/**
		 * 检查自己的状态,返回相应数据
		 * info:{name:建筑名称,level:等级,up:true(可以升级到下一级)}
		 * up:{total:总时间毫秒,cd:剩余时间毫秒,content:文字提升,icon:素材地址,ui:图标类ComPayType(需要 new 出来 addchild 上 使用 setBuildingTipsIcon("icon地址")),building:0}
		 * bubble:{icon:素材地址,num:各种类型下的数量,ui:图标类ComPayType(需要 new 出来 addchild 上 使用 setBuildingTipsIcon("icon地址"))}
		 * visible:-1不能解锁,0能解锁,>0
		 */
		private static const CHECK_STATUS_INFO:String = "info";
		private static const CHECK_STATUS_UP:String = "up";
		private static const CHECK_STATUS_BUBBLE:String = "bubble";
		private static const CHECK_STATUS_VISIBLE:String = "visible";
		public static const CHECK_STATUS_BUBBLET:String = "bubblet";//小气泡 仅兵种研究
		public function checkMyStatus():Object{
			var re:Object = {};
			var isBuilding:Boolean = ModelManager.instance.modelInside.checkBuildingIsIng(this);
			var maxNum:Number = 0;
			var getNum:Number = 0;
			var lastTimer:Number = 0;
			var isMaxLv:Boolean = this.checkIsMaxLv(this.lv+1);
			var normalObj:Object = {name:this.getName(),level:isMaxLv?Tools.getMsgById("_lht47"):this.lv};
			//
			var diff:Boolean = false;
			var vis:int = this.lv;
			//
			// img.skin = AssetsManager.getAssetsUI(icon)
			if(this.lv<=0){
				var canUpgradeB:Boolean = this.canUpgrade(1,false);
				if(this.isAltar()){
					canUpgradeB = (canUpgradeB && ModelLegend.instance.canShow);
				} else if (this.isAwaken()) {
					canUpgradeB = (canUpgradeB && ModelLegendAwaken.instance.open);
				}
				if(canUpgradeB){
					//,icon:"",ui:building_tips1UI
					normalObj["icon"] = "";
					normalObj["ui"] = building_tips1UI;
					normalObj["level"] = vis = 0;
					//
					// re[CHECK_STATUS_INFO] = normalObj;
					re[CHECK_STATUS_BUBBLE] = {icon:AssetsManager.getAssetsUI("home_06.png"),ui:building_tips3UI};
				}
				else{
					vis = -1;
					// re[CHECK_STATUS_INFO] = normalObj;
				}
				re[CHECK_STATUS_VISIBLE] = vis;
				return re;
			}
			else{
				vis = this.lv;
				re[CHECK_STATUS_VISIBLE] = vis;
			}
			//
			if(this.isArmy()){
				lastTimer = this.getMakingArmyLastTimer();
				if(lastTimer>0){
					maxNum = this.getArmyMakeCDms(this.getArmyMakingNum());
					//升级 0  or 训练 1"正在训练"+
					re[CHECK_STATUS_UP] = {total:maxNum,cd:lastTimer,content:Tools.getMsgById("_building55",[this.getArmyTypeName()]),icon:AssetsManager.getAssetsUI(AssetsManager.army_icon_building_ui2[army_type[this.id]]),ui:building_tips0UI,building:1};
					diff = true;
				}
				else{
					getNum = this.getArmyMakingNum();
					if(getNum>0){

						re[CHECK_STATUS_BUBBLE] = {icon:AssetsManager.getAssetsUI(AssetsManager.army_icon_building_ui[army_type[this.id]]),num:getNum,ui:building_tips2UI};
						re[CHECK_STATUS_INFO] = normalObj;
						diff = true;
					}
					else{
						re[CHECK_STATUS_INFO] = normalObj;
					}
				}
				//if(!diff || lastTimer>0){// 以前是大气泡  现在改成小气泡了  条件：可研究&&不在建造中 && (训练中||没有训练)
				if(ModelManager.instance.modelInside.isCanArmyUp(this.id) && !isBuilding && (lastTimer>0 || this.getArmyMakingNum()==0)){
					//re[CHECK_STATUS_BUBBLE] = {icon:AssetsManager.getAssetsUI("home_36.png"),ui:building_tips2UI};
					re[CHECK_STATUS_BUBBLET] = {icon:AssetsManager.getAssetsUI("home_36.png"),ui:building_tips3UI};
					re[CHECK_STATUS_INFO] = normalObj;	
					diff = true;					
				}
				//}
			}
			else if(this.produce>=0){
				getNum = this.getMyGift(this.lv);
				//check_produce_id[this.produce][this.id]
				if(getNum>0 && !isBuilding){
					var pui:String = AssetsManager.getAssetPayIconBig(ModelBuiding.material_type[this.produce+1]);

					re[CHECK_STATUS_BUBBLE] = {icon:pui,num:getNum,ui:building_tips1UI};
					re[CHECK_STATUS_INFO] = normalObj;
					// diff = true;
				}
				else{
					re[CHECK_STATUS_INFO] = normalObj;
				}					
			}
			else if(this.isEquip()){//宝物
				var emd:ModelEquip = ModelEquip.getCDingModel();
				if(emd){//有宝物
					lastTimer = emd.getLastCDtimer();
					var isGet:Boolean = lastTimer<=1000;
					if(emd.isUpgradeIng()>-1){//宝物在锻造或升级中
						if(isGet){//
							
							re[CHECK_STATUS_BUBBLE] = {icon:emd.isMine()?AssetsManager.getAssetsICON(ModelEquip.getIcon(emd.id)):AssetsManager.getAssetsUI("home_08.png"),ui:building_tips2UI};
							re[CHECK_STATUS_INFO] = normalObj;
							diff = true;
						}
						else{
							maxNum = emd.getLvCD(emd.getLv()+1)*Tools.oneMillis;
							re[CHECK_STATUS_UP] = {total:maxNum,cd:lastTimer,content:emd.isMine()?Tools.getMsgById("_building56",[emd.getName()]):Tools.getMsgById("_building57",[emd.isSpecial()?emd.getName():ModelEquip.equip_type_name[emd.type]]),icon:AssetsManager.getAssetsUI("icon_paopao09.png"),ui:building_tips0UI,building:2};
							diff = true;
						}
					}
					else{
						re[CHECK_STATUS_INFO] = normalObj;
					}
				}
				else{
					re[CHECK_STATUS_INFO] = normalObj;
				}
			}
			else if(this.isScience()){
				var isGetType:Boolean = false;
				var smd:ModelScience = ModelScience.getCDingModel();
				if(smd){
					lastTimer = smd.getLastCDtimer();
					var isUpOk:Boolean = lastTimer<=1000;
					var is0:Boolean = false;
					if(smd.isUpgradeIng()>-1){//升级中
						if(isUpOk){
							re[CHECK_STATUS_BUBBLE] = {icon:AssetsManager.getAssetsScience(smd.icon),ui:building_tips2UI};
							re[CHECK_STATUS_INFO] = normalObj;
							diff = true;							
						}
						else{
							maxNum = smd.getLvCD(smd.getLv()+1)*Tools.oneMillis;
							re[CHECK_STATUS_UP] = {total:maxNum,cd:lastTimer,content:Tools.getMsgById("_building56",[smd.getName()]),icon:AssetsManager.getAssetsUI("icon_paopao09.png"),ui:building_tips0UI,building:2};
							diff = true;
							isGetType = true;							
						}
					}
					else{
						re[CHECK_STATUS_INFO] = normalObj;
						isGetType = true;
						is0 = true;
					}
				}
				else{
					re[CHECK_STATUS_INFO] = normalObj;
					isGetType = true;
					is0 = true;
				}	
				if(ModelScience.check_science_day_get() && isGetType){//有buff 收获物品
					re[CHECK_STATUS_BUBBLE] = {icon:AssetsManager.getAssetsICON(ConfigServer.system_simple.science_show),ui:building_tips2UI};
					diff = true;
					//补丁 （有领奖气泡时显示不了升级中的动画）
					if(isBuilding)
						re[CHECK_STATUS_UP] = {total:this.getLvCD(this.lv)*Tools.oneMillis,cd:this.getLastCDtimer(),content:Tools.getMsgById("_building59",[this.getName()]),icon:AssetsManager.getAssetsUI("icon_paopao08.png"),ui:building_tips0UI,building:0};
				}
				else{
					if(ModelScience.checkHaveUp() && is0 && !isBuilding){
						re[CHECK_STATUS_BUBBLE] = {icon:AssetsManager.getAssetsUI("home_07.png"),ui:building_tips2UI};					
					}
				}
			}
			else if(this.isPubHero()){
				re[CHECK_STATUS_INFO] = normalObj;
				re[CHECK_STATUS_BUBBLE] = {icon:AssetsManager.getAssetsUI("home_24.png"),ui:building_tips2UI};
				
			}
			else if(this.isStarRuneHero()){
				re[CHECK_STATUS_INFO] = normalObj;
				//var b1:Boolean=ModelGame.unlock(null,"star_get");
				var o:Object=ModelManager.instance.modelUser.star_records;
				var a:Array=ConfigServer.system_simple.star_price;
				var b2:Boolean=ModelManager.instance.modelProp.isHaveItemProp(a[5],1);
				var b3:Boolean=Tools.isNewDay(o.get_time)?true:(o.get_times<a[4]);
				var b4:Boolean=!ModelGame.unlock(null,"star_get").stop;
				//if(ModelManager.instance.modelInside.getBase().lv>=15){
				if(b2 && b3 && b4){
					re[CHECK_STATUS_BUBBLE] = {icon:AssetsManager.getAssetsUI("home_29.png"),ui:building_tips2UI};
				}
			}
			else if(this.isBase()){
				re[CHECK_STATUS_INFO] = normalObj;
				if(ModelOffice.checkOfficeCanUp() && !ModelGame.unlock(null,"more_office").stop){
					re[CHECK_STATUS_BUBBLE] = {icon:AssetsManager.getAssetsUI("home_09.png"),ui:building_tips2UI};
				}
				else if(ModelManager.instance.modelUser.isCanLvUpShogun() && !ModelGame.unlock(null,"shogun").stop){
					re[CHECK_STATUS_BUBBLE] = {icon:AssetsManager.getAssetsUI("home_33.png"),ui:building_tips2UI};
				}
				else if(ModelAchievement.instance.hasNewAchieve() && !ModelGame.unlock(null,"effort").stop){ // 成就
					re[CHECK_STATUS_BUBBLE] = {icon:AssetsManager.getAssetsUI("home_51.png"),ui:building_tips2UI};
				}
				else{
				}
			} else if(this.isAltar()) {
				re[CHECK_STATUS_INFO] = normalObj;
				if(ModelLegend.instance.redPoint && !ModelGame.unlock(null,"legend").stop){ // 传奇
					re[CHECK_STATUS_BUBBLE] = {icon:AssetsManager.getAssetsUI("home_legend.png"),ui:building_tips2UI};
				}
			} else if(this.isAwaken()) {
				re[CHECK_STATUS_INFO] = normalObj;
				if(ModelLegendAwaken.instance.drawOpen){ // 英雄冢
					re[CHECK_STATUS_BUBBLE] = {icon:AssetsManager.getAssetsUI("home_63.png"),ui:building_tips2UI};
				}
			} else if(this.isPVE()){
				re[CHECK_STATUS_INFO] = normalObj;
				if(ModelManager.instance.modelClimb.isGetAward()){
					re[CHECK_STATUS_BUBBLE] = {icon:AssetsManager.getAssetsICON(ConfigServer.system_simple.pve_show),ui:building_tips2UI};
					diff = true;
				}
			}
			else if(this.isBagagage()){
				re[CHECK_STATUS_INFO] = normalObj;
				if(ModelBuiding.isBaggageBubble()){//暴击次数
					re[CHECK_STATUS_BUBBLE] = {icon:AssetsManager.getAssetsUI("home_48.png"),ui:building_tips2UI};
				}else if(ModelBuiding.isBaggageBubble1()){//免费次数
					re[CHECK_STATUS_BUBBLE] = {icon:AssetsManager.getAssetsUI("home_59.png"),ui:building_tips2UI};
				}
			}
			else if(this.isPVP()){
				re[CHECK_STATUS_INFO] = normalObj;
				if(ModelManager.instance.modelUser.champion_user){
					// re[CHECK_STATUS_BUBBLE] = {icon:AssetsManager.getAssetsUI("home_48.png"),ui:building_tips2UI};
				}
			}
			else{
				re[CHECK_STATUS_INFO] = normalObj;
			}
			if(isBuilding && !diff){
				maxNum = this.getLvCD(this.lv)*Tools.oneMillis;
				var cdNum:Number = this.getLastCDtimer();
				var bubbleArr:Array = [];
				if(re.hasOwnProperty(CHECK_STATUS_BUBBLE)){//共存pop
					bubbleArr.push(CHECK_STATUS_BUBBLE);
					bubbleArr.push(re[CHECK_STATUS_BUBBLE]);
				}
				re = {};
				re[CHECK_STATUS_VISIBLE] = vis;
				re[CHECK_STATUS_UP] = {total:maxNum,cd:cdNum,content:Tools.getMsgById("_building59",[this.getName()]),icon:AssetsManager.getAssetsUI("icon_paopao08.png"),ui:building_tips0UI,building:0};
				if(bubbleArr.length>0){
					re[bubbleArr[0]] = bubbleArr[1];
				}
				if(this.isFreeCanUse()){
					re = {};
					re[CHECK_STATUS_VISIBLE] = vis;
					re[CHECK_STATUS_BUBBLE] = {icon:AssetsManager.getAssetsUI("home_37.png"),ui:building_tips1UI,building:0};
				}
			}
			
			if(re.hasOwnProperty(CHECK_STATUS_INFO)){
				normalObj = re[CHECK_STATUS_INFO];
				if(!isMaxLv){
					normalObj[CHECK_STATUS_UP] = this.canUpgrade(this.lv+1);
				}
				re[CHECK_STATUS_INFO] = normalObj;
			}
			//建筑物状态数据
			return re;
		}

		/**
		 * n个人需要多少 秒 + 科技效果;/////原来是分钟
		 */
		public function getArmyMakeCD(num:Number):Number{
			return Math.ceil(num * (getArmyBuildingLvCfg(this.id,this.lv)[0])*0.1)/(1+ModelScience.func_sum_type(ModelScience.army_rate,this.id)+ModelOfficial.getArmyMakeBuff());
		}
		public function getArmyMakeCDms(num:Number):Number{
			return this.getArmyMakeCD(num)*Tools.oneMillis;
		}
		/**
		 * 获取 兵种 系统杂项 barracks 配置、等级配置
		 */
		public static function getArmyBuildingLvCfg(id:String,lv:int = -1):Array{
			if(lv>=0){
				var arr:Array = getArmyBuildingLvCfg(id,-1);
				if(lv > arr.length){
					return null;
				}
				else{
					var index:int = lv-1;
					if(index<0){
						index = 0;
					}
					return arr[index];
				}
			}
			else{
				return ConfigServer.system_simple.barracks[id];
			}
		}
		/**
		 * 获取 barracks 配置下的,新等级,index
		 * 
		 */
		public static function getArmyBuildingNewLvIndex(id:String,lv:Number):int{
			var arr:Array = ConfigServer.system_simple.barracks[id];
			var len:int = arr.length;
			var ruler:Array = getArmyBuildingLvCfg(id,lv);
			var index:int = -1;
			var fn:int = lv-1;
			fn = (fn<0)?0:fn;
			for(var i:int = fn; i < len; i++){
				if(ruler[3]!=arr[i][3]){
					index = i;
					break;
				}
			}
			// if(index<0){
			// 	index = len-1;
			// }
			return index;
		}
		/**
		 * 获取产出 数量 v = 等级
		 */
		public function getMyGift(v:int):Number{
			if(this.produce>=0){
				if(this.giftTimer<=0){
					return -1;
				}
				var abArr:Array = this.getMyGiftEvery(v);
				var cdr:Number = abArr[1]*Tools.oneMinuteMilli;//封地单位时间
				var e:Number = ConfigServer.system_simple.material_gift_limit[1];
				var cdmax:Number = e*cdr;//上限时间
				var d:Number = (ConfigServer.getServerTimer() - this.giftTimer);
				// trace("getMyGift :"+Tools.getTimeStyle(d));
				if(d>=cdmax){
					d = cdmax;
				}
				var c:Number = Math.floor(d/cdr);

				return Math.ceil(abArr[2]*c);
			}else{
				return -1;
			}
			//1000 23 85795039 3600000 1521194389039 1521108594000
		}
		/**
		 * 产出 物品 周期 提示
		 */
		public function checkProduceTips():Boolean{
			var now:Number = ConfigServer.getServerTimer();
			var d:Number =  (now - this.giftTimer);//now- this.produceTipsTimer;
			var cdr:Number = ConfigServer.system_simple.material_gift_cd[1];
			var cdrms:Number = cdr*Tools.oneMinuteMilli;
			var gift:Number = this.getMyGift(this.lv);
			var c:Number = Math.ceil(d/cdrms);

			if(this.produceTipsTimer<0){
				this.produceTipsTimer = this.giftTimer + c*cdrms;
			}
			else{
				if(now>=this.produceTipsTimer){
					this.produceTipsTimer = this.giftTimer + c*cdrms;

					return true;
				}
			}

			return false;
		}
		/**
		 * 单个建筑 单位时间 产出
		 */
		public function getMyGiftEvery(v:int):Array{
			if(this.produce>=0 && v>0){
				var a:Number = ConfigServer.system_simple.material_gift[v-1];//等级参数
				var cdr:Number = ConfigServer.system_simple.material_gift_cd[1];//封地单位时间
				var b:Number = ConfigServer.system_simple.material_scale[this.produce];//类型参数
				//a*b 是单位时间产出
				var addType:int = check_produce_type.hasOwnProperty(this.id)?check_produce_type[this.id]:-1;
				var addP:Number = 0;
				var stt:String = "";
				switch(addType)
				{
					case 0:
						stt = "gold";
						addP = ModelOffice.func_homegold();
						break;
					case 1:
						stt = "food";
						addP = ModelOffice.func_homefood();
						break;	
					case 2:		
						stt = "wood";							
						addP = ModelOffice.func_homewood();
						break;
					case 3:	
						stt = "iron";
						addP = ModelOffice.func_homeiron();
						break;
					default:
						stt ="gold";
						addP = 0;
						break;							
				};
				var num:Number = a*b*(1+addP+ModelScience.func_sum_type(ModelScience.fief_produce,stt));
				return [a,cdr,num];
			}else{
				return [0,0,0];
			}
		}
		public function getName():String{
			return Tools.getMsgById(this.name);
		}
		public function getInfo():String{
			return Tools.getMsgById(this.info);
		}
		public function getIntroduceStr():String
		{
			var str:String = "";
			if(this.introduce){
				var len:int = this.introduce.length;
				for(var i:int = 0;i < len;i++){
					str +=this.introduceEvery(this.introduce[i]);
					if(i<len-1){
						str+="<br/>";
					}
				}
			}
			return str;
		}
		private function introduceEvery(id:*):String
		{
			var type:int = parseInt(id);
			var bmd:ModelBuiding;
			var reStr:String = "";
			var arr:Array = null;
			var baggageArr:Array;
			switch(type)
			{	
				case 60150:
				case 60151:
				case 60152:
				case 60153:
					arr = [Math.floor(this.getMyGiftEvery(this.lv)[2])];
					break;	
				case 60154:
					bmd = ModelManager.instance.modelInside.getBase();
					arr = [bmd.lv];
					break;
				case 60155:
					bmd = ModelManager.instance.modelInside.getBase();
					arr = [ModelHero.getMaxLv(bmd.lv)];
					break;
				case 60156:
					bmd = ModelManager.instance.modelInside.getBuildingModel("building005");
					arr = [bmd.lv+ConfigServer.pub.hero_box1.free];
					break;					
				case 60157:
					bmd = ModelManager.instance.modelInside.getBuildingModel("building002");
					arr = [ModelManager.instance.modelGame.getShopTimes("treasuer_shop",bmd.id,bmd.lv)];//
					break;
				case 60158:
					arr = [StringUtil.numberToPercent(this.scienceTroopSpd())];
					break;	
				case 60159:
					bmd = ModelManager.instance.modelInside.getBuildingModel("building004");
					arr = [this.baggageBuyNumBase(ConfigServer.system_simple.baggage.buy_gold,bmd.lv),ConfigServer.system_simple.baggage.buy_gold[1]];//购买银两基础量{0}+{1}
					break;	
				case 60160:
					bmd = ModelManager.instance.modelInside.getBuildingModel("building004");
					arr = [this.baggageBuyNumBase(ConfigServer.system_simple.baggage.buy_food,bmd.lv),ConfigServer.system_simple.baggage.buy_food[1]];//购买粮草基础量{0}+{1}
					break;	
				case 60161:
					bmd = ModelManager.instance.modelInside.getBuildingModel("building004");
					arr = [this.baggageBuyNumBase(ConfigServer.system_simple.baggage.buy_wood,bmd.lv),ConfigServer.system_simple.baggage.buy_wood[1]];//购买木材基础量{0}+{1}
					break;
				case 60162:
					bmd = ModelManager.instance.modelInside.getBuildingModel("building004");
					arr = [this.baggageBuyNumBase(ConfigServer.system_simple.baggage.buy_iron,bmd.lv),ConfigServer.system_simple.baggage.buy_iron[1]];//购买生铁基础量{0}+{1}
					break;
				case 60163:
					bmd = ModelManager.instance.modelInside.getBuildingModel("building004");
					arr = [this.baggageBuyTimes(bmd.lv),ConfigServer.system_simple.baggage.limit[1]];//
					break;
				case 60164:
					bmd = ModelManager.instance.modelInside.getBuildingModel(ConfigServer.system_simple.building_soul[0]);
					arr = [Tools.percentFormat(bmd.lv*ConfigServer.system_simple.building_soul[2]),Tools.percentFormat(ConfigServer.system_simple.building_soul[2])];//
					break;	
				case 60165:
					bmd = ModelManager.instance.modelInside.getBuildingModel("building007");
					arr = [this.armyHpmAdd(bmd.lv,0),ConfigServer.fight.propertyTransform.building0[0][1][0]["hpm"][1]];//
					break;	
				case 60166:
					bmd = ModelManager.instance.modelInside.getBuildingModel("building007");
					arr = [this.armyHpmAdd(bmd.lv,1),ConfigServer.fight.propertyTransform.building0[0][1][1]["hpm"][1]];//
					break;
				case 60167:
					bmd = ModelManager.instance.modelInside.getBuildingModel("building008");
					arr = [Tools.percentFormat(this.armyAtkOrDefAdd(bmd.lv,"atkRate")),Tools.percentFormat(FightUtils.pointToPer(ConfigServer.fight.propertyTransform.building1[0][1][0]["atkRate"][1]))];//
					break;
				case 60168:
					bmd = ModelManager.instance.modelInside.getBuildingModel("building008");
					arr = [Tools.percentFormat(this.armyAtkOrDefAdd(bmd.lv,"defRate")),Tools.percentFormat(FightUtils.pointToPer(ConfigServer.fight.propertyTransform.building1[0][1][0]["defRate"][1]))];//
					break;																																																														
				default:
					break;
			}
			reStr = Tools.getMsgById(type,arr);
			return reStr;
		}
		/**
		 * 将魂,基础
		 */
		public static function get_soul_value():Number
		{
			var bmd:ModelBuiding = ModelManager.instance.modelInside.getBuildingModel(ConfigServer.system_simple.building_soul[0]);
			return ConfigServer.system_simple.building_soul[1] + bmd.lv*ConfigServer.system_simple.building_soul[2];
		}
		public function scienceTroopSpd():Number
		{
			return ConfigServer.system_simple.building_army_go[1]+this.lv*ConfigServer.system_simple.building_army_go[2];
		}
		/**
		 * 辎重站,根据等级,获得基础
		 * arr 类型
		 */
		public function baggageBuyNumBase(arr:Array,clv:int):Number
		{
			return arr[0]+arr[1]*clv;
		}
		public function baggageBuyTimes(clv:int):Number
		{
			return ConfigServer.system_simple.baggage.limit[0]+ConfigServer.system_simple.baggage.limit[1]*clv;
		}	
		public function armyHpmAdd(clv:int,fb:int):Number
		{
			var cfg:Array = ConfigServer.fight.propertyTransform.building0[0][1][fb]["hpm"];
			return cfg[0]+cfg[1]*clv;
		}	
		public function armyAtkOrDefAdd(clv:int,type:String):Number{
			var cfg:Array = ConfigServer.fight.propertyTransform.building1[0][1][0][type];
			return cfg[0]+FightUtils.pointToPer(cfg[1])*clv;
		}
		/**
		 * 需要服务器确定处理,建筑 等级 +1
		 */
		public function upOneLv(olv:Number):Boolean{
			var b:Boolean =false;
			var is0:Number = olv;//this.lv;
			// if(v>0){
			// 	this.lv = v;
			// }
			// else{
			// 	this.lv+=1;
			// }
			if(is0==0 && this.lv == 1 && this.produce>=0){
				if(ModelManager.instance.modelUser.home[this.id]["material_time"]){
					var obj:Object = {};
					obj["$datetime"] = ConfigServer.getServerTimer();
					ModelManager.instance.modelUser.home[this.id]["material_time"] = obj;
				}
			}
			ViewManager.instance.showViewEffect(BuildingUpgrade.getEffect(this));
			return b;
		}
		/**
		 * 快速获取 下一等级 数
		 */
		public function lvNext():Number{
			return this.lv+1;
		}
		/**
		 * 获取 配置 cd 秒
		 */
		public function getLvCD(lv:int):Number{//返回秒
			var lvobj:Object = this.getLvCfg(lv);
			var m:Number = -1;
			if(lvobj.hasOwnProperty("cd"))
			{
				m = lvobj["cd"];
			}
			return m;
		}
		/**
		 * 是否存在 等级配置,
		 */
		public function checkIsMaxLv(clv:int):Boolean{
			return Tools.isNullObj(this.getLvCfg(clv));
		}
		/**
		 * 解锁 等级 功能 提示
		 */
		public function unlockFunc(clv:int):Array
		{
			if(!this.checkIsMaxLv(clv)){
				var cfg:Object = this.getLvCfg(clv);
				if(cfg.hasOwnProperty("unlock_info")){
					return cfg["unlock_info"];
				}
			}
			return null;
		}
		/**
		 * 获取 配置 cd 
		 */
		public function getLvCDminute(clv:int):Number{//返回分
			return this.getLvCD(clv)/60;
		}
		/**
		 * 是否 等级是 0 ,没解锁
		 */
		public function checkIslv0toUnlock():Boolean{
			return (this.lv <=0);
		}
		/**
		 * 获取 用户数据 cd 文字
		 */
		public function getLastCDtimerStyle(free:Number = 0):String{
			return Tools.getTimeStyle(this.getLastCDtimer()-free);
		}
		/**
		 * 获取 用户数据 cd 毫秒
		 */
		public function getLastCDtimer():Number{
			return this.cd - ConfigServer.getServerTimer();
		}
		public function getLastCDpercent():Number{
			return this.getLastCDtimer()/this.getLvCD(this.lv)*Tools.oneMillis;
		}
		public function getCDfree():Number{
			return ModelOffice.func_buildtime()
		}
		public function isFreeCanUse():Boolean{
			var cnum:Number = this.getLastCDtimer();
			var freeNum:Number = this.getCDfree()*Tools.oneMinuteMilli;
			if(cnum>0 && freeNum>=cnum){
				return true;
			}
			return false;
		}
		/**
		 * cd 是否在升级中
		 */
		public function isUpgradeIng():Boolean{
			var b:Boolean = false;
			if(this.cd<=0){
				b = false;
				return b;
			}
			if(this.getLastCDtimer()>0){
				b = true;
			}
			return b;
		}
		/**
		 * 检测 升级 过程中
		 */
		public function upgradeIng():void{
			if(this.isUpgradeIng()){
				ModelManager.instance.modelInside.event(ModelInside.BUILDING_UPDATE_CD,this);
				this.event(ModelInside.BUILDING_UPDATE_CD);
			}
			else{
				//升级CD完成
				this.upgradeEnd(1);
			}
		}
		public function updateStatus(subMe:Boolean = false):void{
			this.event(ModelInside.BUILDING_STATUS_CHANGE,subMe?this:null);
		}
		/**
		 * 升级结束
		 */
		public function upgradeEnd(type:int):void{
			ModelManager.instance.modelInside.event(ModelInside.BUILDING_BUILDER_REMOVE,this);
			ModelManager.instance.modelInside.event(ModelInside.BUILDING_UPDATE_END,this);
			this.updateStatus(true);
		}
		/**
		 * 获取 配置 升级 配置
		 */
		private function getLvCfg(lv:int):Object{
			var levelup:Object = this.cfg["levelup"];
			var currLvCfg:Object = levelup[lv+""];
			return currLvCfg;
		}
		/**
		 * 检测 cd 升级 的各种条件 集合
		 */
		public function checkCDupgradeIsOK(lv:int):Array{
			var payAll:Boolean = false;
			var preAll:Boolean = false;
			this.checkPay(null,lv);
			payAll = this.payIsAllEnough<=0;
			this.checkPrecondition(null,lv);
			preAll = this.preIsAllOK<=0;
			return [payAll,preAll];
		}
		public function netUpgrade(sd:Object,handler:Handler):void
		{
			NetSocket.instance.send(NetMethodCfg.WS_SR_KILL_BUILDING_CD,sd,Handler.create(this,function(re:NetPackage):void{
				var type:int = re.sendData.item_id;
				//
				ModelManager.instance.modelUser.updateData(re.receiveData);
				//
				this.freeCDtipsTimer = ConfigServer.getServerTimer();
				//
				if(type<0){//用钱的
					this.upgradeEnd(1);
				}
				else{
					this.updateStatus(true);
				}
				if(handler){
					handler.run();
				}
            //
        	}),sd);
		}
		/**
		 * 检查前置条件等级是否满足,包括建筑、爵位
		 */
		public function checkPrecondition(data:Array = null,lv:int = 1):Array{
			var arr:Array = data?data:Tools.getObjValue(this.getLvCfg(lv),"Precondition",[]);
			var len:int = arr.length;
			var element:Array;
			var re:Array = [];
			var type:String = "";
			var ok:Boolean = false;
			this.preIsAllOK = 0;
			//
			var msg:String = "1";
			for(var index:int = 0; index < len; index++)
			{
				element = arr[index];
				msg = element.length>2?element[2]:"60000";
				if(element[0] is Array){
					checkPre(re,element[0] as Array,element[1],msg);
				}
				else{
					type = element[0];
					if(type.indexOf(NAME_HEAD)>-1){
						ok = getPreBuildingLvIsOK(element[0],element[1]);
					} else if(type.indexOf("office")>-1){
						ok = (ModelManager.instance.modelUser.office >= Number(element[1]));
					} else if(type === 'mergeNum'){
						ok = (ModelManager.instance.modelUser.mergeNum >= Number(element[1]));
					}
					if(!ok){
						re.push([element[0],element[1],msg]);
					}
				}
			}
			this.preIsAllOK = re.length>0?1:0;
			return re;
		}
		public static function checkPre(re:Array,arr:Array,lv:int,msg:String):void{
			
			var newArr:Array = arr.concat();
			var type:String = newArr.shift();
			var len:int = newArr.length;
			var ok:Boolean = false;
			var okNum:int = 0;
			var hid:String = "";
			var reArr:Array;
			var reArrOK:int = 0;
			var hmd:ModelBuiding;
			var hidIndex:String = "";	
			for(var i:int = 0; i < len; i++)
			{
				if(newArr[i] is Array){
					reArr = checkPreArr(newArr[i],lv,msg);
					if(type == "or"){
						if(!reArr[0]){
							reArrOK+=1;
						}
					}
					else{
						if(!reArr[0]){
							
							if(reArr[1].indexOf(ModelBuiding.NAME_HEAD)>-1){
								hmd = ModelManager.instance.modelInside.getBuildingModel(reArr[1]);
								re.push([reArr[1],lv,msg,hmd.produce,type,hmd.isArmy()]);
							}
							else{
								re.push([reArr[1],lv,msg]);
							}
							
						}
					}
				}
				else{
					
					hid = newArr[i];
					
					ok = getPreBuildingLvIsOK(hid,lv);

					// trace(type,hid,lv);
					
					if(type == "or"){
						if(!ok){
							okNum +=1;
							if(!hidIndex){
								hidIndex = hid;
							}
						}
					}
					else{
						if(!ok){
							if(hid.indexOf(ModelBuiding.NAME_HEAD)>-1){
								hmd = ModelManager.instance.modelInside.getBuildingModel(hid);
								re.push([hid,lv,msg,hmd.produce,type,hmd.isArmy()]);
							}
							else{
								re.push([hid,lv,msg]);
							}
						}
					}
				}
			}
			if(type == "or"){
				if(okNum>=len){
					re.push([hidIndex?hidIndex:hid,lv,msg]);
				}
				if(reArrOK>=len){
					re.push([reArr[1],lv,msg]);
				}
			}
		}
		public static function checkPreArr(arr:Array,lv:int,msg:String):Array{
			var newArr:Array = arr.concat();
			var type:String = newArr.shift();
			var len:int = newArr.length;
			var ok:Boolean = false;
			var okNum:int = 0;
			var hid:String = "";
			var hidIndex:String = "";			
			for(var i:int = 0; i < len; i++)
			{
				hid = newArr[i];
				ok = getPreBuildingLvIsOK(hid,lv);
				if(type == "or"){
					
					if(!ok){
						okNum +=1;
						if(!hidIndex){
							hidIndex = hid;
						}
					}
				}
				else{
					if(!ok){
						break;
					}
				}
			}
			if(type == "or"){
				if(okNum>=len){
					ok = false;
				}
			}
			return [ok,hidIndex?hidIndex:hid];
		}
		/**
		 * 前置 建筑 等级
		 */
		public static function getPreBuildingLvIsOK(id:String,target:int):Boolean{
			var building:ModelBuiding = ModelManager.instance.modelInside.getBuildingModel(id);
			if(!building){
				return false;
			}
			return (building.lv >= target);
		}
		/**
		 * 检查消耗品是否满足、食物、木材、矿、钱
		 */
		public function checkPay(material:Array=null,lv:int = 1):Array{
			if(material)
			{
				return getMaterial(material);
			}
			else
			{
				return getMaterial(Tools.getObjValue(this.getLvCfg(lv),"material",null));			
			}
		}
		/**
		 * 消耗 材料 组和
		 */
		public function getMaterial(material:Array):Array{
			var re:Array = [];
			this.payIsAllEnough = 0;
			if(material){
				var len:int = material.length;
				var value:int = 0;
				var type:String = "";
				var enough:Boolean = false;
				for(var index:int = 0; index < len; index++)
				{
					value = parseInt(material[index]);
					if(value>0){
						
						type = material_type[index];
						enough = getMaterialEnough(type,value);
						re.push([type,value,enough]);
						if(!enough){
							this.payIsAllEnough+=1;
						}
					}
				}
			}
			return re;
		}
		/**
		 * 基础材料 是否足够
		 */
		public static function getMaterialEnough(name:String,price:int):Boolean{
			//[功勋，银币，粮草，木材，铁锭，元宝]
			var had:Number = 0;
			switch(name)
			{
				case "merit":
					had = ModelManager.instance.modelUser.merit;
					break;
				case "gold":
					had = ModelManager.instance.modelUser.gold;
					break;
				case "food":
					had = ModelManager.instance.modelUser.food;
					break;	
				case "wood":
					had = ModelManager.instance.modelUser.wood;
					break;
				case "iron":
					had = ModelManager.instance.modelUser.iron;
					break;	
				case "coin":
					had = ModelManager.instance.modelUser.coin;
					break;				
			}
			return (had>=price);
		}
		/**
		 * 基础材料,素材全路径
		 */
		public static function getMaterialTypeUI(name:String,big:Boolean = false):String{
			//[功勋，银币，粮草，木材，铁锭，元宝]
			return AssetsManager.getAssetsUI(ModelItem.getCostIcon(name,big));
		}
		
		/**
		 * 获得 时间 转换 coin 
		 * cd == 分钟
		 * type == 每个功能不同
 		 */
		public static function getCostByCD(cd:Number,type:int = 0):Number{
			return Math.ceil(cd/Number(ConfigServer.system_simple.cd_cost[type]));
		}
		public static function checkUpgradeBuild():ModelBuiding
		{
			var everyBmd:ModelBuiding;
			for(var key:String in ModelManager.instance.modelUser.home){
				everyBmd = ModelManager.instance.modelInside.getBuildingModel(key);
				if(everyBmd.canUpgrade(everyBmd.lv+1)){
					return everyBmd;
				}
			}
			return null;
		}

		/**
		 * 是否显示辎重站气泡 (暴击次数的气泡)
		 */
		public static function isBaggageBubble():Boolean{
			var arr:Array=ModelManager.instance.modelUser.baggage.material;
			for(var i:int=0;i<arr.length;i++){
				if(arr[i][1]>0){
					return true;
				}
			}
			return false;
		}

		
		/**
		 * 是否显示辎重站气泡 (是否有免费次数)
		 */
		public static function isBaggageBubble1():Boolean{
			var n:Number=ConfigServer.system_simple.baggage.free_buy+ModelOffice.func_baggagefree();//总的免费次数
			if(n>0){
				var o:Object=ModelManager.instance.modelUser.baggage;
				var m:Number=Tools.isNewDay(o.refresh_free_time)?0:o.free_times;//使用过的免费次数
				if(m<n){
					return true;
				}
			}
			
			return false;
		}
	}

}