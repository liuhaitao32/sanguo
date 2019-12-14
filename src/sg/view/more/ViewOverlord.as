package sg.view.more
{
    import ui.more.overlord_fightUI;
    import laya.events.Event;
    import ui.more.item_overlordUI;
    import laya.utils.Handler;
    import sg.manager.ModelManager;
    import sg.cfg.ConfigServer;
    import sg.utils.Tools;
    import sg.manager.LoadeManager;
    import sg.manager.AssetsManager;
    import sg.model.ModelOfficial;

    public class ViewOverlord extends overlord_fightUI
    {

        private var mTime:Number;
        public function ViewOverlord()
        {
            this.btn.on(Event.CLICK,this,this.click);
            this.list.itemRender = item_overlordUI;
            this.list.scrollBar.hide = true;
            this.list.renderHandler = new Handler(this,this.list_render);
        }
        override public function initData():void{
            LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsUI("bg_15.png"));
            var cfg:Object = ConfigServer.country_pvp.entrance;
            this.tInfo.style.color = "#ffffff";
            this.tInfo.style.fontSize=18;
            this.tInfo.style.leading = 10;
            this.tInfo.style.wordWrap = true;
            this.tInfo.style.align = "left";
            //
            this.boxInfo.visible = false;
            this.list.visible = !this.boxInfo.visible;
            //
            this.tTitle.text = Tools.getMsgById("_lht12");//"襄阳争夺战";
            this.tInfo.innerHTML = Tools.getMsgById(cfg.info);
            // this.tTime.text = (cfg.cycle - ModelManager.instance.modelUser.getGameDate())+Tools.getMsgById("_public111");//"天";
            this.box_hint0.visible = true;
            
            this.text0.text = Tools.getMsgById("_lht13");//"剩余开启时间";
            this.box_hint1.visible = true;
            
            this.txt_hint.text = Tools.getTimeStyle(mTime);//Tools.getMsgById(cfg.joke);
            //
            this.list.dataSource = cfg.right;            
            this.tInfo.height = this.tInfo.contextHeight;
            this.panelTxt.vScrollBar.hide = true;
            // trace(this.tInfo.height,this.tInfo.displayHeight);
        }
        override public function onAdded():void{
            this.box_hint0.visible=true;
            this.box_hint1.visible=this.box_country.visible=false;
            if([0,1,2].indexOf(ModelOfficial.cities[-1].country)!=-1){
                this.box_country.visible=true;
                this.iTime.text = Tools.getMsgById("_countrypvp_text48");//"当前占有国";
                this.imgFlag.skin=AssetsManager.getAssetsUI("icon_country"+(ModelOfficial.cities[-1].country+1)+".png");
            }else{
                this.box_hint1.visible=true;
                this.iTime.text = Tools.getMsgById("_lht13");//"剩余开启时间";
            }
            mTime=ModelManager.instance.modelCountryPvp.openTime;
            if(mTime==-1) return;
            setTimeLabel();
        }

        private function setTimeLabel():void{
            this.txt_hint.text = Tools.getTimeStyle(mTime);
            this.time0.text = Tools.getTimeStyle(mTime);
            mTime=ModelManager.instance.modelCountryPvp.openTime;
            //mTime-=1000;
            if(mTime<=0) this.closeSelf();
            if(mTime<=0) return;

            Laya.timer.clear(this,setTimeLabel);
            Laya.timer.once(1000,this,setTimeLabel,null,false);
        }

        private function list_render(item:item_overlordUI,index:int):void
        {
            
            var data:Object = this.list.array[index];
            // item.icon.skin = "icon/equip038.png";//AssetsManager.getAssetsAD(data.icon);
            LoadeManager.loadTemp(item.adImg,AssetsManager.getAssetsUI(data.icon));
            item.tInfo.text = Tools.getMsgById(data.info);
            item.tName.text = Tools.getMsgById(data.name);//"特权";
        }
        private function click():void
        {
            this.boxInfo.visible = !this.boxInfo.visible;
            this.list.visible = !this.boxInfo.visible;
        }


        override public function onRemoved():void{
            Laya.timer.clear(this,setTimeLabel);
        }
    }
}