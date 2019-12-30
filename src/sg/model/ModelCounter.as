package sg.model
{
	import sg.cfg.ConfigServer;
	import sg.manager.ViewManager;
	import sg.manager.ModelManager;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;

	/**
	 * ...
	 * @author
	 */
	public class ModelCounter extends ModelBase{
		public function ModelCounter(){
			
		}

		/**
		 * 是否开启
		 */
		public static function isOpen():Boolean{
			return true;
		}

		/**
		 * 升级接口
		 */
		public static function lvUp(hid:String,item_id:String,counter_index:int):void{
			NetSocket.instance.send("hero_counter_lvup",{
				"hid":hid,"item_id":item_id,"counter_index":counter_index
			},null,new Handler(null,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				
			}));
		}

		/**
		 * 检查是否可升级
		 */
		public static function canLvUp(hid:String,itemId:String,index:int,tips:Boolean=false):Boolean{
			if(isOpen()==false){
				if(tips) ViewManager.instance.showTipsTxt("功能暂未开启");
				return false;
			}
			if(checkSeat(index)){
				if(ModelManager.instance.modelUser.hero[hid]){
					var o:Object = ModelManager.instance.modelUser.hero[hid].counter;
					var lv:Number = o[index+""] ? o[index+""] : 0;
					if(lv>=maxLv()){
						if(tips) ViewManager.instance.showTipsTxt("已满级");
						return false;
					}


				}
			}else{
				if(tips) ViewManager.instance.showTipsTxt("位置没开");
			}
			
			return false;
		}

		/**
		 * 检查格子是否可解锁
		 */
		public static function checkSeat(index:int):Boolean{
			var seat:Array = ConfigServer.system_simple.counter_seat ? ConfigServer.system_simple.counter_seat[index] : null;
			if(seat){
				if(seat[0] == 'merge'){
					return ModelManager.instance.modelUser.mergeNum >= seat[0]; 
				}else if(seat[0] == 'science'){
					return ModelManager.instance.modelGame.getModelScience(seat[1]).getLv() > 0;
				}
			}
			return false;
		}
		/**
		 * 获得升级需要的道具数
		 */
		public static function getLvNum(lv:int):void{
			
		}

		public static function maxLv():Number{
			var counter_level:Array = ConfigServer.system_simple.counter_level;
			var n:Number = 0;
			for(var i:int=0;i<counter_level.length;i++){
				var a:Array = counter_level[i];
				if(a[0] == 'merge'){
					if(ModelManager.instance.modelUser.mergeNum >= a[1]){
						n += a[2];
					}
				}else if(a[0] == 'science'){
					n +=  ModelManager.instance.modelGame.getModelScience(a[1]).getLv();
				}
			}
			return n;
		}

		/**
		 * 遗忘接口
		 */
		public static function drop(hid:String,counter_index:int):void{
			NetSocket.instance.send("hero_counter_drop",{
				"hid":hid,"counter_index":counter_index},null,new Handler(null,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				
			}));
		}
	}

}