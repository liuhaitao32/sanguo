package sg.fight.client.view
{
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.Label;
	import sg.cfg.ConfigApp;
	import sg.cfg.ConfigColor;
	import sg.cfg.ConfigServer;
	import sg.fight.FightMain;
	import sg.fight.client.ClientBattle;
	import sg.fight.client.unit.ClientHero;
	import sg.fight.client.unit.ClientTroop;
	import sg.fight.logic.unit.TroopLogic;
	import sg.fight.logic.utils.FightUtils;
	import sg.fight.logic.utils.PassiveStrUtils;
	import sg.manager.AssetsManager;
	import sg.manager.EffectManager;
	import sg.model.ModelGuild;
	import sg.utils.Tools;
	import sg.view.com.ComPayType;
	import ui.battle.fightHeroUI;
	
	/**
	 * 战斗中对战双方英雄的UI
	 * @author zhuda
	 */
	public class ViewFightHero extends fightHeroUI
	{
		private const propertys:Array = ['str', 'agi', 'cha', 'lead'];
		private const colors:Array = ['#FFFFFF', '#FFFF00'];
		
		private var _weakBox:Box;
		private var _blessBox:Box;
		//private var _battleBox:Box;
		
		private var _clientHeroArr:Array;
		
		public function ViewFightHero()
		{
			this.visible = false;
			this._weakBox = new Box();
			this._weakBox.y = 90;
			this._weakBox.left = 0;
			this._weakBox.right = 0;
			this.addChild(this._weakBox);
			
			this._blessBox = new Box();
			this._blessBox.y = 82;
			this._blessBox.left = 10;
			this._blessBox.right = 10;
			this.addChild(this._blessBox);
			
			//this._battleBox = new Box();
			//this._battleBox.y = 100;
			//this._battleBox.left = 10;
			//this._battleBox.right = 10;
			//this.addChild(this._battleBox);
			
			this.once(Event.ADDED, this, this.initUI);
		}
		
		public function initUI():void
		{
			if (ConfigApp.isPC){
				//this.cacheAs = "none";
				//this.boxL.cacheAs = "none";
				//this.boxR.cacheAs = "none";
				this.boxL.scale(1.6, 1.6);
				this.boxR.scale(1.6, 1.6);
				
				this._weakBox.y = 15;
				this._weakBox.left = 400;
				this._weakBox.right = 400;
				
				this._blessBox.y = 130;
				
				//this._battleBox.y = 130;
				//this.reCache();
			}
		}

		/**
		 * 初始化祝福效果
		 */
		private function initBless(troops:Array):void
		{
			this._blessBox.destroyChildren();
			var label:Label;
			var img:Image;
			var img2:Image;
			var value:Number;
			var valueStr:String;
			for (var i:int = 0; i < 2; i++) 
			{
				var troop:ClientTroop = troops[i];
				if (troop.bless){
					//存在祝福效果
					value = troop.bless;
					
					
					img2 = new Image(AssetsManager.getAssetsFight('fight_bg06'));
					img2.height = 20;
					img2.width = 320;
					img2.y = -2;
					img2.alpha = 0.5;
					
					label = new Label();
					label.fontSize = 14;
					label.stroke = 2;
					label.strokeColor = '#CC6633';
					label.color = '#FFEE88';
					label.y = 0;
					
					img = new Image(AssetsManager.getAssetsUI('icon_leitai2.png'));
					var temp:Number = img.width / img.height;
					img.height = 16;
					img.width = 16*temp;
					img.y = 0;
					
					if(i==0){
						label.x = 22;
						img.x = 0;
						img2.x = -100;
					}
					else{
						label.right = 22;
						label.align = 'right';
						img.right = 0;
						img2.right = -100 + img2.width;
						img2.scaleX = -1;
					}
					
					
					valueStr = Tools.percentFormat(value, 1);
					if (value > 0){
						valueStr = '+'+valueStr;
					}
					label.text = Tools.getMsgById('troop_bless', [valueStr, valueStr]);
					
					this._blessBox.addChild(img2);	
					this._blessBox.addChild(label);	
					this._blessBox.addChild(img);	
				}
			}
		}
		/**
		 * 初始化弱点，或者卜卦效果
		 */
		private function initWeak(troops:Array):void
		{
			this._weakBox.destroyChildren();
			var label:Label;
			var img:Image;
			
			var troop0:ClientTroop = troops[0];
			if (troop0.data.magic){
				//存在有效卜卦
				var cfg:Object = ConfigServer.mining.magic_date[troop0.data.magic];
				label = new Label();
				label.x = 60;
				label.fontSize = 16;
				label.stroke = 2;
				label.strokeColor = '#333333';
				label.color = '#FFEE88';
				label.y = 7;
				label.text = Tools.getMsgById(cfg['name']);
				this._weakBox.addChild(label);
				
				label = new Label();
				label.x = 60;
				label.fontSize = 16;
				label.stroke = 2;
				label.strokeColor = '#333333';
				label.color = '#33FF33';
				label.y = 25 + 7;
				label.text = Tools.getMsgById(cfg['info']);
				this._weakBox.addChild(label);
				
				img = new Image(AssetsManager.getAssetsUI('icon_goto03' + AssetsManager.PNG_EXT));
				img.x = 10;
				img.width = 40;
				img.height = 40;
				img.y = 10;
				this._weakBox.addChild(img);
			}

			var troop1:ClientTroop = troops[1];
			if (troop1.data.weak){
				var weakArr:Array = troop1.data.weak;
				var len:int = weakArr.length;
				for (var i:int = 0; i < len; i++)
				{
					var weakOne:Array = weakArr[i];
					var weakKey:String = weakOne[0];
					var passive:Object = FightUtils.formatWeakToPassive(weakOne,true);
					label = new Label();
					label.right = 50;
					label.fontSize = 16;
					label.align = 'right';
					label.stroke = 2;
					label.strokeColor = '#333333';
					label.color = troop0.checkWeak(weakKey) ? '#33FF33':'#DDDDDD';
					label.y = 35 * i + 7;
					label.text = PassiveStrUtils.translatePassiveInfo(passive, false);
					this._weakBox.addChild(label);
					
					//追加图标
					var arr:Array = ModelGuild.getWeakArray(weakKey);
					img = new Image(AssetsManager.getAssetsICON(arr[2] + AssetsManager.PNG_EXT));
					img.right = 10;
					img.width = 30;
					img.height = 30;
					img.y = 35 * i;
					this._weakBox.addChild(img);
				}
			}
		}


		
		/**
		 * 初始化数据，显示英雄信息
		 */
		public function initData(troops:Array):void
		{
			this.initWeak(troops);
			this.initBless(troops);
			//this.initBattle();
			this._clientHeroArr = [];
			
			var label:Label;
			for (var i:int = 0; i < 2; i++)
			{
				var clientTroop:ClientTroop = troops[i];
				var clientHero:ClientHero = clientTroop.getClientHero();
				this._clientHeroArr.push(clientTroop.getClientHero());
				
				
				this.getLabel('lv' + i.toString()).text = clientHero.lv.toString();
				
				var colorLv:int = clientHero.getHeroStarColorLv();
				label = this.getLabel('name' + i.toString());
				var heroName:String = clientHero.name;
				label.text = heroName;
				label.strokeColor = EffectManager.getFontColor(colorLv, ConfigColor.FONT_STROKE_COLORS);
				if (heroName.length > 3){
					label.align = i == 0?'left':'right';
					label.width = 300;
				}
				else{
					label.align = 'center';
					label.width = 108;
				}
				
				this.getHeroCompoment(i).setHeroIcon(clientHero.id, true, colorLv);
			}
			this.updateHeroesProp();
			
			this.visible = true;
		}
		
		/**
		 * 刷新双方英雄属性
		 */
		public function updateHeroesProp():void
		{
			var i:int;
			var j:int;
			var jLen:int = propertys.length;
			var key:String;
			var label:Label;
			var compareArr:Array = [];
			var tempStr:String;
			var tempWidth:Number;
			
			//遍历拼点结果
			for (j = 0; j < jLen; j++)
			{
				key = propertys[j];
				compareArr.push(this.compareProperty(key, this._clientHeroArr[0], this._clientHeroArr[1]));
			}
			
			for (i = 0; i < 2; i++)
			{
				var clientHero:ClientHero = this._clientHeroArr[i];
				for (j = 0; j < jLen; j++)
				{
					key = propertys[j];
					label = this.getLabel(key + i);
					label.text = clientHero[key];
					//值较大的显示黄色
					if (compareArr[j] == i)
					{
						label.color = colors[1];
						label.fontSize = 32;
					}
					else
					{
						label.color = colors[0];
						label.fontSize = 28;
					}
					label = this.getLabel('t_' + key + i);
					tempStr = Tools.getMsgById('info_' + key);
					//tempStr = 'AACCB';
					//label.text = tempStr;
					Tools.textFitFontSize(label, tempStr, 40);
					//tempWidth = label.textField.textWidth;
					//trace(tempStr, tempWidth);
					//if (tempWidth > 150){
						//label.textField.fontSize = 14;
					//}
					//else if (tempWidth > 100){
						//label.textField.fontSize = 18;
					//}
					//else {
						//label.textField.fontSize = 24;
					//}
				}
			}
		}
		
		
		public function getLabel(key:String):Label
		{
			return this[key] as Label;
		}
		public function getHeroCompoment(index:int):ComPayType
		{
			return this['heroIcon'+index] as ComPayType;
		}
		/**
		 * 比较属性，返回较高的index
		 */
		public function compareProperty(key:String,tgt0:*,tgt1:*):int
		{
			var index:int = -1;
			if (tgt0[key] > tgt1[key])
			{
				index = 0;
			}
			else if (tgt1[key] > tgt0[key])
			{
				index = 1;
			}
			return index;
		}
	
	}

}
