package interfaces
{
	/**
	 * 回收内存的接口
	 * @author light
	 */
	public interface IClear {
		/**
		 * 销毁用
		 */
		function clear():void;
		
		/**
		 * 判断当前是否被销毁过！
		 */
		function get cleared():Boolean;
	} 
}