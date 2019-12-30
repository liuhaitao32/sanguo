package sg.view.com
{
	import laya.ui.Component;
	import laya.ui.View;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.display.Sprite;
	import laya.ui.ProgressBar;
	import laya.utils.Ease;
	import laya.utils.Tween;
	import sg.cfg.ConfigColor;
	import sg.fight.client.utils.FightViewUtils;
	import sg.utils.Tools;
	import sg.model.ModelEquip;
	import sg.model.ModelHero;
	import ui.inside.pubHeroItemUI;
	import sg.manager.AssetsManager;
	import laya.events.Event;
	import laya.ui.Panel;
	import laya.utils.Handler;
	import sg.manager.EffectManager;
	import laya.runtime.IConchNode;
	import sg.model.ModelSkill;
	import laya.ui.Button;
	import sg.cfg.ConfigServer;
	import sg.model.ModelItem;
	import laya.display.Node;
	import sg.model.ModelScience;
	import sg.model.ModelRune;
	import sg.model.ModelBuiding;
	import sg.model.ModelPrepare;
	import laya.ui.Box;
	import sg.view.BaseSprite;
	import sg.utils.StringUtil;
	import sg.manager.LoadeManager;
	import sg.model.ModelOfficial;
	import sg.manager.ViewManager;
	import laya.display.Animation;
	import laya.html.dom.HTMLElement;
	import laya.html.dom.HTMLDivElement;
	import sg.manager.ModelManager;
	import sg.model.ModelTalent;
	import sg.cfg.HelpConfig;
	
	/**
	 * ...
	 * @author
	 */
	public class ComPayType extends BaseSprite
	{
		public var mImg:Image;
		public var mLabel:Label;
		private var currImgName:String = "";
		private var currTxtVar:String = "";
		
		public function ComPayType()
		{
		}
		
		public function setData(imgName:String = "", label:* = "", colorType:int = -1, layoutType:int = 0):void
		{//colorType 0 绿  1 红   2 紫
			if (!this.mImg)
			{
				this.mImg = this.getChildByName("img") as Image;
				this.mImg.visible = false;
			}
			if (!this.mLabel)
			{
				this.mLabel = this.getChildByName("label") as Label;
			}
			//
			if (imgName)
			{
				this.mImg.visible = true;
				this.mImg.skin = imgName;
			}
			this.mLabel.text = label;
			
			if (this.mLabel)
			{
				if (colorType == 0)
				{
					this.mLabel.color = "#acff75";
				}
				else if (colorType == 1)
				{
					this.mLabel.color = "#ff7358";
				}
				else if (colorType == 2)
				{
					this.mLabel.color = "#c5dbff";
				}
				else
				{
					this.mLabel.color = "#fffbc1";//默认字体颜色
				}
			}
			this.layout(layoutType);
		}
		
		public function setNum(v:*):void
		{
			this.mLabel = this.getChildByName("label") as Label;
			this.mLabel.text = v + "";
		}
		
		public function changeTxtColor(color:String):void
		{
			if (this.mLabel.color != color)
			{
				this.mLabel.color = color;
			}
		}
		/**
		 * 获得图标和动态文字的总宽度
		 */
		public function getTextFieldWidth():Number
		{
			return this.mLabel.x + this.mLabel.textField.textWidth* this.mLabel.scaleX;
		}
		
		public function getWidth():Number
		{
			return this.mLabel.x + this.mLabel.displayWidth;
		}
		
		private function layout(type:int = 0):void
		{
			if (type == 0)
			{//默认
				if (this.name == "type10000")
				{//coid,gold,图标,数字,排列
					// this.mLabel.width = this.mLabel.displayWidth;
					//
					var imgW:Number = 40;
					var p:Number = 5;
					var ll:Number = Math.floor((this.width - (imgW + p + this.mLabel.displayWidth)) * 0.5);
					// trace(this.width,this.mLabel.width,this.mLabel.displayWidth);
					this.mImg.visible = this.mLabel.text!="";
					this.mImg.x = ll;
					this.mLabel.x = this.mImg.x + imgW + p;
					//
					if (this["textlabel"])
					{
						return;
					}
					this.mLabel.y = this.height * 0.5 - this.mLabel.height * 0.5;
					this.mImg.y = this.height * 0.5 - imgW * 0.5;
					
				}
				else if (this.name == "pay_type_t")
				{
					// this.width = this.mLabel.x+this.mLabel.displayWidth;
				}
			}
			else
			{//纯文字居中
				this.mImg.visible = false;
				// this.mLabel.width = this.mLabel.displayWidth;
				this.mLabel.x = (this.width - this.mLabel.displayWidth) * 0.5;
			}
		
		}
		
		public function setHeroStar(star:Number):void
		{
			var colorType:int = ModelHero.getHeroStarGradeColor(star);
			var score:int = star >= 0 ? star % 6 : 0;
			var img:Image;
			for (var i:int = 1; i <= 5; i++)
			{
				img = this.getChildByName("hStar" + i) as Image;
				if (i <= score)
				{
					img.skin = AssetsManager.getAssetsUI("icon_66.png");
				}
				else
				{
					img.skin = AssetsManager.getAssetsUI("icon_67.png");
				}
				EffectManager.changeSprColor(img, colorType);
			}
		}
		
		public function setRune(rmd:ModelRune, selected:Boolean = false, vName:Boolean = true):void
		{
			var tName:Label = (this.getChildByName("tName") as Label);
			(this.getChildByName("img") as Image).skin = rmd.getIcon();
			tName.text = rmd.getName();
			tName.visible = vName;
			(this.getChildByName("bgName") as Image).visible = vName;
			(this.getChildByName("imgSelect") as Image).visible = selected;
		}
		
		public function setHeroType(str:String):void
		{
			(this.getChildByName("label") as Label).text = str;
		}
		
		public function setHeroProp4(title:String, v:Number):void
		{
			(this.getChildByName("label") as Label).text = title;
			// (this.getChildByName("tVar") as Label).text = v + "";
			(this["tVar"] as Label).text = v + "";
			(this.getChildByName("bar") as ProgressBar).value = v / 100;
		}
		
		public function setHeroArmyProp4(txt:String, v:Number):void
		{
			(this.getChildByName("txt") as Label).text = txt;
			
			var tVar:Label = (this.getChildByName("tVar") as Label);
			var img:Image = (this.getChildByName("img") as Image);
			if (v == 0)
			{
				tVar.text = "";
				img.visible = false;
			}
			else
			{
				tVar.text = v + "";
				img.visible = true;
			}
		
		}
		
		public function setHeroTitle(tid:String):void
		{
			if(Tools.isNullString(tid)){return;}
			var cfg:Object = ConfigServer.title[tid];
			if (cfg)
			{
				this["tName"].text = Tools.getMsgById(tid);
				var si:Number = Number(cfg.rarity);
				for (var i:Number = 1; i <= 4; i++)
				{
					this["lv" + i].visible = (si == i);
				}
			}
		}
		/**
		 * 替换兵种图标，显示兵种和段位
		 * type 兵种
		 * rank 段位
		 * normal 是否用圆形无段位图标
		 **/
		public function setArmyIcon(type:int, rank:int = 1, normal:Boolean = false):void
		{
			var img:Image = (this.getChildByName("img") as Image);
			var str:String = !normal ? ModelHero.army_icon_ui[type] : ModelHero.army_icon_ui2[type];
			img.skin = AssetsManager.getAssetsUI(str);
			if(!normal)
				EffectManager.changeSprColor(img, rank - 1, false);
		}
		
		public function setArmyLv(lv:int):void
		{
			if (this.name == "army_grade")
			{
				var b:Boolean = false;
				for (var i:int = 0; i < 6; i++)
				{
					b = (i < lv);
					(this.getChildByName("grade" + i) as Component).gray = !b;
				}
			}
		}
		/**
		 * 加上装备归属英雄
		 **/
		public function setHeroEquipMaster(emd:ModelEquip = null):void
		{
			if (emd){
				var hmd:ModelHero = emd.getMyHero();
				if (hmd){
					var tHero:Label = (this["tHero"] as Label);
					tHero.visible = true;
					tHero.text = hmd.getName();
					Tools.textFitFontSize(tHero);
					tHero.color = '#FFFFFF';
					tHero.strokeColor = hmd.getStrokeColor();
				}
			}
		}
		
		public function setHeroEquipType(emd:ModelEquip = null, type:int = 0, grade:Boolean = false, clv:int = -1,showSpecial:Boolean=false):void
		{
			(this["imgAdd"] as Image).visible = false;
			(this["tStatus"] as Label).visible = false;
			
			(this["tHero"] as Label).visible = false;//
			//(this["imgName"] as Image).visible = false;//imgName
			(this["glowBox"] as Box).visible = false;//glow
			//
			
			var label:Label = (this["label"] as Label);
			var equipType:Image = (this["equipType"] as Image);
			var imgType:Image = (this["imgType"] as Image);
			var img:Image = (this["img"] as Image);
			//
			label.visible = false;
			imgType.visible = false;
			equipType.visible = false;
			img.visible = false;
			imgType.filters = null;
			this["bgColor"].visible = true;
			this["bgColor"].filters = null;
			//
			(this["glowBox"] as Box).destroyChildren();
			if (emd)
			{
				imgType.visible = true;
				imgType.skin = emd.getBack();
				img.visible = true;
				var eSkin:String = AssetsManager.getAssetsICON(ModelEquip.getIcon(emd.id));
				img.skin = "";//eSkin!=img.skin?eSkin:img.skin;
				img.skin = eSkin;
				//
				var mlv:int = (clv > -1) ? clv : emd.getLv();
				EffectManager.changeSprColor(imgType, mlv);
				EffectManager.changeSprColor(this["bgColor"], mlv);
				//
				if (grade)
				{
					if (emd.isMine())
					{
						label.visible = true;
						label.text = mlv + "";
					}
				}
				if (emd.isMine() || showSpecial){
					if(!Tools.isNullString(emd.special)){
						(this["glowBox"] as Box).visible = true;
						var aniglow:Animation=EffectManager.loadAnimation(emd.special,'',0);
						aniglow.blendMode="lighter";
						(this["glowBox"] as Box).addChild(aniglow);
					}
				}
			}
			else
			{
				imgType.visible = false;
				if(type==-1){
					equipType.visible = false;	
				}else{
					equipType.visible = true;
					equipType.skin = AssetsManager.getAssetsUI("icon_zhenbao0" + (type + 1) + ".png");
				}
				EffectManager.changeSprColor(this["bgColor"], 0);
			}
			if(label.text=="" || label.visible==false){
				(this["imgName"] as Image).visible = false
			}


		}
		
		public function setHeroEquipEmbed(typeNum:int, type:int, emd:ModelEquip = null):void
		{
			var b:Boolean = false;
			var imgAdd:Image = (this["imgAdd"] as Image);
			var tStatus:Label = (this["tStatus"] as Label);
			var label:Label = (this["label"] as Label);
			var imgName:Image = (this["imgName"] as Image);
			var tHero:Label = (this["tHero"] as Label);
			var equipType:Image = (this["equipType"] as Image);
			var imgType:Image = (this["imgType"] as Image);
			var img:Image = (this["img"] as Image);
			(this["glowBox"] as Box).visible = false;//glow
			//
			imgAdd.visible = false;
			tStatus.visible = false;
			imgName.visible = label.visible = false;
			tHero.visible = false;
			equipType.visible = false;
			imgType.visible = false;
			img.visible = false;
			imgType.filters = null;
			this["bgColor"].filters = null;
			//
			(this["glowBox"] as Box).destroyChildren();
			if (emd)
			{
				imgType.visible = true;
				imgType.skin = emd.getBack();
				imgName.visible = label.visible = true;
				label.color = ConfigColor.FONT_COLORS[emd.getLv()];
				label.text = emd.getName();
				Tools.textFitFontSize(label);
				//
				img.visible = true;
				var eSkin:String = AssetsManager.getAssetsICON(ModelEquip.getIcon(emd.id));
				img.skin = "";//eSkin!=img.skin?eSkin:img.skin;
				img.skin = eSkin;
				//
				
				EffectManager.changeSprColor(imgType, emd.getLv());
				EffectManager.changeSprColor(this["bgColor"], emd.getLv());
				if (emd.isMine()){
					if(!Tools.isNullString(emd.special)){
						(this["glowBox"] as Box).visible = true;
						var aniglow:Animation=EffectManager.loadAnimation(emd.special,'',0);
						aniglow.blendMode="lighter";
						(this["glowBox"] as Box).addChild(aniglow);
					}
				}				
			}
			else
			{
				equipType.visible = true;
				equipType.skin = AssetsManager.getAssetsUI("icon_zhenbao0" + (type + 1) + ".png");
				tStatus.visible = true;
				imgAdd.visible = true;
				img.skin = "";
				img.visible = true;
				if (typeNum > 0)
				{
					tStatus.text = Tools.getMsgById("_equip21");//可装备
					imgAdd.skin = AssetsManager.getAssetsUI("icon_plusg.png");
				}
				else
				{
					tStatus.text = Tools.getMsgById("_equip22");//"可锻造";
					imgAdd.skin = AssetsManager.getAssetsUI("icon_plusy.png");
				}
				EffectManager.changeSprColor(this["bgColor"], 0);
			}
		}
		
		public function getImgPanel():Sprite
		{
			return this.getChildByName("imgPanel") as Sprite;
		}
		
		public function setBuildingTipsIcon(icon:String, txt:String = "", bg:String = null, flagText:String = null, flagBg:String = null):void
		{
			this.mImg = this["icon_img"];
			this.mLabel = this["label_txt"];
			this.mLabel.text = txt;
			if ("txt_bg" in this) {
				if (Tools.isNullString(txt)) {
					this["txt_bg"].visible = false;
				} else {
					this["txt_bg"].visible = true;
					Image(this["txt_bg"]).width = this.mLabel.textField.textWidth + 20;
				}
			}
			
			this.centerImage(icon);
			//this.mImg.skin = icon;
			//有这个text 一定要有flagBg
			if (flagText)
			{
				var flagTxt:Label = Label(this["flag_txt"]);
				//flagText = "名将切磋";
				flagTxt.text = flagText;
				var flagImage:Image = Image(this["flag_img"]);
				flagImage.skin = flagBg;
				flagImage.width = flagTxt.textField.textWidth + 20;
				this["flag_container"].visible = true;
			}
			else
			{
				if ("flag_container" in this) this["flag_container"].visible = false;
			}
			
			if (bg)
			{
				(this.getImgPanel().getChildByName("bg") as Image).skin = bg;
			}
		}
		
		/**
		 * 居中对齐中间的图标。 但是异步加载的还没有考虑进去！
		 * @param	icon
		 */
		private function centerImage(icon:String):void
		{
			var ww:Number = Math.max(Sprite(this.mImg.parent).width, Sprite(this.mImg.parent).height);
			
			this.mImg.skin = icon;
			if (this.mImg.source)
			{
				var ww2:Number = Math.max(this.mImg.source.sourceWidth, this.mImg.source.sourceHeight);
				this.mImg.size(this.mImg.source.sourceWidth, this.mImg.source.sourceHeight);
				this.mImg.scale(ww / ww2, ww / ww2);
				this.mImg.pos((ww - this.mImg.displayWidth) * 0.5, (ww - this.mImg.displayHeight) * 0.5);
			}
		
		}
		
		public function setBuildingTipsIcon3(hero:String, flagText:String = null, flagBg:String = null):void
		{
			ComPayType(this["icon"]).setHeroIcon(hero, true);
			
			if (flagText)
			{
				var flagTxt:Label = Label(this["flag_txt"]);
				flagTxt.text = flagText;
				var flagImage:Image = Image(this["flag_img"]);
				flagImage.skin = flagBg;
				flagImage.width = flagTxt.textField.textWidth + 20;
			}
		}
		
		public function setReportTag(b:Boolean = false):void
		{
            var imgPanel:Box = this.getChildByName("imgPanel") as Box;
            var reportTag:Button = this.getChildByName("reportTag") as Button;
			imgPanel.gray = reportTag.visible = b;
		}
		
		public function setBuildingTipsIcon2(icon:String, txt:String = "", bg:String = null):void
		{
			if ("icon_img" in this)
			{
				this.mImg = this["icon_img"];
				this.mImg.skin = icon;
			}
			
			if ("label_txt" in this)
			{
				this.mLabel = this["label_txt"];
				this.mLabel.text = txt;
				this.mLabel.y = 18;
				this.mLabel.fontSize = 20;
				if ("txt_bg" in this) {
					this["txt_bg"].visible = false;
				}
				
			}
			
			if (bg)
			{
				(this.getImgPanel().getChildByName("bg") as Image).skin = bg;
			}
		}
		
		/**
		 * 从若干备选容器中获取指定name的元件，最后尝试直接从this拿取
		 */
		public function getNodeByName(com:*, name:String):Node
		{
			var reNode:Node;
			var tempSpr:Sprite;
			if (com is Array){
				var arr:Array = com as Array;
				var len:int = arr.length;
				for (var i:int = 0; i < len; i++) 
				{
					tempSpr = arr[i] as Sprite;
					if(tempSpr){
						reNode = tempSpr.getChildByName(name);
						if (reNode)
							return reNode;
					}
				}
			}
			else if (com is Sprite){
				tempSpr = com as Sprite;
				reNode = tempSpr.getChildByName(name);
			}
			if (!reNode)
				reNode = this.getChildByName(name);
			return reNode;
		}
		
		/**
		 * 设置 英雄 头像,sm == true 是小图
		 */
		public function setHeroIcon(hid:String, sm:Boolean = true, bgColor:int = -1, vbg:Boolean = true, waitShow:Boolean = false):void
		{
			var panel:Sprite = this.getImgPanel();

			var iconImg:Image = this.getNodeByName(panel,"img") as Image;
			var imgAwaken:Image = this.getNodeByName(panel, "imgAwaken") as Image;
			var heroBg:Image = this.getNodeByName(panel, "heroBg") as Image;
			if (!hid) {
				if(iconImg)
					iconImg.visible = false;
				if(heroBg)
					heroBg.visible = false;
				return;
			}
			var head:String=hid;
			if(hid.indexOf('_')!=-1){
				hid=hid.split('_')[0];
			}
			var _this:ComPayType = this;
			var heroConfig:Object = ConfigServer.hero[hid];
			if (heroConfig && heroConfig.icon)
			{
				hid = heroConfig.icon;
			}

			var isAwaken:Boolean=(head.indexOf('_')!=-1);
			if(imgAwaken) imgAwaken.visible=isAwaken;

			var imgURL:String = AssetsManager.getAssetsHero(hid, sm);
			var changeB:Boolean = false;
			if (this["bgbgbg"])
			{
				this["bgbgbg"].visible = vbg;
			}
			iconImg.visible = true;
			_this.layoutHeroIcon(iconImg, sm);
			if (iconImg && sm)
			{
				if (iconImg["iconURL"])
				{
					if (iconImg["iconURL"] != imgURL)
					{
						changeB = true;
					}
				}
				else
				{
					changeB = true;
				}
			}
			else
			{
				changeB = true;
			}
			if(waitShow){
				this.visible = !changeB;
			}			
			//if(!sm){
				LoadeManager.addTempHeroBigImg(imgURL);
			//}
			if (changeB)
			{
				iconImg["iconURL"] = imgURL;
				LoadeManager.loadImg(imgURL, Handler.create(_this, function(curl:String, csm:Boolean, cimg:Image,cwaitShow:Boolean):void
				{
					if (cimg && cimg.parent)
					{
						if (cimg["iconURL"] == curl || !csm)
						{
							if (!csm)
							{
								cimg.skin = "";
							}
							cimg.skin = curl;
						}
						if(cwaitShow){
							_this.visible = true;
						}
						_this.layoutHeroIcon(cimg, csm);
					}
				}, [imgURL, sm, iconImg,waitShow]));
			}

			var bgf:Image =  this.getNodeByName(panel,"bgf") as Image;
			var awakenBg:Image = this.getNodeByName(panel,"awakenBg") as Image;
			if (bgColor > -1)
			{
				if (heroBg)
				{
					heroBg.visible = true;
					EffectManager.changeSprColor(heroBg, bgColor, false);
				}
				if (awakenBg)
				{
					awakenBg.visible = isAwaken;
					if(isAwaken) EffectManager.changeSprColor(awakenBg, bgColor, false);
				}
				if (bgf)
				{
					bgf.visible = true;
					EffectManager.changeSprColor(bgf, bgColor, false);
				}
			}
			else
			{
				if (heroBg)
					heroBg.visible = false;
				if (bgf)
					bgf.visible = false;
				if (awakenBg)
					awakenBg.visible = false;
			}
		}
		
		public function layoutHeroIcon(iconImg:Image, sm:Boolean):void
		{
			if (this.name == "hero_icon1")
			{
			}
			else if (this.name == "hero_icon2")
			{
				//250x300
				if (sm)
				{
					iconImg.height = this.height;
					iconImg.width = Math.floor(iconImg.height * 250 / 300);
				}
				else
				{
					iconImg.width = this.width;
					iconImg.height = Math.floor(iconImg.width * 640 / 640);
				}
				//
				if (this.parent && !sm)
				{
					var ph:Number = (this.parent as Component).height;
					if (this.height >= ph)
					{
						iconImg.height = ph;
						iconImg.width = Math.floor(ph * 640 / 640);
							//
					}
					else
					{
						iconImg.bottom = 0;
					}
				}
				iconImg.x = Math.floor((this.width - iconImg.width) * 0.5);
			}
		}
		
		/**
		 * 关卡等级
		 */
		public function setPVEStar(n:int):void
		{
			//if(n==0){
			//	return;
			//}
			var img:Image;
			for (var i:int = 1; i <= 3; i++)
			{
				img = this.getChildByName("hStar" + i) as Image;
				if (i <= n)
				{
					img.skin = AssetsManager.getAssetsUI("icon_64.png");
				}
				else
				{
					img.skin = AssetsManager.getAssetsUI("icon_64_0.png");
				}
			}
		}
		
		/**
		 * 设置是否选中
		 */
		public function setHeroSelection(b:Boolean):void
		{
			var img:Image = this.getNodeByName(this.getImgPanel(), "sImg") as Image;
			if (img)
			{
				img.visible = b;
			}
		}
		
		/**
		 * 设置国家旗帜（颜色和文字）
		 */
		public function setCountryFlag(index:int):void {
			var country_sign:Object = ConfigServer.world.country_sign;
			var nameLabel:Label = this.getChildByName("label") as Label;
			var img:Image = this.getChildByName("img") as Image;
			if (!img && !nameLabel) {
				this.alpha = 0.2;
				return;
			}
			img.visible = nameLabel.visible = false;
			this.alpha = 1;
			this.setCountryColor(index);
			var msgId:String = country_sign[index].name;
			var icon:String = country_sign[index].icon;
			if (icon) {
				img.visible = true;
				img.skin = AssetsManager.getAssetsUI(icon);
			} else if (msgId) {
				nameLabel.visible = true;
				nameLabel.text = Tools.getMsgById(msgId);
				nameLabel.color = EffectManager.getFontColor(index, ConfigServer.world.COUNTRY_FONT_COLORS);
				nameLabel.strokeColor = EffectManager.getFontColor(index, ConfigServer.world.COUNTRY_FONT_STROKE_COLORS);
			}
		}
		
		/**
		 * 设置国家颜色
		 */
		public function setCountryColor(index:int):void
		{
			var flagImg:Image = this.getChildByName("flag") as Image;
			EffectManager.changeSprColor(flagImg, index, true, ConfigServer.world.COUNTRY_COLOR_FILTER_MATRIX);
		}
		
		/**
		 * 技能item
		 */
		public function setSkillItem(smd:ModelSkill, value:* = null, str:String = null, autoFit:Boolean = true):void
		{
			var _name:Label = this.getChildByName("nameLabel") as Label;
			var _lv:Label = this.getChildByName("lvLabel") as Label;
			var _img:Image = this.getChildByName("typeIcon") as Image;

			//var n:Number=s.getSkillColor(hmd);
			
			var sLv:int;
			if (value is ModelHero)
			{
				var hmd:ModelHero = value;
				sLv = smd.getLv(hmd);
			}
			else if (value >= 0)
			{
				sLv = value;
			}
			
			if (_name)
			{
				if (autoFit){
					Tools.textScale(_name);
					Tools.textFitFontSize2(_name, smd.getName());
				}
				else{
					_name.text = smd.getName();
				}
			}
			if (_lv)
			{
				if (sLv)
				{
					_lv.text = sLv + "";
				}
				else
				{
					_lv.text = "-";
				}	
			}
			if (str){
				if (autoFit){
					Tools.textScale(_lv);
					Tools.textFitFontSize(_lv, _lv.text+str, 0, 10);
				}
				else{
					_lv.text = _lv.text+str;
				}
				
			}
			if (_img)
			{
				if (smd.data.type >= 0)
				{
					_img.visible = true;
					_img.skin = smd.getSkillTypeIcon();
				}
				else
				{
					_img.visible = false;
				}
					//trace("=====================",s.type,_img.skin,s.getName());
			}
			
			var color:int;
			var isHeroSkill:Boolean = smd.type == 4;
			if (smd.getTypeValue() < 0 || value == null){
				color = -1;
			}
			else
			{
				color = 0;
				var o:Array = ConfigServer.system_simple.skill_color[smd.cost_type];
				for (var i:int = o.length - 1; i >= 0; i--)
				{
					if (sLv >= o[i])
					{
						color = i;
						break;
					}
				}
			}
			this.setSkillBgColor(color, isHeroSkill);
		}
		/**
		 * * 修改技能边框和背景颜色 color上色编号0白1绿2蓝3紫4金5红
		 */
		public function setSkillBgColor(color:int, isHeroSkill:Boolean):void
		{
			var _bg:Image = this.getChildByName("bgImg") as Image;
			var _kuang:Image = this.getChildByName("bgKuang") as Image;
			var _line:Image = this.getChildByName("lineImg") as Image;
			if (_bg){
				EffectManager.changeSprColor(_bg, color);
			}
			if (_kuang){
				EffectManager.changeSprColor(_kuang, color);
				_kuang.visible = isHeroSkill;
			}
			if (_line && _line.visible){
				EffectManager.changeSprColor(_line, color);
			}
		}
		/**
		 * 开关技能item的竖线是否可见
		 */
		public function setSkillLineVisible(b:Boolean):void
		{
			var _img:Image = this.getChildByName("lineImg") as Image;
			if (_img){
				if (_img.visible != b){
					var _name:Label = this.getChildByName("nameLabel") as Label;
					var _lv:Label = this.getChildByName("lvLabel") as Label;
					if (_lv)
						_lv.visible = b;
					_img.visible = b;
					var dis:Number = b? 43: -43;
					if (!_name['originalWidth']){
						_name['originalWidth'] = _name.width;
					}
					_name['originalWidth'] += dis;
					_name.right += dis;
				}
			}
		}
		
		public function setRankIndex(v:*, tips:String = "", isTop:Boolean = false):void
		{
			var index:int = parseInt(v);
			(this.getChildByName("img1") as Image).visible = (index == 1);
			(this.getChildByName("img2") as Image).visible = (index == 2);
			(this.getChildByName("img3") as Image).visible = (index == 3);
			(this.getChildByName("img4") as Image).visible = (index > 3);
			//
			(this.getChildByName("label") as Label).text = (index > 0) ? ("" + index) : ((tips == "") ? "--" : tips);
			if (isTop && index >= 1 && index <= 3)
			{
				(this.getChildByName("label") as Label).text = "";
			}
		}
		
		
		public function setScienceUI(smd:ModelScience, colorB:Boolean = false):void
		{
			var img:Image = this["img"];
			var bg:Image = this["bg"];
			bg.filters = null;
			img.visible = false;
			
			if (smd)
			{
				bg.skin = AssetsManager.getAssetsUI(ModelScience.type_ui[smd.type]);
				// (this["imgMask"] as Image).skin = AssetsManager.getAssetsUI(ModelScience.type_ui_mask[smd.type]);
				img.visible = true;
				img.skin = AssetsManager.getAssetsScience(smd.icon);
				//
				if (colorB)
				{
					EffectManager.changeSprColor(this["imgMask"], smd.color);
				}
			}
		}
		/**
		 * 封地建筑
		 */
		public function setBuildingInfoLv(bmd:ModelBuiding, isNew:Boolean = false, showName:Boolean = true):void
		{
			this["imgName"].visible = this["tbName"].visible = showName;
			if(showName){
				this["tbName"].text = bmd.getName();
			}
			this["tbLv"].text = "" + (isNew ? (bmd.lv - 1) : bmd.lv);
			var nmax:Number = isNew ? bmd.lv : (bmd.lvNext());
			this["tbLvNext"].text = "" + nmax + (bmd.checkIsMaxLv(nmax + 1) ? "(" + Tools.getMsgById("_public9") + ")" : "");
			this["bIcon"].destroyChildren();
			this["bIcon"].addChild(bmd.getAnimation());
		}
		
		public function setBuildingInfoInfo(bmd:ModelBuiding, isNew:Boolean = false, isArmy:Boolean = false, baseLv:Number = -1, armyBase:Boolean = false):void
		{
			this["text0"].text = Tools.getMsgById("_hero29");
			var isProduce:Boolean = bmd.produce > -1;
			this["armyBox"].visible = false;
			this["aBox"].visible = false;
			this["tInfo"].visible = !isProduce;
			this["tInfo"].x = 6;
			this["tInfo"].y = 6;
			this["tInfo"].width = (this.parent as Sprite).width - 6;
			this["tInfo"].height = (this.parent as Sprite).height - 6;
			this["tInfo"].style.fontSize = 18;
			this["tInfo"].style.color = "#c3ebff";
			this["tInfo"].style.wordWrap = true;
			this["tInfo"].style.leading = 5;
			this["pBox"].visible = isProduce;
			var clv:Number = isNew ? bmd.lv - 1 : bmd.lv;
			var nlv:Number = isNew ? bmd.lv : bmd.lvNext();
			if (baseLv >= 0)
			{
				clv = baseLv;
				nlv = baseLv + 1;
			}
			if (isProduce)
			{
				var pArr0:Array = bmd.getMyGiftEvery(clv);
				var pArr1:Array = bmd.getMyGiftEvery(nlv);
				//
				this["pImg"].skin = AssetsManager.getAssetPayIconBig(ModelBuiding.material_type[bmd.produce + 1]);
				this["pNum"].text = Math.round(pArr0[2]) + "/" + Tools.getMsgById("_public124");//"/每小时";
				this["pNumNext"].text = Math.round(pArr1[2]) + "/" + Tools.getMsgById("_public124");
				this["pName"].text = Tools.getNameByID(ModelBuiding.material_type[bmd.produce + 1]);// ModelBuiding.material_type_name[ModelBuiding.material_type[bmd.produce+1]];
			}
			else
			{
				
				if (bmd.isArmy())
				{//兵营建筑 ,特殊 信息 处理
					//
					var unlockStr:String = "";
					var unlockStr2:String = "";
					var newLv:int = ModelBuiding.getArmyBuildingNewLvIndex(bmd.id, clv);
					if (newLv >= 0){
						unlockStr = "";
						unlockStr2 = Tools.getMsgById("_building47", [newLv + 1, ModelBuiding.getArmyBuildingLvCfg(bmd.id, (newLv + 1))[3], ModelHero.army_type_name[ModelBuiding.army_type[bmd.id]]]);
					}
					if (isArmy)
					{
						this["iBg"].visible = false;
						this["aBox"].visible = true;
						this["tInfo"].visible = false;
						var n1:Number = ModelBuiding.army_type[bmd.id];
						var n2:Number = ModelBuiding.getArmyNextGradeByType(ModelBuiding.army_type[bmd.id]);
						var armyAID:String = "army" + n1 + "" + n2;
						(this["aIcon"] as Box).destroyChildren();
						if(HelpConfig.type_app == HelpConfig.TYPE_WW){
							if(this["aImg"]) (this["aImg"] as Image).skin = AssetsManager.getAssetsArmy(armyAID);
							if(this["aImg"]) (this["aImg"] as Image).visible = true;
						}else{
							if(this["aImg"]) (this["aImg"] as Image).visible = false;
							var sp:Sprite = EffectManager.loadArmysIcon(armyAID);
							sp.scaleX = 1.4; 
                			sp.scaleY = 1.4;
							(this["aIcon"] as Box).addChild(sp);
						}
						
						(this["aIcon"] as Box).x = this.width * 0.5;
						(this["aIcon"] as Box).y = 40 + (this.height - 40) * 0.5;
						//					
						this["aTips1"].text = Tools.getMsgById("_building48");//"减少训练时间";
						this["aTips2"].text = unlockStr2;
						return;
					}
					
					//					
					var cfgLvCurr:Array = ModelBuiding.getArmyBuildingLvCfg(bmd.id, clv);
					var cfgLvNext:Array = ModelBuiding.getArmyBuildingLvCfg(bmd.id, nlv);
					var armyNumMax:String = "";
					var armyMakeTime:String = "";
					var armyClass:String = "";
					var atk:String = "";
					// var def:String = "";
					// var spd:String = "";
					var armyCurr:Array;
					var armyCurrObj:Object;
					// var hpm:String = "";
					if (armyBase)
					{
						armyCurr = ModelBuiding.getArmyMakeCfgByGrade(cfgLvCurr[3], bmd.getArmyType());
						armyCurrObj = ModelPrepare.getArmyRankData(bmd.getArmyType(), cfgLvCurr[3]);
						//
						atk = Tools.getMsgById("_building49", [armyCurrObj.atkBase, armyCurrObj.defBase, armyCurrObj.spdBase]);
						// "<br/> 攻击 : "+armyCurrObj.atkBase;//armyCurr[0];
						// def = "<br/> 防御 : "+armyCurrObj.defBase;//armyCurr[1];
						// spd = "<br/> 速度 : "+armyCurrObj.spdBase;//armyCurr[2];
						//
						this["armyBox"].visible = true;
						this["iBg"].visible = false;
						this["tInfo"].visible = false;
						this["t0"].text = Tools.getMsgById("_public125");//"基础攻击";
						this["t1"].text = Tools.getMsgById("_public126");//"基础防御";
						this["t2"].text = Tools.getMsgById("_public127");//"基础速度";
						this["ta0"].text = armyCurrObj.atkBase;
						this["ta1"].text = armyCurrObj.defBase;
						this["ta2"].text = armyCurrObj.spdBase;

						this["t0"].width = this["t0"].textField.textWidth;
						this["t1"].width = this["t1"].textField.textWidth;
						this["t2"].width = this["t2"].textField.textWidth;
						var n:Number = 0;
						if(this["t0"].width>n) n = this["t0"].width;
						if(this["t1"].width>n) n = this["t1"].width;
						if(this["t2"].width>n) n = this["t2"].width;
						this["ta0"].x = this["t0"].x + n + 8;
						this["ta1"].x = this["t0"].x + n + 8;
						this["ta2"].x = this["t0"].x + n + 8;

						this["armyLv"].text = Tools.getMsgById("100001", [ModelBuiding.getArmyBuildingLvCfg(bmd.id, newLv)[3]])//+"级";		
						this["armyType"].text = ModelHero.army_type_name[ModelBuiding.army_type[bmd.id]];
						return;
					}
					else
					{
						var armyName:String = ModelHero.army_type_name[ModelBuiding.army_type[bmd.id]];
						var armyMax:Number = bmd.getArmyNumMax(clv);
						var armyStore:String = Tools.getMsgById("_building50", [armyName, armyMax + StringUtil.htmlFontColor("+" + (bmd.getArmyNumMax(nlv) - armyMax), "#6dfe7e")]);
						// armyName+"库存 : "++"<br/>";
						//
						var armyMakeMax:Number = bmd.getArmyCanMakeNumMax(clv);
						var armyStoreMake:String = Tools.getMsgById("_building51", [armyName, armyMakeMax + StringUtil.htmlFontColor("+" + (bmd.getArmyCanMakeNumMax(nlv) - armyMakeMax), "#6dfe7e")]);
						// armyName+"训练量 : "++"<br/>";						
						armyClass = armyStore + armyStoreMake;
						if (cfgLvNext)
						{
							// if(cfgLvNext[2]>cfgLvCurr[2]){
							// 	armyNumMax = "<br/> 升级增加兵力库存上限";
							// }
							if (cfgLvNext[0] < cfgLvCurr[0])
							{
								armyMakeTime = Tools.getMsgById("_building52");//"训练速度增加<br/>";
							}
							if (clv <= 0)
							{
								armyClass = "";
								unlockStr = Tools.getMsgById("_building53", [armyName]);//"可训练1级"+armyName;
							}
							else
							{
								if (cfgLvNext[3] != cfgLvCurr[3])
								{
									var armyNext:Array = ModelBuiding.getArmyMakeCfgByGrade(cfgLvNext[3], bmd.getArmyType());
									var armyNextObj:Object = ModelPrepare.getArmyRankData(bmd.getArmyType(), cfgLvNext[3]);
									//
									armyCurr = ModelBuiding.getArmyMakeCfgByGrade(cfgLvCurr[3], bmd.getArmyType());
									armyCurrObj = ModelPrepare.getArmyRankData(bmd.getArmyType(), cfgLvCurr[3]);
									//
									unlockStr = Tools.getMsgById("_building54", [armyName, ModelBuiding.getArmyBuildingLvCfg(bmd.id, newLv)[3] + StringUtil.htmlFontColor("+1", "#6dfe7e"), armyCurrObj.atkBase + StringUtil.htmlFontColor("+" + (armyNextObj.atkBase - armyCurrObj.atkBase), "#6dfe7e"), armyCurrObj.defBase + StringUtil.htmlFontColor("+" + (armyNextObj.defBase - armyCurrObj.defBase), "#6dfe7e"), armyCurrObj.spdBase + StringUtil.htmlFontColor("+" + (armyNextObj.spdBase - armyCurrObj.spdBase), "#6dfe7e"),]);
										// armyName+"等级 : "++"<br/>";
										// atk = armyName+"攻击 : "+armyCurrObj.atkBase+StringUtil.htmlFontColor("+"+(armyNextObj.atkBase-armyCurrObj.atkBase),"#6dfe7e")+"<br/>";//armyCurr[0];
										// def = armyName+"防御 : "+armyCurrObj.defBase+StringUtil.htmlFontColor("+"+(armyNextObj.defBase-armyCurrObj.defBase),"#6dfe7e")+"<br/>";//armyCurr[1];
										// spd = armyName+"速度 : "+armyCurrObj.spdBase+StringUtil.htmlFontColor("+"+(armyNextObj.spdBase-armyCurrObj.spdBase),"#6dfe7e")+"<br/>";//armyCurr[2];
										// hpm = "\n 能力 : "+armyCurrObj.hpmBase;//armyCurr[3];							
										// hpm = hpm + " -> "+ armyNextObj.hpmBase;//armyNext[3];
								}
							}
						}
					}
					this["tInfo"].innerHTML = armyClass + unlockStr + armyNumMax + armyMakeTime + atk;//+ def+spd;//,"#6dfe7e","#c3ebff";//+hpm;
				}
				else
				{
					this["tInfo"].innerHTML = bmd.getIntroduceStr();
				}
			}
		}
		
		/**
		 * index 官职  otherInvade 天下大势  
		 */
		public function setOfficialIcon(index:int,otherInvade:int = -1,country:* = ""):void
		{
			var img:Image = this.getChildByName("img") as Image;
			var lab:Label = this.getChildByName("label") as Label;
			if (index == -100)
			{
				img.visible = false;
				lab.text = "";
			}
			else
			{
				img.skin = AssetsManager.getAssetsUI('img_icon_42.png');
				img.visible = true;
				lab.text = ModelOfficial.getOfficerName(index, otherInvade, country);
				EffectManager.changeSprColor(img, ModelOfficial.getOfficerColorLevel(index, otherInvade));
			}
		}
		
		public function setCityBuffs(type:int, txt:String):void
		{
			this["func1"].visible = type == 1;
			this["func2"].visible = type == 2;
			this["func"].visible = type == 3;
			this["tFunc"].text = txt;
		}
		
		/**
		 * 更换宝箱素材
		 */
		public function changeRewardBox(skin:String):void{
			var box:Box = this.getChildByName("box") as Box;
			var boxImg:Image = box.getChildByName("boxImg") as Image;
			if (boxImg){
				boxImg.skin = skin;
			}
		}
		
		/**
		 * 设定奖励宝箱状态 0不可开启 1可开未开 2已经领取
		 */
		public function setRewardBox(type:int):void{
			this['boxType'] = type;
			var box:Box = this.getChildByName("box") as Box;
			var bgImg:Image = this.getChildByName("bgImg") as Image;
			var boxImg:Image = box.getChildByName("boxImg") as Image;
			var getImg:Image = this.getChildByName("getImg") as Image;
			if (bgImg){
				if (!bgImg.anchorX){
					//不做旋转，可领奖时显示
					bgImg.visible = type == 1;
				}
				else{
					//可领奖时旋转
					bgImg.alpha = type != 2 ? 1:0.3;
					if (type == 1){
						EffectManager.startFrameRotate(bgImg, 0.2);
					}
					else{
						EffectManager.endFrameRotate(bgImg);
					}
				}
			}
			if (boxImg){
				var canImg:Image = boxImg.getChildByName("canImg") as Image;
				if (canImg){
					canImg.visible = type == 1;
					if(type == 2){
						EffectManager.changeSprBrightness(boxImg, 0.8);
						boxImg.alpha = 0.7;
					}
					else
					{
						EffectManager.changeSprColorFilter(boxImg, null);
						boxImg.alpha = 1;
					}
					//boxImg.gray = type == 2;
				}
				else{
					//不可领奖时灰色
					boxImg.gray = type != 1;
				}
				boxImg.scale(1, 1);
				Tween.clearAll(boxImg);
				if (type == 1){
					EffectManager.tweenLoop(boxImg, {scaleX:1.15, scaleY:1.15}, 300, Ease.sineInOut, null, 50, -1, 600);
				}
			}
			if (getImg){
				getImg.visible = type == 2;
			}
			box.rotation = 0;	
			Tween.clearAll(box);
			if (type == 1){
				//可领奖，颤抖
				EffectManager.tweenShake(box, {rotation:5}, 100, Ease.sineInOut, null, 650, -1, 900);
			}
		}

		/**
		 * 组件btn_icon_double_txt的设置
		 */
		public function setDoubleTxt(num0:Number,num1:Number,costId:String="coin"):void{
			var box:Box = this.getChildByName("box") as Box;
			var img:Image = box.getChildByName("img") as Image;
			var lab0:Label = box.getChildByName("label0") as Label;
			var lab1:Label = box.getChildByName("label1") as Label;
			var imgLine:Image = box.getChildByName("imgLine") as Image;
			lab1.text=num1+"";
			var n:Number=img.width;
			if(costId==""){
				img.visible=false;
				n=0;
			}else{
				img.skin=AssetsManager.getAssetItemOrPayByID(costId);
				img.visible=true;
			}

			if(num0==0 || num0==num1){
				lab0.text="";
				imgLine.visible=false;
				lab1.x=n+1;
				box.width=n+lab1.width;
			}else{
				lab0.text=num0+"";
				imgLine.visible=true;
				lab0.x=n+1;
				lab1.x=lab0.width+lab0.x+5;
				box.width=n+lab0.width+lab1.width+6;
				imgLine.width=lab0.width;
				imgLine.x=lab0.x;
			}
			
			box.centerX=0;
		}

		/**
		 * 面板标题设置
		 */
		public function setViewTitle(str:String,isGold:Boolean=false):void{
			var img:Image = this.getChildByName("img") as Image;
			var lab:Label = this.getChildByName("label") as Label;
			//img.skin=!isGold?"ui/bar_30.png":"ui/bar_30_1.png";
			//lab.color=!isGold?"#c5dbff":"#fff47c";
			lab.text=str;
			if(HelpConfig.type_app == HelpConfig.TYPE_WW){
				img.width=lab.width<=100 ? 200 : lab.width + 110;
			}else{
				img.width=lab.width<=125 ? 200 : lab.width + 75;
			}
			

		}

		/**
		 *  图文混排 com_text_pic专用
		 * _str=文字@道具id@文字
		 */
		public function setTextWithPic(_str:String):void{
			/*
			var html:HTMLDivElement=this.getChildByName("html") as HTMLDivElement;
			html.style.color="#FFFFFF";
			html.style.fontSize=24;
			html.style.wordWrap=false;
			var itemID:String;
			if(iid==""){
				var n1:Number=_str.indexOf("@");
				var n2:Number=n1!=-1 ? _str.indexOf("@",n1+1) : -1;
				itemID=n1!=-1 && n2!=-1 ? _str.split("@")[1] : "";
			}else{
				itemID=iid;
			}

			if(itemID==""){
				html.innerHTML=str;
			}else{
				var itemUrl:String=ModelItem.getIconUrl(itemID);
				str=str.replace("@"+itemID+"@", "<img src='"+itemUrl+"' style='width:28px;height:28px'></img>");
				html.innerHTML=str;
			}
			this.width=html.contextWidth;
			*/
			var img:Image = this.getChildByName("img") as Image;
			var label0:Label = this.getChildByName("label0") as Label;
			var label1:Label = this.getChildByName("label1") as Label;
			var itemID:String;
			var arr:Array=_str.split("@");
			var n1:Number=_str.indexOf("@");
			var n2:Number=n1!=-1 ? _str.indexOf("@",n1+1) : -1;
			itemID=n1!=-1 && n2!=-1 ? _str.split("@")[1] : "";
			label0.text="";
			label1.text="";
			img.visible=false;
			if(itemID==""){
				label0.text=_str;
			}else{
				img.visible=true;
				var itemUrl:String=ModelItem.getIconUrl(itemID);
				label0.text=arr[0]+"";
				label1.text=arr[2]+"";
				img.skin=itemUrl;
			}
			label0.x=0;
			img.x=label0.width;
			label1.x=img.x+img.width;
			this.width=label1.x+label1.width;
			img.offAll(Event.CLICK);
			img.on(Event.CLICK,this,function():void{
				ViewManager.instance.showItemTips(itemID);
			});
		}

		/**
		 * 英雄觉醒组件
		 */
		public function setAwakenIcon(hid:String):void {
			var rarity:Number=ConfigServer.hero[hid]?ConfigServer.hero[hid].rarity:0;
			var imgAwaken:Image=this.getChildByName("imgAwaken") as Image;
			if(HelpConfig.type_app == HelpConfig.TYPE_SG){
				imgAwaken.skin=AssetsManager.getAssetsUI(rarity === 4 ? "icon_paopao1_1.png" : "icon_paopao1.png");
			}
		}

		/**
		 * 英雄天赋组件
		 */
		public function setTalentIcon(hid:String):void {
			var mt:ModelTalent = ModelTalent.getModel(hid);
			var tTalent:Label=this.getChildByName("tTalent") as Label;
			var imgTalent:Image=this.getChildByName("imgTalent") as Image;
			if (mt){
				this.visible = true;
				tTalent.text = mt.getName();
				Tools.textFitFontSize2(tTalent);
				var rarity:Number=ConfigServer.hero[hid]?ConfigServer.hero[hid].rarity:0;
				imgTalent.skin=AssetsManager.getAssetsUI(rarity==4?"icon_paopao1_1.png":"icon_paopao1.png");
			}else{
				this.visible = false;
			}
		}

		/**
		 * 设置小标题(组件 item_title_s)
		 */
		public function setSamllTitle(s:String,v:Boolean=false):void{
			var img:Image = this.getChildByName("img") as Image;
			var bg:Image = this.getChildByName("bg") as Image;
			var label:Label = this.getChildByName("label") as Label;
			label.text=s;
			bg.visible=v;
			label.width=label.displayWidth;
			img.width=label.width+240;
			img.centerX=label.centerX=bg.centerX=0;
		}


		/**
		 * 设置按钮样式 
		 */
		public function setBtton():void{

		}
		/**
		 * 组件 btn_goto专用
		 */
		public function setGotoBtn(str:String):void{
			var img:Image = this.getChildByName("img") as Image;
			var bg:Image = this.getChildByName("bg") as Image;
			var label:Label = this.getChildByName("text") as Label;
			label.text = str;
			Tools.textFitFontSize(label);
		}

		/**
		 * 设置赛季等级
		 */
		public function setHonourLv(lv:int):void{

		}



	}

}