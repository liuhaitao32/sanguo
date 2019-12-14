package sg.manager
{
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;
	import sg.cfg.ConfigApp;
	import laya.utils.Browser;
	import sg.utils.Base64;

	/**
	 * ...
	 * @author lhw
	 */
	public class FilterManager{

		private static var inst:FilterManager;
		private var cityNameObj:Object={};//城市表
		private var banNameObj:Object={};//命名禁用
		private var banWordObj:Object={};//屏蔽词
		private var banCharObj:Object={};//屏蔽字
		public function FilterManager(){
			
		}


		public static function get instance():FilterManager{
			return inst ||= new FilterManager();
		}
		/**
		 * 屏蔽字处理
		 */
		public function wordBan(str:String):String{
			var s:String = "";
			try{
				s = exec(str,1);
				for(var i:int=0;i<s.length;i++){
					var c:String = s[i];
					if(banCharObj.hasOwnProperty(c)){
						s = s.replace(c,'*');
					}
				}
			}catch(e){

			}
			return s;
		}

		/**
		 * 城市名处理
		 */
		public function cityWrap(str:String):String{
			var s:String = exec(str,0);
			return s;
		}
		
		/**
		 * 起名屏蔽
		 */
		public function nameBan(str:String):String{
			var s:String = exec(str,2);
			return s;
		}


		
		private function exec(str:String,type:int=0):String{
			var index:int=checkIndex(0,str,type);			
			while(index!=-1){
				var arr:Array=getReplaceMsg(index,str,1,type);
				str=arr[0];
				if(arr[1]){
					break;
				}
				index+=1;
				index=checkIndex(index,str,type);
			}

			return str;
		}

		public function isLegalWord(str:String):Boolean{
			var s:String=wordBan(str);
			return s.indexOf('*')!=-1;
		}

		
		public function decode():void
		{
			cityNameObj={};
			var config_city:Object=ConfigServer.city;
			for(var s:String in config_city){
				var str:String=Tools.getMsgById(config_city[s].name);
				if(str=="")
					continue;

				var _char:String=str.charAt(0);
				var o:Object={};
				if(cityNameObj.hasOwnProperty(_char)){
					o=cityNameObj[_char];
					if(!o.hasOwnProperty(str)){
						o[str]="";
					}
				}else{
					o[str]="";
					cityNameObj[_char]=o;
				}
			}
			//trace("====================",cityNameObj);
		}
		public function decode2():void
		{	
			decodeName("lc_name");
			decodeWord("lc_0");
			if(ConfigApp.lan()=='cn'){
				if(ConfigApp.pf == ConfigApp.PF_360_3_h5){
					decodeWord("lc_iwy");
				}else if(ConfigApp.pf == ConfigApp.PF_360_2_h5){
					decodeWord("lc_4399");
				}else{
					decodeWord("lc_37");
				}
			}
		}	
		/**
		 * 
		 */
		private function decodeWord(id:String):void{
			var config:Object = getConfigObj(id);
			for(var str:String in config){
				if(str=="")
					continue;

				if(str.length==1){
					banCharObj[str]="";
					continue;
				}

				var _char:String=str.charAt(0);
				var o:Object={};
				if(banWordObj.hasOwnProperty(_char)){
					o=banWordObj[_char];
					if(!o.hasOwnProperty(str)){
						o[str]="";
					}
				}else{
					o[str]="";
					banWordObj[_char]=o;
				}
			}
		}
		private function decodeName(id:String):void{
			var config:Object = getConfigObj(id);
			for(var str:String in config){
				if(str=="")
					continue;

				var temp:Object = {};
				temp[str] = "";
				if(str.length==1){
					banNameObj[str]=temp;
					continue;
				}

				var _char:String=str.charAt(0);
				var o:Object={};
				if(banNameObj.hasOwnProperty(_char)){
					o=banNameObj[_char];
					if(!o.hasOwnProperty(str)){
						o[str]="";
					}
				}else{
					banNameObj[_char]=temp;
				}
			}
		}		


		private function getConfigObj(id:String):Object{
			var o:Object = {};
			var txt_bug:String = Laya.loader.getRes("ad/"+id+".txt");

			try { // 处理文件获取不到或解析错误的问题
				if(txt_bug){
					txt_bug = txt_bug.substring(3);
					txt_bug = Base64.decode(txt_bug);
					o = JSON.parse(txt_bug);
				}
			} catch (e) {
				console.warn(id);
				console.log(e);
				o = {};
			}
			return o;
		}

		/**
		 * type 0城市   1屏蔽字
		 */
		private function getReplaceMsg(index:int,value:String,len:int=1,type:int=0):Array{
			
			var vlen1:int = value.indexOf("<span"); 
			var vlen2:int = value.indexOf("</span>");
			if(vlen1!=-1 && vlen2!=-1 && index>=vlen1){
				if(index<vlen2){
					return getReplaceMsg(vlen2+("</span>".length),value,1,type);
				}
			}

			var s:String=value.substring(index);
			var f:String=s.charAt(0);
			var str:String=f;
			
			for(var i:int=1;i<len+1;i++){
				str+=s.charAt(i);
			}
			
			var obj:Object={};
			var maxLen:Number = 0;
			if(type==0){
				obj=cityNameObj;
			}else if(type==1){
				obj=banWordObj;
			}else if(type==2){
				obj=banNameObj;
			}
			
			var str2:String=str+s.charAt(str.length);

			var o:Object={};
			if(obj.hasOwnProperty(f)){
				o=obj[f];
				for(var objs:String in o){
					if(objs.length > maxLen){
						maxLen = objs.length;
					} 
				}
				if(o.hasOwnProperty(str)){
					var s1:String=value.substring(0,index);
					var s2:String=value.substring(index+str.length);

					if(str==str2 || !o.hasOwnProperty(str2)){
						if(type==0){
							var cid:String=Tools.getCityIDByName(str);
							return [s1+"<span href='"+cid+"'>"+str+"</span>"+s2,true];
						}else if(type==1){
							//return ["*"["repeat"](str.length),true];
							return [s1+str.replace(/./g, '*')+s2,false];
						}
					}	
				}
			}
			if(maxLen!=0 && len >= maxLen){
				return [value,false];
			}
			if(len>=value.length-index-1){
				return [value,false];
			}
			len++;
			return getReplaceMsg(index,value,len,type);
		}

		private function checkIndex(index:int,msg:String,type:int=0):Number{
			var n:int=-1;
			if(index>msg.length){
				return n;
			}
			msg=msg.substring(index);
			var obj:Object={};
			if(type==0){
				obj=cityNameObj;
			}else if(type==1){
				obj=banWordObj;
			}else if(type==2){
				obj=banNameObj;
			}			
			for(var i:int = 0; i < msg.length; i++)
			{
				if(obj.hasOwnProperty(msg.charAt(i))){
					n=index+i;
					break;
				}
				
			}
			return n;
		}
		

	}

}