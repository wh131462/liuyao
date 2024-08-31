import 'dart:io';

void updateAndroidLabel(String newLabel) async {
// Define the path to your AndroidManifest.xml file
final String manifestPath = 'android/app/src/main/AndroidManifest.xml';

// Read the content of the file
File manifestFile = File(manifestPath);
String content = await manifestFile.readAsString();

// Use a regular expression to find and replace the label
content = content.replaceAll(
RegExp(r'android:label="[^"]*"'), 'android:label="$newLabel"');

// Write the modified content back to the file
await manifestFile.writeAsString(content);

print('android:label has been updated to "$newLabel"');
}

void main() {
updateAndroidLabel('六爻通神');
}

