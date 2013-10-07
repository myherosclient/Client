package 
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;

	public class DevLogin extends Sprite
	{
		private var _Fcm:int = 1;
		private var _FcmBtn:SimpleButton;
		private var _LoginBtn:SimpleButton;
		private var _NameInput:TextField;
		
		public function DevLogin()
		{
			return;
			var nameLbl:TextField = new TextField();
			nameLbl.text = "Account:";
			nameLbl.filters = [new GlowFilter(0, 1, 2, 2, 4, 3)];
			nameLbl.textColor = 0xffffff;
			nameLbl.height = 20;
			
			_NameInput = new TextField();
			_NameInput.type = TextFieldType.INPUT;
			_NameInput.border = true;
			_NameInput.borderColor = 0xcccccc;
			_NameInput.textColor = 0xffffff;
			_NameInput.background =true;
			_NameInput.backgroundColor = 0x333333;
			//_NameInput.restrict = "a-zA-Z0-9_";
			_NameInput.x = nameLbl.textWidth + 10;
			//                _NameInput.text = "meibin";
			_NameInput.width = 100;
			_NameInput.height = 18;
			_NameInput.maxChars = 20;
			

			_FcmBtn = CreateButton("Minor Login");
			_FcmBtn.addEventListener(MouseEvent.CLICK, FcmBtn_OnClick );
			//			_FcmBtn.x = pwdLbl.x;
			//			_FcmBtn.y = _PwdInput.y + pwdLbl.y+ 10;
			_FcmBtn.y = nameLbl.y + nameLbl.textHeight+ 10;
			
			_LoginBtn = CreateButton("Login");
			_LoginBtn.addEventListener(MouseEvent.CLICK, LoginBtn_OnClick );
			_LoginBtn.x = _FcmBtn.x + 90;
			_LoginBtn.y = _FcmBtn.y;
			
			
			var serverinfo:TextField = new TextField();
			serverinfo.filters = [new GlowFilter(0xff0000, 1, 2, 2, 4, 3)];
			serverinfo.textColor = 0xffffff;
			serverinfo.y = _FcmBtn.y + _FcmBtn.height + 10;
			serverinfo.width = 300;
			//serverinfo.text = "ServerName = " + GlobalVariables.ServerName + "   ServerIP = " + GlobalVariables.ServerHost;
			
			
			
			addChild( nameLbl );
			addChild( _NameInput );
			addChild( _FcmBtn );
			addChild( _LoginBtn );
			addChild( serverinfo );
		}
		
		private function CreateButton( txt:String ):SimpleButton {
			var lbl:TextField = new TextField();
			lbl.border = true;
			lbl.borderColor = 0xcccccc;
			lbl.background = true;
			lbl.backgroundColor = 0x333333;
			lbl.textColor = 0xffffff;
			lbl.defaultTextFormat = new TextFormat("宋体",12, 0xffffff, false, false, true, null, null, "center");
			lbl.text = txt;
			lbl.width = 80;
			lbl.height = 20;
			
			var bitmap:BitmapData = new BitmapData(lbl.width+1, lbl.height+1);
			bitmap.draw(lbl);
			
			var shape:Shape = new Shape();
			shape.graphics.beginBitmapFill(bitmap);
			shape.graphics.drawRect(0,0, lbl.width+1,lbl.height+1);
			
			var btn:SimpleButton = new SimpleButton(shape, shape, shape, shape);
			btn.useHandCursor = true;
			btn.width = lbl.width+1;
			btn.height = lbl.height+1;
			
			return btn;
		}
		
		private function LoginBtn_OnClick(e:MouseEvent):void {
			_Fcm = 0;
			
			
			//GlobalVariables.FCM=0;
			Login();
		}
		private function FcmBtn_OnClick(e:MouseEvent):void {
			_Fcm = 1;
			//GlobalVariables.FCM=1;
			Login();
		}
		private function Login():void
		{
			_NameInput.text = _NameInput.text.replace( /^\s+|\s+$/g, "" );
			if ( _NameInput.text )
			{
				_LoginBtn.enabled = false;
				_FcmBtn.enabled = false;
				
				//this.dispatchEvent( new ResLoaderEvent("login", CreateParam() ) );
			}
		}

	}
}