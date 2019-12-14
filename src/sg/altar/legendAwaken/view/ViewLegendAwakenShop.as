package sg.altar.legendAwaken.view
{
    import ui.legendAwaken.legendAwakenShopUI;
    import sg.altar.legendAwaken.model.ModelLegendAwaken;
    import sg.manager.AssetsManager;
    import sg.utils.Tools;
    import sg.boundFor.GotoManager;
    import sg.manager.ViewManager;
    import laya.events.Event;
    import sg.cfg.ConfigClass;
    import sg.manager.ModelManager;
    import sg.model.ModelHero;
    import sg.cfg.ConfigServer;
    import laya.utils.Handler;
    import sg.net.NetMethodCfg;
    import sg.manager.LoadeManager;
    import sg.manager.EffectManager;
    import sg.cfg.ConfigColor;
    import sg.utils.ObjectUtil;
    import sg.utils.TimeHelper;
    import laya.particle.Particle2D;
    import sg.guide.model.ModelGuide;
    import laya.ui.Label;
    import laya.utils.Tween;
    import laya.utils.Ease;

    public class ViewLegendAwakenShop extends legendAwakenShopUI {
        public var model:ModelLegendAwaken = ModelLegendAwaken.instance;
        private var cfg:Object = model.cfg;
		private var mParticles:Array;
        public function ViewLegendAwakenShop() {
            comTitle.setViewTitle(Tools.getMsgById(cfg.name[1]));
            txt_item.text = Tools.getMsgById('500309') + ':';
            txt_pay_hint.text = Tools.getMsgById('500315');
            Tools.textFitFontSize(txt_pay_hint);
            list.itemRender = LegendAwakenListBase;
            list.scrollBar.hide = true;
            list.selectEnable = true;
            list.selectHandler = new Handler(this, this._onSelect);
            btn_help.on(Event.CLICK, this, this._onClickHelp);
            comAwaken.on(Event.CLICK, this, this._onClickTalent);
            comTalent.on(Event.CLICK, this, this._onClickTalent);
            heroIcon.on(Event.CLICK, this, this._onClickHero);
            btn_awaken.label = Tools.getMsgById('500307');
            btn_draw.label = Tools.getMsgById('500306');
            btn_pay.label = Tools.getMsgById('_jia0141');
            box_hint.on(Event.CLICK, this, this._onClickPay);
            btn_draw.on(Event.CLICK, this, this._gotoDraw);
            btn_price.on(Event.CLICK, this, this._onClickBuy);
            itemIcon.on(Event.CLICK, this, this._onClickItem);
        }

        override public function initData():void {
            this.refreshPanel();
            list.selectedIndex = 0;
            model.on(ModelLegendAwaken.UPDATE_DATA, this, this.refreshPanel);
        }

        override public function onAdded():void {
            ModelGuide.executeGuide('awaken_guide');
            this.refreshTime();
            Laya.timer.loop(1000, this, this.refreshTime);
        }

        public function refreshPanel():void {
            var arr:Array = model.listData.sort(function (a:Object, b:Object):Number {
                if (a.awaken && !b.awaken) {
                    return 1;
                } else if (!a.awaken && b.awaken) {
                    return -1;
                } else {
                    return 0;
                }
            });
            list.array = arr;

            // 判断是否需要居中
            var listX:Number = 14;
            if (arr.length < 5) {
                var num:int = arr.length;
                listX = (list.width - (list.getCell(0).width * num + list.spaceX * (num - 1))) * 0.5;
            }
            Laya.timer.callLater(this, function():void {
                list.x = listX;
            });

            itemIcon.setData(AssetsManager.getAssetsICON(model.itemId + '.png'), model.score);
            this._onSelect(list.selectedIndex);
        }
 
        private function refreshTime():void {
             if (model.getRemainingTime(true)) {
                txt_time.text = Tools.getMsgById('500314', [model.getTimeString(true)]);
             } else {
                 this.closeSelf();
             }
        } 
		
		private function clearParticles():void{
			if (this.mParticles){
				for (var i:int = 0,len:int = this.mParticles.length; i < len; i++) {
					var part:Particle2D = this.mParticles[i];
					part.stop();
				}
			}
            this.mParticles = null;   	
		}

        override public function onRemoved():void {
            Laya.timer.clear(this, this.refreshTime);
            model.off(ModelLegendAwaken.UPDATE_DATA, this, this.refreshPanel);
			this.clearParticles();
        }

        private function _onClickTalent():void {
            var hid:String = list.array[list.selectedIndex].hid;
            if(ConfigServer.hero.hasOwnProperty(hid)){
                var hmd:ModelHero = new ModelHero(true);
                var c:Object = ConfigServer.hero[hid];
                c["awaken"] = 1;
                c["hid"] = hid;
                hmd.setData(c);
                ViewManager.instance.showView(ConfigClass.VIEW_HERO_TALENT_INFO, hmd);		
            }
        }

        private function _onClickHero():void {
            var hid:String = list.array[list.selectedIndex].hid;
            if(ConfigServer.hero.hasOwnProperty(hid)){
                var hmd:ModelHero = new ModelHero(true);
                var c:Object = ConfigServer.hero[hid];
                c["awaken"] = 1;
                c["hid"] = hid;
                hmd.setData(c);
                ViewManager.instance.showItemTips(hmd.itemID);
            }
        }

        private function _onSelect(index:int):void {
            if (index < 0)  return;
            list.array.forEach(function(element:Object, index2:int):void {
                element.select = index === index2;
            }, this);
            
            var curData:Object = list.array[list.selectedIndex];
            var hid:String = curData.hid;
            var md:ModelHero = new ModelHero(true);
            md.initData(hid, ConfigServer.hero[hid]);
            comTalent.setTalentIcon(hid);
            comAwaken.setAwakenIcon(hid);
            imgRarity.skin = md.getRaritySkin();
            heroIcon.setHeroIcon(md.id, false);

			this.clearParticles();
            heroIcon.mParticlesBottom.visible = heroIcon.mParticles.visible = true;
            heroIcon.mParticles.removeChildren();
            heroIcon.mParticlesBottom.removeChildren();

            var particle_config:Array = null;
            if( md.rarity === 4) {
                particle_config = ConfigColor.PARTICLE_CONFIG_BY_HERO_RARITY[md.rarity];
                heroIconBg.visible=false;
                imgSuper.visible=true;
                LoadeManager.loadTemp(imgAwaken, AssetsManager.getAssetsAD(ModelHero.img_awaken_super));
                LoadeManager.loadTemp(imgSuper, AssetsManager.getAssetsAD(ModelHero.super_hero_bg));
                EffectManager.changeSprColor(imgSuper, md.getStarGradeColor(), false);
            } else {
                particle_config = ConfigColor.PARTICLE_CONFIG_AWAKEN;
                heroIconBg.visible = true;
                imgSuper.visible = false;
                LoadeManager.loadTemp(imgAwaken, AssetsManager.getAssetsAD(ModelHero.img_awaken_normal));
                EffectManager.changeSprColor(heroIconBg, md.getStarGradeColor(), false);
            }
            // 修改粒子位置并加载粒子特效
            particle_config = ObjectUtil.clone(particle_config, true) as Array;
            particle_config.forEach(function(arr:Array):void {
                arr[3] += mFuncImg.x;
                arr[4] += mFuncImg.y;
            });
            mParticles = EffectManager.loadParticleByArr(particle_config, heroIcon.mParticles, heroIcon.mParticlesBottom);
			if (imgAwaken.parent){
				var ph:Number = mFuncImg.height * 0.8;
				if (ph > 437){
					imgAwaken.centerY = (ph - 437) * 0.2;
					ph = 437;
				}
				else{
					imgAwaken.centerY = 0;
				}
				imgAwaken.centerY -= 60;
				imgAwaken.height = ph;
				imgAwaken.width = ph * 1.4645;
                EffectManager.changeSprColor(imgAwaken, md.getStarGradeColor(), false);
			}

            txt_hero.text = ModelHero.getHeroName(md.id, true);
            btn_price.setData(AssetsManager.getAssetsICON(model.itemId + '.png'), curData.price);
            btn_price.visible = btn_price.gray = btn_awaken.visible = box_hint.visible = false;
            if (curData.awaken) {
                btn_awaken.visible = true;
            } else if (curData.canBuy) {
                btn_price.visible = true;
            } else {
                btn_price.visible = btn_price.gray = box_hint.visible = true;
                payIcon_hint.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_COIN), [model.pay_money * 10, curData.need * 10].join('/'));
            }
        }
        private function _gotoDraw():void {
            if (model.drawOpen) {
                this.closeSelf();
                GotoManager.boundForPanel(GotoManager.VIEW_LEGEND_AWAKEN);
            } else {
                ViewManager.instance.showTipsTxt(Tools.getMsgById('500310'));
            }
        }

        private function _onClickPay():void {
            GotoManager.boundForPanel(GotoManager.VIEW_PAY_TEST);
        }

        private function _onClickBuy():void {
            var curData:Object = list.array[list.selectedIndex];
            if (curData.canBuy) {
                if (model.score >= curData.price) {
                    var l:Label=new Label();
                    l.fontSize=18;
                    l.color="#ff1e00";
                    l.text = '-' + curData.price;
                    l.pos(itemIcon.x + itemIcon.width * 0.4, itemIcon.y + itemIcon.height * 0.8);
                    itemIcon.parent.addChild(l);
                    Tween.to(l, {y: l.y - 30}, 450,  Ease.sineInOut, Handler.create(l, l.destroy), 0, false, false);
                    model.sendMethod(NetMethodCfg.WS_SR_LEGEND_AWAKEN_REWARD, {reward_index: curData.index});
                } else {
                    ViewManager.instance.showTipsTxt(Tools.getMsgById('500308'));
                }
            }
        }

        private function _onClickItem():void {
            ViewManager.instance.showItemTips(model.itemId, model.score);
        }

        private function _onClickHelp():void {
            ViewManager.instance.showTipsPanel(Tools.getMsgById(cfg.info, [cfg.limit * 10]));
        }
    }
}