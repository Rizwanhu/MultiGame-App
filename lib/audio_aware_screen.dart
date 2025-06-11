import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'audio_service.dart';
import '../theme/theme_provider.dart';


abstract class AudioAwareScreen extends StatefulWidget {
  const AudioAwareScreen({Key? key}) : super(key: key);
}

abstract class AudioAwareScreenState<T extends AudioAwareScreen> extends State<T> with WidgetsBindingObserver {
  late AudioService audioService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    
    audioService = AudioService();
    _initializeAudio();
  }
  
  Future<void> _initializeAudio() async {
    
    await audioService.initialize();
  }
  
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    audioService.handleLifecycleChange(state);
    super.didChangeAppLifecycleState(state);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    
    super.dispose();
  }
  
  void showAudioControls(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Audio Settings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Volume"),
                      Expanded(
                        child: Slider(
                          value: audioService.volume * 100,
                          min: 0,
                          max: 100,
                          onChanged: (val) {
                            setModalState(() {
                              audioService.setVolume(val / 100);
                            });
                            setState(() {});
                          },
                        ),
                      ),
                      Text("${(audioService.volume * 100).round()}"),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Music"),
                      Switch(
                        value: audioService.isMusicOn,
                        onChanged: (val) {
                          setModalState(() {
                            audioService.toggleMusic(val);
                          });
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Dark Mode"),
                      Switch(
                        value: themeProvider.themeMode == ThemeMode.dark,
                        onChanged: (val) {
                          themeProvider.toggleTheme(val);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}