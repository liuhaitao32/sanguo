package sg.view.equip
{
	import ui.equip.equipMainUI;
	import laya.utils.Handler;
	import ui.equip.itemEquipTabUI;
	import ui.inside.equipItemUI;
	import sg.model.ModelEquip;
	import sg.manager.AssetsManager;
	import laya.events.Event;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.map.utils.ArrayUtils;
	import sg.view.inside.ItemEquip;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import laya.maths.MathUtil;
	import sg.utils.Tools;
	import sg.model.ModelGame;
	import sg.cfg.ConfigColor;

	/**
	 * ...
	 * @author
	 */
	public class ViewEquipMain extends equipMainUI{

		private var mEid:String;
		private var mType:int;//0 制造 1 突破 2 洗练 3 强化
		private var mNum:int;//当前类型拥有数量
		private var mTabData:Array;
		private var mListData:Array;
		private var mPanel:*;
		private var mLockSpecial:Object;

		private var cfgMakeList:Object;//宝物制作列表
		private var cfgMakeSpecial:Object;//特殊宝物列表
		private var mTitleArr:Array=[Tools.getMsgById("_equip29"),Tools.getMsgById("_equip30"),Tools.getMsgById("_equip31"),Tools.getMsgById("_equip42")];

		public function ViewEquipMain(){
			
			this.tabList.renderHandler   = new Handler(this,tabListRender);
			this.tabList.selectHandler   = new Handler(this,tabListOnSelect);

			this.equipList.itemRender    = ItemEquip;
			this.equipList.renderHandler = new Handler(this,equipListRender);
			this.equipList.selectHandler = new Handler(this,equipListOnSelect);
			this.equipList.scrollBar.visible = false;
		}
		private function callBack():void{
			this.closeSelf();
		}

		private function callBack2():void{
			this.tEname.text = ModelManager.instance.modelGame.getModelEquip(mEid).getName();
			this.equipList.refresh();
		}

		override public function onAdded():void{
			ModelManager.instance.modelGame.on(ModelGame.EVENT_CLOSE_EQUIP_MAIN,this,callBack);
			ModelManager.instance.modelGame.on(ModelGame.EVENT_UPDATE_EQUIP_MAIN,this,callBack2);

			mLockSpecial   = ModelGame.unlock(null,"equip_special");
			cfgMakeList    = ConfigServer.system_simple.equip_make_list;
			cfgMakeSpecial = ConfigServer.system_simple.equip_make_special;

			mEid  = this.currArg && this.currArg[1] ? this.currArg[1] : "";
			mType = this.currArg && this.currArg[0] ? this.currArg[0] : 0;
			this.comTitle.setViewTitle(mTitleArr[mType]);

			switch(mType){
				case 0:
					mPanel = new PanelEquipMake();
					break;
				case 1:
					mPanel = new PanelEquipMake();
					break;
				case 2:
					mPanel = new PanelEquipWash();
					break;
				case 3:
					mPanel = new PanelEquipEnhance();
					break;
			}
			mPanel.x = (this.mBox.width - this.mPanel.width)/2;
			this.mBox.addChild(mPanel);

			mTabData = ModelEquip.getEquipTabArr(mType);
			this.tabList.array = mTabData;
			var n:Number=mEid=="" ? 0 : ModelManager.instance.modelGame.getModelEquip(mEid).type;
			for(var i:int=0;i<mTabData.length;i++){
				if(mTabData[i].type==n){
					n=i;
					break;
				}
			}
			tabItemOnClick(n);

		}

		private function tabListRender(cell:itemEquipTabUI,index:int):void{
			var o:Object = this.tabList.array[index];
			cell.btnBg.selected = this.tabList.selectedIndex == index;
			cell.imgIcon.skin = AssetsManager.getAssetsUI(this.tabList.selectedIndex == index ? o.icon0 : o.icon1);
			cell.tName.text = o.text;	
			cell.tName.color = this.tabList.selectedIndex == index ? "#ffffff" : "#7f8fb8";		
			cell.gray=(mType==0 && index==5 && mLockSpecial.gray);

			cell.off(Event.CLICK,this,tabItemOnClick);
			cell.on(Event.CLICK,this,tabItemOnClick,[index]);

			var b1:Boolean = mType == 0 && ModelEquip.makeRedPointByType(o.type);
			var b2:Boolean = mType == 1 && ModelEquip.upgradeRedPointByType(o.type);
			ModelGame.redCheckOnce(cell,b1 || b2);
		}

		private function tabItemOnClick(index:int):void{
			if(index<0) return;
			if(this.tabList.selectedIndex == index) return;
			if(mType==0 && index==5 && mLockSpecial.gray){
				ViewManager.instance.showTipsTxt(mLockSpecial.text);
				return;
			}

			this.tabList.selectedIndex = index;

			var _type:int = this.tabList.array[index].type;
			this.equipList.array = getEquipListData(_type);
			this.equipList.scrollBar.value = 0;
			//锻造 && 非特殊宝物  则不选中
			this.equipList.selectedIndex=-1;
			var n:Number = 0;
			if(mType==0 && index < 5){
				n = -1;
			}else{
				if(mEid != ""){
					for(var i:int=0;i<this.equipList.array.length;i++){
						if(this.equipList.array[i].id == mEid){
							n = i;
							break;
						}
					}
				}
			}
			equipItemOnClick(n);
			if(n>5){
				this.equipList.scrollTo(n);
			}
			if(mType==0 && index<5){
				mPanel.updateUI("",index,0);
				this.tEname.text = this.tabList.array[index].text;
				this.tEname.color = ConfigColor.FONT_COLORS[0];;
				this.tUname.text = "";
				this.comEquip.setHeroEquipType(null,_type);
			}

			this.tTypeName.text = ModelEquip.equip_type_name[_type];
			this.tTypeNum.text  = mType == 0 ? mNum+"/"+this.equipList.array.length : mNum + "";
		}

		private function tabListOnSelect(index:int):void{
			
		}



		private function equipListRender(cell:ItemEquip,index:int):void{
			var emd:ModelEquip = this.equipList.array[index];
            cell.setData(emd,this.tabList.selectedIndex);
            cell.imgSuc.visible = false;
			cell.showSelect(this.equipList.selectedIndex==-1 || (mType==0 && this.tabList.selectedIndex<5) ? false : (this.equipList.selectedIndex == index));
            cell.off(Event.CLICK,this,this.equipItemOnClick);
            cell.on(Event.CLICK,this,this.equipItemOnClick,[index]);
            if(mType==0 && this.tabList.selectedIndex==5){
				//锻造特殊物品时判断是否可锻造
                cell.checkCanMake();
            }
			if(mType==1){
				//突破界面判断该宝物是否可突破
                cell.checkCanUpgrade();
			}
		}

		private function equipListOnSelect(index:int):void{
			
		}

		private function equipItemOnClick(index:int):void{
			if(index<0) return;
			if(this.equipList.selectedIndex==index) return;
			this.equipList.selectedIndex=index;

			var emd:ModelEquip = this.equipList.array[index];
			mEid = emd.id;
			if(mType==0 && this.tabList.selectedIndex<5){
				if(emd.isMine())
					ViewManager.instance.showView(ConfigClass.VIEW_EQUIP_MAKE_INFO,emd); 
				this.equipList.selectedIndex=-1;
			}else{
				switch(mType){
					case 0:
						mPanel.updateUI(emd.id,this.tabList.array[this.tabList.selectedIndex].type,0);
						break;
					case 1:
						mPanel.updateUI(emd.id,this.tabList.array[this.tabList.selectedIndex].type,1);
						break;
					case 2:
						mPanel.updateUI(emd.id);
						break;
					case 3:
						mPanel.updateUI(emd.id);
						break;
				}

				this.comEquip.setHeroEquipType(emd?emd:null,this.tabList.array[this.tabList.selectedIndex].type);
				this.tEname.text = emd.getName();
				this.tEname.color = ConfigColor.FONT_COLORS[emd.getLv()];
				this.tUname.text = emd.getMyHero() ? emd.getMyHero().getName() : "";
			}
		}

		/**
		 * 获得宝物列表 type 宝物类型
		 */
		private function getEquipListData(type:int):Array{
			if(mType==0)
				return type== 5 ? getSpecialArr() : getNormalArr(type);
			else
				return getEquipListArr(type);
		}

		/**
		 * 获得普通宝物制造列表
		 */
		private function getNormalArr(type:int):Array{
			mNum = 0;
			var cfgArr:Array = cfgMakeList[type][1];
			var arr:Array=[];
			for(var i:int = 0; i < cfgArr.length; i++)
			{
				var key:String = cfgArr[i];
				var emd:ModelEquip = ModelManager.instance.modelGame.getModelEquip(key);
				if(emd.isMine()) mNum++;
				emd["sortIndex"] = (emd.isMine() ? 200000 : 100000) + emd.index;
				emd["sortMake"]  = type>=5 && emd.isCanMake() ? 1 : 0;
				arr.push(emd);
			}
			ArrayUtils.sortOn(["sortMake","sortIndex"],arr,true,true);
			return arr;
		}

		/**
		 * 获得特殊宝物制造列表
		 */
		private function getSpecialArr():Array{
			mNum = 0;
            var arr:Array=[];
            var obj:Object = ConfigServer.equip_make_special;
            if(obj && obj[1]){
                for(var i:int = 0; i <obj[1].length; i++)
                {
                    var emd:ModelEquip = ModelManager.instance.modelGame.getModelEquip(obj[1][i]);
					if(emd.isMine()) mNum++;
					emd["sortMake"] = emd.isCanMake() ? 1 : 0;
					emd["sortIndex"] = (emd.isMine() ? 200000 : 100000) + emd.index;
                    if(emd.isMine() || emd.hasSpecialMaterial()){
                        arr.push(emd);
                    }
                }
				ArrayUtils.sortOn(["sortMake","sortIndex"],arr,true,true);
            }
            return arr;
        }

		/**
		 * 获得突破、洗练、强化的宝物列表
		 */
		private function getEquipListArr(type:int):Array{
			var myEquips:Object = ModelManager.instance.modelUser.equip;
            var item:ModelEquip;
            var arr:Array = [];
            mNum=0;
            for(var key:String in myEquips){
                item = ModelManager.instance.modelGame.getModelEquip(key);
				if(item.type == type){
					mNum++;
					arr.push(item);
				}
				item["sortUp"]  = mType==1 && item.isCanUpgrade() ? 1 : 0;
            }
			ArrayUtils.sortOn(["sortUp","index"],arr,true,true);
			return arr;
		}


		override public function onRemoved():void{
			mPanel.removeCostumeEvent();
			this.mBox.destroyChildren();
			this.tabList.selectedIndex = this.equipList.selectedIndex = -1;
			ModelManager.instance.modelGame.off(ModelGame.EVENT_CLOSE_EQUIP_MAIN,this,callBack);
			ModelManager.instance.modelGame.off(ModelGame.EVENT_UPDATE_EQUIP_MAIN,this,callBack2);
		}

		/**
		 * 根据名字获取界面中的对象
		 * @param	name
		 * @return 	Sprite || undefined
		 */
		override public function getSpriteByName(name:String):* {
			if (mPanel[name]) {
				return mPanel[name];
			}
            return super.getSpriteByName(name);
		}
	}

}