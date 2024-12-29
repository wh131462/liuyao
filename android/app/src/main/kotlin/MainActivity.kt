import io.flutter.embedding.android.FlutterActivity
import com.vocsy.epub_viewer.EpubViewerPlugin

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EpubViewerPlugin.registerWith(flutterEngine)
    }
} 