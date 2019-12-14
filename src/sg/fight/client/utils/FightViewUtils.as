package sg.fight.client.utils
{
	import laya.display.Sprite;
	import laya.utils.Ease;
	import laya.utils.Tween;
	import sg.cfg.ConfigApp;
	import sg.cfg.ConfigColor;
	import sg.cfg.ConfigServer;
	import sg.fight.FightMain;
	import sg.fight.client.ClientFight;
	import sg.fight.client.cfg.ConfigFightView;
	import sg.fight.client.interfaces.IClientUnit;
	import sg.fight.client.spr.FDamage;
	import sg.fight.client.spr.FEffect;
	import sg.fight.client.spr.FHero;
	import sg.fight.client.spr.FShogun;
	import sg.fight.client.spr.FWord;
	import sg.fight.client.unit.ClientAdjutant;
	import sg.fight.client.unit.ClientArmy;
	import sg.fight.client.unit.ClientHero;
	import sg.fight.client.unit.ClientTroop;
	import sg.fight.client.view.ViewFightBannerSkill;
	import sg.fight.client.view.ViewFightBash;
	import sg.fight.client.view.ViewFightBeastSkill;
	import sg.fight.client.view.ViewFightCompare;
	import sg.fight.client.view.ViewFightFate;
	import sg.fight.client.view.ViewFightSpirit;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.utils.FightUtils;
	import sg.utils.MusicManager;
	import sg.utils.Tools;
	
	/**
	 * 战斗视图工具
	 * @author zhuda
	 */
	public class FightViewUtils
	{
		/**
		 * 取得正负范围的随机偏移
		 */
		public static function getRandomValue(value:Number):Number
		{
			if (value)
				return Math.random() * value;
			return 0;
		}
		
		/**
		 * 取得正负范围的随机偏移
		 */
		public static function getRandomOffset(value:Number):Number
		{
			if (value)
				return -value + Math.random() * value * 2;
			return 0;
		}
		
		/**
		 * 取得最大最小中间某值
		 */
		public static function getRandomRange(min:Number, max:Number):Number
		{
			return min + Math.random() * (max - min);
		}
		
		/**
		 * 返回指定目标地，按射程需要停留在哪
		 */
		public static function getPauseXByRange(startX:Number, aimX:Number, range:Number):Number
		{
			if (aimX > startX){
				return startX + Math.max(0,aimX-startX-range);
			}
			else if (aimX < startX){
				return startX + Math.min(0,aimX-startX+range);
			}
			else{
				return aimX;
			}
		}
		/**
		 * 返回射程
		 */
		public static function getRange(range:Number):Number
		{
			if (!range) return 0;
			return range* ConfigFightView.BULLET_RANGE_RATE;
		}
		
		/**
		 * 返回到达目标点的 跑动距离，不算射程（正数，只用来算时间）
		 */
		public static function getDisX(startX:Number, aimX:Number):Number
		{
			var dis:Number = Math.abs(aimX - startX);
			//dis = Math.max(0, dis - range);
			return dis;
		}
		/**
		 * 返回到达目标身前的（考虑射程） 跑动相对距离，有负数
		 */
		public static function getSignDisX(startX:Number, aimX:Number, range:Number):Number
		{
			var dis:Number = aimX - startX;
			if (dis >= 0){
				//向右
				dis = Math.max(1, dis - range);
			}
			else{
				//向左
				dis = Math.min(-1, dis + range);
			}
			return dis;
		}
		
		/**
		 * 返回到达距离，含Y
		 */
		public static function getDis(startX:Number, aimX:Number,startY:Number, aimY:Number):Number
		{
			var xx:Number = aimX - startX;
			var yy:Number = aimY - startY;
			var dis:Number = Math.sqrt(xx*xx+yy*yy);
			return dis;
		}
		
		/**
		 * 返回指定X距离，返回单跑时间，或者跑+停顿子弹跑时间
		 */
		public static function getMoveTime(disX:Number, speedRate:Number = 1, baseTimeRate:Number = 1):int
		{
			if (speedRate == 0)
				return 0;
			var time:int = Math.floor(disX / ConfigFightView.MOVE_BASE_SPEED / speedRate);
			if (baseTimeRate)
				time += ConfigFightView.MOVE_BASE_TIME * baseTimeRate;
			return time;
		}
		
		/**
		 * 返回unit执行行动前摇时间，移动+攻击
		 */
		public static function getActTime(disX:Number, effObj:Object):int
		{
			var moveObj:Object = effObj.move;
			var bulletObj:Object = effObj.bullet;
			var speedRate:Number = effObj.speed;
			
			if (!speedRate && !moveObj && !bulletObj)
				return 0;
			var actTime:int = ConfigFightView.ATTACK_BASE_TIME;
			var range:Number = FightViewUtils.getRange(effObj.range);
			if (range && disX>range && moveObj && bulletObj){
				//移动+发射攻击
				actTime += FightViewUtils.getMoveTime(disX - range, moveObj.speed?moveObj.speed:speedRate, moveObj.hasOwnProperty('baseTimeRate')?moveObj.baseTimeRate:1);
				actTime += FightViewUtils.getMoveTime(range, bulletObj.speed?bulletObj.speed:speedRate, bulletObj.hasOwnProperty('baseTimeRate')?bulletObj.baseTimeRate:1);
			}
			else if (moveObj) 
			{
				//移动+近战攻击
				actTime += FightViewUtils.getMoveTime(disX, moveObj.speed?moveObj.speed:speedRate, moveObj.hasOwnProperty('baseTimeRate')?moveObj.baseTimeRate:1);
			}
			else if (bulletObj) 
			{
				//发射攻击
				actTime += FightViewUtils.getMoveTime(disX, bulletObj.speed?bulletObj.speed:speedRate, bulletObj.hasOwnProperty('baseTimeRate')?bulletObj.baseTimeRate:1);
			}
			return actTime;
		}
		/**
		 * 返回unit执行返程额外时间，如果是移动+攻击，则只取需要额外等待的时间
		 */
		public static function getActEndTime(disX:Number, effObj:Object):int
		{
			var moveObj:Object = effObj.move;
			var bulletObj:Object = effObj.bullet;
			var speedRate:Number = effObj.speed;
			
			if (!speedRate && !moveObj && !bulletObj)
				return 0;
			var range:Number = FightViewUtils.getRange(effObj.range);
			if (range && disX>range && moveObj && bulletObj){
				//移动+发射攻击。返程移动比弹道运动长的时间
				return Math.max(0, FightViewUtils.getMoveTime(disX - range, moveObj.speed?moveObj.speed:speedRate, moveObj.hasOwnProperty('baseTimeRate')?moveObj.baseTimeRate:1) - FightViewUtils.getMoveTime(range, bulletObj.speed?bulletObj.speed:speedRate, bulletObj.hasOwnProperty('baseTimeRate')?bulletObj.baseTimeRate:1));
			}
			else if (moveObj) 
			{
				//移动+近战攻击
				return FightViewUtils.getMoveTime(disX, moveObj.speed?moveObj.speed:speedRate, moveObj.hasOwnProperty('baseTimeRate')?moveObj.baseTimeRate:1);
			}
			return 0;
		}
		
		/**
		 * 结束战斗
		 */
		public static function onExit():void
		{
			if (ConfigApp.testFightType != 0)
			{
				FightMain.instance.reRandomData();
			}
			else
			{
				FightMain.instance.exit();
			}
		}
		
		/**
		 * 返回城市名称
		 */
		public static function getCityName(cid:*):String
		{
			var cityCfg:* = ConfigServer.city[cid.toString()];
			if (cityCfg)
			{
				return Tools.getMsgById(cityCfg.name);
			}
			else
			{
				return '中原';
			}
		}
		
		/**
		 * 获得技能等级对应的颜色类型(默认英雄技)
		 */
		public static function getColorTypeSkill(skillLv:int, type:int = 4):int
		{
			var arr:Array = ConfigServer.system_simple.skill_color[type.toString()];
			for (var i:int = arr.length - 1; i >= 0; i--)
			{
				if (skillLv >= arr[i])
				{
					return i;
				}
			}
			return 0;
		}
		
		/**
		 * 获得英雄星级对应的颜色类型
		 */
		//public static function getColorTypeStar(heroStar:int):int
		//{
			//return Math.max(2,Math.min(5, Math.floor(heroStar / 6) + 2));
		//}
		
		/**
		 * unit执行行动，返回攻击前摇special，命中后收招时间
		 */
		public static function doAction(unit:IClientUnit, srcObj:Object, tgtArr:Array, effObj:Object, fateArr:Array, delay:int):Array
		{
			var fight:ClientFight = unit.getClientFight();
			if (fight == null || fight.isCleared) return [0, 0];
			
			var i:int;
			var len:int = tgtArr.length;
			if (len == 0)
				return [0, 0];
			
			//自身弹出文字，更新血量等(同承受)
			//FightViewUtils.showInfo(unit, srcObj, {}, 0);
			var actTime:int = 0;
			var endTime:int = 0;
			var bangObj:* = effObj.bang;
			var hurtObj:* = effObj.hurt;
			
			var unitObj:Object;
			var unitArr:Array;
			var tgtUnit:IClientUnit;
			var tgtPosX:Number;
			//找到目标的最远最近位置
			var aimMinX:Number = 999999;
			var aimMaxX:Number = -999999;
			if (unit.getArmyIndex() == 2 || bangObj)
			{
				//英雄，或者有bang的技能，应该攻击中心
				unitObj = tgtArr[0];
				unitArr = unitObj.unit;
				tgtUnit = fight.getClientUnit(unitArr[0], unitArr[1]);
				tgtPosX = tgtUnit.getClientTroop().getCenterX();
				aimMinX = aimMaxX = tgtPosX;
			}
			else
			{
				for (i = 0; i < len; i++)
				{
					unitObj = tgtArr[i];
					unitArr = unitObj.unit;
					tgtUnit = fight.getClientUnit(unitArr[0], unitArr[1]);
					tgtPosX = tgtUnit.getPosX();
					
					aimMinX = Math.min(tgtPosX, aimMinX);
					aimMaxX = Math.max(tgtPosX, aimMaxX);
				}
			}
			var effDis:int = effObj.dis;
			if (effDis)
			{
				if (unit.isFlip)
				{
					aimMinX -= effDis;
					aimMaxX -= effDis;
				}
				else
				{
					aimMinX += effDis;
					aimMaxX += effDis;
				}
			}
			var effRndDis:int = effObj.rndDis;
			if (effRndDis)
			{
				if (unit.isFlip)
				{
					//打击左侧
					aimMinX = Math.min(aimMinX - effRndDis, aimMaxX);
				}
				else
				{
					//打击右侧
					aimMaxX = Math.max(aimMaxX + effRndDis, aimMinX);
				}
			}
			
			//使用特效，自动攻击到目标列表
			FightTime.delayTo(delay, unit, unit.attackTo, [aimMinX, aimMaxX, effObj]);
			
			if (effObj.speed)
			{
				var posX:Number = unit.getPosX();
				var aimX:Number = (aimMinX + aimMaxX) / 2;
				var dis:Number = FightViewUtils.getDisX(posX, aimX);
				
				//近战类攻击，跑到后再前摇，远程攻击，发出前前摇，没有子弹和移动的，用bang的特殊前摇命中时间
				actTime = FightViewUtils.getActTime(dis, effObj);
				//trace(unit.getName(), unit.getPosX(), (aimMinX + aimMaxX) / 2, dis, speedRate, actTime);
				var moveObj:Object = effObj.move;
				if (moveObj)
				{
					if (moveObj.noBack)
					{
						endTime = 0;
					}
					else{
						endTime = FightViewUtils.getActEndTime(dis, effObj);
					}
					
					if (moveObj.time)
					{
						//起手延迟
						actTime += moveObj.time;
					}
					if (hurtObj && !hurtObj.hitTime && moveObj.endTime)
					{
						//不存在连击长延迟时，增加收手延迟
						endTime += moveObj.endTime;
					}
				}
				if (fateArr && unit is ClientHero)
				{
					//合击技（不算自身）
					len = fateArr.length;
					var clientHero:ClientHero = unit as ClientHero;
					//已用几号位
					var usedArr:Array = [];
					var index:int = 0;
					var fHero:FHero;
					var hid:String;
					var clientAdjutant:ClientAdjutant;
					
					for (i = 0; i < len; i++)
					{
						//如果副将中存在，则优先使用副将的
						hid = fateArr[i];
						clientAdjutant = clientHero.getClientTroop().getClientAdjutantById(hid);
						if (clientAdjutant){
							usedArr.push(1-clientAdjutant.getAdjutantIndex());
							fHero = clientAdjutant.person as FHero;
							FightTime.delayTo(delay, fHero, fHero.runAndAttack, [aimX, effObj]);
						}
					}
					
					for (i = 0; i < len; i++)
					{
						//增加人一起冲
						hid = fateArr[i];
						clientAdjutant = clientHero.getClientTroop().getClientAdjutantById(hid);
						if (!clientAdjutant){
							//找到未占用位置生成英雄
							while (usedArr.indexOf(index) > -1){
								index++;
							}
							usedArr.push(index);
							var temp:int = ((index % 2 == 0) ? -1 : 1) * Math.floor((index + 2) / 2);
							var posY:Number = temp * 60;
							fHero = new FHero(unit, hid, posX, posY);
							fHero.forcedRender = true;
							var childIndex:int = fight.fightMain.scene.unitLayer.getChildIndex(clientHero.person.spr) + index;
							fHero.setItemIndex(Math.min(fight.fightMain.scene.unitLayer.numChildren - 1, Math.max(0, childIndex)));
							fHero.setAlive();
							//fPerson.runAndAttack(aimX, effObj, false);
							FightTime.delayTo(delay, null, FightViewUtils.addFateHero, [fHero, aimX, effObj]);
							FightEvent.ED.once(FightEvent.FIGHT_TIME_CLEAR, fHero, fHero.clear);
						}
					}
				}
				
			}
			if (bangObj)
			{
				if(bangObj.res2){
					new FEffect(fight.fightMain.scene, bangObj.res2, aimMinX, 0, ConfigFightView.HIT_Z, !tgtUnit.isFlip, 0, bangObj.res2Scale, bangObj.res2Alpha, delay + actTime, bangObj.res2Add);
				}
				if(bangObj.res){
					new FEffect(fight.fightMain.scene, bangObj.res, aimMinX, 0, ConfigFightView.HIT_Z, !tgtUnit.isFlip, 0, bangObj.resScale, bangObj.resAlpha, delay + actTime, bangObj.resAdd);
				}
				FightViewUtils.autoPlaySound(bangObj,  delay + actTime);
				actTime += bangObj.time;
			}
			//if (hurtObj && hurtObj.hitTime)
			//{
			//actTime += hurtObj.hitTime;
			//}
			
			return [actTime, endTime];
		}
		
		/**
		 * 追加一个合击技武将
		 */
		public static function addFateHero(fHero:FHero, aimX:Number, effObj:Object):void
		{
			if(fHero)
				fHero.runAndAttack(aimX, effObj, true);
		}

		/**
		 * 得到部队NPC的名字
		 */
		public static function getTroopUserName(data:*):String
		{
			if (!data){
				return null;
			}
			var uName:String = (data is String)?data:data.uname;
			if (uName &&(data.uid == null || data.uid < 0)){
				//NPC
				if (uName.charAt(0) == '$'){
					//特殊NPC，使用配置文字（可自动补充国家串）
					uName = uName.substr(1);
					if (Tools.hasMsgById(uName)){
						uName = Tools.getMsgById(uName, [Tools.getMsgById('country_' + data.country)]);
					}
				}
			}
			return uName;
		}
		
		/**
		 * unit单体主动承受效果（含受伤和buff叠加）返回出招前弹字用时
		 */
		public static function showInfo(unit:IClientUnit, unitObj:Object, effObj:Object, delay:int, comboNum:int = 1):int
		{
			var fight:ClientFight = unit.getClientFight();
			if (fight == null || fight.isCleared) return 0;
			var i:int;
			var len:int;
			var isFlip:Boolean = unit.isFlip;
			var posX:Number;
			var posY:Number;
			var time:int = 0;
			var tempArr:Array;
			
			if (unit is ClientHero)
			{
				posX = unit.getPosX() + (unit.isFlip ? -50 : 50);
				posY = -10;
			}
			else
			{
				posX = unit.getPosX();
				posY = -100;
			}
			
			//弹出承受型文字
			var infosArr:Array = unitObj.infos;
			
			if (infosArr != null)
			{
				len = infosArr.length;
				var wordArr:Array = [];
				//var beastArr:Array = [];
				
				for (i = 0; i < len; i++)
				{
					var infoArr:Array = infosArr[i];
					var info:String = infoArr[0];
					var infoType:int = infoArr[1];
					var level:int = infoArr[2];
					var colorType:int;
					var isBurn:* = infoArr[3];
					var tempTime:int;
					
					if (infoType == 0)
					{
						//忽略
					}
					else if (infoType == 1)
					{
						//word
						if (unit is ClientAdjutant)
						{
							colorType = FightViewUtils.getColorTypeSkill(level, 8);
						}
						else{
							colorType = FightViewUtils.getColorTypeSkill(level);
						}
						
						wordArr.push([info, colorType, isBurn]);
					}
					else if (infoType == 2)
					{
						//技能bannner文字
						//英雄技音效
						FightTime.playSound('fireHero1',0.6, delay - 200);
						
						var hid:String;
						if (unit is ClientAdjutant)
						{
							hid = (unit as ClientAdjutant).id;
							colorType = FightViewUtils.getColorTypeSkill(level, 7);
						}
						else{
							hid = unit.getClientTroop().hid;
							colorType = FightViewUtils.getColorTypeSkill(level);
						}
						
						if (effObj.noImg)
						{
							hid = null;
						}
						tempTime = 2000;
						if (effObj.bannerTime)
						{
							tempTime = effObj.bannerTime;
						}
						fight.fightMain.ui.infoLayer.addChild(new ViewFightBannerSkill(hid, info, isFlip, colorType, tempTime, isBurn));
						time += 200;
						delay += 200;

					}
					else if (infoType == 3)
					{
						//合击音效
						FightTime.playSound('fireHero2', 0.9, delay - 100);
						
						var fateArr:Array;
						if (effObj.fate)
						{
							fateArr = (effObj.fate as Array).concat();
						}
						else
						{
							fateArr = [];
						}
						fateArr.unshift(unit.getClientTroop().heroLogic.id);
						//合击技
						fight.fightMain.ui.infoLayer.addChild(new ViewFightFate(fateArr, info, isFlip));
						time += 2400;
						delay += 2400;
					}
					else if (infoType == 4)
					{
						//兽灵技能文字
						//beastArr.push([info,isBurn]);
						//beastArr.push(info);
						//beastArr.push(info);
						//beastArr.push(info);
						
						var infoExtra:String = effObj.beast;
						var infoTgt:String= effObj.beastTgt?Tools.getMsgById('rslt_army[' + effObj.beastTgt[1] + ']'):'';

						tempTime = 3000;
						colorType = 4;
						fight.fightMain.ui.infoLayer.addChild(new ViewFightBeastSkill(info.substring(info.length-1), info, infoExtra, infoTgt, isFlip, colorType, tempTime, 0));
						time += 200;
						delay += 200;
					}
				}
				
				//hurtDelay = delay;
				len = wordArr.length;
				for (i = 0; i < len; i++)
				{
					tempArr = wordArr[i];
					new FWord(fight.fightMain.scene, tempArr[0], posX, posY + i * 40, 50, isFlip, tempArr[1], tempArr[2], delay + i * 200);
					time += 100;
					delay += 100;
				}
				
			}
			//time = Math.max(wordNum * 300, bannnerNum *500, fateNum *1500);
			
			if (effObj.comp)
			{
				var compArr:Array = effObj.comp;
				len = compArr.length;
				//有拼点结果
				var hero0:ClientHero = fight.getClientTroop(0).getClientHero();
				var hero1:ClientHero = fight.getClientTroop(1).getClientHero();
				for (i = 0; i < len; i++)
				{
					var compOneArr:Array = compArr[i];
					var compKey:String = compOneArr[0];
					fight.fightMain.ui.infoLayer.addChild(new ViewFightCompare(hero0[compKey], hero1[compKey], compKey, compOneArr[1], i));
				}
			}
			if (effObj.bash)
			{
				//猛击
				fight.fightMain.ui.infoLayer.addChild(new ViewFightBash(isFlip));
			}
			
			//弹出伤害数字，更新人数千分比，播放死亡动作
			var hurtArr:Array = unitObj.hurt;
			var hurtObj:Object = effObj.hurt;
			var buffArr:Array = unitObj.buffs;
			var removeBuffArr:Array = unitObj.removeBuffs;
			var damageType:int = 0;		//类型 0普通 1暴击 -1格挡 3治疗 4护盾
			
			if (hurtArr != null)
			{
				if (unit is ClientArmy)
				{
					var army:ClientArmy = unit as ClientArmy;
					
					if (hurtObj)
					{
						FightTime.delayTo(delay, army, army.addSpecialEffect, [hurtObj]);
						if (hurtObj.hitTime)
						{
							delay += hurtObj.hitTime;
						}
						
						FightViewUtils.autoPlaySound(hurtObj, delay, 'sound', 1 - comboNum * 0.1);
						
						//if (hurtObj.res){
							//FightTime.playSound(hurtObj.res, 1-comboNum*0.1, delay);
						//}
					}
					
					//hurtDelay += army.armyIndex * 100;
					if (!effObj.noHurt)
					{
						var damageLv:int;
						var damage:int = hurtArr[0];
						damageType = hurtArr[1];
						var damageInfo:String = damage.toString();
						var damagePer:Number = damage / army.hpm;
						if (damageType == 3){
							//绿色中字，治疗
							damageLv = 5;
							damageInfo = '+' + (-damage);
							//FightTime.playSound('fire231', 1, delay);
						}
						else if (damageType == 4){
							//粉色中字，护盾
							damageLv = 6;
							damageInfo = '' + damage;
							//FightTime.playSound('fire231', 1, delay);
						}
						else{
							//damageType-1格挡 0正常 1暴击 2自损 3治疗
							if (damagePer < 0.05)
							{
								//白色小字
								damageLv = 0;
							}
							else if (damagePer < 0.2)
							{
								//白色中字
								damageLv = 1;
							}
							else if (damagePer < 0.4)
							{
								//黄色中字
								damageLv = 2;
							}
							else if (damagePer < 0.6)
							{
								//橙色大字
								damageLv = 3;
							}
							else
							{
								//红色大字
								damageLv = 4;
							}

							if (damage && hurtObj){
								if (damagePer < 0.2)
								{
									//小声惨叫
									FightTime.playSound('dead2', damagePer * 2 + 0.3, delay);
								}
								else if (damagePer < 0.6)
								{
									//中声惨叫
									FightTime.playSound('dead2', 0.9, delay);
									FightTime.playSound('dead3', 0.8, delay + 100);
								}
								else
								{
									//大声惨叫
									FightTime.playSound('dead2', 1, delay);
									FightTime.playSound('dead3', 1, delay + 100);
								}
								
								if (army.lastHp <= 0){
									//阵亡
									FightTime.playSound('dead1', 0.7, delay + 200);
								}
							}
						}

						if (!hurtObj || !hurtObj.noNum){
							//弹出数字
							var dmgPosX:Number = posX + (isFlip ? -15 : 15) * (comboNum % 2 == 1 ? 1 : -1) + Math.random() * 20 - 10;
							//var dmgPosY:Number = 0;
							var dmgPosY:Number = -150 + comboNum * 10;
							var dmgPosZ:Number = 100 + Math.random() * 20 - 10 - comboNum * 50;
							new FDamage(fight.fightMain.scene, damageInfo, dmgPosX, dmgPosY, dmgPosZ, isFlip, damageLv, damageType, delay);
						}
					}
				}
				else if (unit is ClientHero)
				{
					if (hurtObj)
					{
						if (hurtObj.hitTime)
						{
							delay += hurtObj.hitTime;
						}
					}
				}
				
				if (removeBuffArr)
				{
					//遍历移除buff
					len = removeBuffArr.length;
					for (i = 0; i < len; i++)
					{
						FightTime.delayTo(delay, unit, unit.removeBuff, [removeBuffArr[i]]);
					}
				}
				if (buffArr)
				{
					//遍历追加buff
					len = buffArr.length;
					for (i = 0; i < len; i++)
					{
						FightTime.delayTo(delay, unit, unit.addBuff, [buffArr[i]]);
					}
				}
				
				//受伤前，将防御动作和效果弹出
				FightTime.delayTo(Math.max(0, delay - 500), unit, unit.defense, [hurtObj]);
				FightViewUtils.autoPlaySound(hurtObj, delay - 500, 'defSound');
				
				//FightTime.timer.clearAll();
				FightTime.delayTo(delay, unit, unit.changeHp, [hurtArr[2], hurtObj, true, damageType != 3]);
			}
			return time;
		}
		
		/**
		 * 自动播放对象内的音效
		 */
		public static function autoPlaySound(obj:Object, delay:int, key:String = 'sound', volume:Number = 1):void
		{
			if(obj){
				var res:String = obj[key];
				if (res){
					volume *= obj[key + 'Volume']?obj[key + 'Volume']:1;
					delay += obj[key + 'Delay']?obj[key + 'Delay']:0;
					FightTime.playSound(res, volume, delay);
				}
			}
		}
		
		/**
		 * 单个部队的激励加成显示
		 */
		public static function showSpirit(fight:ClientFight, clientTroop:ClientTroop, obj:Object):void
		{
			if (fight == null || fight.isCleared) return;
			
			fight.fightMain.ui.infoLayer.addChild(new ViewFightSpirit(obj.arr, obj.data, clientTroop.isFlip, 2000));
		}
		
		/**
		 * 单个部队的幕府加成显示
		 */
		public static function showShogun(fight:ClientFight, clientTroop:ClientTroop, arr:Array, delay:int):void
		{
			if (fight == null || fight.isCleared) return;
			var posX:Number = clientTroop.posX;
			//var posX:Number = (clientTroop.heroLogic as ClientHero).getPosX();
			var offsetX:Number = clientTroop.isFlip ? 80 : -80;
			var len:int = arr.length;
			
			new FShogun(fight.fightMain.scene, Tools.getMsgById('shogun_add'), '', posX, 0, 150, '#cc5500', delay, 3400);
			
			posX -= offsetX;
			delay += 800;
			for (var i:int = 0; i < len; i++)
			{
				var value:Number = arr[i];
				if (value)
				{
					var info:String;
					var valueStr:String;
					if (i == 0)
					{
						info = clientTroop.getClientHero().getShogunName();
					}
					else
					{
						info = clientTroop.getClientArmy(i - 1).getShogunName();
					}
					
					//info = info + '\n+' + Tools.percentFormat(value);
					valueStr = '+' + Tools.percentFormat(value);
					
					var color:String = '#2bc000';
					if (ConfigServer.effect.shogunColorArr){
						var shogunColorArr:Array = ConfigServer.effect.shogunColorArr;
						var j:int;
						var jLen:int = shogunColorArr.length;
						for (j = 0; j < jLen; j++) 
						{
							if (value >= shogunColorArr[j]){
								color = ConfigColor.FONT_STROKE_COLORS[j];
							}else{
								break;
							}
						}
					}
					
					new FShogun(fight.fightMain.scene, info, valueStr, posX + i * offsetX, 0, 120, color, delay + i * 400, 1800 + 800 - i * 400);
				}
			}
		}
		
		/**
		 * 合并特效对象
		 */
		public static function getEffectObj(effArr:Array):Object
		{
			var effStr:String;
			var effObj:Object;
			if (!effArr || effArr.length == 0)
			{
				effArr = ['effDefault'];
			}
			if (effArr[0] is String)
			{
				effStr = effArr[0];
				if (!ConfigServer.effect.hasOwnProperty(effStr))
				{
					effStr = 'effDefault';
				}
				effObj = ConfigServer.effect[effStr];
			}
			else
			{
				effObj = effArr[0];
			}
			
			var len:int = effArr.length;
			if (len > 1)
			{
				effObj = FightUtils.clone(effObj);
				for (var i:int = 1; i < len; i++)
				{
					effStr = effArr[i];
					if (ConfigServer.effect.hasOwnProperty(effStr))
					{
						effObj = FightViewUtils.mergeObj(effObj, ConfigServer.effect[effStr]);
					}
					
				}
			}
			return effObj;
		}
		
		/**
		 * 提取特效对象中所有资源id到指定对象
		 */
		public static function pickEffectRes(effStr:String, loadObj:Object, pickArray:Array, loadObj2:Object, num:int):void
		{
			if (!ConfigServer.effect.hasOwnProperty(effStr))
			{
				return;
			}
			
			var effObj:Object = ConfigServer.effect[effStr];
			for (var i:int = pickArray.length - 1; i >= 0; i--)
			{
				var key:String = pickArray[i];
				var value:* = FightUtils.getValueByPath(effObj, key);
				if (value)
				{
					loadObj[value] = 1;
					loadObj2[value] = num;
				}
			}
		}
		
		/**
		 * 向A中合并所有B的字段，只覆盖
		 */
		public static function mergeObj(srcObj:Object, extraObj:Object):Object
		{
			if (extraObj is String || extraObj is Number)
			{
				return extraObj;
			}
			else if (!(extraObj is Array))
			{
				for (var key:String in extraObj)
				{
					if (srcObj.hasOwnProperty(key))
					{
						srcObj[key] = mergeObj(srcObj[key], extraObj[key]);
					}
					else
					{
						srcObj[key] = extraObj[key];
					}
				}
			}
			return srcObj;
		}
		
		/**
		 * 得到两个回合之间的站位偏移
		 */
		public static function getRoundOffset(round0:int, round1:int):Number
		{
			var len:int = ConfigFightView.ROUND_OFFSET.length;
			round0 = Math.min(len - 1, round0);
			round1 = Math.min(len - 1, round1);
			return ConfigFightView.ROUND_OFFSET[round1] - ConfigFightView.ROUND_OFFSET[round0];
		}
		
		/**
		 * 震屏
		 */
		public static function shockSpr(time:int, spr:Sprite):void
		{
			var offsetBase:Number = Math.sqrt(time) * 0.6 + 6;
			var duration:int = 60;
			var num:int = Math.ceil(time / duration);
			var delay:int = 0;
			var tempX:Number;
			var tempY:Number;
			var offset:Number;
			var radians:Number = Math.random() * Math.PI * 2;
			
			for (var i:int = 0; i < num; i++)
			{
				offset = offsetBase * (1 - i / num);
				tempX = Math.cos(radians) * offset;
				tempY = Math.sin(radians) * offset;
				if (i == 0)
				{
					Tween.to(spr, {x: tempX, y: tempY}, duration, Ease.sineOut, null, delay);
				}
				else
				{
					Tween.to(spr, {x: tempX, y: tempY}, duration, Ease.sineInOut, null, delay);
				}
				
				delay += duration * (1 + i / num);
				radians += Math.PI + Math.random() - 0.5;
			}
			Tween.to(spr, {x: 0, y: 0}, duration, Ease.sineIn, null, delay);
		
		}
	}

}