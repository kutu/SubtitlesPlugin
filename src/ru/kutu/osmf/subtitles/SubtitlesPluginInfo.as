package ru.kutu.osmf.subtitles {
	
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaFactoryItemType;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfo;
	import org.osmf.net.NetLoader;
	
	public class SubtitlesPluginInfo extends PluginInfo {
		
		public static const NAMESPACE:String = "http://kutu.ru/osmf/plugins/subtitles";
		
		public function SubtitlesPluginInfo() {
			var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
			
			var loader:NetLoader = new NetLoader();
			items.push(new MediaFactoryItem("ru.kutu.osmf.subtitles.SubtitlesPlugin"
				, function(resource:MediaResourceBase):Boolean {
					return resource.metadataNamespaceURLs.indexOf(NAMESPACE) != -1;
				}
				, function():MediaElement {
					return new SubtitlesProxyElement();
				}
				, MediaFactoryItemType.PROXY)
			);
			
			super(items);
		}
		
	}
	
}
