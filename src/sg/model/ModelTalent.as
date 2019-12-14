package sg.model
{
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.utils.FightUtils;
	import sg.fight.logic.utils.PassiveStrUtils;
	import sg.map.utils.TestUtils;
	import sg.utils.Tools;
	import sg.manager.ModelManager;
	import sg.cfg.ConfigServer;
	import sg.manager.AssetsManager;
	
	/**
	 * 英雄天赋
	 * @author zhuda
	 */
	public class ModelTalent extends ModelBase
	{
		public var id:String;
		
		public function ModelTalent():void
		{
		
		}
		public static var talentModels:Object = {};
		
		public static function getModel(key:String):ModelTalent
		{
			var model:ModelTalent = ModelTalent.talentModels[key];
			if (!model)
			{
				var cfg:Object = ModelTalent.getConfig(key);
				if (cfg)
				{
					model = new ModelTalent();
					model.initData(key, cfg);
					ModelTalent.talentModels[key] = model;
				}
			}
			return model;
		}
		
		public static function getConfig(key:String):Object
		{
			return ConfigServer.inborn[key];
		}
		
		public function initData(key:String, obj:Object):void
		{
			this.id = key;
			this.data = obj;
			for (var m:String in obj)
			{
				if (this.hasOwnProperty(m))
				{
					this[m] = obj[m];
				}
			}
		}
		
		public function getName():String
		{
			var name:String = Tools.getMsgById(this.getTalentId());
			if (!name)
				name = Tools.getMsgById("msg_ModelTalent_0");
			return name;
		}
		public function getTalentId():String
		{
			return 'talent' + this.id.substr(4);
		}
		
		/**
		 * 得到传奇英雄星级对应的传奇属性值
		 */
		public function getLegendValue(starLv:int):int
		{
			var cfg:* = ConfigFight.legendTalent[this.id]?ConfigFight.legendTalent[this.id]:ConfigFight.legendTalentFight[this.id];
			if (cfg){
				var arr:Array;
				if (cfg is Array){
					arr = cfg as Array;
				}
				else{
					arr = cfg.prop;
				}
				return FightUtils.getRankValue(starLv, arr);
			}
			return 0;
		}
		/**
		 * 得到传奇属性文本原串
		 */
		public function getLegendTalent():String
		{
			return 'talent' + this.id.substr(4) + '_legend';
		}
		
		/**
		 * 得到描述的html文本
		 */
		public function getInfoHtml():String
		{
			var info:String = this.getReplaceHtml('info');
			if (!info)
				info = Tools.getMsgById("msg_ModelTalent_1");
			return info;
		}
		
		/**
		 * 得到替换的html文本
		 */
		public function getReplaceHtml(key:String, hasBrackets:Boolean = true):String
		{
			var replaceArr:Array = [];
			var arr:Array = this.data[key + 'Arr'];
			if (arr)
			{
				var i:int;
				var len:int = arr.length;
				for (i = 0; i < len; i++)
				{
					replaceArr.push(PassiveStrUtils.translateSkillInfo(this.data, arr[i], 1, hasBrackets, true));
				}
			}
			return Tools.getMsgById(this.getTalentId() + '_' + key, replaceArr);
		}
	
	}
}