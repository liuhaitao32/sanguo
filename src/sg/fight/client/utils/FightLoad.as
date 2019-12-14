package sg.fight.client.utils
{
	import laya.display.Animation;
	import laya.events.Event;
	import laya.utils.Handler;
	import laya.utils.Stat;
	import sg.cfg.ConfigApp;
	import sg.cfg.ConfigAssets;
	import sg.cfg.ConfigServer;
	import sg.fight.client.ClientBattle;
	import sg.fight.client.cfg.ConfigFightView;
	import sg.fight.client.unit.ClientTroop;
	import sg.fight.client.view.FightSceneBase;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.utils.FightPrint;
	import sg.fight.logic.utils.FightUtils;
	import sg.fight.test.TestFight;
	import sg.fight.test.TestFightData;
	import sg.manager.AssetsManager;
	import sg.manager.EffectManager;
	import sg.manager.LoadeManager;
	import sg.manager.ViewManager;
	import sg.model.ModelGame;
	import sg.model.ModelHero;
	import sg.utils.Tools;
	
	/**
	 * 管理战斗相关加载
	 * @author zhuda
	 */
	public class FightLoad
	{
		///若新的单次战斗开始加载资源时，清理fightCount比当前小N的所有过期特效动画贴图。配置为0则所有之前的都认为过期
		static public var CLEAR_LAST_NUM:int = 1;
		///缓存本次战斗中，纪录加载特效动画资源的最新fightCount，用于清理动画贴图
		static public var usedEffects:Object = {};
		///缓存本次战斗中，所有英雄及兵种动画，用于退出时清理动画贴图
		static public var usedPersons:Object = {};
		///缓存本次战斗中，所有临时动画，用于退出时清理动画贴图
		static public var usedOthers:Object = {};
		
		///上一次清除资源时的帧数
		//static public var lastClearLoopCount:int;
		
		
		public var clientBattle:ClientBattle;
		
		public function FightLoad(clientBattle:ClientBattle)
		{
			this.clientBattle = clientBattle;
		}
		
		public function initLoad():void
		{
			if (TestFightData.testMode == -3){
				//不加载
				return;
			}
			//return;
			//从所有部队数据，拆出要加载的所有人物资源
			if (!ConfigApp.testFightType){
				ModelGame.isShowLoadingAni = false;
				ModelGame.stageLockOrUnlock('loadFight', true);
			}
			this.startInitLoad();
			//if (Stat.loopCount > FightLoad.lastClearLoopCount+10){
				//this.startInitLoad();
			//}
			//else{
				//Laya.scaleTimer.frameOnce(10, this, this.startInitLoad);
			//}
		}
		private function startInitLoad():void
		{
			print('开始加载战斗资源');
			var loadObj:Object = {};
			var teamArr:Array = this.clientBattle.data.team;
			var i:int;
			var j:int;
			var iLen:int;
			var jLen:int;
			for (i = 0, iLen = teamArr.length; i < iLen; i++)
			{
				var troopArr:Array = teamArr[i].troop;
				for (j = 0, jLen = troopArr.length; j < jLen; j++)
				{
					this.checkTroop(troopArr[j], loadObj);
				}
			}
			var arr:Array = FightUtils.toArray(loadObj).concat(ConfigServer.effect.fightDefaultLoadAniArr);
			//Laya.loader.on(Event.ERROR, this, this.loadError);
			//AssetsManager.preLoadAssets(null, arr, null, this, this.loadInitComplete);
			
			var assets:Array = [];
			AssetsManager.formatAssets(arr, 1, assets);
			if (assets.length > 0){
				Laya.loader.on(Event.ERROR, this, this.loadError);
				LoadeManager.load(assets,Handler.create(this, function(array:Array):void
				{
					AssetsManager.createAnimationMap(array);
					this.loadInitComplete();
				},[assets]),true);
			}
			else{
				this.loadInitComplete();
			}
			
			//trace('加载资源！！！！！！！！！！！！！',assets);
			//EffectManager.preLoadAnimations(arr, this, this.loadComplete);
			//EffectManager.preLoadAnimations(ConfigFightView.DEFAULT_ASSETS, this, this.loadNext);
		}
		
		
		public function addTroopLoad(troopData:Object,clientTroop:ClientTroop):void
		{
			print('追加部队资源');
			var loadObj:Object = {};
			this.checkTroop(troopData, loadObj);
			var arr:Array = FightUtils.toArray(loadObj);
			Laya.loader.on(Event.ERROR, this, this.loadError);
			AssetsManager.preLoadAssets(null, arr, null, this, this.loadAddTroopComplete,[clientTroop]);
			//EffectManager.preLoadAnimations(arr, this, this.loadComplete);
			//EffectManager.preLoadAnimations(ConfigFightView.DEFAULT_ASSETS, this, this.loadNext);
		}
		
		/**
		 * 计算troop中需要的英雄、兵种素材，加入到计划加载的对象中
		 */
		private function checkTroop(troopData:Object, loadObj:Object):void
		{
			var srcData:* = {};
			var key:String = troopData.hid;
			var heroCfg:Object = ConfigServer.hero[key];
			//英雄素材
			if (heroCfg.res) key = heroCfg.res;
			this.addLoadPerson(loadObj, key);
			
			var armyArr:Array = troopData.army;
			var armyType:int;
			var armyRank:int;
			var i:int;
			var len:int = ConfigFight.armyNum;
			
			//前后军素材
			for (i = 0; i < len; i++)
			{
				key = '';
				if(armyArr != null){
					var army:* = armyArr[i];
					if (army.resId){
						key = army.resId;
					}
					else{
						armyType = army.type;
						armyRank = army.rank;
					}
				}
				else
				{
					armyType = heroCfg.army[i];
					armyRank = troopData.hasOwnProperty('armyRank')?troopData.armyRank:ConfigFight.propertyDefaultData.armyRank;
				}
				if (!key) key = 'army' + armyType.toString() + armyRank.toString();
				this.addLoadPerson(loadObj, key);
			}

			//副将素材
			var adjutantArr:Array = troopData.adjutant;
			if (adjutantArr)
			{
				len = adjutantArr.length;
				for (i = 0; i < len; i++)
				{
					var adjutant:Array = adjutantArr[i];
					if(adjutant){
						key = adjutant[0];
						heroCfg = ConfigServer.hero[key];
						if (heroCfg.res) key = heroCfg.res;
						this.addLoadPerson(loadObj, key);
					}
				}
			}
			
			//额外素材，如果是可变兵种或者副将，都需要加载
			var loadArr:Array = troopData.load;
			if (loadArr)
			{
				len = loadArr.length;
				for (i = 0; i < len; i++)
				{
					this.addLoadPerson(loadObj, loadArr[i]);
				}
			}
			//特效，临时写一次
			//loadObj['hit101'] = 1;
		}
		
		/**
		 * 加入当前要加载的内容中，并加入已加载的部队素材中
		 */
		private function addLoadPerson(loadObj:Object,key:String):void
		{
			loadObj[key] = 1;
			FightLoad.usedPersons[key] = 1;
		}
		

		
		private function loadInitComplete():void
		{
			Laya.loader.off(Event.ERROR, this, this.loadError);
			print('加载战斗资源 OK');
			
			this.loadInitAllComplete();
			//if (Stat.loopCount > FightLoad.lastClearLoopCount+10){
				//this.loadInitAllComplete();
			//}
			//else{
				//Laya.scaleTimer.frameOnce(10, this, this.loadInitAllComplete);
			//}
		}
		private function loadInitAllComplete():void
		{
			if(this.clientBattle){
				this.clientBattle.loadComplete();
				if(!ConfigApp.testFightType){
					ViewManager.instance.showFightScenes(this.clientBattle.fightMain.fightLayer);
				}
			}
			if(!ConfigApp.testFightType){
				ModelGame.stageLockOrUnlock('loadFight', false);
				ModelGame.isShowLoadingAni = true;
			}
		}
		
		private function loadAddTroopComplete(clientTroop:ClientTroop):void
		{
			Laya.loader.off(Event.ERROR, this, this.loadError);
			print('追加部队资源 OK');
			clientTroop.checkShow();
		}
		
		private function loadError(errUrl:String):void
		{
			//读取人物资源错，替代资源为army00
			var srcName:String = AssetsManager.getErrorSrcName(errUrl);
			if (!srcName) return;
			var srcType:int = -1;
			if (srcName.indexOf('army') == 0)
				srcType = 0;
			else if (srcName.indexOf('hero') == 0)
				srcType = 1;
			
			var replaceName:String = ConfigServer.effect.fightDefaultLoadAniArr[srcType];
			
			AssetsManager.loadedAnimations[srcName] = replaceName;
			
			print('---' + srcName + ' 加载出错，替换为 ' + replaceName);
			//trace(srcName + '           加载出错，替换为          ' + replaceName);
		}
		
		
		/**
		 * 根据战报中涉及到的特效资源，全部加载
		 */
		public function initLoadPlayback():void
		{
			var loadObj:Object = {};
			var loadImgObj:Object = {};
			var i:int;
			var len:int;
			var j:int;
			var k:int;
	
			var playbacks:Array = this.clientBattle.getClientFight().playbacks;
			len = playbacks.length;
			var playbackObj:Object;
			var actValue:Object;
			var effArr:Array;
			var buffArr:Array;
			var fateArr:Array;
			var res:String;
			var fightCount:int = this.clientBattle.fightCount;
			
			this.clearOldEffects();
	
			for (i = 0; i < len; i++)
			{
				playbackObj = playbacks[i];
				if (playbackObj.key == 'act'){
					actValue = playbackObj.value;
					effArr = actValue.effs;
					fateArr = actValue.fate;
					if(effArr){
						for (j = effArr.length -1; j >= 0; j--) 
						{
							//挑选出必要的特效加载
							FightViewUtils.pickEffectRes(effArr[j], loadObj, ConfigFightView.PICK_EFF_PATHS, FightLoad.usedEffects, fightCount);
						}
					}
					if(fateArr){
						for (j = fateArr.length -1; j >= 0; j--) 
						{
							//合击技英雄加载
							var hid:String = fateArr[j];
							var heroConfig:Object = ConfigServer.hero[hid];
							res = heroConfig.res ? heroConfig.res : hid;
							loadObj[res] = 1;
							FightLoad.usedPersons = 1;
							
							var icon:String = heroConfig.icon ? heroConfig.icon : hid;
							//加载中等英雄图
							icon = AssetsManager.getAssetsHero(icon, true);
							loadImgObj[icon] = 1;
							//FightViewUtils.pickEffectRes(effArr[j], loadObj, ConfigFightView.PICK_EFF_PATHS);
						}
					}
					var srcArr:Array = actValue.src;
					for (k = srcArr.length -1; k >= 0; k--) 
					{
						var srcObj:* = srcArr[k];
						buffArr = srcObj.buffs;
						if (buffArr){
							for (j = buffArr.length -1; j >= 0; j--) 
							{
								//挑选出必要的Buff特效加载
								FightViewUtils.pickEffectRes(buffArr[j], loadObj, ConfigFightView.PICK_BUFF_PATHS, FightLoad.usedEffects, fightCount);
							}
						}
					}
					
					
					var tgtArr:Array = actValue.tgt;
					for (k = tgtArr.length -1; k >= 0; k--) 
					{
						var tgtObj:* = tgtArr[k];
						effArr = tgtObj.effs;
						if(effArr){
							for (j = effArr.length -1; j >= 0; j--) 
							{
								//挑选出必要的特效加载
								FightViewUtils.pickEffectRes(effArr[j], loadObj, ConfigFightView.PICK_EFF_PATHS, FightLoad.usedEffects, fightCount);
							}
						}
						buffArr = tgtObj.buffs;
						if (buffArr){
							for (j = buffArr.length -1; j >= 0; j--) 
							{
								//挑选出必要的Buff特效加载
								FightViewUtils.pickEffectRes(buffArr[j], loadObj, ConfigFightView.PICK_BUFF_PATHS, FightLoad.usedEffects, fightCount);
							}
							
						}
					}
				}
			}
			var arr:Array = FightUtils.toArray(loadObj);
			
			if (FightPrint.check('FightLoad')){
				len = arr.length;
				for (i = 0; i < len; i++){
					res = arr[i];
					FightPrint.print('准备加载' + res);
				}	
			}
			
			//位图加载，将双方英雄及其合击英雄的位图加载完毕
			
			var imgArr:Array = FightUtils.toArray(loadImgObj);

			//var assets:Array = [];
			//AssetsManager.formatAssets(arr, 1, assets);
			//if (assets.length > 0){
				//Laya.loader.on(Event.ERROR, this, this.loadPlaybackError);
				//LoadeManager.load(assets,Handler.create(this, function():void
				//{
					//AssetsManager.createAnimationMap(assets);
					//this.loadPlaybackComplete();
				//}));
			//}
			//else{
				//this.loadPlaybackComplete();
			//}
			AssetsManager.preLoadAssets(imgArr, arr, null, this, this.loadPlaybackComplete);
		}

		private function loadPlaybackComplete():void
		{
			Laya.loader.off(Event.ERROR, this, this.loadPlaybackError);
			print('加载回放资源 OK');
			if(this.clientBattle)
				this.clientBattle.loadPlaybacksComplete();
		}
		private function loadPlaybackError(errUrl:String):void
		{
			var srcName:String = AssetsManager.getErrorSrcName(errUrl);
			if (!srcName) return;
			var srcType:int = -1;
			if (srcName.indexOf('bullet') == 0)
				srcType = 2;
			else if (srcName.indexOf('hit') == 0)
				srcType = 3;
			else if (srcName.indexOf('bang') == 0)
				srcType = 4;
			else if (srcName.indexOf('fire') == 0)
				srcType = 5;
			else if (srcName.indexOf('stick') == 0)
				srcType = 6;
			else if (srcName.indexOf('special') == 0)
				srcType = 7;
			else if (srcName.indexOf('buff') == 0)
				srcType = 8;
			
			var replaceName:String = ConfigServer.effect.fightDefaultLoadAniArr[srcType];
			
			AssetsManager.loadedAnimations[srcName] = replaceName;
			
			print('---' + srcName + ' 加载出错，替换为 ' + replaceName);
		}
		
		/**
		 * 加载临时的动画，于战斗清理时统一清理动画贴图
		 */
		static public function loadAnimation(name:String, stateName:String = '', endType:int = 0, ani:Animation = null):Animation
		{
			if(usedOthers)
				usedOthers[name] = 1;
			return EffectManager.loadAnimation(name, stateName, endType, ani, 'fight');
		}
		
		/**
		 * 清除过期的特效动画资源贴图（新的战斗开始）
		 */
		public function clearOldEffects():void
		{
			if (!this.clientBattle)
				return;
			var fightCount:int = this.clientBattle.fightCount;
			for (var key:String in FightLoad.usedEffects){
				//trace('clearOldEffects遍历:' + key +' ,上次使用：' + FightLoad.usedEffects[key] + ' / ' + fightCount);
				if (FightLoad.usedEffects[key] < fightCount - CLEAR_LAST_NUM){
					this.clearOneUsedAnimation(key);
					delete FightLoad.usedEffects[key];
				}
			}
		}
		
		/**
		 * 清除所有战斗相关的动画资源贴图
		 */
		public function clear():void
		{
			Laya.loader.off(Event.ERROR, this, this.loadError);
			Laya.loader.off(Event.ERROR, this, this.loadPlaybackError);
			this.clientBattle = null;
			
			//return;
			var key:String;
			for (key in FightLoad.usedEffects){
				this.clearOneUsedAnimation(key);
			}
			for (key in FightLoad.usedPersons){
				this.clearOneUsedAnimation(key);
			}
			for (key in FightLoad.usedOthers){
				this.clearOneUsedAnimation(key);
			}
			FightLoad.usedEffects = {};
			FightLoad.usedPersons = {};
			FightLoad.usedOthers = {};
			//FightLoad.lastClearLoopCount = Stat.loopCount;
			
			//战斗的贴图集和大贴图都清除
			Laya.loader.clearTextureRes('res/atlas/fight.atlas');
			Laya.loader.clearTextureRes(FightSceneBase.getSceneSkinUrl('00'));
			Laya.loader.clearTextureRes(FightSceneBase.getSceneSkinUrl('02'));
			Laya.loader.clearTextureRes(FightSceneBase.getSceneSkinUrl('03'));
			
			//顺带清理所有中等尺寸的英雄头像，确保显存健康
			if (ConfigServer.effect.fightClearHeroImages){
				LoadeManager.clearHeroIcon();
			}
		}
		private function clearOneUsedAnimation(key:String):void
		{
			var urlAtlas:String;
			//var urlAnimation:String;
			if(!ConfigAssets.noAtlasAnimations[key]){
				//delete AssetsManager.loadedAnimations[key];
				urlAtlas = AssetsManager.getUrlAtlas(key);
				//urlAnimation = AssetsManager.getUrlAnimation(key);
				//delete Animation.framesMap[urlAnimation + '#'];
				//Laya.loader.clearRes(urlAtlas);
				Laya.loader.clearTextureRes(urlAtlas);
				//trace('clear清理了:' + urlAtlas);
			}
		}
		
		
		/**
		 * 打印(纯客户端使用)
		 */
		public static function print(str:String, data:Object = null):void
		{
			FightPrint.checkPrint('FightLoad', str, data);
		}
	}

}