
class VulnL10nEntry {
  final String title;
  final String description;
  final String howToFix;

  const VulnL10nEntry({
    required this.title,
    required this.description,
    required this.howToFix,
  });
}

VulnL10nEntry? getVulnLocalized(String id, String locale) {
  final map = locale == 'en' ? _en : null;
  return map?[id];
}

const _en = <String, VulnL10nEntry>{
  'MP-001': VulnL10nEntry(
    title: 'Windows Update not configured',
    description:
        'Automatic Windows updates are disabled or not working. '
        'Your device may be vulnerable to known attacks.',
    howToFix:
        '1. Open Settings → Update & Security\n'
        '2. Click "Check for updates"\n'
        '3. Install all available updates\n'
        '4. Enable automatic updates',
  ),
  'MP-002': VulnL10nEntry(
    title: 'Windows auto-update disabled by policy',
    description:
        'Group Policy prevents automatic installation of security updates.',
    howToFix:
        '1. Open gpedit.msc\n'
        '2. Computer Configuration → Administrative Templates '
        '→ Windows Components → Windows Update\n'
        '3. Enable "Configure Automatic Updates"\n'
        '4. Set value to 4 (Auto download and install)',
  ),
  'MP-003': VulnL10nEntry(
    title: 'UAC (User Account Control) disabled',
    description:
        'UAC protects against unauthorized execution of programs with '
        'elevated privileges. Without UAC, malware can gain admin '
        'rights silently.',
    howToFix:
        '1. Open Control Panel\n'
        '2. User Accounts\n'
        '3. "Change User Account Control settings"\n'
        '4. Move the slider to "Always notify"',
  ),
  'MP-004': VulnL10nEntry(
    title: 'Windows SmartScreen disabled',
    description:
        'SmartScreen warns about running unknown or malicious programs. '
        'Without it, the risk of running a malicious file is higher.',
    howToFix:
        '1. Settings → Update & Security\n'
        '2. Windows Security → App & browser control\n'
        '3. Enable "Check apps and files"',
  ),
  'MP-005': VulnL10nEntry(
    title: 'Screen lock not configured',
    description:
        'Without automatic screen lock, others can access your '
        'computer in your absence.',
    howToFix:
        '1. Settings → Personalization → Lock screen → Screen saver settings\n'
        '2. Choose a screensaver, set wait time to 5-10 minutes\n'
        '3. Check "On resume, display logon screen"\n'
        'Or: Settings → Accounts → Sign-in options '
        '→ set the lock timeout',
  ),
  'MP-006': VulnL10nEntry(
    title: 'Guest account enabled',
    description:
        'An enabled guest account allows access to the system without a password.',
    howToFix:
        '1. Open "Computer Management"\n'
        '2. Local Users and Groups → Users\n'
        '3. Right-click "Guest" → Properties\n'
        '4. Check "Account is disabled"',
  ),
  'MP-007': VulnL10nEntry(
    title: 'Windows Firewall disabled',
    description:
        'The firewall is the first line of defense against network attacks. '
        'Without it, the computer is vulnerable to remote attacks.',
    howToFix:
        '1. Settings → Update & Security\n'
        '2. Windows Security → Firewall\n'
        '3. Enable for all profiles\n'
        'Or run: netsh advfirewall set allprofiles state on',
  ),
  'MP-008': VulnL10nEntry(
    title: 'SMBv1 enabled (WannaCry vulnerability)',
    description:
        'The SMBv1 protocol contains the critical EternalBlue vulnerability '
        'used by the WannaCry virus to spread across networks.',
    howToFix:
        'Open PowerShell as administrator:\n'
        'Set-SmbServerConfiguration -EnableSMB1Protocol \$false\n\n'
        'Or via Windows Features:\n'
        '1. Control Panel → Programs\n'
        '2. Turn Windows features on or off\n'
        '3. Uncheck "SMB 1.0/CIFS File Sharing Support"',
  ),
  'MP-009': VulnL10nEntry(
    title: 'RDP (Remote Desktop) enabled',
    description:
        'Unrestricted RDP is a common target for brute-force attacks. '
        'If RDP is not needed - disable it.',
    howToFix:
        'If RDP is not needed:\n'
        'Settings → System → Remote Desktop → Disable\n\n'
        'If RDP is needed:\n'
        '1. Enable NLA (Network Level Authentication)\n'
        '2. Restrict access in the firewall by IP address\n'
        '3. Change the default port 3389',
  ),
  'MP-010': VulnL10nEntry(
    title: 'Windows Defender disabled',
    description:
        'Antivirus protection is not active. The device is not protected '
        'against viruses, trojans, and other malware.',
    howToFix:
        '1. Settings → Update & Security\n'
        '2. Windows Security → Virus & threat protection\n'
        '3. Enable real-time protection\n'
        'If disabled by policy - contact your administrator',
  ),
  'MP-011': VulnL10nEntry(
    title: 'Antivirus definitions not updated',
    description: 'Outdated definitions cannot detect new threats.',
    howToFix:
        '1. Settings → Update & Security\n'
        '2. Windows Security → Virus & threat protection\n'
        '3. Update protection definitions',
  ),
  'MP-012': VulnL10nEntry(
    title: 'Weak password policy',
    description:
        'Minimum password length is less than 8 characters. '
        'Short passwords are easy to crack by brute force.',
    howToFix:
        '1. Open secpol.msc\n'
        '2. Account Policies → Password Policy\n'
        '3. Set minimum password length to 12 characters\n'
        '4. Enable password complexity requirements',
  ),
  'MP-013': VulnL10nEntry(
    title: 'Password does not expire',
    description:
        'Passwords without expiration are never rotated. If a password '
        'was compromised - you may not know about it.',
    howToFix:
        '1. Open secpol.msc\n'
        '2. Account Policies → Password Policy\n'
        '3. Set maximum password age: 90 days',
  ),
  'MP-020': VulnL10nEntry(
    title: 'Insecure service running',
    description:
        'A potentially insecure network service is running. '
        'If not needed, it should be disabled.',
    howToFix:
        '1. Open services.msc\n'
        '2. Find the service\n'
        '3. Right-click → Properties\n'
        '4. Startup type: Disabled → Stop',
  ),
};

