/**
 * 结点类
 * @author light
 * @since 2010-10-16 0:04
 */

package sg.map.model.astar{
	import laya.maths.Point;
	import sg.scene.model.MapGrid;
	import sg.scene.model.entitys.EntityBase;
	import sg.map.model.entitys.EntityCity;
	
	public class AstarNode {		
		
//———————————————————————————以下是public属性—————————————————————————————————————————————		
		/**
		 * 单位X
		 */
		public var unitsX:int;
		
		/**
		 * 单位Y
		 */
		public var unitsY:int;
		
		/**
		 * 总代价
		 */
		public var f:Number;
		
		/**
		 * 结点代价
		 */
		public var g:Number;
		
		/**
		 * 估计代价
		 */
		public var h:Number;
		
		/**
		 * 是否能够通过 ture 能通过 false 不能通过
		 */
		public var walkable:Boolean = false;
		
		/**
		 * 父级结点
		 */
		public var parent:AstarNode;
		
		/**
		 * 代价增加量
		 */
		public var costMultiplier:Number = 1.0;
		
		public var grid:MapGrid;
		
		public var city:EntityCity;
		
//——————————————————————————————————————以下是方法————————————————————————————————————
		/**
		 * 构造函数
		 * @param	unitsX 单位X
		 * @param	unitsY 单位Y
		 */
		public function AstarNode(unitsX:int, unitsY:int) {
			this.unitsX = unitsX;
			this.unitsY = unitsY;
		}
	}
}