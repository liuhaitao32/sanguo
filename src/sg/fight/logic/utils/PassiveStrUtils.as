package sg.fight.logic.utils
{
	import laya.maths.MathUtil;
	import sg.cfg.ConfigServer;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.utils.Tools;
	
	/**
	 * 追加属性，整理文本的工具类
	 * @author zhuda
	 */
	public class PassiveStrUtils
	{
		private static const operatorArr:Array = ['+', '-', '*', '/'];
		///正则匹配数字
		private static const NUMBER_REGEXP:RegExp = new RegExp('^\\d+(\.\\d+)?$');
		///正则匹配替换
		private static const REPLACE_REGEXP:RegExp = new RegExp('\{.\}');
	
		
		/**
         * 得到指定等级的data数据，也可指定无up就自动倍化Passive数据
         */
		public static function getLvData(srcData:Object, lv:int, noUpMult:Boolean = false, hasEnd:Boolean = true ):Object{
			var newData:Object = srcData;
			if (lv - 1 > 0)
			{
				var upData:* = srcData.up;
				if (upData){
					newData = FightUtils.clone(newData);
					for (var upKey:String in upData)
					{
						FightUtils.addObjByPath(newData, upKey, upData[upKey] * (lv - 1), hasEnd);
					}
				}else if (noUpMult && srcData.passive){
					newData = FightUtils.clone(newData);
					newData.passive = PassiveStrUtils.getMultPassive(newData.passive, lv);
				}
			}
			return newData;
		}
		/**
		 * 获得倍化后的passive属性
		 */
		public static function getMultPassive(passive:*, num:int):*
		{
			if (num == 1){
				return passive;
			}
			else if (num < 1){
				return null;
			}
			else if (!passive){
				return null;
			}
			var passiveOne:Object;
			if (passive is Array){
				var newArr:Array = [];
				var arr:Array = passive as Array;
				var len:int = arr.length;
				for (var i:int = 0; i < len; i++) 
				{
					passiveOne = arr[i];
					newArr.push(PassiveStrUtils.getMultPassive(passiveOne,num));
				}
				return newArr;
			}else{
				passiveOne = FightUtils.clone(passive);
				for (var k:* in passiveOne.rslt){
					passiveOne.rslt[k] *= num;
				}
				return passiveOne;
			}
		}
		/**
		 * 按技能配置，取得技能类别，细致到是否主动被动
		 */
		public static function translateSkillTypeInfo(srcObj:Object, hasDetail:Boolean = true):String
		{
			var type:int = srcObj.type;
			var str:String = Tools.getMsgById('skill_type_' + type);
			var str2:String = '';
			if (hasDetail)
			{
				if(type < 4){
					var actType:* = FightUtils.getValueByPath(srcObj, 'act[0].type');
					if (actType == null || actType == 2 || actType == 3 ||actType == 4 || actType == 5)
					{
						str2 = Tools.getMsgById('skill_act_inactive');
					}
					else
					{
						str2 = Tools.getMsgById('skill_act_active');
					}
				}
				else if (type == 4){
					//英雄
					var limit:Object = srcObj.limit;
					if (limit && limit.hasOwnProperty('type')){
						str = Tools.getMsgById('skill_type_4_'+limit.type);
					}
				}
				else if (type == 5){
					//辅助
					str = Tools.getMsgById(srcObj.isAssist?'skill_type_5_1':'skill_type_5_0');
				}
			}
			str = Tools.getMsgById('skill_type_info',[str,str2]);
			return str;
		}
		
		/**
		 * 包装方括号
		 */
		public static function packBrackets(str:String):String
		{
			return '[' + str + ']';
		}
		
		/**
		 * 按格式|引用路径字符串，导出文本替换内容 type -整数 +有符号整数 %百分率 *有符号百分率 /负向百分率
		 */
		public static function translateValueInfo(type:String, value:*, hasBrackets:Boolean = true):String
		{
			var str:String;
			if (type == '-')
			{
				//整数
				str = '' + Tools.numberFormat(value);
			}
			else if (type == '+')
			{
				//有符号整数
				str = (value >= 0 ? '+' : '') + Tools.numberFormat(value);
			}
			else if (type == '#')
			{
				//保留1位小数的有符号整数
				str = (value >= 0 ? '+' : '') + Tools.numberFormat(value,1);
			}
			else if (type == '%')
			{
				//百分率
				str = Tools.percentFormat(value / ConfigFight.ratePoint, 1);
			}
			else if (type == '*')
			{
				//有符号百分率
				str = (value > 0 ? '+' : '') + Tools.percentFormat(value / ConfigFight.ratePoint, 1);
			}
			else if (type == '/')
			{
				//负向百分率
				value = -value;
				str = (value > 0 ? '+' : '') + Tools.percentFormat(value / ConfigFight.ratePoint, 1);
				//str = Tools.percentFormat(1 - 1 / (1 + value / ConfigFight.ratePoint));
			}
			else
			{
				str = '无法解析：' + type + ' ' + value;
			}
			if (hasBrackets)
			{
				str = PassiveStrUtils.packBrackets(str);
			}
			return str;
		}
		
		/**
		 * 按格式|引用路径字符串，导出技能文本替换内容 type r触发回合 p passive文本 0整数 +有符号整数 %百分率 %有符号百分率 $负向百分率
		 */
		public static function translateSkillInfo(srcObj:Object, allStr:String, skillLv:int = 0, hasBrackets:Boolean = true, hasEnd:Boolean = false):String
		{
			var arr:Array = allStr.split('|');
			var type:String = arr[0];
			var funStr:String = arr[1];
			var aimObj:Object;
			var str:String;
			var value:Number;
			
			if (type == 'r')
			{
				//触发回合
				aimObj = FightUtils.getValueByPath(srcObj, funStr, hasEnd);
				return PassiveStrUtils.translateRoundInfo(aimObj);
			}
			else if (type == 'p')
			{
				//格式化passive文本
				aimObj = FightUtils.getValueByPath(srcObj, funStr, hasEnd);
				return PassiveStrUtils.translatePassiveInfo(aimObj);
			}
			else if (type == 'e')
			{
				//格式化数组ax+b %，x为当前等级的值
				arr = FightUtils.getValueByPath(srcObj, funStr, hasEnd);
				if (skillLv < 1)
					skillLv = 1;
				str = Tools.percentFormat(arr[0] * skillLv + arr[1]);
				if (hasBrackets)
				{
					str = PassiveStrUtils.packBrackets(str);
				}
				return str;
			}
			else if (type == 'l')
			{
				//格式化数组Lv倍为当前等级的值
				value = FightUtils.getValueByPath(srcObj, funStr, hasEnd);
				if (skillLv < 1)
					skillLv = 1;
				str = ''+ (value * skillLv);
				if (hasBrackets)
				{
					str = PassiveStrUtils.packBrackets(str);
				}
				return str;
			}
			else
			{
				value = PassiveStrUtils.getFunValue(srcObj, funStr, hasEnd);
				return PassiveStrUtils.translateValueInfo(type, value, hasBrackets);
			}
		}
		
		/**
		 * 格式化passive内容 hasBrackets是否加括号，isAdd是否显示额外, hasValue取出数值，sortType属性排序：0乱序；1不换行；2按\n换行；3按br换行
		 */
		public static function translatePassiveInfo(passive:*, hasBrackets:Boolean = true, isAdd:Boolean = false, sortType:int = 0):String
		{
			if (passive == null)
			{
				return "无passive";
			}
			var str:String = '';
			
			if (passive is Array)
			{
				var arr:Array = passive;
				var len:int = arr.length;
				for (var i:int = 0; i < len; i++)
				{
					var tempStr:String = PassiveStrUtils.translatePassiveInfo(arr[i], hasBrackets, str != '', sortType);
					if (tempStr != '')
					{
						if (str != '')
						{
							str += Tools.getMsgById('rslt_connect0');
						}
						str += tempStr;
					}
				}
			}
			else
			{
				var info:String = passive.info;
				if (passive.noTrans){
					//不解释，只用info
					str = info?Tools.getMsgById(info):"";
				}
				else{
					var condStr:String = PassiveStrUtils.translateCondStr(passive);
					if (info)
					{
						//info不替换cond说明，屏蔽兵种条件类说明
						if (condStr.indexOf('{0}') == -1){
							condStr = Tools.getMsgById('cond');
						}
						//str = Tools.getMsgById(info);
						str = Tools.replaceMsg(condStr, ['', Tools.getMsgById(info)]);
					}
					else if (passive.rslt)
					{
						str = PassiveStrUtils.translateRsltInfo(condStr, passive.rslt, hasBrackets, isAdd, true, sortType);
					}
				}
			}
			return str;
		}
		/**
		 * 格式化condStr
		 */
		public static function translateCondStr(passive:Object):String
		{
			var condArr:Array = passive.cond;
			var condStr:String;
			if (condArr && condArr[0] != 'equip')
			{
				var checkSign:String = condArr[1];
				if (checkSign == '>=' || checkSign == '*' || checkSign == '<'){
					var checkStr:String = condArr[0];
					var skillId:String;
					var skillName:String;
					if (checkStr.indexOf('skill') == 0){
						skillId = checkStr.split('.')[1];
						skillName = Tools.getMsgById(skillId);
					}
					
					if (checkSign == '>='){
						//达到要求
						if (skillName){
							condStr = Tools.getMsgById('cond_skill',[skillName,condArr[2]])+Tools.getMsgById('cond');
						}
						else if (checkStr == 'lv' || checkStr == 'str' || checkStr == 'agi' || checkStr == 'cha' || checkStr == 'lead'){
							condStr = Tools.getMsgById('cond_' + checkStr,[condArr[2]])+Tools.getMsgById('cond');
						}
					}
					else if (checkSign == '*'){
						//每提升一级
						if (skillName){
							condStr = Tools.getMsgById('cond_skill*',[skillName])+Tools.getMsgById('cond');
						}
						else if (checkStr == 'str' || checkStr == 'agi' || checkStr == 'cha' || checkStr == 'lead'){
							condStr = Tools.getMsgById('cond_' + checkStr)+Tools.getMsgById('cond');
						}
					}
					else if (checkSign == '<'){
						//未到达要求
						if (skillName){
							condStr = Tools.getMsgById('cond_skill<', [skillName,condArr[2]]) + Tools.getMsgById('cond');
						}
					}
				}else if (checkSign == '=' && condArr[0] == 'hid'){
					var heroCfg:Object = ConfigServer.hero[condArr[2]];
					var heroName:String = Tools.getMsgById(heroCfg.name);
					condStr = Tools.getMsgById('cond_hid', [heroName])+Tools.getMsgById('cond');
				}
				
				if(!condStr){
					var joinStr:String = 'cond_' + condArr.join('');
					condStr = Tools.getMsgById(joinStr);
				}
			}
			else
			{
				condStr = Tools.getMsgById('cond');
			}
			return condStr;
		}
		
		/**
		 * 格式化Rslt内容 hasBrackets是否加括号，isAdd是否显示额外, hasValue取出数值，sortType属性排序：0乱序；1不换行；2按\n换行；3按br换行
		 */
		public static function translateRsltInfo(condStr:String, rslt:Object, hasBrackets:Boolean = true, isAdd:Boolean = false, hasValue:Boolean = true, sortType:int = 0):String
		{
			var rslt0Str:String;
			var rslt1Str:String;
			var num:int = 0;
			var str:String = '';
			var intervalStr:String;
			if (sortType == 2){
				intervalStr = '\n';
			}
			else if (sortType == 3){
				intervalStr = '<br/>';
			}
			else{
				intervalStr = Tools.getMsgById('rslt_connect1');
			}

			var sortArr:Array;
			if (sortType){
				sortArr = [];
			}
			var tempStr:String;
			var hasDmgArmySkill:Boolean = false;
			for (var key:String in rslt)
			{
				if (key.indexOf('power') >-1){
					continue;
				}
				else if (key=='lv'){
					continue;
				}
				num++;
				if (num == 2 && condStr.indexOf('{0}') != -1)
				{
					//仅忽略连续的兵种说明
					condStr = Tools.getMsgById('cond');
				}
				var keyArr:Array = key.split('.');
				if (keyArr.length > 1)
				{
					//有前后军定语
					if (keyArr[1] == 'dmgSkill'){
						//如果是兵种技能，使用特殊说明
						if (hasDmgArmySkill)
							continue;
						else{
							hasDmgArmySkill = true;
							rslt0Str = '';
							rslt1Str = Tools.getMsgById('rslt_dmgSkillArmy');
						}
					}
					else{
						rslt0Str = Tools.getMsgById('rslt_' + keyArr[0]);
						rslt1Str = Tools.getMsgById('rslt_' + keyArr[1]);
					}
				}
				else
				{	
					rslt1Str = Tools.getMsgById('rslt_' + keyArr[0]);
					if (ConfigFight.propertyArmyArr.indexOf(keyArr[0]) != -1)
					{
						rslt0Str = Tools.getMsgById('rslt_armys');
					}
					else
					{
						rslt0Str = '';
					}
					
					if (isAdd){
						var addIndex:int = rslt1Str.indexOf('{');
						rslt1Str = rslt1Str.slice(0, addIndex) + Tools.getMsgById('rslt_add') + rslt1Str.slice(addIndex);
					}
				}
				//取得值
				if(hasValue){
					rslt1Str = PassiveStrUtils.getMsgFormat(rslt1Str, rslt[key], hasBrackets);
				}
					


				tempStr = Tools.replaceMsg(condStr, [rslt0Str, rslt1Str]);
				if (tempStr != '')
				{
					if (sortType){
						sortArr.push({info:tempStr, index:ConfigFight.passiveSortArr.indexOf(key)})	
					}
					else{
						if (str != '' && str.lastIndexOf(intervalStr) != str.length-1)
						{
							str += intervalStr + tempStr;
						}else{
							str += tempStr;
						}
					}
				}
			}
			if (sortType){
				sortArr.sort(MathUtil.sortByKey('index'));
				for (var i:int = 0, len:int = sortArr.length; i < len; i++) 
				{
					str += sortArr[i].info;
					if (i < len - 1){
						str += intervalStr; 
					}
				}
			}
			else{
				if (num == 0){
					str = Tools.replaceMsg(condStr,['','']);
				}
			}
			return str;
		}
	
		
		/**
		 * 格式化回合内容
		 */
		public static function translateRoundInfo(roundObj:Object):String
		{
			if (!roundObj || !roundObj.round)
			{
				return Tools.getMsgById('round_info_null');
			}
			roundObj = roundObj.round;
			
			if (roundObj.hasOwnProperty('any'))
			{
				return Tools.getMsgById('round_info_any');
			}
			if (roundObj.hasOwnProperty('all'))
			{
				return Tools.getMsgById('round_info_all');
			}
			if (roundObj.hasOwnProperty('far'))
			{
				return Tools.getMsgById('round_info_far');
			}
			if (roundObj.hasOwnProperty('near'))
			{
				return Tools.getMsgById('round_info_near');
			}
			if (roundObj.hasOwnProperty('0'))
			{
				return Tools.getMsgById('round_info_0');
			}
			if (roundObj.hasOwnProperty('1'))
			{
				return Tools.getMsgById('round_info_1');
			}
			if (roundObj.hasOwnProperty('2'))
			{
				return Tools.getMsgById('round_info_2');
			}
			if (roundObj.hasOwnProperty('3'))
			{
				return Tools.getMsgById('round_info_3');
			}
			if (roundObj.hasOwnProperty('4'))
			{
				return Tools.getMsgById('round_info_4');
			}
			return Tools.getMsgById('round_info_other');
		}
		
		/**
		 * 得到简单计算公式的结果值，支持加减乘除
		 */
		public static function getFunValue(srcObj:Object, funStr:String, hasEnd:Boolean = false):Number
		{
			for (var i:int = 0; i < 4; i++)
			{
				var ope:String = operatorArr[i];
				if (funStr.indexOf(ope) >= 0)
				{
					var arr:Array = funStr.split(ope);
					for (var j:int = 0; j < 2; j++)
					{
						var str:String = arr[j];
						arr[j] = NUMBER_REGEXP.test(str) ? parseFloat(str) : FightUtils.getValueByPath(srcObj, str, hasEnd);
					}
					return PassiveStrUtils.calculation(arr[0], arr[1], i);
				}
			}
			return PassiveStrUtils.NUMBER_REGEXP.test(funStr) ? parseFloat(funStr) : FightUtils.getValueByPath(srcObj, funStr, hasEnd);
		}
		
		/**
		 * 计算加减乘除
		 */
		public static function calculation(value0:Number, value1:Number, operator:int):Number
		{
			if (operator == 0)
				return value0 + value1;
			else if (operator == 1)
				return value0 - value1;
			else if (operator == 2)
				return value0 * value1;
			else
				return value0 / value1;
		}
		
		/**
		 * 特殊格式化文本，替换{type} -整数 +有符号整数 %百分率 *有符号百分率 /负向百分率
		 */
		public static function getMsgFormat(str:String, replaceValue:Number, hasBrackets:Boolean = true):String
		{
			var matchArr:Array = PassiveStrUtils.REPLACE_REGEXP.exec(str);
			if (matchArr != null)
			{
				//匹配了替换
				var replaceStr:String = matchArr[0];
				var type:String = replaceStr.substr(1, 1);
				var valueInfo:String = PassiveStrUtils.translateValueInfo(type, replaceValue, hasBrackets);
				return str.replace(replaceStr, valueInfo);
			}
			return str;
		}
		
		/**
		 * 特殊格式化文本，替换{type} -整数 +有符号整数 %百分率 *有符号百分率 /负向百分率  返回值[剔除值的文本，值，0整形1百分数]
		 */
		public static function getAttFormat(str:String, replaceValue:Number):Array
		{
			var attName:String = str;
			var attValue:Number = replaceValue;
			var attType:int = 0;	//0显示整数 1显示百分数
			var matchArr:Array = PassiveStrUtils.REPLACE_REGEXP.exec(str);
			if (matchArr != null)
			{
				//匹配了替换
				var replaceStr:String = matchArr[0];
				var type:String = replaceStr.substr(1, 1);
				if (type == '%' || type == '*'){
					attType = 1;
					attValue = replaceValue / ConfigFight.ratePoint;
				}
				else if (type == '/'){
					attType = 1;
					attValue = -replaceValue / ConfigFight.ratePoint;
				}
				attName = str.replace(replaceStr, '');
			}
			return [attName,attValue,attType];
		}
		
	}

}