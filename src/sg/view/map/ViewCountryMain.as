package sg.view.map
{
    import ui.map.country_mainUI;
    import laya.utils.Handler;
    import laya.ui.Component;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.model.ModelGame;
    import sg.utils.Tools;
    import sg.model.ModelAlert;
    import sg.task.model.ModelTaskCountry;
    import sg.manager.ModelManager;
    import sg.guide.model.ModelGuide;
    import sg.view.country.CountryStoreMainNew;
    import sg.view.country.CountryShopMain;
    import sg.view.country.CountryAlienMain;
    import sg.view.country.CountryBagMain;
    import sg.model.ModelClub;
    import sg.cfg.ConfigServer;
    import laya.ui.CheckBox;
    import sg.model.ModelOfficial;

    public class ViewCountryMain extends country_mainUI{
        private var mView:Component;
        private var mTabData:Object;
        private var mSelectIndex:Number;
        private var mArr:Array;
        public function ViewCountryMain(){
            this.tab.selectHandler = new Handler(this,this.tab_select);
        }
        override public function initData():void{
            mSelectIndex = this.currArg ? this.currArg : 0;
            this.mTabData = [];
            //
            this.setTitle(Tools.getMsgById("_country16"));
            //官职,仓库,任务,太守,排行
            var str:String = "";
            // var arr:Array = [{txt:Tools.getMsgById("_country10"),index:0},
            //     {txt:Tools.getMsgById("_country11"),index:1},{txt:Tools.getMsgById("_country12"),index:2},
            //     {txt:Tools.getMsgById("_country13"),index:3},{txt:Tools.getMsgById("_country14"),index:4},{txt:Tools.getMsgById("_country15"),index:5}];
            
            mArr=[{txt:Tools.getMsgById("_country10"),index:0},
                {txt:Tools.getMsgById("_country11"),index:5},
                {txt:Tools.getMsgById("_country12"),index:2},
                {txt:Tools.getMsgById("_country65"),index:4},
                {txt:Tools.getMsgById(ConfigServer.shop.guild_shop.name),index:3},
                {txt:Tools.getMsgById("_country15"),index:1}];
            var len:int = mArr.length;
            var obj:Object;
            var b:Boolean = false;
            for(var i:int = 0; i < len; i++)
            {
                b = false;
                obj = mArr[i];
                if(i==2){
                    // b = ModelGame.unlock(null,"country_task").visible;
                    b = true;
                }
                else{
                    b = true;

                }
                if(b){
                    this.mTabData.push(obj);
                    str+=obj.txt+",";
                }
            }
            //
            this.tab.labels = str.substr(0,str.length-1);
            for(i = 0;i < len;i++){
                this.tab.items[i].name = "tab_"+this.mTabData[i].index;
            } 
            this.tab.selectedIndex = mSelectIndex;
        }
        override public function onAdded():void{
            ModelManager.instance.modelGame.on(ModelGame.EVENT_TASK_RED,this,this.checkRed);
            ModelManager.instance.modelClub.on(ModelClub.EVENT_COUNTRY_ALIEN_RED,this,this.checkRedAlien);
            ModelManager.instance.modelClub.on(ModelClub.EVENT_COUNTRY_REDBAG,this,this.checkRedBag);
            ModelManager.instance.modelOfficel.on(ModelOfficial.EVENT_UPDATE_IMPEACH,this,this.checkRedImpeach);
            this.checkRed();
            this.checkRedAlien();
            this.checkRedBag();
            this.checkRedImpeach();
            !ModelManager.instance.modelUser.isMerge && ModelTaskCountry.instance.needGuide && ModelGuide.executeGuide('country_guide');
        }
        override public function onRemoved():void{
            ModelManager.instance.modelGame.off(ModelGame.EVENT_TASK_RED,this,this.checkRed);
            ModelManager.instance.modelClub.off(ModelClub.EVENT_COUNTRY_ALIEN_RED,this,this.checkRedAlien);
            ModelManager.instance.modelClub.off(ModelClub.EVENT_COUNTRY_REDBAG,this,this.checkRedBag);
            ModelManager.instance.modelOfficel.off(ModelOfficial.EVENT_UPDATE_IMPEACH,this,this.checkRedImpeach);
            this.tab.selectedIndex = -1;
        }
        private function checkRedImpeach():void{
            ModelGame.redCheckOnce(this.tab.getChildByName("tab_0"),ModelAlert.red_country_check("country_impeach"));
        }
        
        private function checkRed():void {//任务红点
			ModelGame.redCheckOnce(this.tab.getChildByName("tab_2"),ModelAlert.red_country_check("country_task"));
        }
        private function checkRedAlien():void{//异邦红点
            ModelGame.redCheckOnce(this.tab.getChildByName("tab_4"),ModelAlert.red_country_check("country_alien"));
        }
        private function checkRedBag():void{//国家仓库红点
            ModelGame.redCheckOnce(this.tab.getChildByName("tab_5"),ModelAlert.red_country_check("country_bag"));
        }


        private function tab_select(index:int):void{
            if(index<0){
                this.setIndexView(index);
                return;
            }
            var obj:Object = this.mTabData[index];
            var type:int = obj.index;    
               if(type == 3){
                NetSocket.instance.send("get_shop",{shop_id:"guild_shop"},Handler.create(this,function(np:NetPackage):void{
                    ModelManager.instance.modelUser.updateData(np.receiveData);
                    setIndexView(index);
				}));
            }else if(type == 4){
                NetSocket.instance.send("get_club_alien",{},Handler.create(this,function(np:NetPackage):void{
                    ModelManager.instance.modelUser.updateData(np.receiveData);
                    setIndexView(index);
				}));
               
            }else if(type==5){
                 NetSocket.instance.send("get_club_redbag",{},Handler.create(this,function(np:NetPackage):void{
                    ModelManager.instance.modelUser.updateData(np.receiveData);
                    ModelManager.instance.modelUser.checkUserData(["year_build","year_dead_num","year_kill_num"],function():void{
                        setIndexView(index);
                    });
				}));
            }else{
                this.setIndexView(index);    
            }
        }

        private function setIndexView(index:int,data:Array = null):void{
            this.clearView();
            if(index<0){
                return;
            }
            var obj:Object = this.mTabData[index];
            var type:int = obj.index;
            switch(type)
            {
                case 0:
                    this.mView = new CountryOfficerMain();
                    break;
                case 1:
                    this.mView = new CountryStoreMainNew();//new CountryStoreMain();//
                    break;                           
                case 2:
                    this.mView = new CountryTaskMain();
                    break; 
                case 3:
                    this.mView = new CountryShopMain();//new CountryMayorMain();//
                    break;                      
                case 4:
                    this.mView = new CountryAlienMain();//new CountryRankMain(data);//
                    break;  
                case 5:
                    this.mView = new CountryBagMain();//new CountryRankPower();//
                    break;    
                                                         
                default:
                    break;
            }
            if(this.mView){
                this.mView.y = 65;
                this.addChild(this.mView);
            }
        }
        private function clearView():void{
            if(this.mView){
                this.mView.destroy(true);
            }
            this.mView = null;
        }

		/**
		 * 根据名字获取界面中的对象
		 * @param	name
		 * @return 	Sprite || undefined
		 */
		override public function getSpriteByName(name:String):*
		{
            var item:* = null;
			if (name.indexOf('tab') !== -1) {
                item = this.tab.items[parseInt(name[name.length - 1])];
                if (item)    return item;
            }
            return super.getSpriteByName(name);
		}
    }   
}