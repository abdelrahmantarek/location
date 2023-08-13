#include "include/location_plugin/location_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "location_plugin.h"

void LocationPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  location_plugin::LocationPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
