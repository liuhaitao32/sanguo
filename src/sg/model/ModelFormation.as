package sg.model 
{
	import sg.cfg.ConfigServer;
	import sg.fight.logic.utils.FightUtils;
	import sg.fight.logic.utils.PassiveStrUtils;
	import sg.utils.Tools;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	/**
	 * 阵法的配置结构，方便使用  0普通 1锋矢 2钩行 3雁形 4鹤翼 5铁桶 6八卦
	 * @author zhuda
	 */
	public class ModelFormation extends ModelBase{
		private static var _models:Object = {};
		
		public static function getModel(key:int):ModelFormation
		{
			if (!_models[key]){
				var mf:ModelFormation = new ModelFormation();
				if (key is String)
					key = parseInt(key as String);
				mf.initData(key);
				_models[key] = mf;
			}
			return _models[key];
		}
		//分id和品质记录个数
		private static var fomationObj:Object;
		
		
		private var _id:int;
		public function get id():int{
            return this._id;
        }

		///特效配置
		public var effCfg:Object;
		///数值逻辑配置
		public var logicCfg:Object;
		
		///阵法单点位置随机偏移范围
		public var float:Array;
		///旗帜位置[-50,0],
		public var flag:Array;
		///英雄位置[20,0],
		public var hero:Array;
		///副将位置[[0,60],[0,-60]],
		public var adjutant:Array;
		///前后军阵型
		public var army:Array;
		
		///等级属性基础值
		public var lvBase:Object;
		///品质解锁的特性
		public var starRank:Array;

		public var cfgArrLevel:Array   = ConfigServer.system_simple.arr_level;
		public var cfgArrQuality:Array = ConfigServer.system_simple.arr_quality;
		public var cfgArrCost:Array = ConfigServer.system_simple.arr_cost;

		
		public function ModelFormation() 
		{
		}
		
		public function initData(key:int):void{
            this._id = key;
			this.effCfg = ConfigServer.effect.formation[key];
			var m:String;
			for(m in this.effCfg)
			{
				if(this.hasOwnProperty(m)){
					this[m] = this.effCfg[m];
				}
			}
			this.logicCfg = ConfigServer.fight.formation[key];
			for(m in this.logicCfg)
			{
				if(this.hasOwnProperty(m)){
					this[m] = this.logicCfg[m];
				}
			}
        }
		
		/**
		 * 将养成的阵法数据，转为计算战力的阵法数据
		 */
		public static function translateObj(data:Object):void{
			if (data.hasOwnProperty('formation'))
				return;
			
			if (!data.hasOwnProperty('formation_index'))
			{
				data.formation_index = -1;
			}
			if (!data.hasOwnProperty('formation_arr'))
			{
				data.formation_arr = [[0,0],[0,0],[0,0]];
			}
			
			//必定需要转置
			var newFormation:Array = [0,{}];
			
            var heroCfg:Object = ConfigServer.hero[data.hid];
			if (heroCfg){
				var heroCfgArr:Array = heroCfg.arr;
				if(heroCfgArr){
					if (data.formation_index >= 0 && data.formation_index < heroCfgArr.length){
						//当前选中
						newFormation[0] = heroCfgArr[data.formation_index];
					}
					var dataFormation:Array = data.formation_arr;
					var len:int = Math.min(heroCfgArr.length, dataFormation.length);
					var obj:Object = newFormation[1];
					for (var i:int = 0; i < len; i++){
						obj[heroCfgArr[i]] = FightUtils.clone(dataFormation[i]);
					}
				}
			}
			delete data.formation_index;
			delete data.formation_arr;
			data.formation = newFormation;
        }
		
		/**
		 * 得到前军或后军当前尺寸部队的排列数组
		 */
		public function getArmyFormation(index:int,size:int) :Array
		{
			var arr:Array = this.army[index];
			if (size >= arr.length){
				return arr[arr.length - 1];
			}
			else{
				return arr[size];
			}
		}
		/**
		 * 得到阵法名称
		 */
		public function getName() :String
		{
			return Tools.getMsgById('formation' + this.id);
		}
		/**
		 * 得到阵法当前等级、激活状态的属性对象
		 */
		public function getLvObj(lv:int, isUse:Boolean, isInfo:Boolean = false) :Object
		{
			if (!isInfo && !isUse && lv <= 0){
				return {};
			}
			var rank:Array = isUse?ConfigServer.fight.formationUseLvRank:ConfigServer.fight.formationLvRank;
			var arr:Array = FightUtils.getRankArr(lv, rank);
			var rate:Number = arr[1][0] + (lv - arr[0])*arr[1][1];
			var obj:Object = this.lvBase?FightUtils.clone(this.lvBase):{atk:1};
			FightUtils.multObject(obj, rate);
			
			return obj;
		}
		/**
		 * 得到阵法当前等级、激活状态的描述
		 */
		public function getLvInfo(lv:int, isUse:Boolean) :String
		{
			if (lv <= 0 && !isUse){
				return Tools.getMsgById('formation_lv0');
			}
			var obj:Object = this.getLvObj(lv, isUse, true);
			var condStr:String = Tools.getMsgById('condFormation');
			var info:String = PassiveStrUtils.translateRsltInfo(condStr,obj, false,false,true,1);
			return Tools.getMsgById('condFormationInfo',[info]);
		}
		/**
		 * 得到阵法对应克制效果（擅长应对）的描述
		 */
		public function getAdeptInfo() :String
		{
			return Tools.getMsgById('formation' + this.id + '_adept');
		}
		/**
		 * 得到阵法对应品质的描述
		 */
		public function getStarInfo(star:int) :String
		{
			if (!this.starRank){
				return '无';
			}
			var obj:Object = this.starRank[star];
			return PassiveStrUtils.translatePassiveInfo(obj.passive,false,false,1);
		}
		


		
		/**
		 * 最大星级
		 */
		public function maxStar():Number{
			return ConfigServer.system_simple.arr_quality ? ConfigServer.system_simple.arr_quality.length : 6;
		}

		/**
		 * 最大等级
		 */
		public function maxLv():Number{
			return ConfigServer.system_simple.arr_level ? ConfigServer.system_simple.arr_level.length : 10;
		}

		/**
		 * 当前星级
		 */
		public function curStar(hmd:ModelHero):Number{
			var index:int=hmd && hmd.cfg && hmd.cfg.arr ? hmd.cfg.arr.indexOf(this.id) : -1;
			if(index==-1) return 0;//trace("modelFormation error",hmd);
			else return hmd.formation[index][0];
			
		}

		/**
		 * 当前等级
		 */
		public function curLv(hmd:ModelHero):Number{
			var index:int=hmd && hmd.cfg && hmd.cfg.arr ? hmd.cfg.arr.indexOf(this.id) : -1;
			if(index==-1) trace("modelFormation error",hmd);
			else return hmd.formation[index][1];
			return 0;
		}

		/**
		 * 检查是否可进阶
		 */
		public function checkStar(hmd:ModelHero,index:int,isTips:Boolean=false):Boolean{
			if(hmd.isMine()==false){
				isTips && ViewManager.instance.showTipsTxt(Tools.getMsgById("_hero_formation20"));
				return false;
			}
			
			var _id:String=hmd.cfg.arr[index];
			var _star:Number=this.curStar(hmd);
			var arr:Array = [cfgArrCost[_id][0],cfgArrQuality[_star] ? cfgArrQuality[_star][2] : -1];

			if(arr[1]==-1){
				isTips && ViewManager.instance.showTipsTxt(Tools.getMsgById("_hero_formation19"));
				return false;
			} 
			if(!Tools.isCanBuy(arr[0],arr[1],false)){
				isTips && ViewManager.instance.showTipsTxt(Tools.getMsgById("_hero_formation24",[ModelItem.getItemName(arr[0]),arr[1]]));
				return false;
			}

			var n:Number=ModelFormation.serchFormationObj(Number(_id),cfgArrQuality[_star][1]);
			if(n==-1){
				return true;
			}
			if(n<cfgArrQuality[_star][0]){
				//isTips && ViewManager.instance.showTipsTxt("进阶需要"+cfgArrQuality[_star][0]+"名英雄拥有"+Tools.getColorInfo(cfgArrQuality[_star][1])+"品质");
				isTips && ViewManager.instance.showTipsTxt(Tools.getMsgById("_hero_formation11",
							[cfgArrQuality[_star][0],Tools.getColorInfo(cfgArrQuality[_star][1]),this.getName()]));
				return false;
			}

			return true;
		}
		/**
		 * 检查是否可升级
		 */
		public function checkLv(hmd:ModelHero,index:int,isTips:Boolean=false):Boolean{
			if(hmd.isMine()==false){
				isTips && ViewManager.instance.showTipsTxt(Tools.getMsgById("_hero_formation20"));
				return false;
			}

			var _id:String=hmd.cfg.arr[index];
			var _lv:Number=this.curLv(hmd);
			var _star:Number=this.curStar(hmd);
			var arr:Array = [cfgArrCost[_id][1],cfgArrLevel[_lv] ? cfgArrLevel[_lv][1] : -1];

			if(arr[1]==-1){
				isTips && ViewManager.instance.showTipsTxt(Tools.getMsgById("_hero_formation18"));
				return false;
			} 
			if(!Tools.isCanBuy(arr[0],arr[1],false)){
				isTips && ViewManager.instance.showTipsTxt(Tools.getMsgById("_hero_formation23",[ModelItem.getItemName(arr[0]),arr[1]]));
				return false;
			}
			var n:Number=cfgArrLevel[_lv][0];
			if(n>_star){
				isTips && ViewManager.instance.showTipsTxt(Tools.getMsgById("_hero_formation12",[Tools.getColorInfo(n)]));//"品质达到"+Tools.getColorInfo(n)+"后可升级");
				return false;
			}

			return true;
		}
		
		public function getAttrInfo(_star:int):String{
			return this.getStarInfo(_star);
		}



		public static function initFormationObj():void{
			ModelFormation.fomationObj={};
			var heros:Object=ModelManager.instance.modelUser.hero;
			for(var s:String in heros){
				var hmd:ModelHero=ModelManager.instance.modelGame.getModelHero(s)
				var arr:Array=hmd.formation;
				for(var i:int=0;i<arr.length;i++){
					var lv:Number=arr[i][0];
					if(lv>=1){
						var fid:int=hmd.cfg.arr[i];
						var o:Object;
						if(ModelFormation.fomationObj.hasOwnProperty(fid)){
							o=ModelFormation.fomationObj[fid];
							o[lv+""] = o[lv+""]?o[lv+""]+1 : 1;
						}else{
							o={};
							o[lv+""]=1;
							ModelFormation.fomationObj[fid]=o;
						}
					}
				}
			}
		}
		
		
		/**
		 * 得到阵法对象的阵法类型0普通 1锋矢 2钩行 3雁形 4鹤翼 5铁桶 6八卦   和品质
		 */
		public static function getFormationTypeAndStar(formationArr:Array) :Array
		{
			var formationType:int = 0;
			var formationStar:int = 0;
			if(formationArr){
				formationType = formationArr[0];
				var formationObj:Object = formationArr[1];
				if (formationObj){
					var arr:Array = formationObj[formationType];
					if (arr){
						formationStar = arr[0];
					}
				}
			}
			return [formationType,formationStar];
		}
		/**
		 * 得到阵法对应品质下，是否克制某种阵法（写死的显示判断）
		 */
		public static function checkAdept(formation0:int, formation1:int, star:int) :Boolean
		{
			var mf:ModelFormation = ModelFormation.getModel(formation0);
			if (!mf.starRank){
				return false;
			}
			for (var i:int = 0; i <= star; i++) 
			{
				var starObj:Object = mf.starRank[i];
				if (starObj && starObj.special && starObj.special.cond){
					var condArr:Array = starObj.special.cond[0];
					if (condArr[1] == 'formationType' && condArr[2] == formation1){
						return true;
					}
				}
			}
			return false;
		}

		public static function addFormationObj(_id:int,_star:int):void{
			var o:Object;
			if(ModelFormation.fomationObj.hasOwnProperty(_id)){
				o=ModelFormation.fomationObj[_id];
				o[_star] = o[_star]?o[_star]+1 : 1;
				if(o[_star-1]){
					o[_star-1] = o[_star-1]-1;
				}
			}else{
				o={};
				o[_star]=1;
				ModelFormation.fomationObj[_id]=o;
			}
		}

		public static function removeFormationObj(_id:int,_star:int):void{
			var o:Object;
			if(ModelFormation.fomationObj.hasOwnProperty(_id)){
				o=ModelFormation.fomationObj[_id];
				if(o[_star]){
					o[_star] = o[_star]-1;
				}
			}
		}

		public static function serchFormationObj(_id:int,_star:int):Number{
			if(_star==0) return -1;
			var o:Object;
			var n:Number=0;
			if(ModelFormation.fomationObj.hasOwnProperty(_id)){
				o=ModelFormation.fomationObj[_id];
				for(var s:String in o){
					if(Number(s)>=_star){
						n+=o[s];
					}
				}
			}
			return n;
		}

		/**
		 * 获得某个阵法的英雄对应的等级（测试用的）
		 */
		public static function getHidsByID(_id:int):Object{
			var obj:Object = {};
			var heros:Object=ModelManager.instance.modelUser.hero;
			for(var s:String in heros){
				var hmd:ModelHero=ModelManager.instance.modelGame.getModelHero(s)
				var arr:Array = hmd.getFormationArr();
				for(var i:int=0;i<arr.length;i++){
					if((arr[i] as ModelFormation).id == _id){
						var n:Number = (arr[i] as ModelFormation).curStar(hmd);
						if(n!=0){
							obj[hmd.id] = n;
						} 
					}
				}
			}
			return obj;
		}

		

	}

}