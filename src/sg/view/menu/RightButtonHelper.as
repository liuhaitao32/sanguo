package sg.view.menu
{

    import sg.model.ViewModelBase;
    import sg.activities.model.ModelAfficheMerge;
    import sg.manager.ModelManager;
    import sg.net.NetSocket;
    import sg.boundFor.GotoManager;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.scene.view.MapCamera;
    import sg.model.ModelFightTask;
    import sg.model.ModelArena;
    import sg.view.arena.ViewArenaMain;
    import sg.cfg.ConfigServer;

    public class RightButtonHelper
    {
        public static const NAME_XYZ:String    = 'XYZ';    // 襄阳站
        public static const NAME_MERGE:String  = 'Merge';  // 合服公告
        public static const NAME_FIGHT_TASK:String  = 'fight_task';  // 国战任务
        public static const NAME_ARENA:String    = 'arena';    // 襄阳站
        public static const cfg:Array = [
            {name: NAME_XYZ, skin: 'icon_paopao46.png', glow: 'glow047'},
            {name: NAME_MERGE, skin: 'icon_paopao50.png'},
            {name: NAME_FIGHT_TASK, skin: 'icon_paopao51.png', glow: 'glow047'},
            {name: NAME_ARENA, skin: 'icon_paopao52.png', glow: 'glow047'},
        ];

        private var btns:Array = [];
        public function RightButtonHelper() {
        }

        public static function getModelByName(name:String):ViewModelBase {
            switch(name) {
                case NAME_XYZ:
                    return ModelManager.instance.modelCountryPvp as ViewModelBase;
                case NAME_MERGE:
                    return ModelAfficheMerge.instance as ViewModelBase;
                case NAME_FIGHT_TASK:
                    return ModelFightTask.instance as ViewModelBase;
                case NAME_ARENA:
                    return ModelArena.instance as ViewModelBase;
                default:
                    console && console.warn('RightButtonHelper getModelByName');
                    return new ViewModelBase();
            }
        }
        
        public static function onClick(name:String):void {
            switch(name) {
                case NAME_XYZ:
					NetSocket.instance.send("w.get_xyz",{},Handler.create(null, function(re:NetPackage):void {
						ModelManager.instance.modelCountryPvp.updateXYZ(re.receiveData);
						GotoManager.boundForPanel(GotoManager.VIEW_COUNTRY_PVP_MAIN);
                        MapCamera.lookAtCity(-1);//前往襄阳
					}));
                    break;
                case NAME_MERGE:
                    ViewManager.instance.showView(ConfigClass.VIEW_AFFICHE_MERGE);
                    break;
                case NAME_FIGHT_TASK:
                    if (ModelFightTask.instance.canShow) {
                        ViewManager.instance.showView(ConfigClass.VIEW_FIGHT_TASK);
                    } else {
                        ModelFightTask.instance.foreshowTips()
                    }
                    break;
                case NAME_ARENA:
                    var n:Number = ModelArena.instance.mTime1;
                    if(n!=0 && ConfigServer.getServerTimer()>=n){
                        NetSocket.instance.send("get_pk_arena",{},Handler.create(null,function(np:NetPackage):void{
                            ModelArena.instance.arena = np.receiveData;
                            ViewManager.instance.showView(["ViewArenaMain",ViewArenaMain]);
                        }));
                    }else{
                        ModelArena.instance.foreshowTips();
                    }
                    
                    break;
                default:
                    console && console.warn('RightButtonHelper onClick');
                    break;
            }
        }
    }
}