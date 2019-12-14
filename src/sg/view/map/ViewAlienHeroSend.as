package sg.view.map
{
	import sg.fight.FightMain;
	import sg.manager.ViewManager;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import sg.manager.ModelManager;
    import sg.model.ModelGame;
    import sg.model.ModelClimb;

    public class ViewAlienHeroSend extends ViewHeroSend
    {
        public function ViewAlienHeroSend()
        {
            super();
        }
        override public function click_send_func(arr:Array):void{
            // trace("---派兵前往--干异族---",arr);
            var len:int = arr.length;
            var hidArr:Array = [];
            for(var i:int = 0; i < len; i++)
            {
                hidArr.push(arr[i].model.hero);
            }
            if(this.mOtherPa == 1){
                NetSocket.instance.send(NetMethodCfg.WS_SR_PK_NPC_CAPTAIN_FIGHT,{hids:hidArr},Handler.create(this,this.func_re),this.mOtherPa);
            }
            else{
                NetSocket.instance.send(NetMethodCfg.WS_SR_PK_NPC_FIGHT,{city_id:this.mCityId+"",hids:hidArr},Handler.create(this,this.func_re),this.mOtherPa);
            }
        }
        override public function showLoss():void{
            this.box_other.visible = false;
            this.mHeroSendPanel.bottom = 100;
        }        
        private function func_re(re:NetPackage):void
        {
            var isCaptain:Boolean = (re.otherData == 1);

            ModelManager.instance.modelUser.updateData(re.receiveData);
            //
            var evt:String = (isCaptain)?ModelGame.EVENT_CAPTAIN_FIGHT_START:ModelGame.EVENT_ALIEN_FIGHT_START;
            //
            ModelManager.instance.modelGame.event(evt,[re.receiveData,false,isCaptain]);
            //
            this.closeSelf();
        }
    }
}