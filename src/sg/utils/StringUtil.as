package sg.utils 
{
	import laya.html.dom.HTMLDivElement;

	/**
	 * StringUtil 实用程序类是一个全静态类，其方法用于处理 String 对象。不创建 StringUtil 的实例；只是调用如 StringUtil.substitute() 之类的方法。
	 * @author jiaxuyang
	 */
	public class StringUtil 
	{		
		/**
		 * 使用传入的各个参数替换指定的字符串内的“{n}”标记。
		 * label.text = StringUtil.substitute("拥有{0}个等级为{1}的英雄！", 3, 5);
		 * label.text = StringUtil.substitute("拥有{0}个等级为{1}的英雄！", [3, 5]);
		 * @param	str 要进行替换的原始字符串。
		 * @param	rest 可在 str 参数中的每个 {n} 位置被替换的其他参数，其中 n 是一个对指定值数组的整数索引值（从 0 开始）。
		 * @return
		 */
		public static function substitute(str:String, ... rest):String {
			var reg:RegExp = /{(\d+)}/g;
			if (rest[0] is Array)	rest = rest[0];
			return str.replace(reg, function(matchStr:String, index:String):String {
				return rest[index];
			});
		}
		
		/**
		 * 将字符串转换为HTML文本，并为"[文字]"标记的文字添加参数给定的颜色
		 * var html:String = StringUtil.substituteWithColor("[宝物]品质提升至[绿色]", "#E7B818"); 
		 * "<Font color='#FFFFFF'></Font><Font color='#E7B818'>宝物</Font><Font color='#FFFFFF'>品质提升至</Font><Font color='#E7B818'>绿色</Font>"
		 * @param	str 要设置颜色的原始字符串。
		 * @param	color 指定的颜色值。 eg："#E7B818"
		 * @param	defaultColor 默认的颜色值。 eg："#FFFFFF"
		 * @return
		 */
		public static function substituteWithColor(str:String, color:String = '#FFFFFF', defaultColor:String = '#FFFFFF'):String {
			var prefix:String = "<Font color='" + defaultColor + "'>";
			var suffix:String = "</Font>";
			var special:String = "<Font color='" + color + "'>";
			var reg:RegExp = /\[(\S+?)\]/g;
			str = str.replace(reg, function(searchValue, word):String {
				return suffix + special + word + suffix + prefix;
			});	
			return prefix + str + suffix;
		}
		/**
		 * 将\n为换行符的文本，转化为HTML文本，并分段添加颜色
		 * @param	str 要设置颜色的原始字符串。
		 * @param	color 指定的颜色值。 eg："#E7B818"
		 * @param	defaultColor 默认的颜色值。 eg："#FFFFFF"
		 * @return
		 */
		public static function substituteWithLineAndColor(str:String, color:String = '#FFFFFF', defaultColor:String = '#FFFFFF'):String {
			var arr:Array = str.split('\n');
			var len:int = arr.length;
			str = '';
			for (var i:int = 0; i < len; i++) 
			{
				str += StringUtil.substituteWithColor(arr[i], color, defaultColor);
				if (i < len - 1){
					str += '<br/>';
				}
			}
			return str;
		}
		/**
		 * 设置HTML文本，并为"[文字]"标记的文字添加参数给定的颜色
		 * var html:String = StringUtil.substituteWithColor(html, "[宝物]品质提升至[绿色]", ["#E7B818"]);
		 * @param	html 需要设置颜色的html文本。
		 * @param	str  需要设置颜色的原始字符串。
		 * @param	color 指定的颜色值数组。 eg：["#E7B818"]
		 * @param	defaultColor 默认的颜色值。 eg："#FFFFFF"
		 */
		public static function setHtmlText(html:HTMLDivElement, str:String, colors:Array, defaultColor:String='#FFFFFF'):void {			
			var reg:RegExp = /\[(\S+?)\]/g;
			html.style.color = defaultColor;
			var color:String = "FFFFFF";
			var suffix:String = "</Font>";
			str = str.replace(reg, function(searchValue, word):String {
				colors.length && (color = colors.shift());
				return "<Font color='" + color + "'>" + word + suffix;
			});
			html.innerHTML = str;
		}

		/**
		 * 将字符串转换为HTML文本，并为文字添加参数给定的颜色
		 * @param	str 要设置颜色的原始字符串。
		 * @param	color 指定的颜色值。 eg："#E7B818"
		 * @return
		 */
		public static function htmlFontColor(str:String, color:String = '#FFFFFF'):String{
			return StringUtil.substituteWithColor(str, '#FFFFFF', color);
		}

		
		/**
		 * 数字转化为百分数形式的字符串
		 * eg: StringUtil.numberToPercent(0.33333, 2) => '33.33%'
		 * @param	num	需要转化为百分数的原始数字
		 * @param	decimal	保留的小数位数.
		 * @param	abandonZero	是否舍弃小数位末尾的0. eg:StringUtil.numberToPercent(0.20000, 2, true) => "20%"
		 * @param	round	保留小数位数的时候是否四舍五入.
		 */
		public static function numberToPercent(num:Number, decimal:int = 0, abandonZero:Boolean = false, round:Boolean = false):String {
			var percentNum:String = '';
			if (round) {
				percentNum += Number(num * 100).toFixed(decimal);
			}
			else {
				percentNum += ((num * Math.pow(10, 2 + decimal)) >> 0) / Math.pow(10, decimal);
			}
			return (abandonZero ? Number(percentNum) : percentNum) + '%';
		}
		
		/**
		 * 阿拉伯数字转为中文
		 * @param	num 数字
		 * @param	upper 是否转为大写中文
		 * @return
		 */
		public static function numberToChinese(num:Number, upper:Boolean = false):String {
			return num+"";
			
			var reg:RegExp = /^\d*(\.\d*)?/;
			var AA:Array = upper ? ["零", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖"] : ['〇', '一', '二', '三', '四', '五', '六', '七', '八', '九']; 
			var BB:Array = upper ? ["", "拾", "佰", "仟", "萬", "億", "点", ""] : ['', '十', '百', '千', '万', '亿', '点', ''];
			var i:int = 0;
			 
			if (!reg.test(String(num))) {
				return 'Wrong number!';
			}
			var numArr:Array = (num + '').replace(/(^0*)/g, "").split('.'),
				k:int = 0,
				result:String = '';
				
			for (i = numArr[0].length - 1; i >= 0; i--) 
			{
				switch (k) {
					case 0:
						result = BB[7] + result;
						break;
					case 4:
						if (!new RegExp("0{4}\\d{" + (numArr[0].length - i - 1) + "}$").test(numArr[0])) 
						result = BB[4] + result; 
						break;
					case 8: 
						result = BB[5] + result; 
						BB[7] = BB[5]; 
						k = 0; 
						break; 
				}
				(k % 4 == 2 && numArr[0].charAt(i + 2) != 0 && numArr[0].charAt(i + 1) == 0) && (result = AA[0] + result);
				(numArr[0].charAt(i) != 0) && (result = AA[numArr[0].charAt(i)] + BB[k % 4] + result);
				k++;
			}
			if (numArr.length > 1) //加上小数部分(如果有小数部分) 
			{
				result += BB[6]; 
				for (i = 0; i < numArr[1].length; i++) result += AA[numArr[1].charAt(i)];				
			}
			
			//修正
			(result[0] === '一') && (result[1] === '十') && (result = result.substr(1));
			(result[0] === '壹') && (result[1] === '拾') && (result = result.substr(1));
			return result; 
		}
		
		/**
		 * 
		 * 小数转百分数  大于1的整数直接返回 
		 * @param	num
		 * @return
		 */
		public static function numToPercentStr(num:Number):String{
			if(num<1){
				return Math.round(num*100)+"%";
			}else{
				return num+"";
			}
		}
		/**
		 * 数字转整第几位
		 * @param	需要处理的数字
		 * @param	除于多少
		 */
		public static function numToWholeStr(num:Number,num1:Number):String{
			if(num<num1){
				return num1+"";
			}else{
				return (Math.floor(num/num1) * num1) +"";
			}
			return "";
		}
		
		/**
		 * 对指定字符串加入空格符，补足位数（已超出位数不处理）
		 * @param	需要处理的字符串
		 * @param	需要补足位数
		 * @param	是否在前方加入空格
		 * @param	空格符
		 */
		public static function fillSpace(str:String, num:int, isFront:Boolean = true, char:String = ' '):String{
			// var len:int = str.length;
			// var space:String = '';
			// for (var i:int = len; i < num; i++) 
			// {
			// 	space += char;
			// }
			// return isFront?space+str:str + space;
			return StringUtil.padding(str, num, char, !isFront);
		}
		
		/**
		 * 构造并返回一个新字符串，该字符串包含被连接在一起的指定数量的字符串的副本。
		 * @param	str 原始字符串
		 * @param	count	在新构造的字符串中重复了多少遍原字符串。
		 * @return	包含指定字符串的指定数量副本的新字符串。
		 */
		public static function repeat(str:String, count:int = 0):String {
			if (count >= 0) {
				return ArrayUtil.fill(new Array(Math.floor(count)), str).join('');
			}
			else {
				throw(new Error('repeat count must be positive and less than inifinity'));
			}
		}
		
		/**
		 * 用一个字符串填充当前字符串（如果需要的话则重复填充），返回填充后达到指定长度的字符串。
		 * @param	str 原始字符串
		 * @param	targetLength	当前字符串需要填充到的目标长度
		 * @param	padString	填充字符串。如果字符串太长，使填充后的字符串长度超过了目标长度，则只保留最左侧的部分，其他部分会被截断。此参数的缺省值为 " "
		 * @param	padEnd	是否向后填充。
		 * @return	填充指定的填充字符串直到目标长度所形成的新字符串。
		 */
		public static function padding(str:String, targetLength:int, padString:String, padEnd:Boolean = true):String {
			targetLength = targetLength>>0;
			padString = String((typeof padString !== 'undefined' ? padString: ' '));
			if (str.length > targetLength) {
				return String(str);
			}
			else {
				targetLength = targetLength - str.length;
				if (targetLength > padString.length) {
					padString += StringUtil.repeat(padString, targetLength / padString.length); //append to original to ensure we are longer than needed
				}
				padString = padString.slice(0,targetLength);
				return padEnd ? (String(str) + padString) : (padString + String(str));
			}
		}

		/**
		 * 返回一个两端都去掉空白的新字符串。
		 */
		public static function trim(str:String):String {
			return str.replace(/^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g, '');
		}

		/**
		 * 返回一个开头去掉空白的新字符串。
		 */
		public static function trimStart(str:String):String {
			return str.replace(/^[\s\uFEFF\xA0]+/g, '');
		}

		/**
		 * 返回一个末尾去掉空白的新字符串。
		 */
		public static function trimEnd(str:String):String {
			return str.replace(/[\s\uFEFF\xA0]+$/g, '');
		}
	}

}