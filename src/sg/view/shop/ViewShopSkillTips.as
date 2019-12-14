package sg.view.shop
{
	import ui.shop.shopSkillTipsUI;
	import laya.ui.Label;
	import sg.model.ModelSkill;
	import sg.manager.ModelManager;
	import sg.model.ModelItem;
	import sg.utils.Tools;
	import laya.ui.Box;
	import laya.utils.Handler;
	import sg.model.ModelHero;
	import sg.cfg.ConfigColor;
	import sg.utils.StringUtil;
	
	/**
	 * ...
	 * @author
	 */
	public class ViewShopSkillTips extends shopSkillTipsUI
	{
		
		private var obj:Array = [];
		private var smd:ModelSkill;
		private var imd:ModelItem;
		private var itemId:String;
		private var listData1:Array;
		private var listData2:Array;
		private var mType:Number=0;//0 碎片  1 技能
		
		public function ViewShopSkillTips()
		{
			this.list1.renderHandler = new Handler(this, this.listRender1);
			this.list2.renderHandler = new Handler(this, this.listRender2);
			
			this.hInfo.style.fontSize = 16;
			this.hInfo.style.leading = 8;
		}
		
		public override function onAdded():void
		{
			var s:String = this.currArg;
			if(s.indexOf("skill")!=-1){
				this.itemId = s.replace('skill','item');
				mType=1;
			}else{
				this.itemId = this.currArg;
				mType=0;
			}
			
			this.setData();
			
			//this.icon.setData(imd.icon, imd.ratity, "", "", imd.type);
			if(mType==0){
				this.icon.setData(imd.id,-1,-1);
				this.nameLabel.text = imd.getName(true);
				this.numLabel.text=Tools.getMsgById("_public18",[imd.num+""]);
			}else{
				this.icon.setData(smd.id,-1,-1);
				this.nameLabel.text = smd.getName();
				this.numLabel.text="";
			}
			this.nameLabel.color = imd.getColor();
			
			
			this.tType.text = this.smd.getTypeStr();
			this.text0.text=Tools.getMsgById("_shop_text12");
			this.text1.text=Tools.getMsgById("_shop_text13");
			
			this.hInfo.innerHTML = StringUtil.substituteWithColor(this.smd.getInfoHtml(1), "#FCAA44", "#ffffff");
			var sumY:int = this.hInfo.y + this.hInfo.contextHeight + 10;
			
			this.box1.y = sumY;
			this.list1.repeatY = this.list1.array.length;
			this.box1.height = this.list1.y + this.list1.height;
			this.box2.y = this.box1.y + this.box1.height + 5;
			this.list2.repeatY = this.list2.array.length;
			this.box2.height = this.list2.y + this.list2.height + 5;
			this.boxCom.height = sumY + this.box1.height + this.box2.height + 20;
			this.boxCom.centerY = 0;
		}
		
		public function setData():void
		{
			
			this.smd = ModelManager.instance.modelGame.getModelSkill(itemId.replace("item", "skill"));
			this.imd = ModelManager.instance.modelProp.getItemProp(itemId);
			var arr1:Array = smd.isCanGetOrUpgrade().arr;
			var arr2:Array = smd.getSkillTopHero();
			//trace("=================",arr1);
			//trace("=================",arr2);
			this.list1.array = arr1;
			this.list2.array = arr2;
		}
		
		public function listRender1(cell:Box, index:int):void
		{
			var _label:Label = cell.getChildByName("label") as Label;
			_label.text = this.list1.array[index].name + "：" + this.list1.array[index].ext;
		}
		
		public function listRender2(cell:Box, index:int):void
		{
			var _label0:Label = cell.getChildByName("label0") as Label;
			var _label1:Label = cell.getChildByName("label1") as Label;
			var hd:ModelHero = this.list2.array[index] as ModelHero;
			_label0.text = hd.getName();
			var sd:ModelSkill = ModelManager.instance.modelGame.getModelSkill(smd.id);
			var s:String = sd.getLv(hd) == 0 ? Tools.getMsgById("_shop_text09") : sd.getName() + sd.getLv(hd);
			_label1.text = s + Tools.getMsgById("_shop_text10", [imd.num + "", sd.getUpgradeItemNum(hd) + ""]);
			_label1.color = ConfigColor.FONT_COLORS[sd.getColor(hd)];
		}
		
		public override function onRemoved():void
		{
		
		}
	
	}

}