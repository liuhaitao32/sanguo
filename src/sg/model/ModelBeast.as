package sg.model 
{
	import laya.maths.MathUtil;
	import sg.cfg.ConfigServer;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.utils.FightUtils;
	import sg.fight.logic.utils.PassiveStrUtils;
	import sg.manager.EffectManager;
	import sg.map.utils.ArrayUtils;
	import sg.map.utils.TestUtils;
	import sg.utils.Tools;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.utils.StringUtil;
	import sg.cfg.ConfigColor;
	/**
	 * 八门兽灵数据结构
	 * @author zhuda
	 */
	public class ModelBeast extends ModelBase{
		
		public static const EVENT_BEAST_FILTER:String = "event_beast_filter";//筛选
		public static const EVENT_BEAST_SORT:String   = "event_beast_sort";  //排序
		public static const EVENT_BEAST_UPDATE:String = "event_beast_update";//安装/卸载/分解
		public static const EVENT_BEAST_LIST_REFRESH:String = "event_beast_list_refresh";//列表刷新 解锁/锁定

		public static const sortKeyArr:Array = ["sortLock","sortLv","sortStar","sortPos","sortType","sortId"];

		private static var _models:Object = {};
		
		public static function getModel(key:*):ModelBeast
		{
			if (!_models[key]){
				var valueArr:Array = ModelManager.instance.modelUser.beast[key];
				if(valueArr){
					var mb:ModelBeast = new ModelBeast(key,valueArr);
					_models[key] = mb;
				}else{
					_models[key] = null;
				}
			}
			return _models[key];
		}
		
		private var _id:int;
		public function get id():int{
            return this._id;
        }
		
		///兽灵原始串[套装类型，位置，品质，等级，副属性，test是否禁用]
		public var valueArr:Array;

		///兽灵套装类型
		public var type:String;
		///兽灵装备位置
		public var pos:int;
		///兽灵品质 0绿1蓝2紫3金4红
		public var star:int;
		///兽灵等级
		public var lv:int;
		///兽灵的副属性
		public var superArr:Array;
		///test是否启用
		public var ban:Boolean;
		//装备英雄
		public var hid:String;


		public function ModelBeast(id:int, valueArr:Array) 
		{
			this.hid = "";
			this._id = id;
			this.valueArr = valueArr;
			this.type = valueArr[0];
			this.pos = valueArr[1];
			this.star = valueArr[2];
			this.lv = valueArr[3];
			this.superArr = valueArr[4];
			this.ban = valueArr[5]?true:false;
		}
		
		/**
		 * 得到位置名称
		 */
		public function get posName() :String
		{
			return ModelBeast.getPosName(this.pos);
		}
		
		/**
		 * 得到套装名称
		 */
		public function get typeName() :String
		{
			return ModelBeast.getTypeName(this.type);
		}
		
		/**
		 * 得到名称
		 */
		public function getName(canTest:Boolean = false) :String
		{
			var name:String = Tools.getMsgById('_beastName', [this.typeName, this.posName]);
			if (canTest && TestUtils.isTestShow){
				//name += ' ' +this.getLvInfo(0) + ' ';
                name += this.id;
			}
            return name;
		}

		/**
		 * 名字
		 */
		public static function getBeastName(id:String):String{
			return Tools.getMsgById('_beastName', [getTypeName(id[5]),getPosName(id[6])]);
		}

		/**
		 * 得到icon
		 */
		public function getIcon():String
		{
            return getIconByType(this.type);
		}

		/**
		 * 得到icon
		 */
		public static function getIconByType(_type:String):String
		{
            return "beastType_"+_type+".png";
		}
		/**
		 * 得到兽灵指定等级的属性对象
		 */
		public function getLvObj(lv:int) :Object
		{
			if (lv == 0){
				return {};
			}else if(lv < 0){
				lv = this.lv;
			}
			return ModelBeast.getLvObjByPos(lv, this.pos, this.star);
		}
		/**
		 * 得到兽灵指定等级的描述
		 */
		public function getLvInfo(lv:int = -1, hasBrackets:Boolean = false) :String
		{
			return PassiveStrUtils.translateRsltInfo(Tools.getMsgById('cond'),this.getLvObj(lv),hasBrackets);
		}

		/**
		 * 得到兽灵指定等级的数值
		 */
		public function getLvPower(lv:int = -1) :String
		{
			var o:Object = this.getLvObj(lv);
			for(var s:String in o){
				if(s!='power'){
					return o[s];
				}
			}
			return '';
		}
		
		/**
		 * 得到对应位置的副属性是否解锁
		 */
		public function isUnlockSuper(index:int) :Boolean
		{
			return ModelBeast.isSuperUnlock(index, this.lv);
		}
		
		/**
		 * test测试模式编辑后，生成原数据
		 */
		public function getValueArr(hasBan:Boolean) :Array
		{
			var arr:Array = [this.type, this.pos, this.star, this.lv, this.superArr];
			if (hasBan)
				arr.push(this.ban);
			return arr;
		}
		
		
		/**
		 * 得到兽灵指定等级的属性对象
		 */
		static public function getLvObjByPos(lv:int, pos:int ,star:int = -1) :Object
		{
			if (star >= 0){
				//限制最大等级
				lv = Math.min(ModelBeast.getMaxLv(star), lv);
			}
			var rank:Array = ConfigServer.fight.beastLv[pos];
			if (rank){
				return FightUtils.getRankObj(lv, rank);
			}
			return {};
		}
		/**
		 * 得到兽灵全套等级属性对象描述
		 */
		static public function getAllLvInfo(beastArr:Array) :String
		{
			var obj:Object = ModelBeast.getAllLvObj(beastArr);
			var tempObj:Object = {};
			if (obj.atk){
				tempObj['army[0].atk'] = obj.atk;
				tempObj['army[1].atk'] = obj.atk;
				delete obj.atk;
			}
			if (obj.hpm){
				tempObj['army[0].hpm'] = obj.hpm;
				tempObj['army[1].hpm'] = obj.hpm;
				delete obj.hpm;
			}
			FightUtils.mergeObj(obj, tempObj);
			return PassiveStrUtils.translateRsltInfo(Tools.getMsgById('cond'), obj, false,false,true,2);
		}
		/**
		 * 得到兽灵全套等级属性对象{superKey:superValue}
		 */
		static public function getAllLvObj(beastArr:Array) :Object
		{
			var reObj:Object = {};
			var len:int = beastArr.length;
			var i:int;
			var j:int;
			var lvObj:Object;
			var tempArr:Array;
			for (i = 0; i < len; i++) 
			{
				var temp:* = beastArr[i];
				if (temp){
					if (temp is ModelBeast){
						var tempModelBeast:ModelBeast = temp;
						if (tempModelBeast.ban)
							continue;
						lvObj = tempModelBeast.getLvObj(-1);
					}
					else if (temp is Array){
						tempArr = temp;
						if (tempArr[5])
							continue;
						lvObj = ModelBeast.getLvObjByPos(tempArr[3],tempArr[1], tempArr[2]);
					}
					else{
						continue;
					}
					FightUtils.mergeObj(reObj, lvObj);
				}
			}
			return reObj;
		}

		/**
		 * 根据英雄id返回安装兽灵的属性 + 副属性
		 */
		static public function getAllProInfoByHid(hero_id:String):String{
			var hero_beast:Array = ModelManager.instance.modelUser.hero[hero_id].beast_ids;
			var s:String = "";
			if(hero_beast){
				var beastArr:Array = [];
				for(var i:int=0;i<hero_beast.length;i++){
					if(hero_beast[i]){
						beastArr.push(ModelBeast.getModel(hero_beast[i]));
					}
				}
				var s1:String = getAllLvInfo(beastArr);
				var s2:String = getAllSuperInfo(beastArr);
				s = s1 + '\n' + s2;
			}
			return s;
		}
		
		
		
		static public function getPosName(pos:int) :String
		{
			return Tools.getMsgById('_beastPos_' + pos);
		}
		static public function getTypeName(type:String) :String
		{
			return Tools.getMsgById('_beastType_' + type);
		}
		
		
		/**
		 * 得到兽灵副属性值0~20，对应的效果值和颜色
		 */
		static public function getSuperValueArr(v:int) :Array
		{
			if (v >= ConfigFight.beastSuperValue.length){
				v = ConfigFight.beastSuperValue.length - 1;
			}
			else if (v < 0){
				return [0,0];
			}
			return ConfigFight.beastSuperValue[v];
		}
		/**
		 * 判定兽灵副属性是否解锁
		 */
		static public function isSuperUnlock(index:int,lv:int) :Boolean
		{
			return lv >= ConfigFight.beastSuperUnlock[index];
		}
		/**
		 * 兽灵副属性解锁等级
		 */
		static public function getSuperUnlockLv(index:int) :int
		{
			return ConfigFight.beastSuperUnlock[index];
		}

		
		/**
		 * 得到兽灵套装共鸣技能，导出的技能等级从1开始
		 */
		static public function getResonanceSkillObj(beastArr:Array) :Object
		{
			var reObj:Object = {};
			var resonanceArr:Array = ModelBeast.getResonanceArr(beastArr);
			var len:int = resonanceArr.length;
			for (var i:int = 0; i < len; i++) 
			{
				var oneArr:Array = resonanceArr[i];
				reObj['beastResonance' + oneArr[0] + oneArr[1]] = oneArr[2]+1;
			}
			return reObj;
		}
		/**
		 * 得到兽灵套装共鸣，返回[[共鸣套装，共鸣数量，共鸣品质0开始],[共鸣套装，共鸣数量，共鸣品质0开始]]
		 */
		static public function getResonanceArr(beastArr:Array) :Array
		{
			var reArr:Array = [];
			var sumObj:Object = {};
			var len:int = beastArr.length;
			var i:int;
			var j:int;
			var type:String;
			var star:int;
			var tempArr:Array;
			for (i = 0; i < len; i++) 
			{
				var temp:* = beastArr[i];
				if (temp){
					if (temp is ModelBeast){
						var tempModelBeast:ModelBeast = temp;
						if (tempModelBeast.ban)
							continue;
						type = tempModelBeast.type;
						star = tempModelBeast.star;
					}
					else if (temp is Array){
						tempArr = temp;
						if (tempArr[5])
							continue;
						type = tempArr[0];
						star = tempArr[2];
					}
					else{
						continue;
					}
					if (!sumObj[type]){
						//套装type下，对应品质的数量0绿1蓝2紫3金4红
						sumObj[type] = [0,0,0,0,0];
					}
					for (j = 0; j <= star; j++) 
					{
						sumObj[type][j]++;
					}
				}
			}
			//整理对象，激活共鸣套装
			for (type in sumObj){
				tempArr = sumObj[type];
				len = ConfigFight.beastResonance.length;
				var checkResonance:Boolean = true;
				for (i = 0; i < len; i++ ){
					if (!checkResonance)
						continue;
					checkResonance = false;
					for (star = tempArr.length - 1; star >= 0; star-- ){
						var num:int = tempArr[star];
						if (num >= ConfigFight.beastResonance[i]){
							//仅收录该共鸣套装指定数量的最高品质
							reArr.push([type, ConfigFight.beastResonance[i], star]);
							checkResonance = true;
							break;
						}
					}
				}
			}
			return reArr;
		}
		
		
		/**
		 * 得到兽灵套装总共鸣效果说明
		 */
		static public function getAllResonanceInfo(resonanceArr:Array, hasNext:Boolean = false, isHtml:Boolean = false) :String
		{
			var arr:Array;
			var resonanceInfoArr0:Array;
			var resonanceInfoArr1:Array;
			var resonanceInfoArr:Array;
			var isMaxResonance:Boolean;
			
			if (resonanceArr.length > 1){
				arr = resonanceArr[1];
				isMaxResonance = arr[1] == ConfigFight.beastResonance[ConfigFight.beastResonance.length - 1];
				resonanceInfoArr1 = ModelBeast.getResonanceInfoArr(arr[0], arr[1], arr[2], hasNext, isHtml);
			}
			
			if (resonanceArr.length > 0){
				arr = resonanceArr[0];
				resonanceInfoArr0 = ModelBeast.getResonanceInfoArr(arr[0], arr[1], arr[2], hasNext, isHtml);
				//全套共鸣
				if (resonanceInfoArr1){
					if (isMaxResonance){
						resonanceInfoArr = [resonanceInfoArr0[0], resonanceInfoArr1[0], resonanceInfoArr0[1]];
					}
					else{
						resonanceInfoArr = resonanceInfoArr0.concat(resonanceInfoArr1);
					}
				}
				else{
					resonanceInfoArr = resonanceInfoArr0;
				}
			}
			var sep:String = isHtml?'<br/>':'\n\n';
			return resonanceInfoArr.join(sep);
		}
		/**
		 * 得到兽灵套装共鸣的效果字符串数组  star 0绿1蓝2紫3金4红
		 */
		static public function getResonanceInfoArr(type:String, num:int, star:int, hasNext:Boolean = false, isHtml:Boolean = false) :Array
		{
			var reArr:Array = [];
			
			var info:String = 'null';
			var tempInfo:String;
			//var countInfo:String
			var typeName:String = ModelBeast.getTypeName(type);
			var starName:String = Tools.getColorInfo(star + 2);
			var starColor:String = '#AACCDD';
			if (isHtml){
				starName = '[' + starName + ']';
				starColor = EffectManager.getFontColor(star + 2);
			}
			var ms:ModelSkill = ModelSkill.getModel('beastResonance' + type + num);
			var sep:String = isHtml?'<br/>':'\n';
			if (ms){
				//兽灵共鸣技能获得方式的描述
				info = ms.getBeastResonanceEnergyInfo(star+1, isHtml);
			}
			
			if (num == 4){
				if (hasNext && star < 4){
					tempInfo = Tools.getMsgById('_beastResonanceNext', [num, starName, typeName]);
					if (isHtml){
						tempInfo = StringUtil.substituteWithLineAndColor(tempInfo, starColor, '#AAAAAA');
					}
					info += sep + tempInfo;
				}
				reArr.push(info);
				
				//共鸣技能功能
				tempInfo = Tools.getMsgById('_beastResonance_' + type);
				if (isHtml){
					tempInfo = StringUtil.substituteWithLineAndColor(tempInfo, '#FFCC66', '#FFCC66');
				}
				info = tempInfo;
				reArr.push(info);
			}
			else if (num == 8){
				if (hasNext && star < 4){
					tempInfo = Tools.getMsgById('_beastResonanceNext', [num, starName, typeName]);
					if (isHtml){
						tempInfo = StringUtil.substituteWithLineAndColor(tempInfo, starColor, '#AAAAAA');
					}
					info += sep + tempInfo;
				}
				reArr.push(info);
			}
			return reArr;
		}
		/**
		 * 得到单个兽灵套装共鸣的效果字符串  star 0绿1蓝2紫3金4红
		 */
		static public function getResonanceInfo(type:String, num:int, star:int, hasNext:Boolean = false, isHtml:Boolean = false) :String
		{
			var sep:String = isHtml?'<br/>':'\n\n';
			return ModelBeast.getResonanceInfoArr(type, num, star, hasNext, isHtml).join(sep);
		}
		

		
		/**
		 * 得到兽灵全套副属性对象描述
		 */
		static public function getAllSuperInfo(beastArr:Array) :String
		{
			var obj:Object = ModelBeast.getAllSuperObject(beastArr);
			//按key的字母排序打印对象
			var sortArr:Array = FightUtils.objectToArray(obj, true);
			FightUtils.sortArray(sortArr,'0',ConfigFight.testBeastSupers);
			//sortArr.sort(MathUtil.sortByKey('0',false,false));
			var reInfoArr:Array = [];
			var len:int = sortArr.length;
			for (var i:int = 0; i < len; i++) 
			{
				var tempArr:Array = sortArr[i];
				var superType:String = tempArr[0];
				var superValue:Number = tempArr[1];
				var beastObj:Object = ModelBeast.getSuperBeastObj(superType,superValue,true);
				
				var msgId:String = '_beastSuper_' + superType;
				var cfgObj:Object = ConfigFight.beastSuperSkill[superType];
				if (cfgObj)
				{
					var infoArr:Array = cfgObj.infoArr;
					if (infoArr)
					{
						var replaceArr:Array = [];
						var j:int;
						var jLen:int = infoArr.length;
						for (j = 0; j < jLen; j++) 
						{
							replaceArr.push(PassiveStrUtils.translateSkillInfo(beastObj, infoArr[j], 0, false, true));
						}
						reInfoArr.push(Tools.getMsgById(msgId, replaceArr));
					}
				}
				
			}
			return reInfoArr.join('\n');
		}
		
		/**
		 * 得到兽灵已经解锁的全套副属性对象{superKey:superValue}
		 */
		static public function getAllSuperObject(beastArr:Array) :Object
		{
			var reObj:Object = {};
			var len:int = beastArr.length;
			var i:int;
			var j:int;
			var superArr:Array;
			var tempArr:Array;
			var lv:int;
			for (i = 0; i < len; i++) 
			{
				var temp:* = beastArr[i];
				if (temp){
					if (temp is ModelBeast){
						var tempModelBeast:ModelBeast = temp;
						if (tempModelBeast.ban)
							continue;
						superArr = tempModelBeast.superArr;
						lv = tempModelBeast.lv;
					}
					else if (temp is Array){
						tempArr = temp;
						if (tempArr[5])
							continue;
						superArr = tempArr[4];
						lv = tempArr[3];
					}
					else{
						continue;
					}

					var jLen:int = superArr.length;
					for (j = 0; j <= jLen; j++) 
					{
						tempArr = superArr[j];
						if (tempArr && lv>=ConfigFight.beastSuperUnlock[j]){
							var obj:Object = {};
							var superValue:Array = ModelBeast.getSuperValueArr(tempArr[1])[0];
							obj[tempArr[0]] = superValue;
							FightUtils.mergeObj(reObj, obj);
							//FightUtils.mergeObj(reObj,ModelBeast.getSuperBeastObj(tempArr[0],tempArr[1]));
						}
					}
				}
			}
			return reObj;
		}
		
		/**
		 * 得到副属性描述和颜色。由参数指定副属性类别，副属性阶别
		 */
		static public function getSuperInfoAndColorArr(superType:String, superRank:int) :Array
		{
			var valueArr:Array = ModelBeast.getSuperValueArr(superRank);
			//还需要增加技能映射
			var beastObj:Object = ModelBeast.getSuperBeastObj(superType, valueArr[0],true);
			var info:String;
			var msgId:String = '_beastSuper_' + superType;
			if (beastObj){
				var cfgObj:Object = ConfigFight.beastSuperSkill[superType];
				var replaceArr:Array = [];
				var infoArr:Array = cfgObj.infoArr;
				if (infoArr){
					var i:int;
					var len:int = infoArr.length;
					for (i = 0; i < len; i++) 
					{
						replaceArr.push(PassiveStrUtils.translateSkillInfo(beastObj, infoArr[i], 0, false, true));
					}
				}
				info = Tools.getMsgById(msgId, replaceArr);
			}
			else{
				info = Tools.getMsgById(msgId, [valueArr[0]]);
			}
			return [info,valueArr[1]];
		}
		
		/**
		 * 指定副属性类型及属性比率，获得副属性对象用于战前生效的副本{beast,skill}
		 */
		static public function getSuperBeastObj(superType:String, superValue:Number, containPassive:Boolean = false) :Object
		{
			var cfgObj:Object = ConfigFight.beastSuperSkill[superType];
			var reObj:Object;
			if (cfgObj){
				reObj = {};
				if (cfgObj.beast)
				{
					reObj.beast = FightUtils.clone(cfgObj.beast);
				}
				if (cfgObj.skill)
				{
					reObj.skill = FightUtils.clone(cfgObj.skill);
				}
				if (containPassive && cfgObj.passive && cfgObj.passive.rslt){
					reObj.passive = {};
					reObj.passive.rslt = FightUtils.clone(cfgObj.passive.rslt);
				}
				FightUtils.multObject(reObj, superValue);
			}
			return reObj;
		}
		
		/**
		 * 指定副属性类型及属性比率，获得副属性对象用于计算战力的副本{cond,rslt}
		 */
		static public function getSuperPassiveObj(superType:String, superValue:Number) :Object
		{
			var cfgObj:Object = ConfigFight.beastSuperSkill[superType];
			var reObj:Object;
			if (cfgObj){
				if (cfgObj.passive)
				{
					reObj = FightUtils.clone(cfgObj.passive);
				}
				else{
					reObj = FightUtils.clone(ConfigFight.beastSuperSkillDefaultPassive);
				}
				//刨除掉条件类
				FightUtils.multPassive(reObj, superValue);
			}
			return reObj;
		}
		
		
		
		
		////////////////////////////以下为养成系统需要实现的功能


		/**
		 * 得到对应副属性的描述和颜色
		 */
		public function getSuperInfoAndColor(index:int) :Array
		{
			var arr:Array = this.superArr[index];
			if (arr){
				return ModelBeast.getSuperInfoAndColorArr(arr[0],arr[1]);
			}
			return null;
		}

		/**
		 * 获得副属性数据 [[描述,颜色],[解锁等级,是否解锁]]
		 */
		public function getSuperData():Array{
			var arr:Array = [];
			for(var i:int=0;i<this.superArr.length;i++){
				var a1:Array = getSuperInfoAndColor(i);
				var a2:Array = [getSuperUnlockLv(i),isUnlockSuper(i)?1:0];
				arr.push([a1,a2]);
			}
			return arr;
		}

		public function getSuperHtmlInfo():String{
			var arr:Array = this.getSuperData();
			var len:Number = arr.length;
			var superStr:String = "";
			for(var i:int=0;i<arr.length;i++){
				var data:Array = arr[i];
				var s1:String = "<Font color='" + (ConfigColor.FONT_COLORS[data[0][1]]) + "'>"+Tools.getMsgById('_equip26') + data[0][0]+"</Font>";
				var s2:String = "&nbsp;&nbsp;&nbsp;&nbsp;" + "<Font color='" + (data[1][1]==0 ? "#828282":"#ffffff") + "'>"+Tools.getMsgById('_beast_text34',[data[1][0]])+"</Font>";
				var s:String = s1+s2;
				superStr += s;
				if(i<len-1){
                    superStr+="<br/>";
                }
			}
			return superStr;
		}
		
		/**
		 * 最大等级
		 */
		public function maxLv():Number{
			return ModelBeast.getMaxLv(this.star);
		}
		static public function getMaxLv(star:int):Number{
			var cfg:Array = ConfigServer.beast.upgrade_limit;
			return cfg[star];
		}
		
		/**
		 * 根据材料 现在最多可升至几级 0的话就是不能升级了
		 */
		public function canUpToLv():Number{
			var _curLv:Number = this.lv;
			var _maxLv:Number = this.maxLv();
			var _toLv:Number = 0;
			if(_curLv<_maxLv){
				var arr:Array = ConfigServer.beast.upgrade;
				for(var i:int=_curLv+1;i<=_maxLv;i++){
					var o:Object = lvUpNeedObj(i);
					var b:Boolean = true;
					for(var s:String in o){
						if(!Tools.isCanBuy(s,o[s],false)){
							b = false;
						}
					}
					if(b){
						_toLv = i;
					}else{
						break;
					}
				}
			}else{
				return 0;
			}
			return _toLv;
		}

		/**
		 * 升到x级需要的资源
		 */
		public function lvUpNeedObj(_lv:int,curLv:int = 0):Object{
			var _curLv:Number = curLv == 0 ? this.lv : curLv;
			if(_lv<=_curLv) return null;

			var arr:Array = ConfigServer.beast.upgrade;
			var obj:Object = arr[_lv-2] ? arr[_lv-2][this.pos] : null;
			var data:Object = {};
			if(obj){
				for(var i:int=_lv-2;i>=_curLv-1;i--){
					var o:Object = arr[i][this.pos];
					for(var s:String in o){
						if(data[s]) data[s] = data[s]+o[s];
						else data[s] = o[s];
					}
				}
			}else{
				trace("===modelBeast lv error",_lv);
			}
			return data;
		}

	

		/**
		 * 检查是否可升级
		 */
		public function checkLv(isTips:Boolean=false):Boolean{
			var _curLv:Number = this.lv;
			var _maxLv:Number = this.maxLv();
			if(_curLv == _maxLv){
				if(isTips) ViewManager.instance.showTipsTxt(Tools.getMsgById('_beast_tips0')); //'已到达该稀有度的最高级别');
				return false;
			}
			if(canUpToLv()==0){
				if(isTips) ViewManager.instance.showTipsTxt(Tools.getMsgById('_beast_tips1')); //'材料不足');
				return false;
			}
			return true;
		}

		/**
		 * 是否锁定
		 */
		public function isLock():Boolean{
			return ModelManager.instance.modelUser.beast_lock_ids.indexOf(this.id+"")!=-1;
		}


		/**
		 * 获得背包格子数
		 */
		public static function getBagTotalNum():Number{
			var cfg:Array = ConfigServer.beast.add_bag;
			var buy_times:Number = ModelManager.instance.modelUser.beast_times; 
			var n:Number = cfg[0]+buy_times*cfg[2];
			return n;
		}
		/**
		 * 获得背包当前使用格子数
		 */
		public static function getBagCurNum():Number{
			var beasts:Object = ModelManager.instance.modelUser.beast;
			var heros:Object = ModelManager.instance.modelUser.hero;
			var n:Number = 0;
			var n1:Number = Tools.getDictLength(beasts);
			var n2:Number = 0;
			for(var hid:String in heros){
				if(heros[hid].beast_ids){
					for(var i:int=0;i<heros[hid].beast_ids.length;i++){
						if(heros[hid].beast_ids[i]!=null){
							n2+=1;
						}
					}
				}
			}
			n = n1 - n2;
			return n;
		}

		/**
		 * 购买背包格子需要的coin值 0的话就是不能买了
		 */
		public static function buyBagNumNeedCoin():Number{
			var n:Number = 0;
			var cfg:Array = ConfigServer.beast.add_bag;
			var buy_times:Number = ModelManager.instance.modelUser.beast_times;
			if(buy_times<cfg[1]){
				n = (cfg[3+buy_times]) ? cfg[3+buy_times] : cfg[cfg.length-1];
			}
			return n;
		}

		/**
		 * 按条件获得兽灵列表
		 */
		public static function getBeastArr(_type:String="",_pos:Number=-1,sortKey:String = "",bigFirst:Boolean = true):Array{
			var beastObj:Object = ModelManager.instance.modelUser.beast;
			var arr:Array = [];
			for(var s:String in beastObj){
				
				var beast:ModelBeast = ModelBeast.getModel(Number(s));
				if(beast.hid != "") continue;

				var b0:Boolean = _type == "" && _pos==-1;         //所有
				var b1:Boolean = _type=="" && beast.pos == _pos;  //指定位置
				var b2:Boolean = _pos==-1 && beast.type == _type; //指定类型
				var b3:Boolean = beast.pos == _pos && beast.type == _type; //指定类型&位置
				if(b0 || b1 || b2 || b3){
					var n:Number = (beast.type).charCodeAt(0);
					var o:Object = {};
					o["data"] = beast;
					o["sortLock"] = beast.isLock() ? 1 : 0;
					o["sortLv"] = beast.lv;
					o["sortStar"] = beast.star;
					o["sortPos"] = beast.pos*-1;
					o["sortType"] = n;
					o["sortId"] = Number(s);
					arr.push(o);
				}
			} 
			var newSort:Array = sortKey=="" ? ModelBeast.sortKeyArr : [sortKey];
			if(sortKey!=""){
				for(var i:int=0;i<ModelBeast.sortKeyArr.length;i++){
					if(ModelBeast.sortKeyArr[i]!=sortKey){
						newSort.push(ModelBeast.sortKeyArr[i]);
					}
				}
			}
			
			ArrayUtils.sortOn(newSort,arr,bigFirst,true);
			return arr;
		}

		/**
		 * 获得我有的类型的列表
		 */
		public static function getAllTypeArr():Array{
			var arr:Array = [];
			var userBeasts:Object = ModelManager.instance.modelUser.beast;
			for(var s:String in userBeasts){
				var a:Array = userBeasts[s];
				var b:Boolean = false;
				if(ModelBeast.getModel(s).hid == ""){
					for(var i:int=0;i<arr.length;i++){
						if(arr[i].key == a[0]){
							b = true;
							break;
						}
					}

					if(b==false){
						var o:Object = {};
						var n:Number = (a[0]).charCodeAt(0);
						o["key"] = a[0];
						o["text"] = ModelBeast.getTypeName(a[0]);
						o["sortType"] = n;
						arr.push(o);
					}
				}
			}
			ArrayUtils.sortOn(["sortType"],arr,false,true);
			return arr;
		}
		
		/**
		 * 这个兽灵在已安装的英雄身上的4或8件套的品质
		 */
		public function getResonanceStar(_num:Number):Number{
			if(this.hid != ""){
				var arr:Array = ModelManager.instance.modelGame.getModelHero(this.hid).getBeastResonanceArr();
				for(var i:int=0;i<arr.length;i++){
					if(arr[i][0] == this.type && arr[i][1] == _num){
						return arr[i][2];
					}
				}
			}
			return -1;
		}


		public static function testMsg(s:String,o:Object):void{
			NetSocket.instance.send(s,o,new Handler(null,function(np:NetPackage):void{
				var o:Object = np.receiveData;
				trace(s,"==",o);
			}));
		}

		/**
		 * 功能是否开启
		 */
		public static function isOpen():Boolean{
			if(ConfigServer.beast){
				var n1:Number = ConfigServer.beast["switch"] != null ?  ConfigServer.beast["switch"] : -1;
				var n2:Number = ModelManager.instance.modelUser.mergeNum;
				return n1>=0 && n1 <= n2;
			}
			return false;
		}

	}

}