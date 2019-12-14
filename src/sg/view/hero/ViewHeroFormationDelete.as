package sg.view.hero
{
	import ui.hero.heroFormationDeleteUI;
	import sg.model.ModelHero;
	import laya.utils.Handler;
	import ui.bag.bagItemUI;
	import sg.manager.ModelManager;
	import sg.manager.AssetsManager;
	import sg.cfg.ConfigServer;
	import sg.model.ModelItem;
	import sg.utils.Tools;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.manager.ViewManager;
	import sg.model.ModelFormation;
	import laya.events.Event;

	/**
	 * ...
	 * @author
	 */
	public class ViewHeroFormationDelete extends heroFormationDeleteUI{
		
		private var hmd:ModelHero;
		public function ViewHeroFormationDelete(){
			this.list.renderHandler = new Handler(this,listRender);
			this.list.itemRender = bagItemUI;
			this.btnDel.on(Event.CLICK,this,btnClick);
			this.comItem.on(Event.CLICK,this,function():void{
				ViewManager.instance.showItemTips(ConfigServer.system_simple.arr_forget_item);
			});

			this.comTitle.setViewTitle(Tools.getMsgById('_hero_formation25'));
			this.tText.text = Tools.getMsgById('_equip41');
			this.btnDel.label = Tools.getMsgById('_hero_formation27');
			
		}

		override public function onAdded():void{
			hmd = this.currArg;
			this.tTips.text = Tools.getMsgById('_hero_formation26',[hmd.getName()]);
			if(this.currArg == null) return;

			var arr:Array = ModelManager.instance.modelProp.getRewardProp(hmd.forgetFormationObj());
			this.list.repeatX = arr.length;
			this.list.array = arr;

			var itemId:String = ConfigServer.system_simple.arr_forget_item;
			this.comItem.setData(AssetsManager.getAssetItemOrPayByID(itemId),ModelItem.getMyItemNum(itemId)+'/1',ModelItem.getMyItemNum(itemId)>0 ? -1 : 1);
		}

		private function listRender(cell:bagItemUI,index:int):void{
			var a:Array = this.list.array[index];
			cell.setData(a[0],a[1]);
		}

		private function btnClick():void{
			if(Tools.isCanBuy(ConfigServer.system_simple.arr_forget_item,1)){

				NetSocket.instance.send("hero_formation_forget",{"hid":this.hmd.id},new Handler(this,function(np:NetPackage):void{
					var arr:Array = hmd.getFormationArr();
					for(var i:int=0;i<arr.length;i++){
						var n:Number = arr[i].curStar(hmd);
						ModelFormation.removeFormationObj(arr[i].id,n);
					}
					ModelManager.instance.modelUser.updateData(np.receiveData);
					ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
					hmd.event(ModelHero.EVENT_HERO_FORMATION_DELETE);
					hmd.event(ModelHero.EVENT_HERO_FORMATION_CHANGE);
					
					closeSelf();
				}));
			}
			
		}


		override public function onRemoved():void{

		}
	}

}