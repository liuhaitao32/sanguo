package sg.view.beast
{
	import sg.model.ModelHero;
	import ui.beast.itemBeastUI;
	import sg.model.ModelBeast;
	import sg.manager.AssetsManager;
	import sg.manager.EffectManager;

	/**
	 * ...
	 * @author
	 */
	public class ItemBeast extends itemBeastUI{

		public var mUid:String = "";
		public var mBid:String;
		public var mHmd:ModelHero;
		public var mstatus:int;
		public var mBmd:ModelBeast;
		public var mDropItem:ItemBeast;

		public var mLv:Number;
		public var mPos:int = -1;
		public var mStar:int;
		public var mType:String;

		public var isUp:Boolean = false;
		public var isEmpty:Boolean = false;

		public function ItemBeast(){
			this.btnLock.visible = this.btnChoose.visible = false;
			btnChoose.mouseEnabled = false;
			btnChoose.label = '';
		}

		public function setMyData(id:String):void{
			mUid = id;
			mBmd = ModelBeast.getModel(Number(id));
			mBid = mBmd.id + mBmd.type + mBmd.pos + mBmd.star + "";
			this.mType = mBmd.type;
			this.mPos = mBmd.pos;
			this.mStar = mBmd.star;
			this.mLv = mBmd.lv;
			setUI();
		}

		public function setOtherData(bid:String):void{
			mBid = bid;
			this.mType = mBid[5];
			this.mPos = Number(mBid[6]);
			this.mStar = Number(mBid[7]);
			this.mLv = 0;
			setUI();
		}

		public function setEmpty(_pos:int):void{
			this.alpha = 0;
			isUp = false;
			isEmpty = true;
			mPos = _pos;
			mUid = "";
		}

		private function setUI():void{
			this.alpha = 1;
			isUp = isEmpty = false;
			
			this.tLv.text = this.mLv == 0 ? "" : this.mLv + "";
			this.imgLv.visible = this.mLv > 0;
			this.imgIcon.skin = AssetsManager.getAssetLater(ModelBeast.getIconByType(this.mType));
			EffectManager.changeSprColor(this.imgPos,this.mStar+1); 
			EffectManager.changeSprColor(this.imgRatity,this.mStar+1); 
			this.boxPos.rotation = this.mPos * 45;
		}

		public function setLv(n:int):void{
			this.tLv.text = n == 0 ? "" : n + "";
			this.imgLv.visible = n > 0;

		}

		/**
		 * 锁
		 */
		public function setLock():void{
			this.btnLock.visible = mUid!="" && ModelBeast.getModel(mUid).isLock()==true; 
		}

	}

}