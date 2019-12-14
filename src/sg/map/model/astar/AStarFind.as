/**
 * AStar寻路类
 * @author light
 * @since 2010-10-16 0:01
 */

package sg.map.model.astar{
	import laya.events.EventDispatcher;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
	import sg.scene.constant.ConfigConstant;
	import sg.map.utils.ArrayUtils;
	
	public class AStarFind extends EventDispatcher {
		
		
//————————————————————————————————————以下是常量——————————————————————————————————————————————	
		/**
		 * 找寻成功的事件常量
		 */
		public static const FIND_PATH:String = "findPath";
		
		/**
		 * 没有找到的路径的事件常量
		 */
		public static const NOT_FIND_PATH:String = "notFindPath";
		
		
//——————————————————————————————————以下是private属性————————————————————————————————————————		
		/**
		 * 待考察表数组
		 */
		private var openListArray:Array;
		
		/**
		 * 已考察表数组
		 */
		private var closedListArray:Array;
		
		/**
		 * 网格
		 */
		private var grid:AStarGrid;
		
		/**
		 * 终点结点
		 */		
		private var endNode:AstarNode;
		
		/**
		 * 起点结点
		 */
		private var startNode:AstarNode;
		
		/**
		 * 最佳路径
		 */
		private var pathArray:Array;
		
		/**
		 * 估价函数 这里曼哈顿算法最快
		 */
		private var evaluation:Function = manhattan;
		//private var evaluation:Function = euclidian;
		//private var evaluation:Function = diagonal;
		
		/**
		 * 相邻代价
		 */
		private var straightCost:Number = 1.0;
		
		/**
		 * 对角代价
		 */
		private var diagonalCost:Number = Math.SQRT2;
		
		/**
		 * 结点
		 */
		private var node:AstarNode;
		
//———————————————————————————————————————————————以下是方法——————————————————————————————————————	

//————————————————————————————————————————————————get属性————————————————————————————————————————
		/**
		 * 取得待考察表
		 */
		public function get openList():Array {
			return this.openListArray;
		}
		
		/**
		 * 取得已考察表
		 */
		public function get closedList():Array {
			return this.closedListArray;
		}
		
		/**
		 * 取得最短路径
		 */
		public function get path():Array {
			return this.pathArray;
		}
//————————————————————————————————————————————构造函数及初始化——————————————————————————————————
		
		
		/**
		 * 设置表格以及结点分布、代价
		 * @param	grid 表格
		 */		
		public function initAStar(grid:AStarGrid):void {
			this.grid = grid;
			//this.openListArray = new Array();
			//this.closedListArray = new Array();
			//this.startNode = this.grid.startNode;
			//this.endNode = this.grid.endNode;
			//this.startNode.g = 0;
			//this.endNode.h = this.evaluation(this.startNode);
			//this.startNode.f = this.startNode.g + this.startNode.h;
			//this.node = this.startNode;
		}

//——————————————————————————————————————以下是private方法——————————————————————————————————————————		
		/**
		 * 建造路径 从endNode开始的父路径寻找
		 */
		private function buildPath():void {
			this.pathArray = [];
			var node:AstarNode = this.endNode;
			this.pathArray.push(node);
			while (node != this.startNode) {
				node = node.parent;
				this.pathArray.unshift(node);
			}
		}
		
		/**
		 * 曼哈顿算法 （笔直的）
		 * @param	node 计算的结点
		 * @return 曼哈顿的路径值
		 */
		private function manhattan(node:AstarNode):Number {
			return Math.abs(node.unitsX - this.endNode.unitsX) * this.straightCost +
					Math.abs(node.unitsY - this.endNode.unitsY) * this.straightCost;
		}
		
		/**
		 * 几何计算法（两点距离）
		 * @param	node 计算的结点
		 * @return 几何计算的路径值
		 */
		private function euclidian(node:AstarNode):Number {
			var dx:Number = node.unitsX - this.endNode.unitsX;
			var dy:Number = node.unitsY - this.endNode.unitsY;
			//两点的最短距离
			return Math.sqrt(dx * dx + dy * dy) * this.straightCost;
		}
		
		/**
		 * 对角线算法
		 * @param	node 计算的结点
		 * @return 对角线的计算路径值
		 */
		private function diagonal(node:AstarNode):Number {
			var dx:Number = Math.abs(node.unitsX - this.endNode.unitsX);
			var dy:Number = Math.abs(node.unitsY - this.endNode.unitsY);
			//计算出结点到终点最小的 dx 或者 dy 乘以对角线代价
			var diag:Number = Math.min(dx, dy);
			return this.diagonalCost * diag + this.straightCost * Math.abs(dy - dx);
		}
		
		/**
		 * 找寻节点周围的城市。
		 * @param	node
		 * @return
		 */
		public function findNearCity(node:AstarNode, close:Array, city:Array):void {
			
			var range:Array = [[0, -1], [1, 0], [0, 1], [ -1, 0]]
			if (close.indexOf(node) != -1) return;
			close.push(node);
			for (var i:int = 0, len:int = range.length; i < len; i++) {
				var testNode:AstarNode = this.grid.getNode(node.unitsX + range[i][0], node.unitsY + range[i][1]);
				if (testNode == null || !testNode.walkable) continue;
				if (testNode.grid.getEntitysByType(ConfigConstant.ENTITY_CITY).length > 0) {
					var entity:EntityCity = testNode.grid.getEntitysByType(ConfigConstant.ENTITY_CITY)[0];
					if (city.indexOf(entity) == -1) city.push(entity);
				}else {
					findNearCity(testNode, close, city);
				}
			}			
			
		}
		
		
		public function checkCity(city:EntityCity):Array {
			var node:AstarNode = null;
			var open:Array = [city];
			var close:Array = [];
			
			while (open.length != 0) {
				var citys:Array = [];
				var cc:EntityCity = EntityCity(open.shift());
				node = cc.mapGrid.node;
				this.findNearCity(node, [], citys);
				ArrayUtils.remove(cc, citys);
				var entity:EntityCity = node.grid.getEntitysByType(ConfigConstant.ENTITY_CITY)[0];
				entity.nearCitys = citys;
				
				close.push(entity);
				citys = citys.filter(function(a:EntityCity, i:int , arr:Array):Boolean{
					return close.indexOf(a) == -1 && open.indexOf(a) == -1;
				});				
				open = open.concat(citys);	
			}
			
			//已经连接成功就在各自的close里。
			return close;
		}
		
		
		/**
		 * 核心函数 查找路径（找寻一次）
		 * @return 找到return true 没找到 return false
		 */		
		public function searchCity(startCity:EntityCity, endCity:EntityCity, pathCost:Object):Boolean {
			this.openListArray = [];
			this.closedListArray = [];
			
			var startNode:AstarNode = startCity.mapGrid.node;
			var endNode:AstarNode = endCity.mapGrid.node;
			this.startNode = startNode;
			this.endNode = endNode;
			this.node = startNode;
			startNode.g = 0;
			endNode.h = this.evaluation(startNode);
			startNode.f = startNode.g + startNode.h;
			
			
			
			while (this.node != endNode) {				
				var nearDist:Object = this.node.city.geAlltNearDist();
				for (var nearCityId:String in nearDist) {					
					var testNode:AstarNode = EntityCity(MapModel.instance.citys[parseInt(nearCityId)]).mapGrid.node;
						//当有结点是自身,不能往下走！就跳过
						if (testNode == this.node || (testNode != endNode && testNode.city.country != this.node.city.country)) {
							continue;
						}
						
						var cost:Number = nearDist[nearCityId].path / ConfigConstant.WAY_DIST_UNIT;
						//如果是对角线则重新赋值
						//相邻结点代价
						var c_c:String = EntityCity.getConnectKey(this.node.city.cityId, testNode.city.cityId);
						var rate:Number = (1 + (pathCost[c_c] ? pathCost[c_c][0] : 0 ));
						
						//临时先这么写一下吧。。。
						if (nearDist[nearCityId].isWall) {
							//这里长城还需要加速一下。 这个赋值之后不确定会不会绕回来。 理论上不会出现这样的问题。。。
							var arrWall:Array = this.node.city.getMarchRate();
							rate += arrWall[0];
							pathCost[c_c] ||= [arrWall[0], 0];
							//pathCost[c_c][1] += arrWall[1];
							
						}
						var g:Number = this.node.g + cost / rate;//乘以代价增加量
						//测试结点到最终结点的代价
						var h:Number = this.evaluation(testNode) * 0.1;
						//总代价值
						var f:Number = g + h;
						
						//判断是否当前节点在待考察表里 或者已考察表里（不需要再push了） 
						if (-1 != this.openListArray.indexOf(testNode) || -1 != this.closedListArray.indexOf(testNode)) {
							if (testNode.f > f) {
								testNode.f = f;
								testNode.g = g;
								testNode.h = h;
								//四周的父类都是中心结点
								testNode.parent = node;
							}
						}else {
							testNode.f = f;
							testNode.g = g;
							testNode.h = h;
							testNode.parent = node;
							this.openListArray.push(testNode);
						}
				}
				
				//--------------------------------------------------------------------------
				
				this.closedListArray.push(node);
				//没有路径在待考察表里 派发事件：NOT_FIND_PATH
				if (this.openListArray.length == 0) {
					return false;
				}
				//排序 取出最小的路径 node（并不是当前node四周的testNode是最短的！）
				this.openListArray.sort(function(n1:AstarNode, n2:AstarNode):int{
					return n1.f - n2.f;
				});
				this.node = this.openListArray.shift();
			}			
			this.buildPath();
			this.pathArray = this.pathArray.map(function(n:AstarNode, index:int , arr:Array):EntityCity{
				return n.city;
			});
			return true;
		}
		
		
//————————————————————————————————————以下是public方法——————————————————————————————————————————
		/**
		 * 核心函数 查找路径（找寻一次）
		 * @return 找到return true 没找到 return false
		 */		
		public function search4(startNode:AstarNode, endNode:AstarNode):Boolean {
			this.openListArray = [];
			this.closedListArray = [];
			
			this.startNode = startNode;
			this.endNode = endNode;
			this.startNode.g = 0;
			this.endNode.h = this.evaluation(this.startNode);
			this.startNode.f = this.startNode.g + this.startNode.h;
			this.node = this.startNode;
			
			var range:Array = [[0, -1], [1, 0], [0, 1], [-1, 0]]
			while (node != this.endNode) {
				
				//------------对该结点四周（四个方向最多）进行比较----------------------------
				for (var i:int = 0, len:int = range.length; i < len; i++) {
					var testNode:AstarNode = this.grid.getNode(node.unitsX + range[i][0], node.unitsY + range[i][1]);
						if (testNode == null) continue;
						//当有结点是自身、或者障碍物、或者临近有障碍物不检测
						if (testNode == this.node || 
							!testNode.walkable || 
							!this.grid.canWalkable(node.unitsX, testNode.unitsY) ||
							!this.grid.canWalkable(testNode.unitsX, node.unitsY)) {
							continue;
						}
						
						//单位1赋值
						var cost:Number = this.straightCost;
						//如果是对角线则重新赋值			
						//相邻结点代价
						var g:Number = node.g + cost * testNode.costMultiplier;//乘以代价增加量
						//测试结点到最终结点的代价
						var h:Number = this.evaluation(testNode);
						//总代价值
						var f:Number = g + h;
						//判断是否当前节点在待考察表里 或者已考察表里（不需要再push了） 
						if (-1 != this.openListArray.indexOf(testNode) || -1 != this.closedListArray.indexOf(testNode)) {
							if (testNode.f > f) {
								testNode.f = f;
								testNode.g = g;
								testNode.h = h;
								//四周的父类都是中心结点
								testNode.parent = node;
							}
						}else {
							testNode.f = f;
							testNode.g = g;
							testNode.h = h;
							testNode.parent = node;
							this.openListArray.push(testNode);
						}
				}
				
				//--------------------------------------------------------------------------
				
				this.closedListArray.push(node);
				//没有路径在待考察表里 派发事件：NOT_FIND_PATH
				if (this.openListArray.length == 0) {
					return false;
				}
				//排序 取出最小的路径 node（并不是当前node四周的testNode是最短的！）
				this.openListArray.sort(function(n1:AstarNode, n2:AstarNode):int{
					return n1.f - n2.f;
				});
				this.node = this.openListArray.shift() as AstarNode;
			}			
			this.buildPath();
			return true;
		}

		/**
		 * 核心函数 查找路径（找寻一次）
		 * @return 找到return true 没找到 return false
		 */		
		public function search8():Boolean {
			while (node != this.endNode) {
				var startX:int = Math.max(0, node.unitsX - 1);
				var endX:int = Math.min(this.grid.columns - 1, node.unitsX + 1);
				var startY:int = Math.max(0, node.unitsY - 1);
				var endY:int = Math.min(this.grid.rows - 1, node.unitsY + 1);
				
				//------------对该结点四周（八个方向最多）进行比较----------------------------
				for (var i:int = startX; i <= endX; i++ ) {					
					for (var j:int = startY; j <= endY; j++ ) {
						var testNode:AstarNode = this.grid.getNode(i, j);
						if (testNode == null) continue;
						//当有结点是自身、或者障碍物、或者临近有障碍物不检测
						if (testNode == node || 
							!testNode.walkable || 
							!this.grid.canWalkable(node.unitsX, testNode.unitsY) ||
							!this.grid.canWalkable(testNode.unitsX, node.unitsY)) {
							continue;
						}
						
						//单位1赋值
						var cost:Number = this.straightCost;
						//如果是对角线则重新赋值
						if (node.unitsX != testNode.unitsX && node.unitsY != testNode.unitsY) {
							cost = this.diagonalCost;
						}					
						//相邻结点代价
						var g:Number = node.g + cost * testNode.costMultiplier;//乘以代价增加量
						//测试结点到最终结点的代价
						var h:Number = this.evaluation(testNode);
						//总代价值
						var f:Number = g + h;
						//判断是否当前节点在待考察表里 或者已考察表里（不需要再push了） 
						if (-1 != this.openListArray.indexOf(testNode) || -1 != this.closedListArray.indexOf(testNode)) {
							if (testNode.f > f) {
								testNode.f = f;
								testNode.g = g;
								testNode.h = h;
								//四周的父类都是中心结点
								testNode.parent = node;
							}
						}else {
							testNode.f = f;
							testNode.g = g;
							testNode.h = h;
							testNode.parent = node;
							this.openListArray.push(testNode);
						}
					}//end for （内层）
				}//end for （外层）
				//--------------------------------------------------------------------------
				
				this.closedListArray.push(node);
				//没有路径在待考察表里 派发事件：NOT_FIND_PATH
				if (this.openListArray.length == 0) {
					return false;
				}
				//排序 取出最小的路径 node（并不是当前node四周的testNode是最短的！）
				this.openListArray.sortOn("f", Array.NUMERIC);
				node = this.openListArray.shift() as AstarNode;
			}			
			this.buildPath();
			return true;
		}
	}
}