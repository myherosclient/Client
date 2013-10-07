package 
{
	import myheros.devconsole.console.Cc;
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import myheros.devconsole.LogType;
	
	
	public class DevConsole extends Sprite{
		public function DevConsole() {
			//
			// SET UP - only required once
			//
			Cc.config.style.backgroundAlpha = 0.5;
			Cc.config.alwaysOnTop = true;
			
			Cc.startOnStage(this, "`"); // "`" - change for password. This will start hidden
			//Cc.fpsMonitor = true;
			//Cc.visible = true; // Show console, because having password hides console.
			//Cc.instance.panels.mainPanel.visible = false;
			
			Cc.config.commandLineAllowed = true; // enable advanced (but security risk) features.
			Cc.config.tracing = true; // Also trace on flash's normal trace
			//			Cc.config.remotingPassword = ""; // Just so that remote don't ask for password
			//			Cc.remoting = true; // Start sending logs to remote (using LocalConnection)
			
			Cc.commandLine = true; // Show command line
			Cc.width = 400;
			Cc.height = 300; // change height. You can set x y width height to position/size the main panel
		}
		
		public function AddCommand( cmd:String, callback:Function, desc:String = "" ):void
		{
			Cc.addSlashCommand(cmd, callback, desc);
		}
		
		public function Log( msg:String, type:int=0, color:uint=0xbbbbbb ):void {
			var ch:String = "socket";
			switch( type ) {
				case LogType.PACKET_BUFF:
					color = 0xffff00;
					break;
				case LogType.ERROR:
					color = 0xff0000;
					break;
				case LogType.PACKET_RECV:
					color = 0xff9900;
					break;
				case LogType.PACKET_SEND:
					color = 0x33BFE7;
					break;
				case LogType.INFO:
					ch = "info";
					color = 0x83E733;
					break;
				case LogType.ERROR:
					ch = "error";
					color = 0xFF0000;
					break;
				//				case LogType.MOVING:
				//					ch = "move";
				//					color = 0xFF00FF;
				//					break;
				//				case LogType.LOADING:
				//					ch = "load";
				//					color = 0xffffff;
				//					break;
				//				case LogType.WORKER:
				//					ch = "worker";
				//					color = 0xff5566;
				//					break;
				default:
					ch = "trace";
					break;
			}
			var t:int = getTimer();
			//var stamp:String = '[' + Utility.FormatTime( t/1000 ) + '.' + (t%1000) + "]";
			var stamp:String = '[' + t/1000 + '.' + (t%1000) + "]";
			msg = "<font color='#" + color.toString(16) + "'>" + stamp + msg + "</font>";
			return Cc.addHTMLch(ch, 1, msg);
		}
	}
}