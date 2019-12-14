package sg.sdks
{
    import laya.utils.Handler;
    import sg.net.NetHttp;
    import sg.net.NetMethodCfg;
    import sg.model.ModelSalePay;
    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;
    import sg.model.ModelUser;
    import sg.utils.Tools;
    import sg.utils.MD5;
    import sg.utils.ObjectUtil;
    import laya.utils.Browser;
    import sg.zmPlatform.ModelFocus;

    public class H5JJ37 extends H5sdk {
        public function H5JJ37(pf:String, params:Object) {
            super(pf, params)
        }

        override public function login(handler:Handler):void {
            var data:Object = ObjectUtil.clone(params);
            delete data.fx_c_game_id;
            handler && handler.runWith([0, data]);
            this.user = ModelManager.instance.modelUser;
        }

        override public function pay(orderId:String, payObj:Object, serverName:String):void {
            var data:Object = {
                appid: params.appid,
                game_id: params.game_id,
                uid: params.uid,
                sid: user.zone,
                actor_id: user.mUID,
                order_no: orderId,
                money: payObj.cfg[0],
                game_coin: ModelSalePay.getCoinNumByPID(payObj.pid),
                product_id: payObj.pid,
                subject: 'Gold',
                time: Math.floor(ConfigServer.getServerTimer() * 0.001),
                ext: ''
            };
            NetHttp.instance.send(NetMethodCfg.HTTP_USER_JJ_37_SIGN, data, Handler.create(this, function(re:*):void {
                data.referer = params.referer;
                data.order_ip = re.ip;
                data.sign = re.sign;
                sdk.pay(data);
            }));
        }

        override public function log(type:int, serverName:String = ''):void {
            var data:Object = {
                serverid: user.zone,
                servername: serverName,
                roleid: user.mUID,
                rolename: user.uname,
                rolelevel: user.getLv(),
                viplevel: 0,
                fightvalue: user.getLv(),
                balance: user.coin,
                countryid: user.country,
                country: ModelUser.country_name[user.country],
                countryrolename: '',
                timestamp: ConfigServer.getServerTimer(),
                rolecreatetime: Tools.getTimeStamp(user.add_time),
                isnewrole: user.country === -1,
                roles: []
            };
            var method:String = {
                '1000': 'create',
                '1': 'entergame',
                '2': 'levelup'
            }[type];
            if (type === 1000) {
                sdk.log(data, 'server'); // 先上报选服
                (data.timestamp = Tools.getTimeStamp(user.add_time)); // 再上报创角
            }
            method && sdk.log(data, method);

            var timeUnix:int = Math.floor(ConfigServer.getServerTimer() * 0.001);

            // 进游戏回调接口
            var data_report:Object = {
                appid: params.appid,
                game_id: params.game_id,
                uid: params.uid,
                sid: user.zone,
                ip: user.ip,
                time: timeUnix,
                guid: params.guid,
                deviceplate: Browser.onIOS ? 'ios': (Browser.onAndroid ? 'android': Browser.onPC ? 'pc': 'other'),
                ext: JSON.stringify({fx_c_game_id: params.fx_c_game_id})
            };

            var sign:String = '';
            var baseURL:String = ''
            if (method === 'create') {
                data_report.role_id = user.mUID;
                data_report.role_name = user.uname;
                data_report.role_type = '';
                data_report.create_time = Math.floor(Tools.getTimeStamp(user.add_time) * 0.001);
            } else if (method === 'entergame') {
                data_report.enter_time = timeUnix;
            }

            sign = MD5.md5(Platform.sortObjkeyToString(data_report) + '&tEH(eun)23^w2H~6P@5LU^_,5C7j@t').toLowerCase();
            console.log(Platform.sortObjkeyToString(data_report), sign)
            data_report.sign = sign;
            if(method === 'create') {
                baseURL = 'https://apiouterh5.37.com/index.php?c=role&';
            } else if (method === 'entergame') {
                baseURL = 'https://apigameh5.37.com/index.php?c=enter&a=callback&';
            }
            baseURL && NetHttp.instance.getRequest(baseURL + Platform.sortObjkeyToString(data_report), Handler.create(null, function(re:*):void {
                console.log(re);
            }));
        }

        override public function get shareOpen():Boolean {
            return params.shared_switch;
        }

        override public function share():void {
            sdk.share(Tools.getMsgById(shareData[1]), Tools.getMsgById(shareData[0]), shareData[2], this.shareSuccessCB, this.shareFailCB);
        }

        override public function get focusSupport():Boolean {
            return ['wx', 'qq'].indexOf(params.subscribe_switch) !== -1;
        }

        override public function get focused():Boolean {
            return params.wx_is_subscribe === 2;
        }

        override public function focus():void {
            sdk.subscribe(function(result:int):void {
                if(result && result == 1) {
                    // 执行关注成功回调
                    ModelFocus.instance.focused = 1;
                }
            });
        }

        override public function get switchSupport():Boolean {
            return params.change_account_switch === 2;
        }

        override public function switchAccount():void {
            console.log('警戒37切换账号');
            sdk.switchAccount();
        }
    }
}