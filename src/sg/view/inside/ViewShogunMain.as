package sg.view.inside
{
	import ui.inside.shogunMainUI;
	import ui.inside.shogunItemUI;
	import sg.manager.ModelManager;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.model.ModelUser;
	import sg.model.ModelHero;
	import laya.utils.Handler;
	import sg.boundFor.GotoManager;
	import sg.utils.Tools;

	/**
	 * ...
	 * @author
	 */
	public class ViewShogunMain extends shogunMainUI{
		

		public var userData:Array=[];
		public function ViewShogunMain(){
			
			this.titleLabel.text=Tools.getMsgById("_shogun_text05");
			this.list.scrollBar.visible=false;
			this.list.itemRender=Item;
			this.list.renderHandler=new Handler(this,listRender);
			ModelManager.instance.modelUser.on(ModelUser.EVENT_USER_UPDATE,this,eventCallBack);
			//this.testBtn.on(Event.CLICK,this,this.testClick);
			
		}

		override public function onAdded():void{
			this.setTitle(Tools.getMsgById("lvup12_1_name"));
			getData();
		}

		public function eventCallBack():void{
			// trace("shogunMain收到刷新消息");
			getData();
		}

		public function testClick():void{
			//ViewManager.instance.showView(ConfigClass.VIEW_SHOGUN_HERO,0,1,false);
		}

		public function getData():void{
			userData=ModelManager.instance.modelUser.shogun;
			this.list.array=userData;
		}

		public function listRender(cell:Item,index:int):void{
			cell.setData(index,this.list.array[index]);
			cell.off(Event.CLICK,this,this.itemClick);
			cell.on(Event.CLICK,this,this.itemClick,[index]);
		}

		public function itemClick(index:int):void{
			GotoManager.boundForPanel(GotoManager.VIEW_SHOGUN_HERO,"",index,{type:1,child:false});
		}
		override public function onRemoved():void{
			this.list.scrollBar.value=0;
		}
	}

}



import ui.inside.shogunItemUI;
import laya.ui.Label;
import sg.model.ModelHero;
import sg.manager.ModelManager;
import sg.model.ModelGame;
import sg.cfg.ConfigServer;
import sg.model.ModelUser;
import laya.ui.Image;
import laya.ui.Box;
import sg.manager.AssetsManager;
import sg.utils.Tools;
import sg.manager.LoadeManager;

class Item extends shogunItemUI{
	public function Item(){

	}
	public function setData(index:int,obj:Object):void{
		this.text0.text=Tools.getMsgById("_shogun_text02");
		LoadeManager.loadTemp(this.imgBG,AssetsManager.getAssetsAD("shogun0"+(index+1)+".jpg"));
		var shogun_book:Array=ConfigServer.shogun.shogun_book;
		var shogun_levelup:Array=ConfigServer.shogun.shogun_levelup;
		var hids:Array=obj.hids;
		var total_score:Number=0;
		var isHaveKong:Boolean=false;
		for(var i:int=0;i<hids.length;i++){
			var _img:Image=(this.getChildByName("box"+i) as Box).getChildByName("cell"+i) as Image;
			if(hids[i]){
				if((hids[i]+"").indexOf("hero")!=-1){
					var hmd:ModelHero=ModelManager.instance.modelGame.getModelHero(hids[i]);
					var o:Object=hmd.getShogunScore(obj.lv);
					_img.skin=ModelHero.shogun_rank_color[o.rank];
					total_score+=o.score;
				}else{
					_img.skin=AssetsManager.getAssetsUI("icon_grade08.png");
				}
			}else{
				_img.skin=AssetsManager.getAssetsUI("icon_grade07.png");
				isHaveKong=true;
			}
		}
		//this.lvUpLabel.text="可升级";
		this.scoreLabel.text=total_score+"";
		this.titleLabel.text= Tools.getMsgById("_building40",[ModelHero.shogun_name[index+1],obj.lv]);
		// ModelHero.shogun_name[index+1]+"府"+obj.lv+"级";
		var prop:Object=ModelManager.instance.modelUser.property;
		this.imgUp.visible=this.imgInto.visible=false;
		if(ModelManager.instance.modelUser.isCanLvUpShogunByIndex(index)){//可升级
			this.imgUp.visible=true;
		}else{
			if(isHaveKong){//可上阵
				this.imgInto.visible=true;
				//this.lvUpLabel.text="可上阵";
			}
		}
	}
}