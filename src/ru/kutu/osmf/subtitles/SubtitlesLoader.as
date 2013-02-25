package ru.kutu.osmf.subtitles {
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.utils.OSMFSettings;
	
	public class SubtitlesLoader extends LoaderBase {
		
		public function SubtitlesLoader() {
		}
		
		override public function canHandleResource(media:MediaResourceBase):Boolean {
			return true;
		}
		
		override protected function executeLoad(loadTrait:LoadTrait):void {
			updateLoadTrait(loadTrait, LoadState.LOADING);
			
			var resource:URLResource = loadTrait.resource as URLResource;
			var req:URLRequest = new URLRequest(resource.url);
			var loader:URLLoader = new URLLoader(req);
			
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			
			function removeListeners():void {
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			}
			
			var attempts:uint = OSMFSettings.hdsMaximumRetries;
			function onError(event:ErrorEvent):void {
				attempts--;
				if (attempts == 0) {
					removeListeners();
					updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
					loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, new MediaError(0, event.text)));
				} else {
					loader.load(req);
				}
			}
			
			function onComplete(event:Event):void {
				removeListeners();
				try {
					var data:String = String((event.target as URLLoader).data);
					SubtitlesLoadTrait(loadTrait).subtitlesVO = SubRipParser.parse(data);
					updateLoadTrait(loadTrait, LoadState.READY);
				} catch (parseError:Error) {
					updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
					loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, new MediaError(parseError.errorID, parseError.message)));
				}
			}
		}
		
		override protected function executeUnload(loadTrait:LoadTrait):void {
			updateLoadTrait(loadTrait, LoadState.UNLOADING);			
			updateLoadTrait(loadTrait, LoadState.UNINITIALIZED);
		}
		
	}
	
}
