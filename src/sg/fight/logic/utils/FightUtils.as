package sg.fight.logic.utils {
    import laya.maths.MathUtil;
    import sg.cfg.ConfigServer;
    import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.test.TestFightData;
    
    /**
     * 战斗相关的工具类
     * @author zhuda
     */
    public class FightUtils {
        /**
         * 深度克隆对象
         */
        public static function clone(srcObj:*):* {
            var reObj:*;
            if (srcObj is Number || srcObj is String || srcObj is Boolean || srcObj == null || typeof(srcObj) == "undefined") {
                return srcObj;
            }
            else if (srcObj is Array) {
                reObj = [];
            }
            else {
                reObj = {};
            }
            for (var key:* in srcObj) {
                reObj[key] = FightUtils.clone(srcObj[key]);
            }
            return reObj;
        }
		/**
         * 深度克隆对象，只使用某些根目录key
         */
        public static function cloneOnly(srcObj:*, only:Object):* {
            var reObj:* = {};
            for (var key:* in srcObj) {
				if(only.hasOwnProperty(key))
					reObj[key] = FightUtils.clone(srcObj[key]);
            }
            return reObj;
        }
		/**
         * 深度克隆对象，但忽略跳过某些根目录key
         */
        public static function cloneIgnore(srcObj:*, ignore:Object):* {
			var reObj:* = {};
            for (var key:* in srcObj) {
				if(!ignore.hasOwnProperty(key))
					reObj[key] = FightUtils.clone(srcObj[key]);
            }
            return reObj;
        }
        /**
         * 按比例混合数值型对象
         */
        public static function mix(obj1:*, obj2:*, rate:Number = 0.5, isClone:Boolean = false):* {
			var temp:Number = 1 - rate;
            if (obj1 is Number && obj2 is Number) {
                return obj1*temp+obj2*rate;
            }
            else if (obj1 is Array && obj2 is Array) {
				if (isClone)
					obj1 = FightUtils.clone(obj1);
				var arr1:Array = obj1;
				var arr2:Array = obj2;
				var len:int = Math.min(arr1.length, arr2.length);
                for (var i:int = 0; i < len; i++) 
				{
					arr1[i] = FightUtils.mix(arr1[i], arr2[i], rate, false);
				}
            }
            else if (obj1 is Object && obj2 is Object){
				if (isClone)
					obj1 = FightUtils.clone(obj1);
				for (var key:* in obj1) {
					obj1[key] = FightUtils.mix(obj1[key], obj2[key], rate, false);
				}
            }

            return obj1;
        }
        
		/**
         * 判断空或无内容对象
         */
        public static function isNullObj(obj:Object):Boolean {
            for (var key:* in obj) {
                return false;
            }
            return true;
        }
        /**
         * 得到对象内的key数量
         */
        public static function getObjectLength(obj:*):int {
            var num:int = 0;
            for (var key:* in obj) {
                num++;
            }
            return num;
        }
		/**
         * 将对象转为数组。packArray是否再次包装数组
         */
        public static function objectToArray(obj:*, packArray:Boolean):Array {
            var arr:Array = [];
            for (var key:* in obj) {
				if (packArray){
					arr.push([key,obj[key]]);
				}
				else{
					arr.push(key,obj[key]);
				}
            }
            return arr;
        }
		/**
         * 将对象转为数组。会将对象的key包装到数组对象中，不克隆原对象
         */
        public static function objectToArrayAddKey(obj:*, keyName:String = 'id'):Array {
            var arr:Array = [];
            for (var key:* in obj) {
				var one:Object = obj[key];
				if (one){
					one[keyName] = key
					arr.push(one);
				}
            }
            return arr;
        }
		
		/**
         * 将数组内key按照指定数组顺序排列，找不到的排在最前
         */
        public static function sortArray(arr:Array, key:String, indexArr:Array):Array {
			arr.sort(function(a:*, b:*):Number {
				var aIndex:int = indexArr.indexOf(a[key]);
				var bIndex:int = indexArr.indexOf(b[key]);
				return bIndex > aIndex ? -1 : 1;
			})
            return arr;
        }
		
        
        /**
         * 填充默认值，如果有值则不会用默认值覆盖
         */
        public static function fillDefault(data:*, key:String, value:*):void {
            if (!data.hasOwnProperty(key)) data[key] = value;
        }
        
        /**
         * 对比后，删除默认值
         */
        public static function deleteDefault(data:*, key:String, value:*):void {
            if (data[key] == value) delete data[key];
        }
        
        /**
         * 用指定操作符，比较两个值，满足条件则返回true
         */
        public static function compareValue(value0:Number, value1:Number, key:String):Boolean {
            if (key == '>') {
                if (value0 > value1) {
                    return true;
                }
            }
            else if (key == '>=') {
                if (value0 >= value1) {
                    return true;
                }
            }
            else if (key == '=') {
                if (value0 == value1) {
                    return true;
                }
            }
            else if (key == '<=') {
                if (value0 <= value1) {
                    return true;
                }
            }
            else if (key == '<') {
                if (value0 < value1) {
                    return true;
                }
            }
			else if (key == '!=') {
                if (value0 != value1) {
                    return true;
                }
            }
            else {
                return true;
            }
            return false;
        }
		
		/**
         * 静态，返回归档后转化数组。value一级属性值，arr归档前转化数组。返回值：所归档的数组，[0]原点，[1...]归档内容。
         */
        public static function getRankArr(value:Number, arr:Array):Array {
            var i:int;
            var len:int;
            var rankArr:Array;
            for (i = 0, len = arr.length; i < len; i++) {
                rankArr = arr[i];
                if (value >= rankArr[0]) {
                    return rankArr;
                }
            }
            //全部映射不到，取最后档斜率偏移
            return rankArr;
        }
		/**
		 * 静态，指定未归档数组和等级，返回指定参数的数值
		 */
		public static function getRankValue(lv:Number, arr:Array, key:String = null):*
		{
			var rankArr:Array = FightUtils.getRankArr(lv, arr);
			var temp:* = rankArr[1];
			if (temp is Array){
				temp = temp[0];
			}
			var valueArr:Array;
			if (key){
				valueArr = temp[key];
			}
			else{
				for (key in temp){
					valueArr = temp[key];
					break;
				}
			}
			if (valueArr){
				return valueArr[0] + valueArr[1] * (lv - rankArr[0]);
			}
			else{
				return 0;
			}
		}
		/**
		 * 静态，指定未归档数组和等级，返回合并完成后的对象
		 */
		public static function getRankObj(lv:Number, arr:Array):Object
		{
			var rankArr:Array = FightUtils.getRankArr(lv, arr);
			var temp:* = rankArr[1];
			if (temp is Array){
				temp = temp[0];
			}
			var obj:Object = {};
			var valueArr:Array;
			for (var key:String in temp){
				valueArr = temp[key];
				obj[key] = valueArr[0] + valueArr[1] * (lv - rankArr[0]);
			}
			return obj;
		}
		
        
        /**
         * 转化千分点为比率(以1为基础 小数。是否保障最小值)
         */
        public static function pointToRate(value:Number, limitMin:Boolean = false):Number {
			value += ConfigFight.ratePoint;
			if (limitMin){
				value = Math.max(ConfigFight.minPoint, value);
			}
            return value / ConfigFight.ratePoint;
        }
        
        /**
         * 转化千分点为的几率(以0为基础 0~1小数)
         */
        public static function pointToPer(value:Number):Number {
            return value / ConfigFight.ratePoint;
        }
        
        /**
         * 转化几率为千分点(以0为基础 0~1小数)
         */
        public static function perToPoint(value:Number):int {
            return Math.ceil(value * ConfigFight.ratePoint);
        }
        
        ///正则匹配路径
        private static const PATH_REGEXP:RegExp = new RegExp('^(\\w+)\\[(\\d+)\\]$');
        
        /**
         * 按path字符串，得到srcObj中的子对象，返回值[对象引用，key]
         */
        public static function getObjByPath(srcObj:*, path:String, hasEnd:Boolean = false):Array {
            var matchArr:Array;
			var endStr:String;
			if (hasEnd){
				var endIndex:int = path.indexOf('$');
				if (endIndex >-1){
					endStr = path.substr(endIndex+1);
					path = path.substr(0, endIndex-1);
				}
			}
            var msgArr:Array = path.split('.');
			if (endStr){
				msgArr.push(endStr);
			}
            
            var curr:* = srcObj;
            var currKey:String;
            var currArr:Array;
            var currIndex:int;
            
            var i:int;
            var len:int;
            for (i = 0, len = msgArr.length; i < len; i++) {
				if (!curr)
					return null;
                currKey = msgArr[i].toString();
				if (i == len - 1 && endStr) {
					//最后一个
					return [curr, currKey];
				}
				
                matchArr = FightUtils.PATH_REGEXP.exec(currKey);
                if (matchArr != null) {
                    //匹配了数组
                    curr = curr[matchArr[1].toString()];
					if (!curr)
						return null;
                    currArr = curr as Array;
                    currIndex = matchArr[2];
                    
                    if (i == len - 1) {
                        return [currArr, currIndex];
                    }
                    else {
                        curr = currArr[currIndex];
                    }
                }
                else {
                    if (i == len - 1) {
                        return [curr, currKey];
                    }
                    else if (curr.hasOwnProperty(currKey)) {
                        curr = curr[currKey];
                    }
                    else {
                        //丢失匹配
                        return null;
                    }
                }
            }
            return null;
        }
        
        /**
         * 解析path字符串，叠加方式修改对应data值
         */
        public static function addObjByPath(srcObj:*, path:String, value:Number, hasEnd:Boolean = false):void {
            var arr:Array = FightUtils.getObjByPath(srcObj, path, hasEnd);
			if (arr){
				if (!(arr[0][arr[1]] is Number)) {
                    arr[0][arr[1]] = 0;
                }
				arr[0][arr[1]] += value;
			}
        }
		/**
         * 解析path字符串，覆盖方式修改对应data值
         */
        public static function fixedObjByPath(srcObj:*, path:String, value:Number, hasEnd:Boolean = false):void {
            var arr:Array = FightUtils.getObjByPath(srcObj, path, hasEnd);
			if(arr){
				arr[0][arr[1]] = value;
			}
        }
        
        /**
         * 解析path字符串并修改数据，根据value不同，可自动添加字段、叠加、删除或替换该字段
         */
        public static function changeObjByPath(srcObj:*, path:String, value:*, hasEnd:Boolean = false):void {
            var arr:Array = FightUtils.getObjByPath(srcObj, path, hasEnd);
            if (arr != null) {
                if (value is Number) {
                    if (!(arr[0][arr[1]] is Number)) {
                        arr[0][arr[1]] = 0;
                    }
                    arr[0][arr[1]] += value;
                }
                else if (value is String) {
					var str:String = value;
					if(str == 'del') {
						delete arr[0][arr[1]];
					}
					else if (str.charAt(0) == '$') {
						value = parseFloat(str.substring(1));
						arr[0][arr[1]] = value;
					}
					else{
						arr[0][arr[1]] = value;
					}
                }
                else {
					//复杂对象，替换为克隆版，以免再次被修改影响源数据
                    arr[0][arr[1]] = FightUtils.clone(value);
                }
                    //TestPrint.instance.print("源数据：\n" + FightUtils.toString(srcObj) + "\n已找到path：" + path);
                    //FightUtils.print("源数据：\n"+FightUtils.toString(srcObj)+"\n已找到path："+path);
            }
            else {
                FightPrint.checkPrint('FightSpecial', "change源数据：\n未能找到path：" + path, srcObj);
                    //FightUtils.print("change源数据：\n" + FightUtils.toString(srcObj) + "\n未能找到path：" + path);
            }
        }
        
        /**
         * 解析path字符串并设置该字段数据
         */
        public static function setObjByPath(srcObj:*, path:String, value:*):void {
            var arr:Array = FightUtils.getObjByPath(srcObj, path);
            if (arr != null) {
                arr[0][arr[1]] = value;
            }
            else {
                FightPrint.checkPrint('FightSpecial', "set源数据：\n未能找到path：" + path, srcObj);
                    //FightUtils.print("set源数据：\n" + FightUtils.toString(srcObj) + "\n未能找到path：" + path);
            }
        }
        
        /**
         * 按path字符串，得到srcObj中的子对象，返回值
         */
        public static function getValueByPath(srcObj:*, path:String, hasEnd:Boolean = false):* {
            var arr:Array = FightUtils.getObjByPath(srcObj, path, hasEnd);
            if (arr && arr[0]) {
                return (arr[0])[arr[1]];
            }
            return null;
        }
        
        /**
         * 按priority排序数组，较大的在前
         */
        public static function sortPriority(arr:Array):void {
            arr.sort(MathUtil.sortByKey('priority', true, true));
        }
		
		
		/**
         * 检查数组中对象里相同的值，返回重复对象
         */
        public static function checkSameValue(arr:Array, key:String):Object {
			var sameObj:Object = {};
			var len:int = arr.length;
			var value:*;
			var valueArr:Array;
			
			for (var i:int = 0; i < len; i++) 
			{
				var obj:Object = arr[i];
				value = obj[key];
				
				if (!sameObj[value]){
					sameObj[value] = [];
				}
				valueArr = sameObj[value];
				valueArr.push(obj);
			}
			
			var isSame:Boolean = false;
			for (value in sameObj){
				valueArr = sameObj[value];
				if (valueArr.length < 2){
					delete sameObj[value];
				}
				else {
					isSame = true;
				}
			}
			if (isSame){
				return sameObj;
			}
			return null;
        }
        
        /**
         * 按obj1的key对比obj2，如果不存在key或值不同，忽略对方没有的key（仅打印，不返回不同）则返回false并打印区别
         */
        public static function compareObj(obj1:*, obj2:*, path:String = '', ignoreKeys:Object = null):Boolean {
            var b:Boolean = true;
			if (typeof(obj1) == "undefined" || typeof(obj2) == "undefined") {
				if (obj1 != obj2) {
                    trace(path + " 忽略值不同: ", obj1, '/', obj2);
                }		
			}
			else if (obj1 is Number || obj1 is Boolean) {
                if (obj1 != obj2) {
                    trace(path + " 值不同: ", obj1, '/', obj2);
                    b = false;
                }
            }
			else if (obj1 is String) {
                if (obj1 != obj2) {
					if (obj1 == '' || obj2 == ''){
						trace(path + " 忽略值不同: ", obj1, '/', obj2);
					}
					else{
						trace(path + " 值不同: ", obj1, '/', obj2);
						b = false;
					}
                }
            }
            else if (obj1 is Array) {
                if (!(obj2 is Array)) {
                    trace(path + " 不是数组！");
                    return false;
                }
				var arr1:Array = obj1 as Array;
                var arr2:Array = obj2 as Array;
                var i:int;
                var len:int = arr1.length;
                if (arr2.length < len) {
                    trace(path + " 数组长度不足 " + len);
					b = false;
                    //return false;
                }
                for (i = 0; i < len; i++) {
                    b = compareObj(arr1[i], arr2[i], path + '[' + i + ']', ignoreKeys) && b;
                }
            }
            else {
                for (var key:String in obj1) {
					if (ignoreKeys && ignoreKeys[key]){
						continue;
					}
                    b = compareObj(obj1[key], obj2[key], path + '.' + key, ignoreKeys) && b;
                }
            }
            return b;
        }
	
		
		 /**
         * 将obj2的所有值，混合到obj1中，默认自动克隆复杂对象，不会带上obj2中的引用
         */
        public static function mergeObj(obj1:*, obj2:*, canNew:Boolean = true):void {
			//trace(obj1, obj2);
			for (var key:String in obj2){
				var value2:* = obj2[key];
				if (!obj1.hasOwnProperty(key)){
					if(canNew)
						obj1[key] = FightUtils.clone(value2);
				}else{
					if (value2 is Number) {
						obj1[key] += value2;
					}else if (value2 is String) {
						obj1[key] = value2;
					}else{
						FightUtils.mergeObj(obj1[key], obj2[key],canNew);
					}
				}
			}
        }
        
        /**
         * 将字符串、数组或对象的所有key或value，转为数组格式
         */
        public static function toArray(data:*, type:int = 0):Array {
            if (data is String) {
                return [data];
            }
            else if (data is Array) {
                return data;
            }
            else if (data is Object) {
                var arr:Array = [];
                for (var key:String in data) {
                    if (type == 0)
                        arr.push(key);
                    else if (type == 1)
                        arr.push([key,data[key]]);
                }
                return arr;
            }
            return [];
        }
		/**
         * 倍化对象内的数值，不做克隆
         */
        public static function multObject(data:*, mult:int):Object {
			if (data is Number) {
                data *= mult;
            }
            else if (data is Array) {
				var arr:Array = data;
				var len:int = arr.length;
				for (var i:int = 0; i < len; i++) 
				{
					arr[i] = multObject(arr[i], mult);
				}
            }
            else if (data is Object) {
				for (var key:String in data) {
					data[key] = multObject(data[key], mult);
				}
			}
            return data;
        }
		/**
         * 倍化passive对象内的数值，不做克隆，排除cond
         */
        public static function multPassive(data:*, mult:int):Object {
			if (data is Number) {
                data *= mult;
            }
            else if (data is Array) {
				var arr:Array = data;
				var len:int = arr.length;
				for (var i:int = 0; i < len; i++) 
				{
					arr[i] = multPassive(arr[i], mult);
				}
            }
            else if (data is Object) {
				//排除cond
				var condArr:Array = data.cond;
				if (condArr){
					delete data.cond;
				}
				for (var key:String in data) {
					data[key] = multPassive(data[key], mult);
				}
				if (condArr){
					data.cond = condArr;
				}
			}
            return data;
        }
		
        
        /**
         * 通过分析战报数据，获得单挑战斗的战损比例
         */
        public static function getSoloRate(pk_result:Object):Number {
            var records:Array = pk_result.records;
            var troop0:Object = records[0].troop[0];
            var hpInit:int = troop0.hp + troop0.dead;
            return troop0.dead / hpInit;
        }
        
        /**
         * 进行模拟单挑战役，返回预计战损比例
         */
        public static function checkSoloRate(data:Object):Number {
            var reData:Object = FightInterface.doBattle(data);
            return getSoloRate(reData);
        }
		
		/**
         * 返回weak对应的passive
         */
        public static function formatWeakToPassive(weakOne:Array, isShow:Boolean):Object {
			if (!weakOne)
				return null;
				
           	//异邦来访，弱点伤害加成 [1]已弃用
			var rslt:Object = {};				
			var key:String = weakOne[0];
			var value:Number = weakOne[2];
			if (!isShow){
				value = Math.floor((1 / (1 + value) - 1) * ConfigFight.ratePoint);
			}
			else{
				value = -value * ConfigFight.ratePoint;
			}
			rslt[key] = value;
			return {'rslt':rslt};
        }
		
		/**
         * 得到指定等级生效up的克隆技能数据（可忽略部分key）
		 * cloneType 1skillOnly 2skillOnlyFight 3skillOnlyFightAct
         */
        public static function getSkillLvData(skillObj:Object, skillLv:int, cloneType:int):Object {
			if (!skillObj)
				return null;
			var upObj:Object = skillObj.up;
			if (cloneType < 3 && (!upObj || skillLv <= 1))
				return skillObj;
			var key:String;
			var lvPatchObj:Object = skillObj.lvPatch;
			
			var onlyObj:Object;
			if (cloneType == 1){
				onlyObj = ConfigFight.skillOnly;
			}
			else if (cloneType == 2){
				onlyObj = ConfigFight.skillOnlyFight;
			}
			else if (cloneType == 3){
				onlyObj = ConfigFight.skillOnlyFightAct;
			}
			else{
				onlyObj = null;
			}
			skillObj = cloneOnly(skillObj, onlyObj);
			for (key in upObj)
			{
				FightUtils.addObjByPath(skillObj, key, upObj[key] * (skillLv - 1));
			}
			
			if (lvPatchObj){
				var lvPatchData:Object = lvPatchObj[skillLv]; 
				if(lvPatchData){
					for (key in lvPatchData)
					{
						FightUtils.addObjByPath(skillObj, key, lvPatchData[key]);
					}
				}
			}
			return skillObj;
        }
		
        
        /**
         * 返回满足合击技生效的英雄hid，如果返回空则表示不能生效(优先使用副将)
         */
        public static function getFateHid(attends:Object, adjutants:Array, key:String, value:*, selfId:String):String {
            if (!attends)
                return null;
            var hid:String;
			var i:int;
            if (key == 'num') {
				var num:int = FightUtils.getObjectLength(attends) + adjutants.length;
                if (num > value) {
                    return '';
                }
            }
            else if (key == 'ids') {
                var arr:Array = value;
                for (i = arr.length - 1; i >= 0; i--) {
					hid = arr[i];
                    if (adjutants.indexOf(hid) > -1 || attends[hid]) {
                        return hid;
                    }
                }
            }
            else if (key == 'id') {
				hid = value;
                if (adjutants.indexOf(hid) > -1 || attends[hid])
                    return hid;
            }
            else {
                //查找同时上阵英雄中，是否有配置值=设定的
                var heroConig:Object;
				for (i = adjutants.length - 1; i >= 0; i--) {
					hid = adjutants[i];
					heroConig = ConfigServer.hero[hid];
                    if (heroConig[key] == value) {
                        return hid;
                    }
                }
				
                for (hid in attends) {
                    if (hid == selfId) {
                        continue;
                    }
                    heroConig = ConfigServer.hero[hid];
                    if (heroConig[key] == value) {
                        return hid;
                    }
                }
            }
            return null;
        }
		
		
		/**
         * 通过副将宝物总评分，计算出最终技能加成强度
         */
        public static function getAdjutantEquipDmgFinal(score:int):Number {
			return FightUtils.getRankValue(score, ConfigFight.adjutantEquipDmgFinal,'dmgFinal');
        }
    }

}