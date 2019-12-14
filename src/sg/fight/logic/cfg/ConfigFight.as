package sg.fight.logic.cfg 
{
	import sg.cfg.ConfigServer;
	import sg.fight.logic.utils.FightUtils;
	/**
	 * 战斗配置，为了能点出引用
	 * @author zhuda
	 */
	public class ConfigFight 
	{
		public static const ACT_CHECK_BUFF:int = -1;        //每回合行动前buffManager检查阶段
		public static const ACT_CHECK_END:int = -2;        //每回合行动后buffManager检查阶段
		
		public static const ACT_FIRST:int = 0;
		public static const ACT_MAIN:int = 1;
		public static const ACT_ATK_BFR:int = 2;
		public static const ACT_ATK_AFT:int = 3;
		public static const ACT_HIT_BFR:int = 4;
		public static const ACT_HIT_AFT:int = 5;
		public static const ACT_BUFF:int = 6;		//回合开始，执行buff绑定动作
		public static const ACT_HERO:int = 7;       //对方英雄技能
		public static const ACT_WIN:int = 8;
		public static const ACT_LOSS:int = 9;
		public static const ACT_PRE:int = 10;        //每回合早于Buff，用于急救治疗和净化buff的
		public static const ACT_DEBUFF_FAIL:int = 11;        //对敌方施加不良状态，且未成功时
		public static const ACT_ASSIST:int = 12;        //对方欲发动任意触发型辅助技能时
		public static const ACT_ROUND:int = 13;        //每个大回合重置阶段（无视速度）需要执行的动作
		
		///每回合需要清理的动作数组
		public static const ACT_ROUND_ARRAY:Array = [13, 10, 0, 6, 1, 2, 3, 4, 5, 7, 11, 12];
		///每回合主动回合开始，需要遍历的动作数组
		public static const ACT_ACTIVE_ARRAY:Array = [10, -1, 0, 6, 1, -2];
		
		///0起始 1主 2攻前 3攻后 4防前 5防后 6状态 7对方英雄技 8战胜 9战败 10急救净化 11施加debuff失败 12对方触发型辅助技能 13大回合重置  -1每回合buffManager检查阶段
		public static const ACT_NUM:int = 14;
		
		///国战前端堆积超过几条战报，就直接跳过战斗（堆积1条以上都使用极速播放）
		public static var fightSkipNum:Number;
		
		///战斗最大速率，超过该速率直接跳过
		public static var fightMaxSpeed:Number;
		///战斗2倍速的实际速率
		public static var fightHighSpeed:Number;
		///战斗1倍速的实际速率
		public static var fightLowSpeed:Number;
		///战斗超过此倍速，不再震屏
		public static var fightShockSpeed:Number;

		///战斗开启音效（同时需要用户音效打开）
		public static var fightOpenSound:Boolean;
		///战斗开始毫秒
		public static var fightStartTime:int;
		///战斗展示激励时间
		public static var fightSpiritTime:int;
		///战斗展示幕府时间
		public static var fightShogunTime:int;
		///战斗中大回合重置动作耗费毫秒
		public static var fightResetRoundTime:int;
		///战斗中每个回合间隔时间毫秒
		public static var fightRoundTime:int;
		///战斗中每个动作间隔时间毫秒
		public static var fightActionTime:int;
		///战斗中被无懈的动作间隔时间毫秒
		public static var fightStopActionTime:int;
		///战斗最终互怼时间
		public static var fightCutTime:int;

		///对应每个回合的伤害系数
		public static var roundDmgArr:Array;
		///开战前兵力比例具备的攻击力千分率，占比当前的比例，(越大越能缓解后手劣势)
		public static var initHpPerPoint:int;

		///最大战斗回合数，超过此回合数，双方怼光剩余兵力，仍生存者胜（相同时守方胜）
		public static var roundMax:int;
		///千分率1000
		public static var ratePoint:Number;
		///暴击或格挡大于此值时，认为必定发生
		public static var maxPoint:Number;
		///免伤等负值的最小值，避免为-1000以下变为异常或加血
		public static var minPoint:Number;
		
		///!!!!!!!!!!!!!!每点防御的倍率
		public static var defValuePer:Number;
		///!!!!!!!!!!!!!!最小伤害千分率
		public static var damageMinPer:Number;
		///!!!!!!!!!!!!!!通用结算伤害千分率
		public static var damageOutPer:Number;
		///兵力仅剩0%时，仍具备的攻击力千分率，线性过渡到满
		public static var attackMinPoint:Number;
		///!!!!!!!!!!!!!!所有被击杀的兵力中，转化为可治疗伤兵的比例
		public static var woundedPer:Number;
		///!!!!!!!!!!!!!!pkDamagePoint玩家间对抗，普通伤害系数
		public static var pkDamagePer:Number;
		///!!!!!!!!!!!!!!pkShogunPoint玩家间对抗，幕府效果只生效部分（新增）
		public static var pkShogunPer:Number;
		
		
		///暴击伤害倍数（不影响真实伤害）
		public static var critRate:int;
		///格挡伤害倍数（不影响真实伤害）
		public static var blockRate:int;
		///触发暴击时，可额外消灭{0}名士兵
		public static var critAdd:int;
		///触发格挡时，可额外保全{0}名士兵
		public static var blockAdd:int;

		
		///新进玩家部队应该被插入的位置插入参数N。插入到max(玩家尾,min(队尾，N))
		public static var troopInsertIndex:Number;
				
		///每点傲气降低所有技能释放千分点，降低的上限
		public static var proudActionRate:Array;
		///每点疲劳降低攻防atkRate defRate千分点效果，非buff，降低的上限
		public static var proudTiredRate:Array;
		///每1.0(100%)幕府在战斗开始buff,提升的攻击atkRate、防御defRate、破攻、破防千分点
		public static var shogunRate:Array;
		///每1.0(100%)英雄幕府，提升的外层属性
		public static var shogunHeroRate:Object;
		///每1.0(100%)兵种幕府，提升的内层属性
		public static var shogunArmyRate:Object;
		
		///国家官职对应的攻防加成千分点
		public static var officialRate:Object;
		///每城市buff,1.0(100%)在战斗中影响的含真实伤害提升减少比率
		public static var cityBuffRate:Array;
		
		///兽灵低兵力比例
		public static var beastHpLow:Number;	
		///兽灵高兵力比例
		public static var beastHpHigh:Number;
		///兽灵中穿透防御和临时防御100%，对于伤害值增量的价值
		public static var beastDefPer:Number;	
		///兽灵中穿透防御最高导致单项伤害率变化
		public static var beastDefDmgMax:Number;
		///兽灵中穿透防御最低导致单项伤害率变化
		public static var beastDefDmgMin:Number;	
		///兽灵中拼点的压制基准值
		public static var beastCompPoint:int;	
		

		///兽灵副属性解锁等级
		public static var beastSuperUnlock:Array;	
		///兽灵对应技能的转化默认Passive
		public static var beastSuperSkillDefaultPassive:Object;
		///兽灵对应技能的转化值，在战前checkSpecial之前合并
		public static var beastSuperSkill:Object;
		///兽灵，可检查套装共鸣的数量
		public static var beastResonance:Array;
		///兽灵，副属性值对应的效果等级和颜色
		public static var beastSuperValue:Array;
		///兽灵，不同门的等级获得的升级属性
		public static var beastLv:Array;
		
		///宝物强化，对应不同位置的额外属性
		public static var equipRise:Object;
		
		///战败技能，仅当克制情况释放，如果被禁用则不可用
		public static var loserAct:Object;
		///拥有特殊能力的副将英雄
		public static var adjutantSpecial:Object;
		///副将宝物总评分，计算出最终对副将技能加成强度
		public static var adjutantEquipDmgFinal:Array;
		///副将宝物总评分，对原英雄总加成
		public static var adjutantEquipScore:Array;
		
		///前后军部队数量
		public static var armyNum:int;
		///兵种强化数量
		public static var armyAddNum:int;
		
		
		
		///比武大会、蓬莱寻宝中，战报早于此时间的强制不可回放
		public static var playbackChangeDate:Object;
		///比武大会、蓬莱寻宝中，最长可回放战报的分钟数
		public static var playbackMaxMinute:int;
		
		
		///某种模式的战斗，包含Playback战报（用于调试对比）
		public static var testPlaybackMode:int;
		///支持打印的type
		public static var printTypes:Object;
		///可忽略而不进入回放显示的能量标记
		public static var ignoreEnergyTypes:Object;
		
		///ModelPrepare初始化非战斗对象时，skill包含的内容
		public static var skillOnly:Object;
		///ModelPrepare初始化战斗对象时，skill包含的内容（special不能用limit检查，要在战前cond内检查）
		public static var skillOnlyFight:Object;
		///skill在战前展开act，skill包含的内容
		public static var skillOnlyFightAct:Object;
		
		///被动属性排序（仅显示）
		public static var passiveSortArr:Array;
		///需要增加前后军前缀的属性（仅显示）
		public static var propertyArmyArr:Array;
		///需要遍历的二级属性
		public static var propertySecondLevelArr:Array;
		///最简式时，遍历的属性，为0的可以删除
		public static var propertySimplestArr:Array;
		///需要转移的二级属性（不转移技能伤害）
		public static var propertyTransformArr:Array;
		///战斗单位有的属性
		public static var propertyUnitArr:Array;
		///攻击者有的属性
		public static var propertyAttackerArr:Array;
		///英雄最终数据中舍弃的属性
		public static var propertyDeleteArr:Array;
		
		
		///需要混合Rate和Base的二级属性
		public static var propertyMergeArr:Array;
		///需要对比英雄配置，删除的默认属性
		public static var propertyHeroDefaultArr:Array;
		///计算战力默认属性值
		public static var propertyDefaultData:Object;
		///包装战斗部队默认属性值
		public static var propertyFightDefaultData:Object;
		
		///战报文字信息可能的key
		//public static var playbackInfoArr:Array;
		
		
		///默认行为
		public static var actDefault:Object;
		///官职passive效果，含精英或大将
		public static var official:Object;

		///星辰属性，对应属性加成=a+b*(x-c)，如果数组长度为4则取兵种，长度为2取前后军，长度为1全体加成
		//public static var starTransform:*;
		
		
		///拥有传奇天赋的英雄，按其星级对应所有部队属性加成
		public static var legendTalent:Object;
		///拥有参战传奇天赋的英雄，按其星级对应所有部队属性加成
		public static var legendTalentFight:Object;
		
		///玩家间对抗，战力每有1点差距时，给与弱势方援助
		public static var pkAid:Array;
				
		///特定标记数量变化时，立即变化的buff效果
		public static var energyBuff:Object;
		///对应不同buff类型的固有默认值，战斗中加入。包含优先级，防止单个行动加入时乱序，使随机数错
		public static var buffDefault:Object;
		
		///擂台战，如果守擂者胜出，清除所有疲劳，遍历所有部队前后军，少于10%兵力的，补充到10%兵力
		public static var arenaWinnerHpPer:Number;
		///擂台战，攻擂者每击杀擂主1%的兵力，获得2%的额外奖励，上限100%
		public static var arenaReward:Array;
		
		///对应不同战斗类型的特别描述
		public static var battleMode:Object;
		
		///一级属性转化兵种二级属性，对应属性加成=a+b*(x-c)，如果数组长度为4则取兵种，长度为2取前后军，长度为1全体加成
		public static var propertyTransform:*;
		///用于计算战力的属性,对A、B、C型的加值，最终战力= A基础 * B比率（千分点） + C固定。通过passive加入的战力都为C类型
		public static var powerValue:*;
		
		///不同技能类型的额外进阶效果
		public static var skillTypeLv:*;
		///兵种普攻触发器,步骑弓方
		public static var armyActMainArr:Array;
		
		///箭楼
		public static var towerAct0:Object;
		///石炮
		public static var towerAct1:Object;
		

		//！！！！！！！！！！！！！！！！！！！！！！！！以下为测试专用配置
		///审核版号时，专用的章节关卡信息
		public static var testChapter:Array;
		
		///福将挑战关卡
		public static var testBlessPart:Array;
		
		///测试模拟次数
		public static var testStatisticsNum:int;
		///测试专用配置，可选特殊模式
		public static var testModes:Array;
		///测试专用配置，可选英雄
		public static var testHids:Array;
		///测试专用配置，预设宝物
		public static var testEquips:Array;
		///测试专用配置，预设星辰
		public static var testStars:Array;
		///测试专用配置，预设科技
		public static var testSciences:Array;
		///测试专用配置，可选副将
		public static var testAdjutants:Array;
		///测试专用配置，预设官职
		public static var testOfficials:Array;
		///测试专用配置，预设称号
		public static var testTitles:Array;
		///测试专用配置，预设传奇
		public static var testLegends:Array;
		///测试专用配置，预设阵法
		public static var testFormations:Array;
		///测试专用配置，预设激励
		public static var testSpirits:Array;
		
		///测试专用配置，预设兵力比例
		public static var testHpPoints:Array;
		///测试专用配置，预设傲气
		public static var testProuds:Array;
		

		///测试专用配置，内政技能
		public static var testPoliticsSkills:Object;
		
		///测试专用配置，八门兽灵
		public static var testBeasts:Array;
		///测试专用配置，八门兽灵可选套装类别
		public static var testBeastTypes:Array;
		///测试专用配置，八门兽灵可选品质
		public static var testBeastStars:Array;
		///测试专用配置，八门兽灵可选等级
		public static var testBeastLvs:Array;
		///测试专用配置，八门兽灵可选副属性类别
		public static var testBeastSupers:Array;
		///测试专用配置，八门兽灵可选副属性值
		public static var testBeastSuperValues:Array;
		
		
		///测试专用配置，可选技能
		public static var testSkills:Array;
		///测试修改初始化数据 [英雄 星级 等级 技级 兵段 兵阶 兵科]
		public static var testInitArr:Array;
		///测试不同阶段的数据 [星级 等级 技级 兵段 兵阶 兵科]
		public static var testLvArr:Array;
		///测试不同阶段预设的数据 [星级 等级 技级 兵段 兵阶 兵科]
		public static var testLvArr2:Array;
		///对应指定英雄，或者品质英雄的技能适配（英雄技和辅助技）
		public static var testDefaultSkills:Object;
		
		///测试专用配置，可以指定战斗双方的初始化数值
		public static var testFightInit:Array;
		///测试专用配置，可以指定战斗双方的初始化数值
		public static var testBattle:Object;
		///设定每个切磋阵列的预设英雄, 1为开启
		public static var testTable:Array;
		
		
		public static function init():void {
			var data:* = ConfigServer.fight;
			for(var key:String in data)
			{
				if(ConfigFight.hasOwnProperty(key)){
					ConfigFight[key] = data[key];
				}
			}
			ConfigFight.defValuePer = FightUtils.pointToPer(data.defValuePoint);
			ConfigFight.damageMinPer = FightUtils.pointToPer(data.damageMinPoint);
			ConfigFight.damageOutPer = FightUtils.pointToPer(data.damageOutPoint);
			ConfigFight.woundedPer = FightUtils.pointToPer(data.woundedPoint);
			ConfigFight.pkDamagePer = FightUtils.pointToPer(data.pkDamagePoint);
			ConfigFight.pkShogunPer = data.pkShogunPoint?FightUtils.pointToPer(data.pkShogunPoint):1;
		}

		
		public static function getBattleSpecial(mode:int):Object {
			if (ConfigFight.battleMode){
				var modeCfg:Object = ConfigFight.battleMode[mode];
				if (modeCfg){
					return modeCfg.battle_special;
				}
			}
			return null;
		}
	}

}