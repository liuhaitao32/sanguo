package sg.fight.logic.utils
{
	
	/**
	 * 战斗用随机数生成器
	 * @author zhuda
	 */
	public class FightRandom
	{
		public static const NUM_1:int = 239641;
		public static const NUM_2:int = 6700417;
		public static const NUM_3:int = 9991;
		private static const POINT:Number = 1000;
		
		public var seedBase:int;
		public var seed:int;
		public var seedNum:int;
		
		public function FightRandom(seed:int, seedBase:int = -1, seedNum:int = -1)
		{
			this.initSeed(seed, seedBase, seedNum);
		}
		
		/**
		 * 初始化种子
		 */
		public function initSeed(seed:int, seedBase:int = -1, seedNum:int = -1):void
		{
			if (seedBase < 0)
			{
				seedBase = seed;
			}
			if (seedNum < 0)
			{
				seedNum = 0;
			}
			this.seed = seed;
			this.seedBase = seedBase;
			this.seedNum = seedNum;
		}
		
		/**
		 * 生成下一个随机种子
		 */
		private function nextSeed():int
		{
			this.seed = (this.seed * NUM_3 + NUM_2) % NUM_1;
			this.seedNum++;
			return this.seed;
		}
		
		/**
		 * 返回一个随机数，0~1之间
		 */
		public function getRandom():Number
		{
			return this.nextSeed() / NUM_1;
		}
		
		/**
		 * 返回一个在指定范围内的随机整数（含下上限）, exp-3~3,越小越会向低比例映射
		 */
		public function getRandomRange(min:int, max:int, exp:Number = 0):int
		{
			return min + this.getRandomInt(max - min, exp);
		}
		
		/**
		 * 返回一个随机整数（0~N含N）
		 */
		//public function getRandomInt(value:int):int
		//{
			//return this.nextSeed() % (value + 1);
		//}
		/**
		 * 返回一个随机整数（0~N含N）, exp 期望-2:0.2, -1:0.29, -0.5:0.37, 0:0.5, 0.5:0.63, 1:0.71, 2:0.8。越小越会向低比例映射
		 */
		public function getRandomInt(value:int, exp:Number = 0):int
		{
			var num:int;
			var rnd:Number = this.getRandom();
			if (!exp){
				//num = Math.round(value * rnd);
				//this.nextSeed() % (value+1);
			}
			else if (exp < 0){
				//低比例提升
				rnd = Math.pow(rnd, 1 - exp);
			}
			else{
				//高比例提升
				rnd = 1-Math.pow(rnd, 1 + exp);
			}
			num = Math.round(value * rnd);

			return num;
		}
		/**
		 * 返回一个随机整数（0~N不含N）
		 */
		public function getRandomIndex(value:int):int
		{
			return this.nextSeed() % (value);
		}
		
		/**
		 * 返回一个随机布尔值
		 */
		public function getRandomBoolean():Boolean
		{
			return this.nextSeed() % 2 == 1;
		}
		
		/**
		 * 返回一个判定结果，命中为true。传入判定千分点0~1000，越大越容易命中
		 */
		public function determine(point:int):Boolean
		{
			if (point >= POINT){
				return true;
			}
			else if (point <= 0){
				return false;
			}
			else if ((this.getRandomInt(POINT-1)) < point){
				return true;
			}
			return false;
		}
	}
}