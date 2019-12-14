package sg.view.fight
{
    import ui.fight.pkRankUI;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import sg.utils.Tools;
    import laya.events.Event;
    import ui.fight.itemPKrankUI;
    import sg.manager.ModelManager;
    import sg.model.ModelBuiding;
    import sg.model.ModelItem;
    import sg.model.ModelUser;
    import sg.cfg.ConfigServer;

    public class ViewPKRank extends pkRankUI{
        private var mPage:Number = 1;
        private var mPageNum:Number = 8;
        private var mMax:Number = 5000;
        private var mPageMax:Number = 1;
        private var timeGetList:Number = 0;
        private var mTempMyData:Object;
        //
        public function ViewPKRank(){
            this.text0.text=Tools.getMsgById("_country14");
            this.text1.text=Tools.getMsgById("_more_rank07");
            this.text2.text=Tools.getMsgById("_pk06");
            this.text3.text=Tools.getMsgById("_public206");
            this.btn_add.on(Event.CLICK,this,this.click,[1]);
            this.btn_back.on(Event.CLICK,this,this.click,[-1]);
            //
            this.list.itemRender = itemPKrankUI;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.scrollBar.hide = true;
        }
        override public function initData():void{
            this.mMax = ConfigServer.pk.pk_robot[ConfigServer.pk.pk_robot.length-1][0];
            //this.tTitle.text = Tools.getMsgById("_country14");//"排行";
            this.comTitle.setViewTitle(Tools.getMsgById("_country14"));
            this.mTempMyData = this.currArg;
            this.mPageMax =  Math.ceil(this.mMax/this.mPageNum);
            this.mPage = 1;
            //
            var rank:int = this.mTempMyData?this.mTempMyData.rank:(this.mMax+1);
            this.mSelf.cRank.setRankIndex(rank);
            this.mSelf.tName.text = ModelManager.instance.modelUser.uname;
            this.mSelf.tPower.text = ""+ModelManager.instance.modelUser.getPower();
            this.mSelf.countryIcon.setCountryFlag(ModelUser.getCountryID());
            this.setAward(this.mSelf,rank);
            //
            this.click(0);
        }
        private function getRank(num:Number):void{
            this.btn_back.visible = false;
            this.btn_add.visible = false;
            //
            this.mPage += num;
            if(this.mPage>1){
                this.btn_back.visible = true;
            }
            if(this.mPage<this.mPageMax){
                this.btn_add.visible = true;
            }
            //
            this.tPage.text = this.mPage+"/"+this.mPageMax;            
            var max:Number = this.mPage*this.mPageNum;
            //
            var s:Number = (max - this.mPageNum);
            //
            var e:Number = Math.min(max,this.mMax);
            //
            NetSocket.instance.send(NetMethodCfg.WS_SR_GET_PK_RANK,{start:s+1,end:e},Handler.create(this,this.ws_sr_get_pk_rank));
        }
        private function ws_sr_get_pk_rank(re:NetPackage):void{
            this.setList(re.receiveData);
        }
        private function setList(arr:Array):void{
            // this
            this.list.dataSource = arr;
        }
        private function list_render(item:itemPKrankUI,index:int):void{
            var data:Object = this.list.array[index];
            var rank:int = (((this.mPage-1)*this.mPageNum)+index+1);
            // item.tIndex.text =  rank + "";
            item.countryIcon.setCountryFlag((data.uid<0)?3:(data.hasOwnProperty("country")?data.country:ModelUser.getCountryID()));
            item.cRank.setRankIndex(rank,"",true);
            item.tName.text = data.uname;
            Tools.textFitFontSize(item.tName);
            
            item.tPower.text = ""+data.power;
            this.setAward(item,rank);
        }
        private function setAward(item:itemPKrankUI,rank:int):void{
            if(rank>this.mMax){
                item.award0.visible = false;
                item.award1.visible = false;
                return;
            }
            var award:Array = ModelManager.instance.modelClimb.getPKrankAward(rank);
            var i:int = 0;
            for(var key:String in award[1]){
                item["award"+i].visible = true;
                item["award"+i].setData(key,award[1][key]);
                item["award"+i].setName("");
                item["award"+i].visible = award[1][key]>0;
                i++;
            }
        }
        private function click(num:Number):void{
            //
            this.timeGetList = Tools.runAtTimer(this.timeGetList,1000,Handler.create(this,this.getRank,[num]));
        }
    }   
}