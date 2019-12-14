package sg.view.map
{
    import ui.map.country_officer_tips_orderUI;
    import sg.manager.LoadeManager;
    import sg.manager.AssetsManager;
    import sg.model.ModelOfficial;
    import sg.utils.Tools;
    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;
    import sg.model.ModelUser;
    import laya.events.Event;
    import sg.boundFor.GotoManager;

    public class ViewCountryTipsOrder extends country_officer_tips_orderUI
    {
        private var country:Number;
        private var type:Number;
        private var gotoCity:String;        
        public function ViewCountryTipsOrder()
        {
            this.btnGo.setGotoBtn(Tools.getMsgById('501030'));
            this.btnGo.on(Event.CLICK,this,this.click_go);
        }
        private function click_go():void
        {
            if(Number(this.gotoCity)>=0){
                GotoManager.boundFor({type:1,cityID:this.gotoCity});
            }
            this.closeSelf();
            // trace(this.currArg[1]);
        }
        override public function initData():void{
            //#b6d1ff
            LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsUI("bg_15.png"));
            this.country = Number(this.currArg[2]);
            this.type = Number(this.currArg[3]);
            this.tName2.style.color  = "#b6d1ff";
            this.tName2.style.fontSize  = 18;
            // this.tName.style.align = "right";
            this.tName2.style.align ="left";
            this.tName2.style.wordWrap = true;
            this.tName2.style.valign = "middle";
            this.tName2.style.leading = 8;
            //
            var officer:Array = ModelOfficial.getOfficers(this.country);
            var arr:Array;
            
            this.tName2.visible = false;
            this.btnGo.visible = false;
            if(this.type == 2){
                this.tName2.visible = true;
                // this.tTitle.text = Tools.getMsgById("_country24");//"颁布诏令";
                var orderID:String = this.currArg[0];
                var data:Array = this.currArg[1];
                this.btnGo.visible = data[0]?true:false;
                if(this.btnGo.visible){
                    this.gotoCity = data[0];
                }
                var str:String = "";
                var orderName:String = Tools.getMsgById(ConfigServer.country[orderID].name);
                var oid:String = "";
                var param:Array = [];
                switch(orderID)
                {
                    case "buff_corps"://太守
                        oid = "";
                        break;                    
                    case "buff_country1"://训练令
                        oid = "7";
                        break;
                    case "buff_country2"://建设令
                        oid = "10";                        
                    case "buff_country3"://攻城令
                        oid = data[4]?data[4]+"":"0";
                        break;     
                    case "buff_country4"://守城令
                        oid = data[4]?data[4]+"":"0";
                        break; 
                    case "buff_country5"://都尉令
                        oid = data[4]?data[4]+"":"0";
                        break;                                    
                    default:
                        break;
                }
                if(oid){
                    arr = officer[oid];
                    if(arr){
                        this.heroIcon.setHeroIcon(ModelUser.getUserHead(arr[3]));
                        this.lName.text = arr[1];

                        this.lOfficer.text = ModelOfficial.getOfficerName(oid,-1,this.country);

                        switch(orderID)
                        {
                            case "buff_corps"://训练令
                                break;                    
                            case "buff_country1"://训练令
                                param = [this.lOfficer.text,this.lName.text];
                                break;
                            case "buff_country2"://建设令
                                param = [this.lOfficer.text,this.lName.text];                       
                            case "buff_country3"://攻城令
                                param = [this.lOfficer.text,this.lName.text,ModelOfficial.getCityName(data[0])];
                                break;     
                            case "buff_country4"://守城令
                                param = [this.lOfficer.text,this.lName.text,ModelOfficial.getCityName(data[0])];
                                break; 
                            case "buff_country5"://守城令
                                param = [this.lOfficer.text,this.lName.text,ModelOfficial.getCityName(data[0])];
                                break;                                    
                            default:
                                break;
                        }
                        //
                        if(ConfigServer.country[orderID].poster){
                            str = Tools.getMsgById(ConfigServer.country[orderID].poster,param);
                        }
                        
                    }     
                    // this.tOfficer.text = orderName;
                }            
                else{
                    arr = ModelOfficial.getCityMayor(data[0]);
                    this.heroIcon.setHeroIcon(ModelUser.getUserHead(arr[3]));
                    this.lOfficer.text = Tools.getMsgById("_country13");//"太守";
                    this.lName.text = arr[1];
                    if(ConfigServer.country[orderID].poster){
                        str = Tools.getMsgById(ConfigServer.country[orderID].poster,[Tools.getMsgById(ModelOfficial.getCityCfg(data[0]).name)]);
                    }                    
                }
                this.tName2.innerHTML = str;
            }   

            lName.x = lOfficer.x + lOfficer.width + 10;
        }        
    }
}