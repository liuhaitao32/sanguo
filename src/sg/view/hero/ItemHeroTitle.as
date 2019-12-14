package sg.view.hero
{
    import ui.hero.itemTitleUI;
    import sg.utils.Tools;
    import sg.cfg.ConfigServer;
    import sg.model.ModelHero;

    public class ItemHeroTitle extends itemTitleUI{
        public var mIndex:int;
        public var outTime:Boolean = false;
        public function ItemHeroTitle(){

        }
        public function setData(data:Object):void{
            // this.mIndex = index;
            var now:Number = ConfigServer.getServerTimer();
            var end:Number = Tools.getTimeStamp(data.data[1]);
            var dis:Number = end - now;
            this.titleIcon.setHeroTitle(data.data[0]);
            this.tTime.text = (dis>0)?Tools.getTimeStyle(dis):Tools.getMsgById("_hero20");
            this.outTime = (dis<=0);
            
            var heroOK:Boolean = false;
            if(data.hid && dis>0){
                heroOK = true;
            }
            this.tStatus.text = heroOK?ModelHero.getHeroName(data.hid):((dis>0)?Tools.getMsgById("_equip21"):Tools.getMsgById("_hero20"));
        }
        public function setSelect(b:Boolean):void{
            this.select.visible = b;
        }
    }   
}