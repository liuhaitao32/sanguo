package sg.view.menu
{
	import ui.com.icon_orderUI;
	import laya.events.Event;
	import sg.manager.AssetsManager;
	import sg.cfg.ConfigServer;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.view.country.ViewOrderTips;
	import sg.utils.Tools;
	import sg.model.ModelOfficial;
	import sg.boundFor.GotoManager;

	/**
	 * ...
	 * @author
	 */
	public class ItemOrder extends icon_orderUI{
		private var mId:String = "";
		private var mTime:Number = 0;
		public function ItemOrder(id:String){
			mId = id;
			this.on(Event.CLICK,this,click);
			setUI();
		}

		private function setUI():void{
			var s:String = "icon_duilie14_6.png";
			if(ConfigServer.country[mId]){
				s = ConfigServer.country[mId].buff_icon;
			}else if(mId == "country_army"){
				s = "icon_duilie14_5.png";	
			}else if(mId == "task_buff"){
				s = "icon_duilie14_6.png";
			}
			iIcon.skin = AssetsManager.getAssetsUI(s);
			mTime = ModelOfficial.getBuffTimeById(mId);
			setTime();

		}

		private function click():void{
			if(mId == "country_army"){
				ViewManager.instance.showView(ConfigClass.VIEW_NPC_INFO,[2]);
			}
			//else if(mId == "task_buff"){
			//	ViewManager.instance.showView(ConfigClass.VIEW_FIGHT_TASK);
			//}
			else{
				var cfg:Object = ConfigServer.country[mId];	
				var order:Array = ModelOfficial.buffs_dic[mId];
				if(order && order[0] && order[0]>=0){
					GotoManager.instance.boundForMap(order[0],-1);
				}
				ViewManager.instance.showView(["ViewOrderTips",ViewOrderTips],mId);
			}
		}

		private function setTime():void{
			var n:Number = mTime;
			this.tBox.visible = n>0;
			if(n<0) return;

			this.tTime.text= n<=0 ? "" : Tools.getTimeStyle(n,2);
			mTime-=1000;
			Laya.timer.once(1000,this,setTime);
		}

		override public function onRemove():void{

		}




	}

}