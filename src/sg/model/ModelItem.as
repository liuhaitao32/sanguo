package sg.model
{
	/**
	 * ...
	 * @author
	 */

	import sg.cfg.ConfigColor;
	import sg.cfg.ConfigServer;
	import sg.model.*;
	import sg.manager.ModelManager;
	import laya.maths.MathUtil;
	import sg.map.utils.TestUtils;
	import ui.inside.pubItemUI;
	import sg.utils.Tools;
	import sg.manager.AssetsManager;
	import sg.manager.ViewManager;

	public class ModelItem extends ModelBase{
		public static const material_type_ui:Object = {
			"merit":AssetsManager.IMG_MERIT,
			"gold":AssetsManager.IMG_GOLD,
			"food":AssetsManager.IMG_FOOD,
			"wood":AssetsManager.IMG_WOOD,
			"iron":AssetsManager.IMG_IRON,
			"coin":AssetsManager.IMG_COIN
		};
		public static const material_type_ui_bg:Object = {
			"merit":"img_icon_08_big.png",
			"gold":"img_icon_04_big.png",
			"food":"img_icon_05_big.png",
			"wood":"img_icon_06_big.png",
			"iron":"img_icon_07_big.png",
			"coin":"img_icon_09_big.png"
		};

		//private var userModel:ModelUser=ModelManager.instance.modelUser;
		public var id:String;
		public var name:String;
		private var _info:String;
		public var icon:String;
		public var type:Number;//道具类型：1：普通，2：技能碎片，3：军械碎片，4：宝物碎片，5：神器，6：星宿，7：英雄碎片
		public var source:Object;//道具获得途径
		public var ratity:int;//道具品质：1：白，2：绿，3：蓝，4：紫，5：金，6：红
		//var awardId:String;//打开该道具的箱子id 好像没啥用
		public var index:Number;
		private var _num:Number=0;
		public var addNum:Number=0;
		public var boxT:*=null;
		public var awardid:String;
		public var range:Array;
		public var isNew:int = 1;
		public var paixu:int=0;
		public var equip_info:Array;
		public function ModelItem(){

		}

		/**
		 * name id  info  type  icon  来源  品质  index   宝箱类型
		 */
		public function initData(n:String, _id:String,info:String,_type:Number,iconStr:String,source_obj:Object,qualityNum:int,_in:Number,_boxT:*):ModelItem{
			this.id = _id;
			this.name=Tools.getMsgById(n);
			this._info=info;
			this.type=_type;
			this.icon=iconStr;
			this.source=source_obj;
			this.ratity=qualityNum;
			this.index=_in;
			this.boxT=_boxT;
			var s:* = ConfigServer.property.hasOwnProperty(id) && ConfigServer.property[id].hasOwnProperty("equip_info") ? ConfigServer.property[id].equip_info:"";
			if(s is String){
				this.equip_info = (s == "") ? [] : [s];	
			}else{
				this.equip_info = s;
			}
			if(this.equip_info.length==0) this.equip_info = null;
			return this;
		}

		public function getModelSkill():ModelSkill{
			var numStr:String = this.id.substr(4);
			return ModelSkill.getModel('skill' + numStr);
		}
		public function get info():String{
			var ms:ModelSkill = this.getModelSkill();
			if (ms){
				var str:String = Tools.getMsgById('skill_type')+'：' + ms.getTypeStr() + '\n' + ms.getReplaceHtml('info',1, false);
				return str;
			}
			else{
				return Tools.getMsgById(this._info);
			}
		}
		public function getName(canTest:Boolean = false):String{
			var name:String = this.name;
			if (canTest && TestUtils.isTestShow){
				name += ' ' + this.id;
			}
            return name;
        }
		public function getColor():String{
			if(this.ratity>=6){
				return ConfigColor.FONT_COLORS[5];	
			}else{
				return ConfigColor.FONT_COLORS[this.ratity];
			}
		}
		
		public function initDataByCfg(key:String,obj:Object):void{
			this.id = key;
			for(var m:String in obj)
			{
				if(this.hasOwnProperty(m)){
					this[m] = obj[m];
				}
			}
		}
		public function get num():Number{ 
			_num = getMyItemNum(this.id);
			return _num;
		}
		public static function getBuildingUpdateItems(type:int = 0):Array{
			var arr:Array = [];
			var cfg:Object = ConfigServer.system_simple.item_cd[type] as Object;
			var myProp:Object = ModelManager.instance.modelUser.property;
			var server:Object = ConfigServer.property;
			var c:Number = 0;
			for(var key:String in cfg)
			{
				c = 0;
				if(myProp[key]){
					c = myProp[key];
				}
				arr.push({id:key,cd:cfg[key],num:c});
			}
			arr.sort(MathUtil.sortByKey("id",false,false));
			return arr;
		}
		public static function getMyItemNum(iid:String):Number{
			var nums:Number = 0;
			if(iid=="coin"|| iid=="gold" || iid=="food" || iid=="wood" || iid=="iron" || iid=="merit"){
				nums=ModelManager.instance.modelUser[iid];
			}
			if(ModelManager.instance.modelUser.property.hasOwnProperty(iid)){
				nums = ModelManager.instance.modelUser.property[iid];
			}

			return nums;
		}
		public static function getItemQuality(iid:String):int{
			var quality:int = 0;
			if(ConfigServer.property.hasOwnProperty(iid)){
				quality = ConfigServer.property[iid].quality;
			}
			return quality;
		}
		public static function getItemType(iid:String):int{
			var type:int = 0;
			if(ConfigServer.property.hasOwnProperty(iid)){
				type = ConfigServer.property[iid].type;
			}
			return type;
		}		
		public static function getItemIcon(iid:String,big:Boolean = true):String{
			var icon:String = getCostIcon(iid,big);
			if(Tools.isNullString(icon)){
				if(ConfigServer.property.hasOwnProperty(iid)){
					icon = ConfigServer.property[iid].icon;
				}
			}
			return icon;
		}
		public static function getIconUrl(id:String):String{
			if(id=="coin" || id == "gold" || id == "wood" || id == "food" || id == "iron" || id == "merit"){
				return AssetsManager.getAssetsUI(ModelItem.getItemIcon(id,true));
			}else{
				return AssetsManager.getAssetsICON(ModelItem.getItemIcon(id,true));
			}
		}

		public static function getItemIDByHero(hid:String):String{
			var str:String = hid.replace("hero","item");
			return str;
		}
		public static function getItemIconAssetUI(iid:String,big:Boolean = true):String{
			var icon:String = getCostIcon(iid,big);
			var str:String = getItemIcon(iid,big);
			return AssetsManager.getAssetsICON(str,!Tools.isNullString(icon))
		}
		public static function getCostIcon(name:String,big:Boolean = true):String{
			var ui:Object = big?material_type_ui_bg:material_type_ui;
			if(ui[name]){
				return ui[name];
			}
			else{
				return "";
			}
		}

		/**
		 * 获得所有资源名称
		 */
		public static function getItemName(iid:String):String{
			var str:String = "";
			if(ModelManager.instance.modelProp.allProp.hasOwnProperty(iid)){
				str = ModelManager.instance.modelProp.getItemProp(iid).name;
			}else if(iid.indexOf("star")!=-1){
				var sStr:String=iid.substr(0,6);
				var itemRune:ModelRune=new ModelRune();
				itemRune.initData(sStr,ConfigServer.star[sStr]);
				str=itemRune.getName();
			}else if(iid.indexOf("equip")!=-1){
				str = ModelEquip.getName(iid,0);
			}else if(iid.indexOf("title")!=-1){
				str=Tools.getMsgById(iid);
			}
			return str;
		}
		public static function checkCDitemStatus(iid:String,num:Number,lastTimer:Number,type:int = 0):Array{
			var status:Array = [0,0];
			var myNum:Number = getMyItemNum(iid);
			if(num>myNum){
				status[0] = -1;//没有那么多
				return status;
			}
			var everyCD:Number = getCDitemNum(iid,type);
			var m:Number = (lastTimer*0.001)/60;
			var all:Number = everyCD*num;
			var last:Number = (all-m);
			var canNum:Number = (num-Math.floor(last/everyCD));
			if(last>=everyCD){
				if(canNum>=myNum){
					status[1] = canNum;
				}
			}
			return status;
		}
		public static function getCDitemNum(iid:String,type:int = 0):Number{
			return (ConfigServer.system_simple.item_cd[type] as Object)[iid];
		}

		/**
		 * 是否可打开
		 */
		public function isCanOpen(openNum:int,tips:Boolean = true):Boolean{
			if(this.type==10){//兽灵箱子
				if(openNum + ModelBeast.getBagCurNum() > ModelBeast.getBagTotalNum()){
					tips && ViewManager.instance.showTipsTxt(Tools.getMsgById('_beast_tips10'));
					return false;
				}
			}
			return true;
		}

	}

}