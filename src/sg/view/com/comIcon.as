package sg.view.com
{
	import laya.ui.View;
	import laya.ui.Image;
	import laya.ui.Label;
	// import laya.debug.tools.comps.Rect;
	import laya.maths.Rectangle;
	import sg.cfg.ConfigColor;
	import sg.model.ModelSkill;
	import sg.utils.Tools;
	import sg.manager.EffectManager;
	import laya.display.Animation;
	import sg.manager.AssetsManager;
	import sg.model.ModelHero;
	import sg.manager.ModelManager;
	import ui.com.hero_icon1UI;
	import sg.model.ModelItem;
	import laya.display.Sprite;
	import sg.cfg.ConfigServer;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import laya.utils.Handler;
	import laya.ui.List;
	import sg.model.ModelEquip;
	import sg.model.ModelRune;
	import sg.view.inside.ItemEquip;
	import sg.model.ModelProp;
	import sg.model.ModelSalePay;
	import sg.view.beast.ItemBeast;
	import sg.model.ModelBeast;

	/**
	 * ...
	 * @author
	 */
	public class comIcon extends View{

		public var imgBG:Image;
		public var imgIcon:Image;
		public var labelNum:Label;
		public var labelName:Label;
		public var selected:Boolean=false;
		public var mCanClick:Boolean = false;
		public var item_id:String="";
		private var mAniName:String;
		//public function comIcon(iconStr:String="",bgRatity:int=0,nameStr:String="",numStr:String="",type:int=1,b:Boolean=false){
		//	this.setData(iconStr,bgRatity,nameStr,numStr,type,b);
		//}

		/**
		 * Added by Thor.
		 */
		private function set dataSource(data:Array):void {
			super.dataSource = data;
			(data is Array) && (data[0] is String) && (data[1] is Number) &&  (data[2] is Number) && this.setData(data[0], data[1], data[2]);
		}
		
		/**
		 * Added by Thor.
		 */
		private function get dataSource():* {
			return _dataSource;
		}

		public function comIcon(_id:String="",num:Number=-1):void{
			if(Tools.isNullString(_id)){
				return;
			}
			setData(_id,num);
		}

		public function setData(_id:String,num:Number=-1,_name:Number=1):void{
			if(Tools.isNullObj(this.imgBG)){
				this.imgBG = this.getChildByName("imgBG") as Image;
			}
			if(Tools.isNullObj(this.imgIcon)){
				this.imgIcon = this.getChildByName("imgIcon") as Image;
			}
			if(Tools.isNullObj(this.labelName)){
				this.labelName = this.getChildByName("labelName") as Label;
			}
			if(Tools.isNullObj(this.labelNum)){
				this.labelNum = this.getChildByName("labelNum") as Label;
			}

			if(this.getChildByName("bg")){
				(this.getChildByName("bg") as Sprite).visible = true;
			}

			this.item_id=_id;
			var iconStr:String="";
			var bgRatity:int=0;
			var nameStr:String="";
			var numStr:String="";
			var isSpecial:Boolean=false;
			var specialStr:String="";
			var type:int=1;
			selected = false;

			if(ModelManager.instance.modelProp.allProp.hasOwnProperty(_id)){
				var it:ModelItem=ModelManager.instance.modelProp.getItemProp(_id);
				type=it.type;
				iconStr=ModelItem.getIconUrl(_id);
				nameStr=it.name;
				numStr=(num==-1) ? "" : num+"";
				bgRatity=it.ratity;
			}else if(_id.indexOf("equip")!=-1){
				nameStr=ModelEquip.getName(_id,0);
			}else if(_id.indexOf("title")!=-1){
				iconStr=AssetsManager.getAssetsICON(ConfigServer.title[_id].icon);
				bgRatity=0;
			}else if(_id.indexOf("star")!=-1){
				var sStr:String=_id.substr(0,6);
				var itemRune:ModelRune=new ModelRune();
				itemRune.initData(sStr,ConfigServer.star[sStr]);
				iconStr="icon/"+itemRune.getImgName();
				nameStr=itemRune.getName();
				numStr=(num==-1) ? "" : num+"";
				bgRatity=1;
				isSpecial=true;				
			}else if(_id.indexOf("skill")!=-1){
				iconStr=ModelSkill.getModel(_id).getIcon();
			}else if(_id.indexOf("hero")!=-1){
				type=100;//觉醒
				nameStr=ModelManager.instance.modelGame.getModelHero(_id).getAwakenName();
			}else if(_id.indexOf("sale")!=-1){
				var saleArr:Array = _id.indexOf("|") ? _id.split('|') : [_id,0];
				var spmd:ModelSalePay = ModelSalePay.getModel(saleArr[0]);
				nameStr = spmd ? spmd.getName(saleArr[1]) : "";
				iconStr = spmd ? spmd.getIcon() : "";
				numStr  = (num==-1) ? "" : num+"";
			}else if(_id.indexOf("beast")!=-1){
				numStr  = (num==-1) ? "" : num+"";
				nameStr = ModelBeast.getBeastName(_id);
				if(this.getChildByName("bg")){
					(this.getChildByName("bg") as Sprite).visible = false;
				}
			}
			setChipIcon(type==2 || type ==7 || type ==8);
			if (type == 2){
				//技能碎片
				var sid:String = _id.replace("item","skill");//'skill' + (iconStr.split('.')[0] as String).substr(4);
				var ms:ModelSkill = ModelSkill.getModel(sid);
				this.setTypeIcon(ms);
			}else{
				this.setTypeIcon(null);
			}
			if(type==7){
				var hid:String=ModelManager.instance.modelProp.getItemProp(_id).id.replace("item","hero");
				setHeroIcon(hid);
				setIcon("");
			}else if(type==100){
				setHeroIcon(_id,1);
				setIcon("");
				bgRatity=-1;
			}else{
				setHeroIcon("");
				setIcon(iconStr);
			}
			isSpecial=(!isSpecial)?(bgRatity>=6):true;
			setClick();
			//

			this.setNum(numStr);

			if(_name==-1) this.setName("");
			else this.setName(nameStr,bgRatity);
			
			if(specialStr!="") this.playEffect(specialStr,false);
			else this.setSpecial(isSpecial);

			this.setRatity(type,bgRatity);

			this.setEquipIcon(false);
			this.setBeastIcon();
			
		}
		public function visibleOnlyIcon(b:Boolean = false):void{
			(this.getChildByName("bg") as Sprite).visible = b;			
			(this.getChildByName("imgBG") as Sprite).visible = b;			
			(this.getChildByName("labelName") as Sprite).visible = b;			
		}
		public function setNum(v:*):void{
			if(Tools.isNullObj(this.labelNum)){
				this.labelNum = this.getChildByName("labelNum") as Label;
			}
			if(!Tools.isNullObj(this.labelNum)){
				this.labelNum.text=Tools.textSytle(v);
			}
			if(this.getChildByName("imgNum")){
				(this.getChildByName("imgNum") as Image).visible=v+""!="";
				(this.getChildByName("imgNum") as Image).width=this.labelNum.displayWidth + 20;
			}
		}
		public function setNumBold(b:Boolean, stroke:int = -1):void{
			if(!Tools.isNullObj(this.labelNum)){
				this.labelNum.bold = b;
				if(stroke >= 0)
					this.labelNum.stroke = stroke;
			}
		}
		public function setNumColor(color:int):void{
			if(!Tools.isNullObj(this.labelNum)){
				this.labelNum.color = EffectManager.getFontColor(color);
			}
		}
		public function setName(v:*,bgRatity:int=-1):void{
			if(Tools.isNullObj(this.labelName)){
				this.labelName = this.getChildByName("labelName") as Label;
			}
			if(!Tools.isNullObj(this.labelName)){
				this.labelName.text = v + "";
				if (bgRatity >= 0){
					if(item_id=="coin"){
						this.labelName.color = ConfigColor.FONT_COLORS[0];	
					}else{
						if(bgRatity>=6){
							this.labelName.color = ConfigColor.FONT_COLORS[5];	
						}else{
							this.labelName.color = ConfigColor.FONT_COLORS[bgRatity];
						}
					}
				}
			}
			// if(this.labelName.width < this.labelName.textField.textWidth){
			// 	var n:Number = Math.round(40 * (this.labelName.width / this.labelName.textField.textWidth));
			// 	this.labelName.fontSize = n < 20 ? 20 : n;
			// }else{
			// 	this.labelName.fontSize = 40;
			// }
			Tools.textFitFontSize2(this.labelName);
		}
		public function setTypeIcon(s:ModelSkill):void{	
			var isShow:Boolean = s && s.data.type >= 0;
			if(isShow){
				if(this.getChildByName("typeIcon")==null){
					var _imgIcon:Image = new Image();// this.getChildByName("typeIcon") as Image;
					var _imgBg:Image = new Image();//this.getChildByName("typeBg") as Image;
					_imgIcon.name="typeIcon";
					_imgBg.name="typeBg";			
					_imgBg.skin="ui/bg_skill.png";
					_imgBg.x=92;
					_imgBg.y=11;
					_imgBg.width=34;
					_imgBg.height=34;
					this.addChild(_imgBg);

					_imgIcon.x=94;
					_imgIcon.y=13;
					_imgIcon.width=30;
					_imgIcon.height=30;
					this.addChild(_imgIcon);
					_imgIcon.skin = s.getSkillTypeIcon();
				}else{
					(this.getChildByName("typeIcon") as Image).skin = s.getSkillTypeIcon();
				}
			}else{
				if(this.getChildByName("typeIcon")){
					this.removeChild(this.getChildByName("typeIcon"));
				}
				if(this.getChildByName("typeBg")){
					this.removeChild(this.getChildByName("typeBg"));
				}
			}

		}

		/**
		 * 新道具图标
		 */
		public function setNewIcon(b:Boolean):void{
			if(b){
				if(this.getChildByName("xin")==null){
					var img:Image=new Image();
					img.skin="ui/icon_xin.png";
					img.left=7;
					img.top=8;
					img.name="xin";
					this.addChild(img);	
					img.zOrder=this.numChildren;
				}
			}else{
				if(this.getChildByName("xin")){
					this.removeChild(this.getChildByName("xin"));
				}
			}
		}

		/**
		 * 道具碎片图标
		 */
		public function setChipIcon(b:Boolean):void{
			if(b){
				if(this.getChildByName("chip")==null){
					var img:Image=new Image();
					img.skin="ui/icon_68.png";
					img.name="chip";
					this.addChild(img);
					img.x=13;
					img.y=14;
				}
			}else{
				if(this.getChildByName("chip")){
					this.removeChild(this.getChildByName("chip"));
				}
			}
		}

		/**
		 * 选中框
		 */
		public function setSelecImg(b:Boolean):void{
			if(b){
				if(this.getChildByName("imgSelect")==null){
					var img:Image=new Image();
					img.skin="ui/icon_chenghao07.png";
					img.sizeGrid="54,56,30,30";
					img.name="imgSelect";
					img.left=img.right=img.top=0;
					img.bottom=14;
					this.addChild(img);
				}
			}else{
				if(this.getChildByName("imgSelect")){
					this.removeChild(this.getChildByName("imgSelect"));
				}
			}
		}

		/**
		 * 设置英雄头像
		 */
		public function setHeroIcon(s:String,type:int=0):void{
			if(s==""){
				if(this.getChildByName("hero_icon")){
					this.removeChild(this.getChildByName("hero_icon"));
				}
				if(this.getChildByName("hero_ani")){
					this.removeChild(this.getChildByName("hero_ani"));
				}
			}else{
				var n:Number=ModelManager.instance.modelGame.getModelHero(s).rarity;
				var hero_icon:hero_icon1UI;
				if(this.getChildByName("hero_icon")==null){
					hero_icon=new hero_icon1UI();
					hero_icon.name="hero_icon";
					hero_icon.x=8;
					hero_icon.y=7;
					hero_icon.scale(1.36,1.36);					
					this.addChild(hero_icon);
					this.setChildIndex(hero_icon,2);
				}else{
					hero_icon=(this.getChildByName("hero_icon") as hero_icon1UI);
				}
				hero_icon.setHeroIcon(type==0? s : s+"_1",true,-1);
				if(n>0){
					var ani:Animation;
					var key:String="glow_hero_icon2";
					if(n==1)
						key="glow_hero_icon1";
					else if(n==4)
						key="glow_hero_icon3";
					
					if(this.getChildByName("hero_ani")==null){
						ani = EffectManager.loadAnimation(key, '', 0);
						ani.x = 8+60;
						ani.y = 8+60;
						ani.name="hero_ani";
						this.addChild(ani);
					}else{
						ani = this.getChildByName("hero_ani") as Animation;
						ani = EffectManager.loadAnimation(key, '', 0, ani);
					}
					ani.blendMode="lighter";
				}else{
					if(this.getChildByName("hero_ani")){
						this.removeChild(this.getChildByName("hero_ani"));
					}
				}
				
			}
		}

		/**
		 * 设置宝物图标
		 */
		private function setEquipIcon(b:Boolean):void{
			if(item_id.indexOf("equip")==-1){
				if(this.getChildByName("equip_icon")){
					this.removeChild(this.getChildByName("equip_icon"));
				}
			}else{
				var equip_icon:ItemEquip;
				if(this.getChildByName("equip_icon")==null){
					equip_icon=new ItemEquip();
					equip_icon.name="equip_icon";
					equip_icon.x=(this.width-equip_icon.width)/2;
					equip_icon.y=0;
					this.addChild(equip_icon);
				}else{
					equip_icon=(this.getChildByName("equip_icon") as ItemEquip);
				}
				equip_icon.setShow(ModelManager.instance.modelGame.getModelEquip(item_id),b);
				
			}
		}

		/**
		 * 设置兽灵图标
		 */
		private function setBeastIcon():void{
			if(item_id.indexOf("beast")==-1){
				if(this.getChildByName("beast_icon")){
					this.removeChild(this.getChildByName("beast_icon"));
				}
			}else{
				var beast_icon:ItemBeast;
				if(this.getChildByName("beast_icon")==null){
					beast_icon=new ItemBeast();
					beast_icon.name="beast_icon";
					beast_icon.x=(this.width-beast_icon.width)/2;
					if(this.imgBG){
						beast_icon.y=this.imgBG.top + (120-beast_icon.height)/2;
						this.imgBG.visible = false;
					}
					this.addChild(beast_icon);
				}else{
					beast_icon=(this.getChildByName("beast_icon") as ItemBeast);
					this.imgBG.visible = false;
				}
				beast_icon.setOtherData(item_id);
				labelNum.zOrder = 100;
				(this.getChildByName("imgNum") as Image).zOrder=99;
			}
		}

		public function setIcon(iconStr:String):void{
			if(Tools.isNullObj(this.imgIcon)){
				this.imgIcon = this.getChildByName("imgIcon") as Image;
			}
			if(this.imgIcon==null){
				return;
			}
			if(iconStr==""){
				this.imgIcon.visible=false;
				this.setNum("");
				this.setBgColor(0);
			}else{
				this.imgIcon.visible=true;
				this.imgIcon.skin=iconStr;
			}
		}
		
		private function setClick():void{
			this.mCanClick = true;
			this.off(Event.CLICK,this,this.click);
			var clickID:String = item_id;
			if(this.mCanClick && clickID){
				this.hitArea = new Rectangle(0,0,this.width,this.height);
				this.on(Event.CLICK,this,this.click,[clickID]);
			}
		}
		/**
		 * 修改边框颜色
		 */
		public function setBgColor(color:int):void{
			if(color>5){
				color=5;
			}
			(this.getChildByName("imgBG") as Image).visible=true;
			EffectManager.changeSprColor(this.getChildByName("imgBG") as Image,color);
		}
		public function setRatity(type:int=0,bgRatity:int = 0):void{			
			if(type==-1){
				(this.getChildByName("imgBG") as Image).visible=false;
				return;
			}
			var rat:int = 0;
			if(type == 7){
				var s:String=item_id.replace("item","hero");
				var hmd:ModelHero=ModelManager.instance.modelGame.getModelHero(s);
				rat = hmd.getStarGradeColor();
			}else{
				rat = bgRatity;//ModelItem.getItemQuality(item_id);
			}
			//
			this.setBgColor(rat);
		}
		public function setSpecial(b:Boolean):void{
			if(!b){
				if(this.getChildByName("glow")){
					this.removeChild(this.getChildByName("glow"));
				}
			}
			b && this.playEffect("glow000", false);
		}



		/**
		 * 播放特效
		 */
		public function playEffect(name:String = 'glow040', autoStop:Boolean = true):void
		{
			var ani:Animation;
			if(this.getChildByName("glow")){
				ani = this.getChildByName("glow") as Animation;
				//如果动画换了  再重新加载 不然动画会重新播放 效果很差
				if(Tools.isNullString(mAniName) || mAniName!=name){
					ani=EffectManager.loadAnimation(name, '', autoStop ? 1 : 0, ani);
				}
			}else{
				ani=EffectManager.loadAnimation(name, '', autoStop ? 1 : 0);
			}
			mAniName=name;
			ani.name="glow";
			ani.x=68;
			ani.y=68;
			if(!this.getChildByName("glow")){
				this.addChild(ani);	
			}
		}


		/**
		 * 是否选中
		 */
		public function setSelection(b:Boolean):void{
			setSelecImg(true);
			if(this.getChildByName("imgSelect")){
				(this.getChildByName("imgSelect") as Image).visible=b;
				selected=b;
			}
		}
		private function click():void
		{
			var events:Object = this.getEvents();
			var num:Number = 0;
			var isMe:Boolean = false;
			for(var key:String in events){
				
				if(key == Event.CLICK && events[key]){
					var handler:Handler;
					if(events[key] is Array){
						var arr:Array = events[key];
						var len:int = arr.length;
						for(var i:int = 0; i < len; i++)
						{
							handler = arr[i];
							if(handler.caller && handler.caller is List && !(handler.caller as List).selectEnable){
								continue;
							}
							num+=1;
							if(handler.caller == this && handler.method == this.click){
								isMe = true;
							}						
						}
					}
					else{
						isMe = true;
						num+=1;
					}
				}
			}
			if(this.mCanClick && num==1 && isMe){// 
				ViewManager.instance.showItemTips(item_id);
			}
		}

		public override function destroy(destroyChild:Boolean = true):void{
			super.destroy();			
		}

		/**
		 * 如果道具只有一个就直接显示具体道具  否则显示默认宝箱并且可以点击预览
		 */
		public function setMoreData(obj:Object):void{
			this.off(Event.CLICK,this,boxClick);
			var arr:Array=ModelManager.instance.modelProp.getRewardProp(obj);
			if(arr.length==0){
				// trace("error error error comIcon",obj);
				return;
			}
			if(arr.length==1){
				this.setData(arr[0][0],arr[0][1],-1);
			}else{
				this.on(Event.CLICK,this,boxClick,[obj]);
				this.setData(ModelProp.boxImg,-1,-1);	
				this.setBgColor(0);
			}
		}

		private function boxClick(obj:Object):void{
			ViewManager.instance.showRewardPanel(obj,null,true);
		}

		public function clearCom():void{
			this.visible=true;
			setChipIcon(false);
			setSelecImg(false);
			setSpecial(false);
			setTypeIcon(null);
			setHeroIcon("");
		}
		
	}

}