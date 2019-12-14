package sg.manager
{
	import laya.debug.tools.ColorTool;
	import laya.display.Animation;
	import laya.display.Node;
	import laya.display.Sprite;
	import laya.display.Text;
	import laya.events.Event;
	import laya.filters.ColorFilter;
	import laya.maths.Point;
	import laya.particle.Particle2D;
	import laya.particle.ParticleSetting;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import sg.cfg.*;
	import sg.fight.client.cfg.ConfigFightView;
	import sg.fight.logic.utils.FightUtils;
	import sg.map.model.entitys.EntityCity;
	import sg.map.utils.TestUtils;
	import sg.scene.constant.EventConstant;
	import sg.utils.Tools;
	import sg.view.com.MouseTips;
	import ui.com.item_bagUI;
	import sg.view.com.ComPayType;
	import laya.utils.Pool;
	import sg.cfg.ConfigApp;
	import laya.utils.Browser;
	import laya.ani.bone.Skeleton;
	import sg.cfg.HelpConfig;
	
	/**
	 * 特效管理器
	 * @author zhuda
	 */
	public class EffectManager
	{
		/**
		 * 粒子obj缓存,临时用来解决内存问题
		 */
		public static var particlesDic:Object = {};
		public static function clearParticle(arr:Array,temp:Boolean):void
		{
			// if(temp){
			// 	Pool.clearBySign('myParticles');
			// 	return;
			// }
			// var len:int = arr?arr.length:0;
			// for(var i:int = 0;i < len;i++){
			// 	Pool.recover('myParticles',arr[0]);
			// }
			// trace(Pool.getPoolBySign('myParticles'));
			// trace('英雄身上粒子检查',particlesDic);
		}
		/**
		 * 加载粒子,自动循环
		 */
		public static function loadParticle(name:String, emissionRate:int = -1, maxPartices:int = -1, parent:Node = null, isTop:Boolean = true, x:Number = -99999, y:Number =-99999, advanceTime:Number = 0):Particle2D
		{
			var part:Particle2D = new Particle2D(null);//Pool.getItemByClass('myParticles',Particle2D);
			//part.stop();
			// var cnew:Boolean = false;
			// if(particlesDic[name]){
			// 	part = particlesDic[name];
			// }
			// else{
			// 	particlesDic[name] = part = new Particle2D(null);
			// 	cnew = true;

			// }
			// AssetsManager.loadedParticles[name] = name;
			//var assets:Array = AssetsManager.getParticleAssets(name);
			LoadeManager.loadImg(AssetsManager.getUrlParticle(name), Handler.create(null, function(setting:ParticleSetting):void
			{
				if (part && !part.destroyed)
				{
					if(setting){
						if(maxPartices > 0){
							setting.maxPartices = maxPartices;
						}
						if(emissionRate > 0){
							setting.emissionRate = emissionRate;
						}
						//part.pos(configArr[3], configArr[4]);
						
						part.setParticleSetting(setting);
						part.emitter.emissionRate = setting.emissionRate;
					}
					if (parent != null && !parent.destroyed)
					{
						if (isTop){
							parent.addChild(part);
						}
						else{
							parent.addChildAt(part,0);
						}
						if(x > -99999){
							part.x = x;
						}
						if(y > -99999){
							part.y = y;
						}
					}					
					if (advanceTime > 0){
						Laya.scaleTimer.once(100, this, function():void{
							if (part && part.advanceTime){
								part.advanceTime(advanceTime);
							}
						});
					}
					//part.emitter.start();
					part.play();
				}
			}));
			return part;
		}
		/**
		 * 加载对应英雄品质的背景粒子,自动循环
		 */
		public static function loadParticleByArr(configArr:Array, parentTop:Node, parentBottom:Node, advanceTime:Number = 0):Array
		{
			var parts:Array;
			if(configArr && configArr.length > 0){
				parts = [];
				var len:int = configArr.length;
				for (var i:int = 0; i < len; i++) 
				{
					var arr:Array = configArr[i];
					var parent:Node =  arr[5]?parentTop:parentBottom;
					var part:Particle2D = EffectManager.loadParticle(arr[0], arr[1], arr[2], parent, arr[5], arr[3], arr[4], advanceTime);
					parts.push(part);
				}
			}
			return parts;
		}
		
		public static var mouseTips:MouseTips;
		/**
		 * 绑定鼠标悬浮提示Tips
		 */
		public static function bindMouseTips(spr:Sprite, info:String, isHtml:Boolean = false, width:int = 0):void
		{
			if (!TestUtils.isTestShow && !ConfigApp.testFightType)
				return;
			if (!EffectManager.mouseTips){
				EffectManager.mouseTips = new MouseTips();
			}
			spr.off(Event.MOUSE_OVER, EffectManager.mouseTips, EffectManager.mouseTips.showInfo);
			spr.off(Event.MOUSE_OUT, null, hideMouseTips);
			if (info){
				spr.on(Event.MOUSE_OVER, EffectManager.mouseTips, EffectManager.mouseTips.showInfo, [spr, info, isHtml, width]);
				spr.on(Event.MOUSE_OUT, null, hideMouseTips);
			}
		}
		public static function hideMouseTips():void
		{
			if (EffectManager.mouseTips){
				EffectManager.mouseTips.removeSelf();
			}
		}

		/**
		 * 加载英雄动画，自动调取配置缩放，默认置为右下方向（在未加载成功时也可调用play其他动作，加载好后自动播放）
		 */
		public static function loadHeroAnimation(hid:String, isSkew:Boolean = true, stateName:String = '', endType:int = -3, group:String = ''):Animation
		{
			var heroConfig:Object = ConfigServer.hero[hid];
			var name:String = (heroConfig.res ? heroConfig.res : hid);
			if (isSkew)
				name += 's';
			if (ConfigServer.effect.checkRes && !ConfigServer.effect.hasRes.hasOwnProperty(name))
			{
				name = ConfigAssets.DefaultHeroAniName;
			}
			var ani:Animation = new Animation();
			ani = EffectManager.loadAnimation(name, stateName, endType, ani, group);
			if (isSkew){
				ani.play(0, true, 'down');
			}
			else{
				ani.play(0, true, 'stand');
			}
			if (heroConfig.scale)
			{
				ani.scale(heroConfig.scale, heroConfig.scale, true);
			}
			return ani;
		}
		
		/**
		 * 向UI容器中填充城池动画（自适应偏移缩放）
		 */
		public static function fillCityAnimation(ec:EntityCity, spr:Sprite, scaleValue:Number = 1):void
		{
			var res:String = ec.getParamConfig('res');

			if(ec.cityType==8) res = 'map012';//城门
			if(ec.cityType==9) res = 'map013';//襄阳城
				
			var arr:Array = res.split('_');
			res = arr[0];
			var ani:Animation = EffectManager.loadAnimation(res);
			if (arr.length > 1) {
				ani.scaleX *= -1;
			}
			scaleValue *= Math.min(spr.width / 200, spr.height / 150);
			var scaleTemp:Number = ec.getParamConfig('scale');

			
			var temp:Number;
			if (scaleTemp > 1){
				scaleValue /= Math.pow(scaleTemp,0.9);
			}

			if(ec.cityType==8) scaleValue = 0.5;//城门
			if(ec.cityType==9) scaleValue = 0.5;//襄阳城

			ani.scale(scaleValue, scaleValue);
			ani.x = spr.width * 0.5;
			ani.y = spr.height * (0.57 - (scaleTemp-1)*0.03);
			spr.addChild(ani);

		}
		
		/**
		 * 加载动画，完成后调用方法（caller和onCompletefun为空时，加载完成后自动显示）
		 */
		public static function loadAnimationAndCall(name:String, caller:* = null, onCompletefun:Function = null, args:Array = null, ani:Animation = null, group:String = ''):Animation
		{
			if (ani == null)
			{
				ani = new Animation();
			}
			//return  ani;
			if (!AssetsManager.loadedAnimations.hasOwnProperty(name))
				AssetsManager.loadedAnimations[name] = name;
			var assets:Array = AssetsManager.getAnimationAssets(name);
			
			var handler:Handler;
			if (onCompletefun)
			{
				handler = Handler.create(caller, onCompletefun, args);
			}
			LoadeManager.loadImg(assets, handler);
			
			if (!ignoreAni[name]) {
				if (!group) {
					ani.on(Event.UNDISPLAY, ani, onCacheDisplayHandler, [ani, name, Event.UNDISPLAY]);
					ani.on(Event.DISPLAY, ani, onCacheDisplayHandler, [ani, name, Event.DISPLAY]);
				} else if(group != 'fight'){
					animationCache['customGroup'][group] ||= {};
					animationCache['customGroup'][group][name] = 1;
				}
				
			}
			
			return ani;
		}
		
		/**
		 * 加载动画，完成后调用方法（caller和onCompletefun为空时，加载完成后自动显示）
		 * @param	name 资源名
		 * @param	stateName 动作名称，默认空。如果是多个动作自动连续调用，中间用|隔开，如'attack|stand|run|stand'
		 * @param	endType 结尾 默认0循环最终动作 1播放完自动删除 2播放完停止 3直接停止到该动作首帧 4直接停止到该动作末帧; -1循环所有动作 -2无动画直接停止 -3仅依赖原生playstop控制； -4循环所有动作切换时停顿半秒
		 * @return Animation
		 */
		public static function loadAnimation(name:String, stateName:String = '', endType:int = 0, ani:Animation = null, group:String = ''):Animation {
			if (ani == null)
			{
				ani = new Animation();
			}
			//return ani;
			if (!AssetsManager.loadedAnimations.hasOwnProperty(name))
				AssetsManager.loadedAnimations[name] = name;
			var assets:Array = AssetsManager.getAnimationAssets(name);
			LoadeManager.loadImg(assets, Handler.create(null, EffectManager.getAnimation, [name, stateName, endType, ani]));
			
			if (!ignoreAni[name]) {
				if (!group) {
					ani.on(Event.UNDISPLAY, ani, onCacheDisplayHandler, [ani, name, Event.UNDISPLAY]);
					ani.on(Event.DISPLAY, ani, onCacheDisplayHandler, [ani, name, Event.DISPLAY]);
				} else if(group != 'fight'){
					animationCache['customGroup'][group] ||= {};
					animationCache['customGroup'][group][name] = 1;
				}
				
			}
			
			return ani;
		}
		
		public static var ignoreAni:Object = {'touch_sc':1, 'glow000':1};
		
		public static function clearCacheGroup(group:String):void {
			var obj:Object = animationCache['customGroup'][group];
			if (!obj) return;
			for (var name:String in obj) {
				Laya.loader.clearTextureRes(AssetsManager.getUrlAtlas(name));
			}
			delete animationCache['customGroup'][group];
		}
		
		static private function onCacheDisplayHandler(ani:Animation, name:String, type:String):void {
			if (type == Event.UNDISPLAY) {				
				animationCache[name]--
				if (!animationCache[name]) {
					delete animationCache[name];
					Laya.loader.clearTextureRes(AssetsManager.getUrlAtlas(name));
				}
			} else {				
				animationCache[name] ||= 0;
				animationCache[name]++;		
			}
		}

		public static var animationCache:Object = {'customGroup':{}};
		
		/**
		 * 加载Spine动画
		 * @param	name 资源名
		 * @return Skeleton
		 */
		public static function loadSkeleton(name:String):Skeleton {
			var sk:Skeleton = new Skeleton();
			sk.load(AssetsManager.getUrlSkeleton(name))
			return sk;
		}
		
		/**
		 * 获得已经加载完成的动画(需要事先加载完毕图片)
		 */
		private static function getAnimationOnly(name:String, ani:Animation = null):Animation
		{
			if (ani == null)
			{
				ani = new Animation();
			}
			//return ani;
			//取得替代名称
			var res:String = AssetsManager.loadedAnimations[name];
			if (!res)
			{
				var obj:Object = AssetsManager.loadedAnimations;
				Trace.log(['loadedAnimations未找到 ' + name+' ,', obj]);
			}
			ani.loadAnimation(AssetsManager.getUrlAnimation(res));
			return ani;
		}
		
		/**
		 * 获得已经加载完成的动画，单纯播放动画
		 */
		public static function playAnimation(name:String, stateName:String = '', startFrame:int = 0, ani:Animation = null):Animation
		{
			ani = EffectManager.getAnimationOnly(name, ani);
			ani.play(startFrame, true, stateName, false);
			return ani;
		}
		
		/**
		 * 获得已经加载完成的动画，并组装动画(需要事先加载完毕图片)
		 * @param	name 资源名
		 * @param	stateName 动作名称，默认空。如果是多个动作自动连续调用，中间用|隔开，如'attack|stand|run|stand'
		 * @param	endType 结尾 默认0循环最终动作 1播放完自动删除 2播放完停止 3直接停止到该动作首帧 4直接停止到该动作末帧; -1循环所有动作 -2无动画直接停止 -3仅依赖原生playstop控制自动播放或停止动作； -4循环所有动作切换时停顿半秒
		 * @param	ani 动画对象
		 * @return
		 */
		public static function getAnimation(name:String, stateName:String = '', endType:int = 0, ani:Animation = null):Animation
		{
			ani = EffectManager.getAnimationOnly(name, ani);
			
			if (endType == -3){
				if(ani.isPlaying)
					ani.play(0, true, ani.actionName);
				else
					ani.stop();
			}
			else
			{
				EffectManager.setAnimationQueue(ani, Tools.isNullString(stateName) ? '' : stateName, endType);
				if (endType == -2)
				{
					ani.stop();
				}
			}
			
			return ani;
		}
		
		/**
		 * 给一个动画，绑定其之后要自动播放的动作序列，将占用.name缓存后续动作！
		 * @param	ani 动画对象
		 * @param	stateName 动作名称，默认空。如果是多个动作自动连续调用，中间用|隔开，如'attack|stand|run|stand'
		 * @param	endType 结尾 默认0循环最终动作 1播放完自动删除 2播放完停止 3直接停止到该动作首帧 4直接停止到该动作末帧; -1循环所有动作 -2无动画，直接停止； -4循环所有动作切换时停顿半秒
		 */
		public static function setAnimationQueue(ani:Animation, stateName:String = '', endType:int = 0):Animation
		{
			var arr:Array = stateName.split('|');
			var currStateName:String = arr[0];
			if (arr.length > 1)
			{
				//未到结尾
				arr.shift();
				if (endType == -1 || endType == -4)
				{
					arr.push(currStateName);
				}
				stateName = arr.join('|');
				ani.play(0, false, currStateName);
				if (endType == -4){
					ani.once(Event.COMPLETE, Laya.scaleTimer, Laya.scaleTimer.once, [500,null,EffectManager.setAnimationQueue,[ani, stateName, endType],false]);
				}
				else{
					ani.once(Event.COMPLETE, null, EffectManager.setAnimationQueue, [ani, stateName, endType]);
				}
			}
			else
			{
				//最后一个动作
				if (endType == 0)
				{
					ani.play(0, true, currStateName);
				}
				else
				{
					ani.play(0, false, currStateName);
					if (endType == 1)
					{
						ani.once(Event.COMPLETE, null, function():void
						{
							ani.event(EventConstant.DEAD);
							Tools.destroy(ani);
						});
					}
					else if (endType == 2)
					{
					}
					else if (endType == 3)
					{
						ani.stop();
					}
					else if (endType == 4)
					{
						ani.gotoAndStop(ani.count - 1);
					}
				}
				
			}
			return ani;
		}
		
		/**
		 * 加载动画并显示到指定位置，然后自动消失
		 */
		public static function popAnimation(src:String, startX:Number, startY:Number, parent:Node = null):Animation
		{
			var ani:Animation = loadAnimation(src, '', 1);
			ani.pos(startX, startY);
			
			if (parent == null)
			{
				parent = Laya.stage;
			}
			parent.addChild(ani);
			return ani;
		}
		
		/**
		 * 混合2种颜色
		 */
		public static function mixColor(color1:String, color2:String, rate:Number = 0.5):String
		{
			var color1Arr:Array = ColorTool.getRGBByRGBStr(color1);
			var color2Arr:Array = ColorTool.getRGBByRGBStr(color2);
			var color:String = ColorTool.getRGBStr(FightUtils.mix(color1Arr,color2Arr,rate));
			return color;
		}
		
		/**
		 * 对红色相对象进行变色，并且缓存位图
		 * @param	spr
		 * @param	colorType  使用默认srcObj时，colorType 0白1绿2蓝3紫4金5红，10以后为特殊颜色
		 * @param	cacheAs  缓存成位图
		 * @param	srcObj
		 * @return
		 */
		public static function changeSprColor(spr:Sprite, colorType:*, cacheAs:Boolean = true, srcObj:Object = null):Sprite
		{
			if (srcObj == null)
				srcObj = ConfigColor.COLOR_FILTER_MATRIX;
			var mat:Array = srcObj[colorType];
			return EffectManager.changeSprColorFilter(spr, mat, cacheAs);
		}
		
		/**
		 * 调整对象色相、饱和度、亮度，值0~1
		 */
		public static function changeSprColorTrans(spr:Sprite, hue:Number, saturation:Number, brightness:Number, cacheAs:Boolean = true):Sprite
		{
			var a:Number;
			var b:Number;
			var c:Number;
			var temp:Number;
			
			hue = hue % 1;
			if (hue < 1 / 3){
				temp = (1 / 3 - hue)*3;
				a = temp;
				b = 1 - temp;
				c = 0;
			}			
			else if (hue < 2 / 3){
				temp = (2 / 3 - hue)*3;
				a = 0;
				b = temp;
				c = 1 - temp;
			}
			else{
				temp = (1 - hue)*3;
				a = 1 - temp;
				b = 0;
				c = temp;
			}
			var rgbArr:Array = ConfigColor.RGB_BRIGHTNESS;
			var gray:Number = (1 - saturation)*brightness;
			var grayArr:Array = [rgbArr[0] * gray, rgbArr[1] * gray, rgbArr[2] * gray];
			brightness *= saturation;
			a *= brightness;
			b *= brightness;
			c *= brightness;
			
			var mat:Array = [
				grayArr[0] + a, grayArr[1] + b, grayArr[2] + c, 0, 0,
				grayArr[0] + c, grayArr[1] + a, grayArr[2] + b, 0, 0,
				grayArr[0] + b, grayArr[1] + c, grayArr[2] + a, 0, 0,
				0, 0, 0, 1, 0
			];
			
			return EffectManager.changeSprColorFilter(spr, mat, cacheAs);
		}
		/**
		 * 调整对象色相，值0~1，1为正常，映射到旋转上
		 */
		public static function changeSprHue(spr:Sprite, hue:Number, cacheAs:Boolean = true):Sprite
		{
			if (!hue || hue == 1)
			{
				spr.filters = null;
				spr.cacheAs = 'none';
				return spr;
			}
			hue = hue % 1;
			var a:Number;
			var b:Number;
			var c:Number;
			var temp:Number;
			if (hue < 1 / 3){
				temp = (1 / 3 - hue)*3;
				a = temp;
				b = 1 - temp;
				c = 0;
			}			
			else if (hue < 2 / 3){
				temp = (2 / 3 - hue)*3;
				a = 0;
				b = temp;
				c = 1 - temp;
			}
			else{
				temp = (1 - hue)*3;
				a = 1 - temp;
				b = 0;
				c = temp;
			}
			var mat:Array = [
				a, b, c, 0, 0,
				c, a, b, 0, 0,
				b, c, a, 0, 0,
				0, 0, 0, 1, 0
			];
			return EffectManager.changeSprColorFilter(spr, mat, cacheAs);
		}
		/**
		 * 调整对象饱和度，值0~1，1为正常，0为完全灰度，并且缓存位图
		 */
		public static function changeSprSaturation(spr:Sprite, saturation:Number, cacheAs:Boolean = true, rgbArr:Array = null):Sprite
		{
			if (saturation == 1)
			{
				spr.filters = null;
				spr.cacheAs = 'none';
				return spr;
			}
			if (!rgbArr)
				rgbArr = ConfigColor.RGB_BRIGHTNESS;
				
			var gray:Number = 1 - saturation;
			var grayArr:Array = [rgbArr[0] * gray, rgbArr[1] * gray, rgbArr[2] * gray];
			var mat:Array = [
				grayArr[0] + saturation, grayArr[1], grayArr[2], 0, 0,
				grayArr[0], grayArr[1] + saturation, grayArr[2], 0, 0,
				grayArr[0], grayArr[1], grayArr[2] + saturation, 0, 0,
				0, 0, 0, 1, 0
			];
			return EffectManager.changeSprColorFilter(spr, mat, cacheAs);
		}
		/**
		 * 调整对象亮度，亮度值0~10，1为正常，0为全黑，并且缓存位图
		 */
		public static function changeSprBrightness(spr:Sprite, brightness:Number, cacheAs:Boolean = true):Sprite
		{
			if (brightness == 1)
			{
				spr.filters = null;
				spr.cacheAs = 'none';
				return spr;
			}
			var mat:Array = [
				brightness, 0, 0, 0, 0,
				0, brightness, 0, 0, 0,
				0, 0, brightness, 0, 0,
				0, 0, 0, 1, 0
			];
			return EffectManager.changeSprColorFilter(spr, mat, cacheAs);
		}
		
		/**
		 * 调整对象的颜色滤镜，传入矩阵参数
		 */
		public static function changeSprColorFilter(spr:Sprite, mat:Array, cacheAs:Boolean = true):Sprite
		{
			if (mat)
			{
				var colorFilter:ColorFilter = new ColorFilter(mat);
				spr.filters = [colorFilter];
				if (cacheAs)
					spr.cacheAs = 'bitmap';
			}
			else{
				spr.filters = null;
				spr.cacheAs = 'none';
			}
			return spr;
		}
		
		/**
		 * 得到对应的颜色
		 * @param	colorType 使用默认srcObj时，0白1绿2蓝3紫4金5红，10以后为特殊颜色
		 * @param	srcArr
		 * @return
		 */
		public static function getFontColor(colorType:int, srcArr:Array = null):String
		{
			if (colorType < 0)
				return ConfigColor.FONT_COLOR_NULL;
			if (srcArr == null)
				srcArr = ConfigColor.FONT_COLORS;
			if (colorType >= srcArr.length){
				colorType = srcArr.length - 1;
			}
			return srcArr[colorType];
		}
		
		/**
		 * 开启自动循环自转，如果被移出屏幕自动关闭
		 */
		public static function startFrameRotate(spr:Sprite, speed:Number):void
		{
			spr['frameRotate'] = function(_this:Sprite, speed:Number):void{
				_this.rotation += speed;
			}
			spr.once(Event.REMOVED, null, endFrameRotate, [spr]);
			Laya.scaleTimer.frameLoop(1, spr ,spr['frameRotate'],[spr,speed],false);
		}
		private static function frameRotate(spr:Sprite, speed:Number):void
		{
			if (!spr || spr.destroyed) {
				endFrameRotate(spr);
				return;
			}
			spr.rotation += speed;
		}
		/**
		 * 开启自动循环自转，如果被移出屏幕自动关闭
		 */
		public static function endFrameRotate(spr:Sprite):void
		{
			//spr.off(Event.REMOVED, null, endFrameRotate, [spr]);
			spr.off(Event.REMOVED, null, endFrameRotate);
			if(spr['frameRotate'])
				Laya.scaleTimer.clear(spr, spr['frameRotate']);
		}
		
		/**
		 * 循环使用Tween，周期为 duration*2+wait0+wait1
		 */
		public static function tweenLoop(spr:Sprite, props:Object, duration:int, ease:Function = null, complete:Handler = null, delay:int = 0, loop:int = -1, wait0:int = 0, wait1:int = 0):void
		{
			if (!spr || spr.destroyed) return;
			var srcProps:Object = {};
			for (var key:String in props)
			{
				srcProps[key] = spr[key];
			}
			Tween.to(spr, props, duration, ease, null, delay);
			
			Tween.to(spr, srcProps, duration, ease, Handler.create(null, function():void
			{
				if (loop >= 0)
				{
					loop--;
					if (loop < 0)
					{
						if (complete)
							complete.run();
						return;
					}
				}
				EffectManager.tweenLoop(spr, props, duration, ease, complete, wait0, loop, wait0, wait1);
			
			}), delay + duration + wait1);
		}
		
		/**
		 * 循环使用Tween摇动，3段，周期为 duration*3+wait
		 */
		public static function tweenShake(spr:Sprite, props:Object, duration:int, ease:Function = null, complete:Handler = null, delay:int = 0, loop:int = -1, wait:int = 0):void
		{
			if (!spr || spr.destroyed) return;
			var srcProps:Object = {};
			var key:String;
			for (key in props)
			{
				if (props[key] is Number)
				{
					srcProps[key] = spr[key];
				}
				else
				{
					srcProps[key] = spr[key];
				}
			}
			var tempProps:Object = {};
			for (key in props)
			{
				if (props[key] is Number)
				{
					tempProps[key] = -props[key];
				}
				else
				{
					tempProps[key] = props[key];
				}
			}
			
			Tween.to(spr, props, duration, ease, null, delay);
			Tween.to(spr, tempProps, duration, ease, null, delay + duration);
			
			Tween.to(spr, srcProps, duration, ease, Handler.create(null, function():void
			{
				if (loop >= 0)
				{
					loop--;
					if (loop < 0)
					{
						if (complete)
							complete.run();
						return;
					}
				}
				EffectManager.tweenShake(spr, props, duration, ease, complete, wait, loop, wait);
			
			}), delay + duration * 2);
		}
		
		/**
		 * 为某个UI内增加特效，如果已存在则不添加
		 */
		public static function addUIAnimation(spr:Sprite, aniName:String, scale:Number = 1, posX:Number = 0, posY:Number = 0, isAdd:Boolean = false):void
		{
			var ani:Animation = spr.getChildByName(aniName) as Animation;
			if(!ani){
				ani = EffectManager.loadAnimation(aniName);
				ani.scale(scale, scale);
				ani.name = aniName;
				if(isAdd)
					ani.blendMode = 'lighter';
				ani.pos(posX, posY);
				spr.addChild(ani);
			}
		}
		
		/**
		 * 在某处弹出文本
		 */
		public static function createLabelRise(text:String, startX:Number, startY:Number, time:int = 2000, fontSize:Number = 40, color:String = '#FFFF00', strokeColor:String = '#333333', parent:Node = null):Label
		{
			var label:Label = new Label();
			label.pos(startX, startY);
			label.stroke = 3;
			label.strokeColor = strokeColor;
			label.color = color;
			label.fontSize = fontSize;
			label.text = text;
			label.align = 'center';
			label.valign = 'middle';
			label.height = fontSize + 10;
			label.anchorX = 0.5;
			label.anchorY = 0.5;
			label.scaleX = 0.5;
			label.scaleY = 0.5;
			Tween.to(label, {scaleX: 1, scaleY: 1}, 300, Ease.backOut);
			Tween.to(label, {y: startY - 80}, time, Ease.sineIn);
			Tween.to(label, {alpha: 0, scaleX: 1.5, scaleY: 1.5}, 300, Ease.sineIn, Handler.create(null, Tools.destroy, [label]), time - 300);
			
			if (parent == null)
			{
				parent = Laya.stage;
			}
			parent.addChild(label);
			
			return label;
		}
		
		/**
		 * 在某处生成大量图标，飞到指定位置消失
		 * @param	skin
		 * @param	startX
		 * @param	startY
		 * @param	endX
		 * @param	endY
		 * @param	scale
		 * @param	num
		 * @return
		 */
		public static function createIconFlight(skin:String, startX:Number, startY:Number, endX:Number, endY:Number, scale:Number = 1, num:int = 20, parent:Node = null):Box
		{
			var box:Box = new Box();
			var popDis:Number = 50;
			
			var allDis:Number = Math.sqrt(Math.pow(endX - startX, 2) + Math.pow(endY - startY, 2));
			var time:Number = allDis * 0.15 + 400;
			var popTime:Number = 250;
			var waitTime:Number = 200;
			var offsetMiddleY:Number = 40;
			if (endY > startY)
			{
				offsetMiddleY = -offsetMiddleY;
			}
			
			for (var i:int = 0; i < num; i++)
			{
				var delay:int = 100 * Math.random();
				var img:Image = new Image(skin);
				var angle:Number = Math.random() * Math.PI * 2;
				var tempDis:Number = (Math.random()*0.6+0.7) * popDis;
				var tempX:Number = tempDis * Math.cos(angle);
				var tempY:Number = tempDis * Math.sin(angle);
				var handleX:Number = (startX + endX) * 0.5 + tempX * 1.5;
				var handleY:Number = startY + tempY * 1.5 + offsetMiddleY * (Math.random()*0.6+0.7);
				var downDis:Number = (Math.random()*0.6+0.7) * 10;
				
				img.alpha = 0;
				img.scale(0.5, 0.5);
				img.anchorX = 0.5;
				img.anchorY = 0.5;
				tempX += startX;
				tempY += startY;
				img.x = startX;
				img.y = startY;
				img['temp'] = 0;
				//img.t = 0;//liuhaitao
				box.addChild(img);
				//Tween.to(img, {x:endX, y:endY, alpha:0}, endTime, Ease.sineInOut, null, 100);
				//先圆形炸开，下沉等待，后快速飞行
				
				Tween.to(img, {alpha:1, scaleX: scale, scaleY: scale, x:tempX, y:tempY}, popTime, Ease.backOut, null, delay);
				Tween.to(img, {y:tempY + downDis}, waitTime, Ease.linearNone, null, delay + popTime);
				
				Tween.to(img, {update: new Handler(null, EffectManager.bezierFlight, [img, tempX, tempY + downDis, handleX, handleY, endX, endY]), temp: 1}, time, Ease.sineIn, null, delay + popTime + waitTime);
				Tween.to(img, {alpha: 0.2}, time * 0.2, Ease.linearNone, Handler.create(null, Tools.destroy, [img]), delay + popTime + waitTime + time * 0.8);
			}
			if (parent == null)
			{
				parent = Laya.stage;
			}
			parent.addChild(box);
			
			var ani:Animation = EffectManager.popAnimation('glow011', startX, startY, box);
			ani.scale(0.6, 0.6);
			return box;
		}
		
		/**
		 * 获得货币的时候的文字飘动
		 * @param	str
		 * @param	str2
		 * @param	startX
		 * @param	startY
		 */
		public static function textFlight(str:String, str2:String, startX:Number, startY:Number, parent:Node = null,dir:Number = -1):Text
		{
			if (str == '' || str2 == ' ')
				return null;
			var t:Text = new Text();
			t.x = startX;
			t.y = startY;
			var strNum:Number = Number(str);
			t.text = str2 + ((strNum>0)?' +' + str:str);
			t.fontSize = 30;
			t.color = '#ffffff';
			t.strokeColor = '#000000';
			t.stroke = 2;
			if (t.x + t.width > Laya.stage.width)
			{
				t.x = Laya.stage.width - t.width;
			}
			//Laya.stage.addChild(t);
			if (parent == null)
			{
				parent = Laya.stage;
			}
			// t.pivotX = t.width*0.5;
			t.pivotY = t.height*0.5;
			parent.addChild(t);
			t.scaleX = 0.9;
			t.scaleY = 0.9;
			Tween.to(t, {y: t.y + (50*dir),scaleX:1.1,scaleY:1.1}, 800, null, Handler.create(Laya.stage, function():void
			{
				t.destroy();
			}), 0, false, false);
			return t;
		}


		public static function comFlight(com:Sprite,startX:Number, startY:Number, parent:Node = null):void{
			if (parent == null)
			{
				parent = Laya.stage;
			}
			parent.addChild(com);
			com.x = startX;
			com.y = startY;
			Tween.to(com, {y: com.y - 100}, 800,  Ease.sineInOut, Handler.create(Laya.stage, function():void
			{
				com.destroy();
			}), 0, false, false);
		}
		
		/**
		 * 将某道具对象提到最上层，飞到指定位置消失
		 * @param	spr
		 * @param	endX
		 * @param	endY
		 * @return
		 */
		public static function itemFlight(spr:Sprite, endX:Number, endY:Number, parent:Node = null,hasBag:Boolean = true):Number
		{
			EffectManager.popAnimation('glow044', 68, 69, spr);
			return spriteFlight(spr, endX, endY, 136, 136, parent, hasBag);
		}
		
		/**
		 * 将某显示对象提到最上层，飞到指定位置消失
		 * @param	spr
		 * @param	endX
		 * @param	endY
		 * @param	width
		 * @param	height
		 * @return
		 */
		public static function spriteFlight(spr:Sprite, endX:Number, endY:Number, width:Number = 0, height:Number = 0, parent:Node = null, hasBag:Boolean = true):Number
		{
			
			if (spr == null || spr.destroyed)
				return 0;
			var point:Point = spr.localToGlobal(new Point());
			spr.pos(point.x, point.y);
			
			//spr.getBounds
			//var rect:Rectangle = spr.getSelfBounds();
			var popDis:Number = 50;
			
			var popTime:Number = 450;
			var waitTime:Number = 0;
			var tempX:Number = Math.random() * 10 -5 + point.x;
			var tempY:Number = Math.random() * 20 -30 + point.y;
			//tempX = point.x;

			
			var allDis:Number = Math.sqrt(Math.pow(endX - tempX, 2) + Math.pow(endY - tempY, 2));
			var time:Number = allDis * (ConfigApp.isPC?0.1:0.15) + 400;
			
			var offsetMiddleY:Number = ConfigApp.isPC?100:40;
			var globalScaleX:Number = spr.globalScaleX;
			var globalScaleY:Number = spr.globalScaleY;
			
			spr.cacheAs = 'bitmap';
			if (endY >= point.y)
			{
				offsetMiddleY = -offsetMiddleY;
			}
			var handleX:Number = (tempX + endX) * 0.5;
			var handleY:Number = tempY + offsetMiddleY;
			
			spr.pivotX = width * 0.5;
			spr.pivotY = height * 0.5;
			spr.scaleX = globalScaleX;
			spr.scaleY = globalScaleY;
			
			spr['temp'] = 0;
			//上浮后向下飞行
			Tween.to(spr, {x:tempX, y:tempY}, popTime, Ease.backOut, null);
			Tween.to(spr, {update: new Handler(null, EffectManager.bezierFlight, [spr, tempX, tempY, handleX, handleY, endX, endY]), temp: 1}, time, Ease.sineIn, null, popTime + waitTime);
			Tween.to(spr, {scaleX:0.3, scaleY:0.3}, time * 0.8, Ease.sineIn, null, popTime + waitTime + time * 0.2);
			Tween.to(spr, {alpha: 0.2}, time * 0.2, Ease.linearNone, Handler.create(null, Tools.destroy, [spr]), popTime + waitTime + time * 0.8);
			
			if (parent == null)
			{
				parent = Laya.stage;
			}
			parent.addChild(spr);
			


			if (hasBag){
				var item_bag:item_bagUI = new item_bagUI();
				//Laya.stage.addChild(item_bag);
				item_bag.name = 'bag';
				item_bag.bottom = 0;
				if(ConfigApp.isPC){
					item_bag.right = 130 + (69+30)*2;
				}else{
					item_bag.centerX = 61;	
				}
				item_bag.alpha = 0;
				item_bag.icon.cacheAs = 'bitmap';
				if (ConfigApp.testFightType){
					Laya.stage.addChild(item_bag);
				}
				else{
					ViewManager.instance.showEffect(item_bag, false);
				}
				
				Tween.to(item_bag, {alpha:1}, 100, Ease.linearNone, null, popTime + waitTime + time - 50);
				Tween.to(item_bag.icon, {y: 15}, 100, Ease.backInOut, null, popTime + waitTime + time + 0);
				Tween.to(item_bag.icon, {y: 5}, 100, Ease.backInOut, null, popTime + waitTime + time + 100);
				Tween.to(item_bag.icon, {y: 15}, 100, Ease.backInOut, null, popTime + waitTime + time + 200);
				Tween.to(item_bag, {alpha: 0}, 500, Ease.sineIn, Handler.create(null, Tools.destroy, [item_bag]), popTime + waitTime + time + 500);
			}
			return popTime + waitTime + time;
		}
		
		/**
		 * 1段贝塞尔曲线
		 * @param	spr
		 * @param	startX
		 * @param	startY
		 * @param	handleX
		 * @param	handleY
		 * @param	endX
		 * @param	endY
		 */
		private static function bezierFlight(spr:Sprite, startX:Number, startY:Number, handleX:Number, handleY:Number, endX:Number, endY:Number):void
		{
			if (!spr || spr.destroyed)
				return;
			var t:Number = spr['temp'];
			var temp:Number = 1 - t;
			var tx:Number = temp * temp * startX + 2 * t * temp * handleX + t * t * endX;
			var ty:Number = temp * temp * startY + 2 * t * temp * handleY + t * t * endY;
			spr.x = tx;
			spr.y = ty;
		}
		
		/**
		 * 生成一队兵的静态Sprite，自动按体型排布，中心点对齐
		 */
		public static function loadArmysIcon(id:String):Sprite
		{
			var spr:Sprite = new Sprite();
			EffectManager.loadAnimationAndCall(id, null, function():void{
				var size:int = ConfigFightView.ARMY_SIZE[id] != null ? ConfigFightView.ARMY_SIZE[id] : 0;
				var formation:Array = ConfigFightView.ARMY_ICON_FORMATION[size] as Array;
				var i:int;
				var len:int = formation.length;
				//var img:Image = new Image('ui/icon_ army01.png');
				//img.centerX = 0;
				//img.centerY = 0;
				//spr.addChild(img);
				//spr.addChild(EffectManager.loadAnimation('glow011'));
				for (i = len- 1; i >=0; i-- ){
					var ani:Animation = EffectManager.loadAnimation(id, 'stand', 4);
					var pos:Array = formation[i];
					spr.addChild(ani);
					ani.pos(pos[0], pos[1]);
					var scale:Number = (1 - pos[2] * 0.1) * (pos.length>3?pos[3]:1);
					ani.scale(scale, scale, true);
					EffectManager.changeSprBrightness(ani, 1 - pos[2] * 0.1);
				}	
			});
			return spr;
		}
		
		/**
		 * 加载并显示开始画面(欢迎屏幕)动画组。完整加载所有素材再播放，保证连贯体验
		 */
		public static function loadWelcomeScreen():Sprite
		{
			var spr:Sprite = new Sprite();
			AssetsManager.preloadWelcomeScreen(null, EffectManager.getWelcomeScreen, [spr]);
			return spr;
		}
		
		public static function getWelcomeScreen(spr:Sprite = null):Sprite
		{
			if (spr == null){
				spr = new Sprite();
			}
			var bg:Image = new Image();
			LoadeManager.loadTemp(bg, AssetsManager.getAssetsAD('000.jpg'));
			bg.anchorX = bg.anchorY = 0.5;
			var spr_f:Sprite = new Sprite();
			var spr_b:Sprite = new Sprite();
			var spr_m:Sprite = new Sprite();
			spr.addChildren(bg, spr_b, spr_m, spr_f);
			var stageW:Number = Laya.stage.width;
			var stageH:Number = Laya.stage.height;
			spr_f.name = 'spr_f';
			spr_b.name = 'spr_b';
			spr_m.name = 'spr_m';

			//创建一个Skeleton对象
			var skeleton:Skeleton;
			if(HelpConfig.type_app == HelpConfig.TYPE_SG){
				if(ConfigApp.isPC){
					skeleton = EffectManager.loadSkeleton('s_pc');
					skeleton.y = 180;
					skeleton.scaleX = skeleton.scaleY = 1.35;
				}else{
					skeleton = EffectManager.loadSkeleton('s_01');
				}
				spr_f.addChild(skeleton);
			}else if (HelpConfig.type_app == HelpConfig.TYPE_WW){
				spr_f.addChild(EffectManager.loadSkeleton('s_a'));
				
				var c_skeleton:Skeleton = EffectManager.loadSkeleton('s_c');
				c_skeleton.scaleX = c_skeleton.scaleY = 1.05;
				spr_b.addChild(c_skeleton);

				spr_b.addChild(EffectManager.loadSkeleton('s_b'));
			}
			
			
			var part:Particle2D;
			var offsetX:Number = 100;
			var ratio:Number = (Browser.clientHeight / Browser.clientWidth) / (stageH / stageW);
			var offsetY:Number = ratio * stageH * 0.6;
			if(HelpConfig.type_app == HelpConfig.TYPE_SG){
				part = EffectManager.loadParticle('p018', 15, 15, spr_b, true, 0, 200);
				part.scaleX = part.scaleY = 6;
				part = EffectManager.loadParticle('p019', 30, 30, spr_f, true, offsetX, offsetY - 100);
				part.scaleX = part.scaleY = 3;
				if(ConfigApp.isPC){//云粒子*2 火苗粒子去掉
					part = EffectManager.loadParticle('p020', 10, 100, spr_f, true, offsetX, offsetY - 100);
				}else{
					part = EffectManager.loadParticle('p020', 10, 50, spr_f, true, offsetX, offsetY - 100);
					EffectManager.loadParticle('p017', 100, 400, spr_f, true, offsetX, offsetY - 150);	
				}
			}else if(HelpConfig.type_app == HelpConfig.TYPE_WW){

				part = EffectManager.loadParticle('p017', 100, 400, spr_m, true, offsetX, offsetY-600);	
				part = EffectManager.loadParticle('p021', 20, 500, spr_f, true, offsetX, offsetY-400);
				part.scaleX = part.scaleY = 3;
				part = EffectManager.loadParticle('p020', 20, 500, spr_f, true, offsetX, offsetY-300);
				part.scaleX = part.scaleY = 3;
				part = EffectManager.loadParticle('p020', 20, 500, spr_f, true, offsetX, offsetY-200);
				part.scaleX = part.scaleY = 3;
				part = EffectManager.loadParticle('p017', 100, 400, spr_f, true, offsetX, offsetY-500);	
			}
			spr.pos(stageW / 2, stageH / 2);
			if(ConfigApp.isPC) bg.visible = false;	
			if(HelpConfig.type_app == HelpConfig.TYPE_WW) bg.visible = false;
			return spr;
		}
		
		/**
		 * 创建英雄升星动画组。完整加载所有素材再播放，保证连贯体验
		 */
		public static function loadHeroStarUp(heroId:String, starType:int, caller:* = null, onCompletefun:Function = null, args:Array = null):Sprite
		{
			var spr:Sprite = new Sprite();
			AssetsManager.preLoadAssets([AssetsManager.getAssetsHero(heroId, false)], ['glow008bg', 'glow008fg'], null, null, EffectManager.getHeroStarUp, [heroId, starType, spr, caller, onCompletefun, args]);
			return spr;
		}
		
		private static function getHeroStarUp(heroId:String, starType:int, spr:Sprite = null, caller:* = null, onCompletefun:Function = null, args:Array = null):Sprite
		{
			if (spr == null)
			{
				spr = new Animation();
			}
			var ani:Animation;
			var img:Image;
			
			ani = EffectManager.loadAnimation('glow008bg', '', 1);
			EffectManager.changeSprColor(ani, starType, false);
			spr.addChild(ani);
			
			img = new Image(AssetsManager.getAssetsHero(heroId, false));
			img.y = -80;
			img.anchorX = 0.5;
			img.anchorY = 0.5;
			img.scale(1.2, 1.2, true);
			img.alpha = 0;
			Tween.to(img, {alpha: 1}, 200);
			Tween.to(img, {y: img.y - 30}, 2000, Ease.sineOut);
			Tween.to(img, {alpha: 0, y: img.y - 100}, 200, Ease.sineIn, Handler.create(img, function():void
			{
				img.destroy();
				if (onCompletefun)
				{
					onCompletefun.apply(caller, args);
				}
			}), 2000);
			spr.addChild(img);
			
			ani = EffectManager.loadAnimation('glow008fg', '', 1);
			EffectManager.changeSprColor(ani, starType, false);
			spr.addChild(ani);
			
			spr.pos(Laya.stage.width / 2, Laya.stage.height / 2);
			return spr;
		}
	}

}
