import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class IosSettings extends StatelessWidget {
  final ValueChanged<TargetPlatform> onPlatformSwitch;

  const IosSettings({super.key, required this.onPlatformSwitch});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Settings"),
        backgroundColor: Color(0xFFF2F2F7),
        border: null,
      ),
      backgroundColor: const Color(0xFFF2F2F7),
      child: ListView(
        children: [
          const SizedBox(height: 20),
          // User Section
          _buildSection(
            children: [
              _buildTile(
                icon: CupertinoIcons.person_crop_circle_fill,
                iconColor: Colors.grey,
                title: "TechoChat",
                subtitle: "Apple ID, iCloud, Media & Purchases",
                onTap: () {},
                showChevron: true,
                isLarge: true,
              ),
            ],
          ),

          const SizedBox(height: 35),

          // Network / Links Section
          _buildHeader("Connectivity"),
          _buildSection(
            children: [
              _buildTile(
                icon: CupertinoIcons.globe,
                iconColor: CupertinoColors.activeBlue,
                title: "LinkedIn",
                value: "Connected",
                onTap: () => launchUrl(
                  Uri.parse("https://www.linkedin.com/in/techochat/"),
                ),
              ),
              _buildTile(
                icon: Icons.code, // Material icon is fine
                iconColor: Colors.black,
                title: "GitHub",
                value: "Online",
                onTap: () =>
                    launchUrl(Uri.parse("https://github.com/TechoChat")),
              ),
            ],
          ),

          const SizedBox(height: 35),

          // Storage / This PC Section
          _buildHeader("Storage"),
          _buildSection(
            children: [
              _buildTile(
                icon: CupertinoIcons.device_laptop,
                iconColor: Colors.grey,
                title: "Local Disk (C:)",
                value: "200GB Free",
              ),
              _buildTile(
                icon: CupertinoIcons.doc_fill,
                iconColor: Colors.orange,
                title: "Skills (D:)",
                value: "Full",
              ),
              _buildTile(
                icon: CupertinoIcons.doc_text_fill,
                iconColor: Colors.red,
                title: "Resume.pdf",
                onTap: () async {
                  const url =
                      'https://drive.google.com/file/d/1_YtPDqTXcC_eBlAPqsHSq3G1n_2_MJPs/view?usp=sharing';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 35),

          // OS Switcher
          _buildSection(
            children: [
              _buildTile(
                icon: Icons.monitor,
                iconColor: Colors.blueAccent,
                title: "Switch to Windows",
                onTap: () {
                  Navigator.of(context).pop(); // Close settings
                  onPlatformSwitch(TargetPlatform.windows);
                },
              ),
              _buildTile(
                icon: Icons.laptop_mac,
                iconColor: Colors.black,
                title: "Switch to macOS",
                onTap: () {
                  Navigator.of(context).pop();
                  onPlatformSwitch(TargetPlatform.macOS);
                },
              ),
              _buildTile(
                icon: Icons.android,
                iconColor: Colors.green,
                title: "Switch to Android",
                onTap: () {
                  Navigator.of(context).pop();
                  onPlatformSwitch(TargetPlatform.android);
                },
              ),
            ],
          ),

          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 13),
      ),
    );
  }

  Widget _buildSection({required List<Widget> children}) {
    return Container(
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFBCBBC1), width: 0.0),
          bottom: BorderSide(color: Color(0xFFBCBBC1), width: 0.0),
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const Padding(
                padding: EdgeInsets.only(left: 60),
                child: Divider(height: 1, color: Color(0xFFBCBBC1)),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    String? value,
    VoidCallback? onTap,
    bool showChevron = true,
    bool isLarge = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: isLarge ? 12 : 10,
            horizontal: 16,
          ),
          child: Row(
            children: [
              Container(
                width: isLarge ? 50 : 30,
                height: isLarge ? 50 : 30,
                decoration: BoxDecoration(
                  color: isLarge ? null : iconColor,
                  borderRadius: BorderRadius.circular(isLarge ? 25 : 6),
                ),
                alignment: Alignment.center,
                child: isLarge
                    ? Icon(icon, size: 50, color: iconColor)
                    : Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: isLarge ? FontWeight.w500 : FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              if (value != null)
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              if (showChevron && onTap != null) ...[
                const SizedBox(width: 8),
                const Icon(
                  CupertinoIcons.chevron_right,
                  size: 20,
                  color: Color(0xFFC7C7CC),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
