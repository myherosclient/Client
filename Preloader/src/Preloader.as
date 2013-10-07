package 
{
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import myheros.loader.LoaderMgr;
	import myheros.loader.LoaderNode;

	[SWF(widthPercent="100", heightPercent="100",backgroundColor="#000000", frameRate="30")]
	public class Preloader extends Sprite
	{
		private var centerText:TextField;
		private var windowsUrl:String;
		
		public function Preloader(){
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.stageFocusRect = false;
			
			ParserWindowsUrl();

			centerText = new TextField();
			centerText.defaultTextFormat = new TextFormat( "", 24, 0xffffff, false, false, false, null, null, "center" );
			centerText.autoSize = TextFieldAutoSize.CENTER;
			centerText.x = (stage.stageWidth - centerText.width) >> 1;
			centerText.y = (stage.stageHeight - centerText.height) >> 1;
			centerText.text = "Start Loading...";
			addChild( centerText );
			
			stage.addEventListener( Event.RESIZE, OnResize );
			
			var frameclass_file:String = "config/frameclass.dat";
			var frameclass_md5:String = GetFrameClassFileMd5();

			LoaderNode.lnCdnVec.push("");
			LoaderMgr.inst.AddRequest(frameclass_file, frameclass_md5, LoaderNode.LNTYPE_XML, LoaderMgr.LM_PRI_CLASS, LoadComplete, Preloader_OnProgress, LoadError);
			LoaderMgr.inst.TryNextLoading();

			setTimeout(LoaderMgr.inst.ClearTest, 10000);
			
//			LoaderNode.lnCdnVec.push( "2222" );
//			LoaderNode.lnCdnVec.push( "3333" );

//			LoaderMgr.inst.AddRequest( "ccc.swf", "", 1, LoaderMgr.LM_PRI_CLASS, LoadComplete, Preloader_OnProgress, LoadError );
//			LoaderMgr.inst.AddRequest( "ConsoleXajh.swf", "", 1, LoaderMgr.LM_PRI_CLASS, LoadComplete, Preloader_OnProgress, LoadError );
		}
		
		private function ParserWindowsUrl():void{
			windowsUrl = ExternalInterface.call( "function getURL(){return window.location.search;}" );
			if(windowsUrl.search("unUseMD5=1") >= 0){
				LoaderNode.LOADFILE_BYMD5 = false;
			}
		}
		
		private function GetFrameClassFileMd5():String{
			var temp:String = windowsUrl;
			var pos:int = temp.search("m=");
			if( pos >= 0 ){
				temp = temp.substr(pos+2);
			}
			
			return temp.substr(0, 32);
		}

		private function dispose():void{
			stage.removeEventListener( Event.RESIZE, OnResize );
			removeChild( centerText );
			centerText = null;
		}
		
		private function OnResize( e:Event ):void{
			centerText.x = (stage.stageWidth - centerText.width) >> 1;
			centerText.y = (stage.stageHeight - centerText.height) >> 1;
		}
		
		private function Preloader_OnProgress(e:ProgressEvent, ln:LoaderNode):void{
			centerText.text = int(( e.bytesLoaded/e.bytesTotal )*100 )+"%";
		}
		
		private function DevLoginLoaded(e:Event, ln:LoaderNode):void{
//			var dev_con:Sprite = e.currentTarget.content as Sprite;
//			addChild( dev_con );
			
			dispose();
		}
		
		private function LoadComplete(e:Event, ln:LoaderNode):void{
			if( ln.fileType == LoaderNode.LNTYPE_CLASS ){
//				var console:DisplayObject = e.currentTarget.content as DisplayObject;
//				addChild( console );
			}
			
			if( ln.fileType == LoaderNode.LNTYPE_XML ){
				var ldi:LoaderInfo = e.currentTarget as LoaderInfo;
				var ba:ByteArray = ldi.bytes;
				
				ba.position = 581;
				var out:String = ba.readUTFBytes(189);
				var x:XML = new XML(out);
				
				var devconsole_module:XML = x.Module.(@file == "DevConsole")[0];
				if( null == devconsole_module ){
					centerText.text = "can't find DevConsole";
				}else{
					var devconsole_file:String = devconsole_module.@file + ".swf";
					var devconsole_md5:String = devconsole_module.@md5;
					
					LoaderMgr.inst.AddRequest(devconsole_file, devconsole_md5, LoaderNode.LNTYPE_CLASS, LoaderMgr.LM_PRI_CLASS, LoadComplete, Preloader_OnProgress, LoadError);
					LoaderMgr.inst.TryNextLoading();
				}
				
				var devlogin_module:XML = x.Module.(@file == "DevLogin")[0];
				if( null == devlogin_module ){
					centerText.text = "can't find DevLogin";
				}else{
					var devlogin_file:String = devlogin_module.@file + ".swf";
					var devlogin_md5:String = devlogin_module.@md5;
					
					LoaderMgr.inst.AddRequest(devlogin_file, devlogin_md5, LoaderNode.LNTYPE_CLASS, LoaderMgr.LM_PRI_CLASS, DevLoginLoaded, Preloader_OnProgress, LoadError);
					LoaderMgr.inst.TryNextLoading();
				}
				
			}
		}

		private function LoadError(ln:LoaderNode):void{
			centerText.text = ln.fileUrl + " 下载失败！ md5=" + ln.fileMD5;
		}
	}
}