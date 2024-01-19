package com.example.attendance_system;

import io.flutter.app.FlutterApplication;
import io.flutter.view.FlutterMain;

public class FlutterMultiDexApplication extends FlutterApplication {
    @Override
    public void onCreate() {
        super.onCreate();
        FlutterMain.startInitialization(this);
    }
}
