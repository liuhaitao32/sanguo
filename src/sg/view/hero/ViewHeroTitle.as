package sg.view.hero
{
	import sg.cfg.ConfigServer;
	import sg.fight.logic.utils.PassiveStrUtils;
	import sg.utils.Tools;
    import ui.hero.heroTitleUI;
    import laya.utils.Handler;
    import laya.events.Event;
    import sg.model.ModelHero;
    import sg.manager.ModelManager;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.manager.ViewManager;
    import sg.manager.LoadeManager;
    import sg.manager.AssetsManager;
    import sg.map.view.entity.MarchMatrixClip;
    import sg.model.ModelUser;

    public class ViewHeroTitle extends heroTitleUI{
        private var mSelect:ItemHeroTitle;
        private var mModel:ModelHero;
        private var mMarchMatrixClip:MarchMatrixClip;
        public function ViewHeroTitle(){
            this.list.itemRender = ItemHeroTitle;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.selectEnable = true;
            this.list.scrollBar.hide = true;
            this.list.selectHandler = new Handler(this,this.list_select);
            //
            this.btn.off(Event.CLICK,this,this.click);
            this.btn.on(Event.CLICK,this,this.click);
            this.btn.label = Tools.getMsgById("_bag_text04");

            //this.text0.text = Tools.getMsgById("_title4");
            this.comTitle.setViewTitle(Tools.getMsgById("_title4"));
            this.text1.text = Tools.getMsgById("_title5");
            this.text2.text = Tools.getMsgById("_title6");
        }
        override public function initData():void{
            LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsAD("bg_chenghao.png"));
            //
            this.mModel = this.currArg;
            this.mMarchMatrixClip = new MarchMatrixClip();
            this.mMarchMatrixClip.init(this.mModel.id, false, false, true, "title001", ModelUser.getCountryID());
            this.mMarchMatrixClip.changeDir(2);
            this.mBox.addChild(this.mMarchMatrixClip);
            this.mMarchMatrixClip.x = this.adImg.x + 10;
            this.mMarchMatrixClip.y = this.adImg.y+40;
            //
            this.list.dataSource = ModelManager.instance.modelUser.getMyTitleAll();
            //
            if(this.list.array.length>0){
                this.list.selectedIndex = 0;
            }
        }
        override public function onRemoved():void{
            if(this.mMarchMatrixClip){
                this.mMarchMatrixClip.destroy(true);
            }
            this.mSelect = null;
            this.list.scrollTo(0);
            this.list.selectedIndex = -1;
        }
        private function click():void{
            if(this.list.selectedIndex>-1){
                var data:Object = this.list.array[this.list.selectedIndex];
                if(data.index<0){
                    ViewManager.instance.showTipsTxt(Tools.getMsgById("_title3"));//称号已经过期,无法安装
                    return;
                }
                var _this:* = this;
                ViewManager.instance.showAlert(Tools.getMsgById('_title7'),function(index:int):void{
                    if(index == 0){
                        NetSocket.instance.send(NetMethodCfg.WS_SR_HERO_INSTALL_TITLE,{hid:_this.mModel.id,title_index:data.index},Handler.create(_this,_this.ws_sr_hero_install_title));
                    }
                    
                });
                
            }
        }
        private function ws_sr_hero_install_title(re:NetPackage):void{
            ModelManager.instance.modelUser.updateData(re.receiveData);
            this.mModel.event(ModelHero.EVENT_HERO_TITLE_CHANGE);
            this.closeSelf();
        }
        private function list_render(item:ItemHeroTitle,index:int):void{
            var data:Object = this.list.array[index];
            item.setData(data);
            item.setSelect((this.list.selectedIndex == index));
            //
            item.off(Event.CLICK,this,this.click_title);
            item.on(Event.CLICK,this,this.click_title,[index,item.outTime]);
        }
        private function list_select(index:int):void{
            if(index>-1){
                this.setUI(this.list.array[index]);
            }
        }
        private function click_title(index:int,outTime:Boolean):void{
            if(outTime){
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_title2"));//称号已经过期,无法安装
                return;
            }         
            if(index!=this.list.selectedIndex){
                this.list.selectedIndex = index;
            }
        }
        private function setUI(data:Object):void{
			var key:String = data.data[0];
            this.tInfo.text = ModelHero.getTitleInfo(key);
			if(this.mMarchMatrixClip){
                this.mMarchMatrixClip.changeTitle(key);
            }
			var passive:Object = ConfigServer.title[key].passive;
			this.tPassive.text = PassiveStrUtils.translatePassiveInfo(passive, false, false, 2);
        }        
    }   
}