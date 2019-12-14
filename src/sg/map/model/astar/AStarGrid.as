/**
 * 格子类（抽象）
 * @author light
 * @since 2010-10-16 0:02
 */

package sg.map.model.astar{
	import laya.maths.Point;
	
	public class AStarGrid {
		
//————————————————————————————————————以下是private属性——————————————————————————————
		/**
		 * 结点数组
		 */
		private var nodeArray:Array = [];
		
//————————————————————————————————————以下是public属性————————————————————————————————
		/**
		 * 开始结点
		 */
		public var startNode:AstarNode;
		
		/**
		 * 终点结点
		 */
		public var endNode:AstarNode;	
		
		/**
		 * 列
		 */
		public var columns:int;
		
		/**
		 * 行
		 */
		public var rows:int;

//——————————————————————————————————以下是方法—————————————————————————————————————————————
		/**
		 * 构造函数
		 * @param	columns 列
		 * @param	rows 行
		 */
		public function AStarGrid() {
			
		}
		
		public function setNode(unitsX:int, unitsY:int):AstarNode {
			if (this.nodeArray[unitsX] == null) this.nodeArray[unitsX] = [];
			if (this.nodeArray[unitsX][unitsY] == null) {
				var node:AstarNode = new AstarNode(unitsX, unitsY);
				this.nodeArray[unitsX][unitsY] = node;
			}else {
				//trace("重复设置格子信息", unitsX, unitsY);
			}
			return this.nodeArray[unitsX][unitsY];
		}
		
		

//——————————————————————————————————————以下是public方法——————————————————————————————————
		/**
		 * 得到结点
		 * @param	unitsX 单位X
		 * @param	unitsY 单位Y
		 * @return 结点
		 */
		public function getNode(unitsX:int, unitsY:int):AstarNode {
			if (this.nodeArray[unitsX] != null && this.nodeArray[unitsX][unitsY] != null) return this.nodeArray[unitsX][unitsY] as AstarNode;
			return null;
		}
		
		public function canWalkable(unitsX:int, unitsY:int):Boolean {
			if (this.nodeArray[unitsX] != null && this.nodeArray[unitsX][unitsY] != null && this.getNode(unitsX, unitsY).walkable) return true;
			return false;
		}
		
		/**
		 * 设置终点
		 * @param	unitsX 单位X
		 * @param	unitsY 单位Y
		 */
		public function setEndNode(unitsX:int, unitsY:int):void {
			this.endNode = this.nodeArray[unitsX][unitsY] as AstarNode;
		}
		
		/**
		 * 设置起点
		 * @param	unitsX 单位X
		 * @param	unitsY 单位Y
		 */
		public function setStartNode(unitsX:int, unitsY:int):void {
			this.startNode = this.nodeArray[unitsX][unitsY] as AstarNode;
		}
		
		/**
		 * 设置障碍点
		 * @param	unitsX 单位X
		 * @param	unitsY 单位Y
		 * @param	value true代表能通过 false 代表不能通过
		 */
		public function setWalkable(unitsX:int, unitsY:int, value:Boolean):void {
			this.nodeArray[unitsX][unitsY].walkable = value;
		}
	}
}