package myheros.loader
{
	import flash.system.System;
	import flash.utils.Dictionary;

	public class LoaderMgr
	{
		public static var LM_PRI_CLASS:int = 0;
		public static var LM_PRI_UISWF:int = 1;
		public static var LM_PRI_RESSWF:int = 2;
		public static var LM_PRI_MAX:int = 3;

		public static const inst:LoaderMgr = new LoaderMgr();
		
		private var fileMap:Dictionary = new Dictionary();
		private var priorityVec:Vector.<Vector.<LoaderNode>> = new Vector.<Vector.<LoaderNode>>(LM_PRI_MAX, true);
		public function LoaderMgr(){
			for(var i:int; i < priorityVec.length; i++){
				priorityVec[i] = new Vector.<LoaderNode>;
			}
		}
		
		public function AddRequest(urlfile:String, md5:String, type:int, priority:int, 
								   complete_cb:Function = null, progress_cb:Function = null, error_cb:Function = null):void{
			var ln:LoaderNode = fileMap[urlfile];
			if( null == ln ){
				ln = new LoaderNode(urlfile, md5, type, priority);
				fileMap[urlfile] = ln;
				
				priorityVec[priority].push(ln);
			}

			ln.PushCallBack(complete_cb, progress_cb, error_cb);
		}
		
		public function TryNextLoading():void{
			var ln:LoaderNode = PopLoaderWithPriority();
			if( ln != null ){
				ln.TryStart(TryNextLoading);
			}
		}
		
		public function ClearTest():void{
			for each(var ln:LoaderNode in fileMap){
				if( ln.loadStep == LoaderNode.LNLOAD_LOADED ){
					ln.dispose();
					delete fileMap[ln.fileUrl];
				}
			}
						
			System.gc();
		}
		
		private function PopLoaderWithPriority():LoaderNode{
			for each(var v:Vector.<LoaderNode> in priorityVec){
				if( v.length > 0 )
					return v.pop();
			}
			
			return null;
		}
	}
}