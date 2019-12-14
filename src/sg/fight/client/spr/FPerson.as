package sg.fight.client.spr {
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import sg.fight.FightMain;
	import sg.fight.client.cfg.ConfigFightView;
	import sg.fight.client.interfaces.IClientUnit;
	import sg.fight.client.spr.FAnimation;
	import sg.fight.client.utils.FightEvent;
	import sg.fight.client.utils.FightViewUtils;
	import sg.fight.client.view.FightSceneBase;
	import sg.fight.logic.utils.FightUtils;
	import sg.manager.EffectManager;
    
    
    /**
     * 战斗场景中的单位，包含英雄，前军，后军中的任意个体(控制器，spr为显示对象)
     * @author zhuda
     */
    public class FPerson extends FAnimation {
        public static var lastPerson:FPerson;
        
        private var unit:IClientUnit;
        public var alive:Boolean;
        ///原本生成时的阵型序号
        public var index:int;
        
        ///基础翻转
        private var _baseFlip:Boolean;
        private var _baseScale:Number;
        
        public var standX:Number;
        public var standY:Number;
        
        public function FPerson(scene:FightSceneBase, unit:IClientUnit, id:String, x:Number, y:Number, baseScale:Number = 1, baseAlpha:Number = 1) {
            this._baseFlip = unit.isFlip;
            super(scene, id, x, y, 0, this._baseFlip, baseScale, baseAlpha);
            this.unit = unit;
            //this.isMelee = true;
            this.standX = x;
            this.standY = y;
            this.index = -1;
        }
        
        override public function init():void {
            super.init();
            //this.ani.interval = 10;
            this.toStand();
            FPerson.lastPerson = this;
        }
		
		/**
         * 得到当前排序
         */
        public function get sortValue():Number
        {
			return this.alive?(this.standX + this.standY * 10000):-10000000;
        }
		
        /**
         * 计算自身站位和目标人物站位的距离平方
         */
        public function dis2To(p:FPerson):Number
        {
			var xx:int = p.standX - this.standX;
			var yy:int = p.standY - this.standY;
			return xx*xx+yy*yy;
        }

		/**
         * 两个人交换站位，并交换index
         */
        public function exchange(p:FPerson):void
        {
			var xx:int = this.standX;
			var yy:int = this.standY;
			var i:int = this.index;
			this.standX = p.standX;
			this.standY = p.standY;
			this.index = p.index;
			p.standX = xx;
			p.standY = yy;
			p.index = i;
        }
        
        public function recovery():void {
            if (!this.alive) return;
            this.ani.offAll(Event.COMPLETE);
            //this.isFlip = this._baseFlip;
            this.setFlip(this._baseFlip);
            //this.updatePos(true);
        }
        
        public function reset(x:Number, y:Number, isAppear:Boolean = false):void {
			if (!this.spr || this.spr.destroyed)
				return;
            //this._baseScale = 0.5;
            //this._alive = this.alive;
            this.ani.offAll(Event.COMPLETE);
            //this.isFlip = this._baseFlip;
            this.standX = this.x = x;
            this.standY = this.y = y;
            this.stand();
            this.spr.rotation = 0;
            if (this.alive) {
                if (isAppear) {
                    this.appear();
                }
                else {
                    this.spr.alpha = 1;
                }
            }
            this.setFlip(this._baseFlip);
            //this.updatePos();
        }
        
        protected function toStand():void {
            this.aniPlay(Math.floor(Math.random() * 20), true, ConfigFightView.ANIMATION_STAND);
        }
        
        public function stand():void {
            if (!this.alive) return;
            this.toStand();
        }
        
        private function standAndFlip():void {
            if (!this.alive) return;
            this.setFlip(this._baseFlip);
            this.toStand();
        }
        
        /**
         * 回归站立
         */
        private function reStand():void {
            if (!this.alive) return;
            this.ani.offAll(Event.COMPLETE);
            Tween.clearAll(this);
            //this.isFlip = this._baseFlip;
            this.x = this.standX;
            this.y = this.standY;
            
            this.stand();
            this.setFlip(this._baseFlip);
            //this.updatePos();
        }

        /**
         * 移动并停留在新位置(强制整队，停止之前动作)
         */
        public function move(offset:Number, speedRate:Number = 1):void {
            if (this.alive)
                Tween.clearAll(this);
            
            this.setFlip(offset < 0);
            this.standX = this.standX + offset;

            if (!this.alive) {
                return;
            }
            
            this.aniPlay(0, true, ConfigFightView.ANIMATION_RUN);
            var arr:Array = null;
			var dis:Number;
			if (this.standY != this.y){
				dis = FightViewUtils.getDis(this.x, this.standX, this.y, this.standY);
				arr = [true];
			}
			else{
				dis = FightViewUtils.getDisX(this.x, this.standX);
			}
            var time:int = FightViewUtils.getMoveTime(dis, speedRate);
            this.tweenTo(this, {update: new Handler(this, this.updatePos,arr), x: this.standX, y: this.standY}, time, Ease.sineInOut, Handler.create(this, this.standAndFlip));
        }
        
        /**
         * 自动攻击
         */
        public function autoAttack(aimMinX:Number, aimMaxX:Number, effObj:Object, dis:Number = 0):void {
            if (!this.alive) return;
            var aimX:Number = FightViewUtils.getRandomRange(aimMinX, aimMaxX);
            if (effObj.move)//this.isMelee
            {
				if(dis){
					//固定了目标距离，说明按阵型行动
					aimX = aimX * 0.1 + (this.standX + this.getFrontX(dis)) * 0.9;
					Tween.clearAll(this);
				}
                this.runAndAttack(aimX, effObj);
            }
            else if (effObj.bullet) {
                this.bulletAttack(aimX, effObj, true);
            }
            //new FEffect(this.scene, "hit204", this.x, this.y, ConfigFightView.HIT_Z, this.isFlip, 0, 1, 222);
        }
        
        /**
         * 子弹攻击(前摇后发出子弹)
         */
        public function bulletAttack(aimX:Number, effObj:Object, playAni:Boolean):void {
            if (!this.alive) return;
			var offsetX:Number = aimX - this.standX;
			if (offsetX != 0) {
                this.setFlip(offsetX < 0);
            }
			if(playAni){
				this.aniPlay(0, false, ConfigFightView.ANIMATION_ATTACK);
				this.ani.once(Event.COMPLETE, this, this.stand);
			}
			var bulletObj:Object = effObj.bullet;
			if(bulletObj){
				this.delayTo(ConfigFightView.ATTACK_BASE_TIME, this, this.fireBullet, [aimX, bulletObj, bulletObj.speed?bulletObj.speed:effObj.speed]);
			}
        }
        
        /**
         * 发出子弹
         */
        private function fireBullet(aimX:Number, bulletObj:Object, speedRate:Number = 1):void {
            if (!this.alive) return;
            if (bulletObj.res) {
                var rndX:Number = this.index < 0 ? 0 : (Math.random() * 40 - 20);
                var rndY:Number = this.index < 0 ? 0 : (Math.random() * 20 - 10);
                aimX = aimX + rndX;
                var aimY:Number = this.index < 0 ? this.standY : (this.standY * 0.99 + rndY);

				var fireX:Number = this.x + (bulletObj.resX?this.getFrontX(bulletObj.resX):0);
				var fireZ:Number = ConfigFightView.BULLET_FIRE_Z + (bulletObj.resZ?bulletObj.resZ:0);
				var dis:Number = Math.abs(aimX - this.standX);
                var time:int = FightViewUtils.getMoveTime(dis, speedRate, bulletObj.hasOwnProperty('baseTimeRate')?bulletObj.baseTimeRate:1);
				
				
                var bullet:FBullet = new FBullet(this.scene, bulletObj.res, fireX, this.y, fireZ, this.isFlip, bulletObj.resScale, bulletObj.resAlpha, bulletObj.resAdd);
                bullet.addAnimation(bulletObj.stick, '', 0, 0, bulletObj.stickAdd, true, true, bulletObj.stickScale, bulletObj.stickAlpha);
				
				var gravity:Number = 0;
				//近距离抛射受到额外重力
				if (bulletObj.gravity)
					gravity += bulletObj.gravity;
				if (bulletObj.gravityNear && dis<ConfigFightView.BULLET_DISTANCE_NEAR)
					gravity += bulletObj.gravityNear * (ConfigFightView.BULLET_DISTANCE_NEAR - dis) / ConfigFightView.BULLET_DISTANCE_NEAR;
					
                bullet.doFlight(aimX, aimY, ConfigFightView.HIT_Z, time, gravity);
            }
        }
		/**
         * 得到前方的x
         */
        private function getFrontX(offsetX:Number):Number {
			return this._baseFlip? -offsetX:offsetX;
		}
        
        /**
         * 前冲攻击，并回阵
         */
        public function runAndAttack(aimX:Number, effObj:Object, isClear:Boolean = false):void {
            if (!this.alive) return;
            this.ani.offAll(Event.COMPLETE);
            this.aniPlay(0, true, ConfigFightView.ANIMATION_RUN);

            var moveObj:Object = effObj.move;
            var speedRate:Number = moveObj.speed?moveObj.speed:effObj.speed;
            
            var rndX:Number = this.index < 0 ? 0 : (Math.random() * 40 - 20);
            var rndY:Number = this.index < 0 ? 0 : (Math.random() * 20 - 10);
			aimX = aimX + rndX;
			
			//跑动停留的位置
			var range:Number = FightViewUtils.getRange(effObj.range);
			var pauseX:Number = range?FightViewUtils.getPauseXByRange(this.standX, aimX, range):aimX;
			if (pauseX == this.standX && effObj.bullet)
			{
				//原地开炮
				this.bulletAttack(aimX, effObj, true);
				return;
			}
            var aimY:Number = this.index < 0 ? this.standY : (this.standY * 0.99 + rndY);
			
            var dis:Number = FightViewUtils.getDisX(this.standX, pauseX);
            var time:int = FightViewUtils.getMoveTime(dis, speedRate, moveObj.hasOwnProperty('baseTimeRate')?moveObj.baseTimeRate:1);
            //var tempDis:Number = this.isFlip ? -dis : dis;
            //aimX = this.standX + tempDis + rndX;
			
			var offsetX:Number = pauseX - this.standX;
			if (offsetX != 0) {
                this.setFlip(offsetX < 0);
            }
            
						
			if (moveObj.noBack)
			{
				//战败自杀一击
				this.tweenTo(this, {update: new Handler(this, this.updatePos), x: pauseX, y: aimY}, time, Ease.sineIn);
				this.tweenTo(this.spr, {alpha: 0}, 200, null, null, time - 200);
			}
            else if (effObj.bang) {
                //如果有bang，则跑到后立即隐身，等待bang时间结束，再现身向回跑
                var endTime:int = ConfigFightView.HURT_END_TIME;
                if (effObj.hurt) {
                    if (effObj.hurt.hasOwnProperty('endTime'))
                        endTime = effObj.hurt.endTime;
                }
                if (moveObj.hasOwnProperty('endTime'))
                    endTime += moveObj.endTime;
                this.tweenTo(this, {update: new Handler(this, this.updatePos), x: pauseX, y: aimY}, time, Ease.sineIn, Handler.create(this, this.hideAndShowBack, [endTime, speedRate, isClear]));
                this.tweenTo(this.spr, {alpha: 0}, 200, null, null, time - 200);
            }
            else {
                this.tweenTo(this, {update: new Handler(this, this.updatePos), x: pauseX, y: aimY}, time, Ease.sineIn, Handler.create(this, this.runEnd, [effObj, aimX, speedRate, isClear]));
            }
            
            var stick:String = moveObj.stick;
            if (stick) {// && Math.random() > 0.5
                this.addAnimation(stick, '', 20, -20, moveObj.stickAdd, true, true, moveObj.stickScale, moveObj.stickAlpha);
                this.delayTo(time, this, this.removeAnimation, [stick]);
            }

			
			//if (isClear){
				//FightEvent.ED.once(FightEvent.FIGHT_TIME_CLEAR, this, this.clear);
			//}
        
            //new FEffect(this.scene, "hit204", aimX, aimY, ConfigFightView.HIT_Z, this.isFlip, 0, 1, time);
        
        }
        
        /**
         * 隐身接显形返回
         */
        private function hideAndShowBack(time:int, speedRate:Number = 1, isClear:Boolean = false):void {
            this.hide();
            this.delayTo(time, this, this.showBack, [speedRate, isClear]);
        }
        
        /**
         * 显形返回
         */
        private function showBack(speedRate:Number = 1, isClear:Boolean = false):void {
            this.appear();
            //this.show();
            this.backMove(speedRate, isClear);
        }
        
        /**
         * 跑动结束，准备近战攻击或开炮
         */
        private function runEnd(effObj:Object, aimX:Number, speedRate:Number = 1, isClear:Boolean = false):void {
			var moveObj:Object = effObj.move;
			if(moveObj){
				if (moveObj.time) {
					this.toStand();
					this.delayTo(moveObj.time, this, this.attackAndBack, [effObj, aimX, speedRate, isClear]);
				}
				else {
					this.attackAndBack(effObj, aimX, speedRate, isClear);
				}
			}
        }
        
        /**
         * 攻击后接转身
         */
        private function attackAndBack(effObj:Object, aimX:Number, speedRate:Number = 1, isClear:Boolean = false):void {
            if (!this.alive) return;
			var moveObj:Object = effObj.move;
			if(!moveObj)return;
			
			if (effObj.bullet) {
				//炮弹发出后等待，然后返回
                this.bulletAttack(aimX, effObj, false);
            }else{
				if (moveObj.atk) {
					new FEffect(this.scene, moveObj.atk, this.x, this.y, ConfigFightView.HIT_Z, this.isFlip, 0, moveObj.atkScale, moveObj.atkAlpha, 0, moveObj.atkAdd);
				}
			}
            
			if (moveObj.ani) {
				//EffectManager.setAnimationQueue(this.ani, stateName, endType);
				this.doAnimationQueue(moveObj.ani);
			}
			else {
				this.aniPlay(0, false, ConfigFightView.ANIMATION_ATTACK);
			}

			
            if (moveObj.endTime) {
                this.delayTo(moveObj.endTime, this, this.backMove, [speedRate, isClear]);
            }
            else {
                this.ani.once(Event.COMPLETE, this, this.backMove, [speedRate, isClear]);
            }
        }
        
        /**
         * 转身回阵
         */
        private function backMove(speedRate:Number = 1, isClear:Boolean = false):void {
            if (!this.alive) return;
            //this.isFlip = !this._baseFlip;
            //this.updatePos();
            this.setFlip(!this._baseFlip);
            //this.spr.scaleX = -this.spr.scaleX;
            this.aniPlay(0, true, ConfigFightView.ANIMATION_RUN);
			var dis:Number = FightViewUtils.getDisX(this.standX, this.x);
            var time:int = Math.ceil(FightViewUtils.getMoveTime(dis, speedRate) / ConfigFightView.BACK_SPEED_RATE);
            //if (this.isFlip) {
                //dis = -dis;
            //}
            
            if (isClear) {
                this.tweenTo(this, {update: new Handler(this, this.updatePos), x: this.standX, y: this.standY}, time, Ease.sineInOut, Handler.create(this, this.clear));
                this.tweenTo(this.spr, {alpha: 0}, 800, null, null, time - 800);
            }
            else {
                this.tweenTo(this, {update: new Handler(this, this.updatePos), x: this.standX, y: this.standY}, time, Ease.sineInOut, Handler.create(this, this.reStand));
            }
        }
        
        /**
         * 单纯攻击
         */
        //public function standAttack(effObj:Object):void
        //{
        //if (!this.alive) return;
        //this.reStand();
        //this.ani.play(0, false, ConfigFightView.ANIMATION_ATTACK);
        //this.spr.once(Event.COMPLETE, this, this.stand);
        //}
        
        /**
         * 站立欢呼(较为整齐)
         */
        public function cheer():void {
            if (!this.alive) return;
            //this.spr.offAll(Event.COMPLETE);
			this.ani.offAll(Event.COMPLETE);
            this.reStand();
            this.aniPlay(Math.floor(Math.random() * 3), true, ConfigFightView.ANIMATION_CHEER);
        }
        
        /**
         * 施法
         */
        public function fire(fireObj:Object):void {
            if (!this.alive || fireObj == null) return;
            
			if (fireObj.ani){
				this.reStand();
				this.doAnimationQueue(fireObj.ani);
			}
            if (fireObj.res) {
				var resZ:int = ConfigFightView.HIT_Z + (fireObj.resZ?fireObj.resZ:0);
                new FEffect(this.scene, fireObj.res, this.x, this.y, resZ, this.isFlip, 0, fireObj.resScale, fireObj.resAlpha, 0, fireObj.resAdd);
            }
        }
        
        /**
         * 执行动作序列，然后返回Stand
         */
        public function doAnimationQueue(stateName:String = '' , endType:int = 0):void {
            if (!this.alive) return;
            //this.reStand();
            EffectManager.setAnimationQueue(this.ani, stateName, endType);
        }
        
        /**
         * 防御
         */
        public function defense(hurtObj:Object):void {
            if (!this.alive || hurtObj == null) return;
            this.doAnimationQueue(hurtObj.ani);
            
            if (hurtObj.def) {
                new FEffect(this.scene, hurtObj.def, this.x, this.y, ConfigFightView.HIT_Z, this.isFlip, 0, hurtObj.defScale, hurtObj.defAlpha, 0, hurtObj.defAdd);
            }
        }
        
        /**
         * 受伤
         */
        public function injured(hurtObj:Object):void {
            if (!this.alive || hurtObj == null) return;
            var ani:Animation = this.ani;
            ani.play(0, false, hurtObj.injured ? ConfigFightView.ANIMATION_INJURED1 : ConfigFightView.ANIMATION_INJURED2);
            ani.once(Event.COMPLETE, this, this.stand);
            
            this.beHit(hurtObj);
        }
        
        protected function beHit(hurtObj:Object):void {
            if (hurtObj) {
                if (hurtObj.res) {
                    var rota:Number = FightViewUtils.getRandomOffset(hurtObj.resRota);
                    new FEffect(this.scene, hurtObj.res, this.x, this.y, ConfigFightView.HIT_Z, !this.isFlip, rota, hurtObj.resScale, hurtObj.resAlpha, 0, hurtObj.resAdd);
                }
                
                //受力
                var forceX:Number = 0;
                var forceY:Number = 0;
                var force:Number;
                var tempX:Number;
                var tempY:Number;
                var arr:Array;
                var forceDef:Number = hurtObj.forceDef ? hurtObj.forceDef : 0;
                if (forceDef < 1000000)
				{
                    //return;
                
					//hurtObj.forceY = 20;
					//hurtObj.forceX = 30;
					//hurtObj.forceR = 50;
					
					if (hurtObj.forceX) {
						forceX += hurtObj.forceX;
					}
					if (hurtObj.forceY) {
						tempY = this.standY > 0 ? 1 : (this.standY < 0 ? -1 : 0);
						forceY += tempY * hurtObj.forceY;
					}
					if (hurtObj.forceO) {
						tempX = this.unit.getClientTroop().posX + (this._baseFlip ? 50 : -50);
						arr = this.getPointForce(tempX, 0, hurtObj.forceO);
						
						forceX += arr[0];
						forceY += arr[1];
					}
					if (hurtObj.forceF) {
						tempX = this.unit.getClientTroop().posX + (this._baseFlip ? -150 : 150);
						arr = this.getPointForce(tempX, 0, hurtObj.forceF, 1.5);
						
						forceX += arr[0];
						forceY += arr[1];
					}
					if (hurtObj.forceS && hurtObj.num) {
						//找到距离自己最近的发射点，向外弹出
						tempX = this.unit.getPosX();
						var len:int = hurtObj.num;
						force = hurtObj.forceS * (1 / len + 0.1);
						var offsetY:Number = ConfigFightView.FORMATION_Y * 2 / len;
						for (var i:int = 0; i < len; i++) {
							//分布y
							tempY = offsetY * (i - (len - 1) / 2);
							arr = this.getPointForce(tempX, tempY, force);
							forceX += arr[0];
							forceY += arr[1];
						}
					}
					if (hurtObj.forceR) {
						force = hurtObj.forceR;
						forceX += FightViewUtils.getRandomOffset(force);
						forceY += FightViewUtils.getRandomOffset(force);
					}
					if (forceDef) {
						force = FightUtils.pointToRate(forceDef);
						forceX /= force;
						forceY /= force;
					}
				}
                
                if (forceX != 0 || forceY != 0 || this.x != this.standX || this.y != this.standY) {
                    this.addForce(forceX, forceY);
                }
                
            }
        }
        
        /**
         * 收到某点的力，返回合力
         */
        private function getPointForce(posX:int, posY:int, force:Number, disRate:Number = 1):Array {
            var arr:Array = [0, 0];
            var temp:Number;
            var tempX:Number;
            var tempY:Number;
            var dis:Number;
            var dis2:Number;
            var radians:Number;
            
            tempX = this.standX - posX;
            if (!this._baseFlip)
                tempX = -tempX;
            tempY = this.standY - posY;
            
            radians = Math.atan2(tempY, tempX);
            
            //越远受力越小
            dis = Math.sqrt(tempX * tempX + tempY * tempY);
            temp = Math.max(-dis, force * 1.5);
            dis2 = (Math.abs(force) + 100) * disRate;
            temp = Math.min(1, dis2 / dis) * temp;
            
            arr[0] = Math.cos(radians) * temp;
            arr[1] = Math.sin(radians) * temp;
            
            return arr;
        }
        
        /**
         * 以自身面向受力，有随机值
         */
        public function addForce(forceX:Number, forceY:Number = 0):void {
            if (!this.alive) return;
            Tween.clearAll(this);
            forceX *= 1.5;
            var time:int = (Math.random() * 3 + 1) * Math.sqrt(forceX * forceX + forceY * forceY);
            
            if (this.standX != this.x)
                forceX *= 0.5;
            if (this.standY != this.y)
                forceY *= 0.5;
            if (!this.alive) {
                forceX = forceX * 1.2 + Math.random() * 20;
                forceY = forceY * 1.2 + (this.standY == 0 ? 0 : (Math.random() * 20 - 10));
                time += Math.random() * 100;
            }
            else {
                this.tweenTo(this, {}, 1, null, Handler.create(this, this.moveBack), time + 200 + Math.random() * 100);
                    //this.tweenTo(this, {update: new Handler(this, this.updatePos), x: this.standX, y: this.standY}, 300, Ease.quartIn, null, time + 200 + Math.random() * 100);
            }
            var tempX:Number = this.x + (this._baseFlip ? forceX : -forceX);
            var tempY:Number = this.y + forceY;
            var offsetX:Number = tempX - this.x;
            if (offsetX != 0) {
                this.setFlip(offsetX > 0);
            }
            //tempY = 0;
            this.tweenTo(this, {update: new Handler(this, this.updatePos), x: tempX, y: tempY}, time, Ease.sineOut);
        }
        
        /**
         * 跑回原位
         */
        private function moveBack():void {
            if (!this.alive) return;
            //var offsetX:Number = this.standX - this.x;
            //var offsetY:Number = this.standY - this.y;
            //var dis:Number = Math.sqrt(offsetX * offsetX + offsetY * offsetY);
			
			var dis:Number;
			var arr:Array = null;
			if (this.standY != this.y){
				dis = FightViewUtils.getDis(this.x, this.standX, this.y, this.standY);
				arr = [true];
			}
			else{
				dis = FightViewUtils.getDisX(this.x, this.standX);
			}

            if (this.standX != this.x) {
                this.setFlip(this.standX < this.x);
            }
            
            this.aniPlay(0, true, ConfigFightView.ANIMATION_RUN);
            var time:int = Math.ceil(FightViewUtils.getMoveTime(dis, 1) / ConfigFightView.BACK_SPEED_RATE);
            this.tweenTo(this, {update: new Handler(this, this.updatePos,arr), x: this.standX, y: this.standY}, time, Ease.sineInOut, Handler.create(this, this.standAndFlip));
        }
		
		
		/**
         * 添加buff
         */
        public function addBuff(buffObj:Object):void {
            if (!buffObj || !this.alive) return;
			var buffRes:String = buffObj.res;
			if (buffRes){
				var resZ:int = ConfigFightView.BUFF_Y - (buffObj.resZ?buffObj.resZ:0);
                this.addAnimation(buffRes, '', 0, resZ, buffObj.resAdd, true, true, buffObj.resScale, buffObj.resAlpha);
			}
        }
		/**
         * 移除buff
         */
        public function removeBuff(buffObj:Object):void {
            if (!buffObj || !this.alive) return;
			var buffRes:String = buffObj.res;
			if (buffRes){
				this.removeAnimation(buffRes);
			}
        }
        
        /**
         * 死亡
         */
        public function dead(hurtObj:Object):void {
            if (!this.alive) return;
            this.ani.offAll(Event.COMPLETE);
			this.removeAllAnimation();
            
            this.alive = false;
            this.aniPlay(0, false, ConfigFightView.ANIMATION_INJURED1);
            var time:int = Math.random() * 250 + 50;
            if (hurtObj) {
                this.beHit(hurtObj);
            }
            else {
                var newX:Number = this.x + (this._baseFlip ? -1 : 1) * (Math.random() * 40);
                var newY:Number = this.y + (this.standY == 0 ? 0 : (Math.random() * 40 - 20));
                
                //防御击退后才会死亡
                this.tweenTo(this, {update: new Handler(this, this.updatePos), x: newX, y: newY}, time, Ease.sineOut);
            }
            this.delayTo(time, this, this.deadEnd);
        }
        
        private function deadEnd():void {
			if (!this.spr || this.spr.destroyed)
				return;
            this.ani.offAll(Event.COMPLETE);
            if (this.standY != 0)
                this.spr.rotation = Math.random() * 40 - 20;
            
            this.updatePos();
			this.aniPlay(0, false, Math.random() > 0.5 ? ConfigFightView.ANIMATION_DEAD1 : ConfigFightView.ANIMATION_DEAD2);
            
            this.deadAndHide();
        }
        
        protected function deadAndHide():void {
			if (!this.spr || this.spr.destroyed)
				return;
            var unitLayer:Sprite = FightMain.instance.scene.unitLayer;
            if (this.spr.parent == unitLayer)
                unitLayer.setChildIndex(this.spr, 0);
            
            this.tweenTo(this.spr, {alpha: 0}, 500, null, Handler.create(this, this.hide), Math.random() * 3000 + 1000);
        }
        
        /**
         * 复活
         */
        public function revive():void {
            if (!this.spr || this.spr.destroyed)
				return;

			if (this.alive) return;
			this.clearDelayTo(this);
			//this.clearDelayTo(this, this.deadEnd);
			Tween.clearAll(this.spr);
			
			this.alive = true;
			this.spr.rotation = 0;
			this.spr.alpha = 0.5;
			this.spr.visible = true;
			//this.spr.rotation = 90;
			this.reStand();
			this.updatePos();
			this.appear();
        }
        
        /**
         * 设定为活着
         */
        public function setAlive():void {
            //this._baseScale = 1.5;
            this.alive = true;
            if (!this.spr || this.spr.destroyed)
				return;
				
			this.spr.rotation = 0;
			//this.spr.rotation = 45;
			this.spr.alpha = 0;
			this.appear();

        }
        
        /**
         * 设定为死亡
         */
        public function setDead():void {
            this.alive = false;
            this.hide();
        }
        
        public function show():void {
            if (this.spr != null) {
                this.spr.alpha = 1;
                this.spr.visible = true;
            }
        }
        
        public function hide():void {
            if (this.spr != null) {
                this.spr.alpha = 0;
                this.spr.visible = false;
            }
        }
		
		/**
         * 播放动画
         */
        public function aniPlay(start:* = 0, loop:Boolean = true, name:String = ""):void {
			//if (!this.ani.hasActionName(name)){
				//name = ConfigFightView.ANIMATION_STAND;
			//}
			this.ani.play(start, loop, name ,false);
		}
        

        override public function clear():void {
            //this.dead();
            super.clear();
            this.alive = false;
            Tween.clearAll(this);
        }
    }

}