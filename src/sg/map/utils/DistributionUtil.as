package sg.map.utils {
	import laya.display.Node;
	import laya.display.Sprite;
	/**
	 * 分布式布局工具 用来居中显示
	 * @author light
	 */
	public class DistributionUtil {
		
		/**
		 * 垂直分布
		 */
		public static const VERTICAL:String = "v";
		
		/**
		 * 水平分布~
		 */
		public static const HORIZONTAL:String = "h";
		
		/**
		 * 分布式布局用的
		 * @param	container 当前已经添加好的对象的容器
		 * @param	range 范围， 需要布局总的宽度或者高度
		 * @param	padding 两段的填充的距离 -1代表两段间距与物品间距一致！
		 * @param	direction 方向： 这个类的常量 垂直或者水平
		 */
		public static function distribution(container:Sprite, range:Number, padding:Number = -1, direction:String = DistributionUtil.HORIZONTAL):void {
			if (!container.numChildren) return;
			
			var sum:Number = 0;
			
			for (var i:int = 0; i < container.numChildren; i++) {
				sum += (direction == HORIZONTAL ? Sprite(container.getChildAt(i)).width : Sprite(container.getChildAt(i)).height);
			}
			var gap:Number = 0;
			if ( -1 == padding) {
				padding = gap = (range - sum) / (container.numChildren + 1);
			}else {
				gap = (range - padding * 2 - sum) / (container.numChildren - 1);
			}
			
			for (i = 0; i < container.numChildren; i++) {
				var child:Sprite = Sprite(container.getChildAt(i));
				if (0 == i) {
					direction == HORIZONTAL ? child.x = padding : child.y = padding;
				}else {
					var preChild:Sprite = Sprite(container.getChildAt(i - 1));
					direction == HORIZONTAL ? (child.x = preChild.x + preChild.width + gap) : (child.y = preChild.y + child.height + gap);
				}
				
			}
		}
		
	}

}