package sg.boundFor
{
    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;
    import sg.manager.ViewManager;
    import sg.map.model.MapModel;
    import sg.model.ModelGame;
    import sg.model.ModelUser;
    import sg.utils.Tools;

    /**
     * 检查是否能进行跳转
     */
    public class GotoChecker
    {
        /**
         * 检测产业功能是否开启
         */
        public static function checkEstateOpen(t):Boolean {
            return GotoChecker.checkDestination('estate');
        }

        /**
         * 检测是否拥有该产业
         * estate_id 产业类型1：村落 2：港口 3：农田 4：林场 5：矿场 6：牧场
         */
        public static function checkEstate(estate_id:int):Boolean {
            var modelUser:ModelUser = ModelManager.instance.modelUser;
            return modelUser.estate.some(function(data:*):Boolean{return data['estate_id'] === String(estate_id)});
        }
        
        /**
         * 检测目标功能是否开启
         * 
         */
        public static function checkDestination(key:String = ''):Boolean {
            var openCfg:* = ConfigServer.system_simple.func_open[key];
            var obj:* = openCfg ? ModelGame.unlock(null, key) : {gray: false, visible: true};
            var funOpen:Boolean = obj.gray === false && obj.visible === true;
            funOpen || ViewManager.instance.showTipsTxt(Tools.getMsgById('190007'));
            return funOpen;
        }
    }
}