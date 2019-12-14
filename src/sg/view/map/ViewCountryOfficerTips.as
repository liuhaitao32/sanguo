package sg.view.map
{
    import ui.map.country_officer_tipsUI;
    import sg.model.ModelOfficial;
    import sg.manager.LoadeManager;
    import sg.manager.AssetsManager;
    import sg.cfg.ConfigServer;
    import sg.utils.Tools;
    import sg.manager.ModelManager;

    public class ViewCountryOfficerTips extends country_officer_tipsUI
    {
        private var country:Number;
        private var type:Number
        public function ViewCountryOfficerTips()
        {
            
        }
        override public function initData():void{
            //#b6d1ff
            LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsUI("bg_15.png"));
            this.country = Number(this.currArg[2]);
            this.type = Number(this.currArg[3]);
            var uname:String = this.currArg[4]?this.currArg[4]:"";
            this.tName.style.color = "#b6d1ff";
            this.tName.style.fontSize = 18;
            this.tName.style.align = "right";
            //
            var officer:Array = ModelOfficial.getOfficers(this.country);
            var arr:Array;
            this.tTips.visible = this.type>=1;
            this.tTips.text = Tools.getMsgById(530072);
            //
            this.tName.visible = false;
            this.tOfficer.visible = false;
            this.bgTxt.visible = false;
            if(this.type >= 1){
                this.tName.visible =this.bgTxt.visible =this.tOfficer.visible = true;       
                var leader:Number = Number(this.currArg[0]);
                arr= officer[leader];
                if(arr){
                    this.lName.text = arr[1];
                    this.lOfficer.text = ModelOfficial.getOfficerName(leader,-1,this.country);
                }
                if(this.type == 1){
                    this.tTitle.text = Tools.getMsgById("_country22");
                    var manager:Number = Number(this.currArg[1]);  
                    arr = officer[manager];
                    if(arr){
                        this.tName.innerHTML = Tools.getMsgById("_country23",[arr[1]]);//"加封<Font color=#ffffff size=22>+arr"[1]+"</Font>为";
                        this.tOfficer.text = ModelOfficial.getOfficerName(manager,-1,this.country);
                    }
                }else{
                    this.tTitle.text = Tools.getMsgById("_country62");
                    this.tName.innerHTML = Tools.getMsgById("_country61",[uname]);//"加封<Font color=#ffffff size=22>+arr"[1]+"</Font>为";
                    this.tOfficer.text = ModelOfficial.getCityName(this.currArg[1])+Tools.getMsgById("_country13");
                }
            }
            this.img0.visible = this.country==0;         
            this.img1.visible = this.country==1;         
            this.img2.visible = this.country==2;         
        }
    }
}