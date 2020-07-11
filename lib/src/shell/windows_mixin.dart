import '../../dshell.dart';
import '../installers/windows_installer.dart';
import '../script/commands/install.dart';

mixin WindowsMixin {
  String checkInstallPreconditions() {
    if (!inDeveloperMode()) {
      return '''You must be running in Windows Developer Mode to install DShell.
Read additional details here: https://github.com/bsutton/dshell/wiki/Installing-DShell#windows''';
    }
    return null;
  }

  /// Windows 10+ has a developer mode that needs to be enabled to create symlinks without escalated prividedges.
  bool inDeveloperMode() {
    /// Example result:
    /// <blank line>
    /// HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock
    /// AllowDevelopmentWithoutDevLicense    REG_DWORD    0x1

    var response =
        'reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /v "AllowDevelopmentWithoutDevLicense"'
            .toList(skipLines: 2)
            .first;
    var parts = response.split(r'\s+');
    if (parts.length != 3) {
      throw InstallException('Unable to obtain development mode settings');
    }

    return parts[3] == '0x1';
  }

  bool get isPrivilegedUser {
    var currentPrincipal =
        'New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())'
            .firstLine;
    Settings().verbose('currentPrinciple: $currentPrincipal');
    var isPrivileged =
        '$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)'
            .firstLine;
    Settings().verbose('isPrivileged: $isPrivileged');

    return isPrivileged.toLowerCase() == 'true';
  }

  bool install() {
    return WindowsDShellInstaller().install();
  }

  String privilegesRequiredMessage(String app) {
    return 'You need to be a privileged user to run $app';
  }

  String get loggedInUser => env('USERNAME');
}