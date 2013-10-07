package myheros.loader
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.setTimeout;
	
	public class LoaderNode
	{
		public static var LOADFILE_BYMD5:Boolean = true;
		
		public static const LNLOAD_FAILED:int = -1;
		public static const LNLOAD_EMPTY:int = 0;
		public static const LNLOAD_LOADING:int = 1;
		public static const LNLOAD_LOADED:int = 2;
		
		public static const LNTYPE_CLASS:int = 1;
		public static const LNTYPE_XML:int = 2;
		
		public static const lnLoaderCon:LoaderContext = new LoaderContext( false, new ApplicationDomain() );
		public static const lnCdnVec:Vector.<String> = new Vector.<String>;
		
		public var loadStep:int = LNLOAD_EMPTY;
		
		public var fileUrl:String;
		public var fileMD5:String;
		public var fileType:int;
		public var downPriority:int;
		
		private var loaderMain:Loader = new Loader();
		private var loadedEvent:Event;
		private var reloadCount:int;
		private var cdnIndex:int;
		
		private const completeFuncVec:Vector.<Function> = new Vector.<Function>;
		private const progressFuncVec:Vector.<Function> = new Vector.<Function>;
		private const errorFuncVec:Vector.<Function> = new Vector.<Function>;
		private const callnextFuncVec:Vector.<Function> = new Vector.<Function>;
		
		public function LoaderNode(url:String, md5:String, type:int, pri:int){
			fileUrl = url;
			fileMD5 = md5;
			fileType = type;
			downPriority = pri;
						
			reloadCount = lnCdnVec.length;
			cdnIndex = Math.random()*lnCdnVec.length;
		}
		
		public function dispose():void{
			loaderMain.unload();
			loaderMain=null;
		}
		
		public function PushCallBack(complete_cb:Function = null, progress_cb:Function = null, error_cb:Function = null):void{
			if( LNLOAD_LOADED == loadStep ){
				complete_cb(loadedEvent);
			}else if( LNLOAD_FAILED == loadStep ){
				error_cb();
			}else{
				if( complete_cb != null )
					completeFuncVec.push(complete_cb);
				
				if( progress_cb != null )
					progressFuncVec.push(progress_cb);
				
				if( error_cb != null )
					errorFuncVec.push(error_cb);
			}
		}
		
		public function TryStart(callnext:Function):void{
			if( LNLOAD_LOADED == loadStep || LNLOAD_FAILED == loadStep ){
				callnext();
				return;
			}

			callnextFuncVec.push(callnext);

			if( loadStep == LNLOAD_EMPTY ){
				loadStep = LNLOAD_LOADING;
				
				var url_req:URLRequest = new URLRequest(GetUrlReqStr());
				AddEvent();
				loaderMain.load(url_req, lnLoaderCon);
			}
		}
		
		private function GetUrlReqStr():String{
			if( LOADFILE_BYMD5 ){
				return lnCdnVec[cdnIndex] + "cdn/" + fileMD5;
			}else{
				return lnCdnVec[cdnIndex] + fileUrl;
			}
		}
		
		private function AddEvent():void{
			var li:LoaderInfo = loaderMain.contentLoaderInfo;
			li.addEventListener(Event.COMPLETE, LoadComplete);
			li.addEventListener(ProgressEvent.PROGRESS, Progress);
			//li.addEventListener(HTTPStatusEvent.HTTP_STATUS, HttpStatus);
			li.addEventListener(IOErrorEvent.IO_ERROR, IoErrorHandler);
			li.addEventListener(SecurityErrorEvent.SECURITY_ERROR, SecurityErrorHandler);
		}
		
		private function RemoveEvent():void{
			var li:LoaderInfo = loaderMain.contentLoaderInfo;			
			li.removeEventListener(Event.COMPLETE, LoadComplete);
			li.removeEventListener(ProgressEvent.PROGRESS, Progress);
			//li.removeEventListener(HTTPStatusEvent.HTTP_STATUS, HttpStatus);
			li.removeEventListener(IOErrorEvent.IO_ERROR, IoErrorHandler);
			li.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, SecurityErrorHandler);
		}
		
		/** 这里只能设置结果状态 loaded 或 failed */
		private function SetLoadResult(r:int):void{
			loadStep = r;
			
			for each( var f:Function in callnextFuncVec ){
				f();
			}
			
			completeFuncVec.length = 0;
			progressFuncVec.length = 0;
			errorFuncVec.length = 0;
			callnextFuncVec.length = 0;
			
			RemoveEvent();
		}
		
		private function LoadComplete(e:Event):void{
			loadedEvent = e;
			for each( var f:Function in completeFuncVec ){
				f(e, this);
			}
			
			SetLoadResult( LNLOAD_LOADED );
		}
		
		private function Progress(e:ProgressEvent):void{
			for each( var f:Function in progressFuncVec ){
				f(e, this);
			}
		}
		
//		private function HttpStatus(e:HTTPStatusEvent):void{
//			//trace(e);
//		}
		
		private function SecurityErrorHandler(e:SecurityErrorEvent):void{
			//trace(e);
			DelayToLoad();
		}
		
		private function IoErrorHandler(e:IOErrorEvent):void{
			//trace(e);
			DelayToLoad();
		}
		
		private function DelayToLoad():void{
			loaderMain.unload();
			
			if (this.reloadCount <= 1){
				for each( var f:Function in errorFuncVec ){
					f(this);
				}
				
				SetLoadResult( LNLOAD_FAILED );
				return;
			};
			
			this.reloadCount--;
			cdnIndex++;
			if( cdnIndex >= lnCdnVec.length ) cdnIndex = 0;
			
			setTimeout( Retry, 100 );
		}
		
		private function Retry():void{
			var url_req:URLRequest = new URLRequest(GetUrlReqStr());
			loaderMain.load(url_req, lnLoaderCon);
		}
	}
}