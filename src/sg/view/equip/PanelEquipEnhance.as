package sg.view.equip
{
	import ui.equip.panelEquipEnhanceUI;
	import laya.events.Event;
	import sg.model.ModelEquip;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.manager.ModelManager;
	import sg.model.ModelItem;
	import sg.utils.Tools;
	import sg.manager.ViewManager;
	import sg.manager.AssetsManager;
	import sg.cfg.ConfigServer;
	import sg.manager.EffectManager;
	import sg.model.ModelGame;
	import sg.view.effect.equipEnhance;
	import sg.cfg.ConfigColor;
	import laya.display.Animation;
	import sg.utils.MusicManager;

	/**
	 * ...
	 * @author
	 */
	public class PanelEquipEnhance extends panelEquipEnhanceUI{

		private var mEmd:ModelEquip;
		private var mCfg:Array;
		private var mCurLv:Number;
		private var mTimes:Number;
		private var mAni:Animation;
		public function PanelEquipEnhance(){
			this.btn.on(Event.CLICK,this,btnClick);
			this.text6.text=Tools.getMsgById("_equip41");
			this.btn.label=Tools.getMsgById("_enhance09");

			EffectManager.changeSprColor(this.img00,3,false,ConfigColor.COLOR_WORSHIP);
			EffectManager.changeSprColor(this.img01,3,false,ConfigColor.COLOR_WORSHIP);

		}

		

		private function updateUI(id:String):void{
			mEmd   = ModelManager.instance.modelGame.getModelEquip(id);
			mCfg   = mEmd.getEnhanceCfg();
			mCurLv = mEmd.getEnhanceLv();
			mTimes = mEmd.getEnhanceTimes() < mCfg[4] ? mEmd.getEnhanceTimes() : mCfg[4];
			this.text0.text = Tools.getMsgById("_enhance05",["+"+mCurLv,mEmd.getEnhanceLvBaseInfo(mCurLv)]);
			this.text1.text = Tools.getMsgById("_enhance06", ["+"+(mCurLv+1),mEmd.getEnhanceLvBaseInfo(mCurLv+1)]);
			this.text1.visible = mCurLv < mEmd.getEnhanceLvMax();

			var showLv:Array = ConfigServer.system_simple.equip_enhance_show;
			var highArr0:Array = mEmd.getEnhanceLvHighArr(0);
			var highArr1:Array = mEmd.getEnhanceLvHighArr(1);
			var highArr2:Array = mEmd.getEnhanceLvHighArr(2);
			this.text2.text = mCurLv >= (showLv[0] ? showLv[0] : mCurLv+1) ? Tools.getMsgById("_enhance07",["+"+highArr0[0],highArr0[1]]) : "";
			this.text3.text = mCurLv >= (showLv[1] ? showLv[1] : mCurLv+1) ? Tools.getMsgById("_enhance07",["+"+highArr1[0],highArr1[1]]) : "";
			this.text4.text = mCurLv >= (showLv[2] ? showLv[2] : mCurLv+1) ? Tools.getMsgById("_enhance07", ["+"+highArr2[0],highArr2[1]]) : "";
			this.text2.gray = mCurLv < highArr0[0];
			this.text3.gray = mCurLv < highArr1[0];
			this.text4.gray = mCurLv < highArr2[0];
			
			this.img0.visible = this.text2.text != "";
			this.img1.visible = this.text3.text != "";
			this.img2.visible = this.text4.text != "";

			var n1:Number = this.box0.height;
			var n2:Number = this.box1.height;
			var n3:Number = 4;
			var n:Number = n3 * 3 + n1 + n2 * 3;
			var nn:Number = 0;
			if(this.text2.text == ""){
				nn = n1 + (n2 + n3) * 0;
			}else if(this.text3.text == ""){
				nn = n1 + (n2 + n3) * 1;
			}else if(this.text4.text == ""){
				nn = n1 + (n2 + n3) * 2;
			}else{
				nn = n1 + (n2 + n3) * 3;
			}
			var n4:Number = 0;
			this.box0.y = 4+ (n - nn)/2;
			
			for(var i:int=1;i<=3;i++){
				this["box"+i].y = this["box"+(i-1)].y + this["box"+(i-1)].height + n3;
			}

			EffectManager.changeSprColor(this.img0,3);
			EffectManager.changeSprColor(this.img1,4);
			EffectManager.changeSprColor(this.img2,5);

			this.text5.text = mCurLv==mEmd.getEnhanceLvMax() ? Tools.getMsgById("_enhance04") : Tools.getMsgById("_enhance08",[mEmd.getCurProbability()]);// + "   失败次数:  "+mEmd.getEnhanceTimes();;

			var m1:Number = mCfg[1];
			var m2:Number = ModelItem.getMyItemNum(mCfg[0]);
			this.comItem.setData(AssetsManager.getAssetItemOrPayByID(mCfg[0]),m2+"/"+m1,m2>=m1 ? 0 : 1);
			this.comItem.off(Event.CLICK,this,comClick);
			this.comItem.on(Event.CLICK,this,comClick,[mCfg[0]]);

			this.btn.gray = !mEmd.checkCanEnhance();
		}

		private function comClick(id:String):void{
			ViewManager.instance.showItemTips(id);
		}

		private function btnClick():void{
			if(!mEmd.checkCanEnhance(true)) return;

			NetSocket.instance.send("equip_enhance",{"equip_id":mEmd.id},new Handler(this,function(re:NetPackage):void{
				ModelManager.instance.modelUser.updateData(re.receiveData);
				mouseEnabled = false;
				var b:Boolean = mEmd.getEnhanceLv()>mCurLv;
				mAni = EffectManager.loadAnimation(b ? "equip_enhance_success" : "equip_enhance_fail", "ani1", 1);
				mAni.off(Event.COMPLETE,this,aniCallBack);
				mAni.on(Event.COMPLETE,this,aniCallBack,[b]);
				boxAni.addChild(mAni);
				mAni.x = boxAni.width/2;
				mAni.y = boxAni.height/2;
				MusicManager.playSoundUI(b ? MusicManager.SOUND_ENHANCE_SUCCESS : MusicManager.SOUND_ENHANCE_FAIL);
			}));
		}

		private function aniCallBack(b:Boolean):void{
			mouseEnabled = true;
			if(b){
				successFun();
			}else{
				defeateFun();
			}
			updateUI(mEmd.id);

		}

		private function successFun():void{
			//ViewManager.instance.showTipsTxt(Tools.getMsgById("_enhance01"));
			ModelManager.instance.modelGame.event(ModelGame.EVENT_UPDATE_EQUIP_MAIN);
			ViewManager.instance.showViewEffect(equipEnhance.getEffect(this.mEmd),0.5);
		}

		private function defeateFun():void{
			ViewManager.instance.showTipsTxt(Tools.getMsgById(mTimes>=mCfg[4] ? "_enhance02" : "_enhance03"));
		}

		public function removeCostumeEvent():void{
			
		}


	}

}