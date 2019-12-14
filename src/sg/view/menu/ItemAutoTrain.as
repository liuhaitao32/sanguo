package sg.view.menu
{
	import laya.events.Event;
	import sg.model.ModelOffice;
	import sg.net.NetSocket;
	import sg.manager.ModelManager;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.model.ModelInside;
	import sg.manager.AssetsManager;
	import sg.utils.Tools;
	import ui.menu.builderUI;
	import laya.display.Animation;
	import sg.manager.EffectManager;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigServer;

	/**
	 * ...
	 * @author
	 */
	public class ItemAutoTrain  extends builderUI{

		private var mAin:Animation;
		private var aniFree:Animation;
		public function ItemAutoTrain(){
			
			ModelManager.instance.modelInside.on(ModelInside.CHANGE_AUTO_MK_ARMY,this,updateData);
			this.on(Event.CLICK,this,click);
		}

		public function initData(md:*):void{
			mAin = EffectManager.loadAnimation("glow041");
			this.addChild(mAin);
			this.img.zOrder=-1;
			mAin.zOrder=-1;
			this.img.anchorX=this.img.anchorY=0.5;
			this.img.bottom=22;
			mAin.x=this.img.x;
			mAin.y=this.img.y;
			mAin.scaleX=mAin.scaleY=0.7;

			this.aniFree = EffectManager.loadAnimation("glow018");
			this.aniFree.x = this.width*0.5;
			this.aniFree.y = this.height*0.5;
			this.addChild(this.aniFree);

			updateData();
		}

		public function updateData(type:* = null):void{
			var b:Boolean=ModelOffice.func_autotrain();
			var n:Number=ModelManager.instance.modelUser.records.auto_mk_army;
			this.img.skin = AssetsManager.getAssetsUI(n==0 ? "icon_paopao48.png":"icon_paopao49.png");
			this.txt.wordWrap=true;
			this.bgTimer.visible=false;
			this.bgTxt.bottom=this.txt.bottom=2;
			this.txt.valign="middle";
			if(b){
				this.txt.text = n==1 ? Tools.getMsgById("193008") : Tools.getMsgById("193009");
				this.txt.height=this.bgTxt.height=30;				
			}else{
				this.txt.text = Tools.getMsgById("193013");
				this.txt.height=this.bgTxt.height=15;
			}
				
			this.mAin.visible = b && n==1;
			this.aniFree.visible = b && n==0;
			this.gray=!b;
		}

		private function click():void{
			var b:Boolean=ModelOffice.func_autotrain();
			if(b){
				ModelManager.instance.modelInside.sendChangeAutoMkArmy();
			}else{
				ViewManager.instance.showTipsTxt(Tools.getMsgById("193012",[Tools.getMsgById(ConfigServer.office.right[ConfigServer.office.righttype["autotrain"][0]].name)]));
			}
		}
	}

}