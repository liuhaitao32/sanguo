package sg.model 
{
	import sg.cfg.ConfigServer;
	import sg.fight.logic.utils.PassiveStrUtils;
	import sg.utils.Tools;
	/**
	 * 英雄觉醒天赋
	 * @author zhuda
	 */
	public class ModelAwaken extends ModelBase
	{
		public var id:String;
		public function ModelAwaken() 
		{
			
		}
		
		public static var awakenModels:Object = {};
		
		public static function getModel(key:String):ModelAwaken
		{
			var model:ModelAwaken = ModelAwaken.awakenModels[key];
			if (!model)
			{
				var cfg:Object = ModelAwaken.getConfig(key);
				if (cfg)
				{
					model = new ModelAwaken();
					model.initData(key, cfg);
					ModelAwaken.awakenModels[key] = model;
				}
			}
			return model;
		}
		
		public static function getConfig(key:String):Object
		{
			return ConfigServer.inborn[key + 'a'];
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
			//var name:String = Tools.getMsgById(this.getTalentId());
			//if (!name)
				//name = Tools.getMsgById("msg_ModelTalent_0");
			return '';
		}
		public function getAwakenId():String
		{
			return 'awaken' + this.id.substr(4);
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
			return Tools.getMsgById(this.getAwakenId() + '_' + key, replaceArr);
		}
		
	}

}