import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kevins_tech/platforms/ios/apps/ios_app_store.dart';
import 'package:kevins_tech/platforms/ios/apps/ios_safari.dart';
import 'package:kevins_tech/platforms/ios/apps/ios_settings.dart';
import 'package:kevins_tech/platforms/ios/apps/ios_terminal.dart';
import 'package:url_launcher/url_launcher.dart';

class IosAppLibrary extends StatefulWidget {
  final ValueChanged<TargetPlatform> onPlatformSwitch;

  const IosAppLibrary({super.key, required this.onPlatformSwitch});

  @override
  State<IosAppLibrary> createState() => _IosAppLibraryState();
}

class _IosAppLibraryState extends State<IosAppLibrary> {
  final TextEditingController _searchController = TextEditingController();
  List<_LibraryApp> _allApps = [];
  List<_LibraryApp> _filteredApps = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _allApps = [
      _LibraryApp(
        "App Store",
        CupertinoIcons.app_badge_fill,
        Colors.blueAccent,
        () => _openApp(const IosAppStore()),
      ),
      _LibraryApp("Calendar", CupertinoIcons.calendar, Colors.redAccent, () {}),
      _LibraryApp("Camera", CupertinoIcons.camera_fill, Colors.grey, () {}),
      _LibraryApp("Clock", CupertinoIcons.clock, Colors.black, () {}),
      _LibraryApp("Files", CupertinoIcons.folder_fill, Colors.blue, () {}),
      _LibraryApp(
        "GitHub",
        CupertinoIcons.briefcase,
        Colors.black,
        () => launchUrl(Uri.parse("https://github.com/TechoChat")),
      ),
      _LibraryApp(
        "LinkedIn",
        CupertinoIcons.person_2_fill,
        Colors.blueAccent,
        () => launchUrl(Uri.parse("https://linkedin.com/in/techochat")),
      ),
      _LibraryApp(
        "Mail",
        CupertinoIcons.mail_solid,
        Colors.blue,
        () => launchUrl(Uri.parse("mailto:contact@techo.chat")),
      ),
      _LibraryApp(
        "Maps",
        CupertinoIcons.location_fill,
        Colors.greenAccent,
        () => launchUrl(Uri.parse("https://maps.google.com")),
      ),
      _LibraryApp(
        "Messages",
        CupertinoIcons.chat_bubble_fill,
        Colors.green,
        () => launchUrl(Uri.parse("sms:")),
      ),
      _LibraryApp("Notes", CupertinoIcons.doc_text_fill, Colors.amber, () {}),
      _LibraryApp(
        "Photos",
        CupertinoIcons.photo_fill_on_rectangle_fill,
        Colors.pinkAccent,
        () {},
      ),
      _LibraryApp(
        "Safari",
        CupertinoIcons.compass,
        Colors.blue,
        () => _openApp(const IosSafari()),
      ),
      _LibraryApp(
        "Settings",
        CupertinoIcons.settings,
        Colors.grey,
        () => _openApp(IosSettings(onPlatformSwitch: widget.onPlatformSwitch)),
      ),
      _LibraryApp(
        "Switch OS",
        Icons.android,
        Colors.purple,
        () => widget.onPlatformSwitch(TargetPlatform.android),
      ),
      _LibraryApp(
        "Terminal",
        CupertinoIcons.command,
        Colors.black,
        () => _openApp(const IosTerminal()),
      ),
      _LibraryApp(
        "Weather",
        CupertinoIcons.cloud_sun_fill,
        Colors.lightBlue,
        () {},
      ),
    ];
    _allApps.sort((a, b) => a.name.compareTo(b.name));
    _filteredApps = List.from(_allApps);
  }

  void _filterApps(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredApps = List.from(_allApps);
      } else {
        _filteredApps = _allApps
            .where(
              (app) => app.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _openApp(Widget app) {
    Navigator.of(context).push(CupertinoPageRoute(builder: (context) => app));
  }

  @override
  Widget build(BuildContext context) {
    // Group apps by first letter
    Map<String, List<_LibraryApp>> groupedApps = {};
    for (var app in _filteredApps) {
      String letter = app.name[0].toUpperCase();
      if (!groupedApps.containsKey(letter)) {
        groupedApps[letter] = [];
      }
      groupedApps[letter]!.add(app);
    }
    final letters = groupedApps.keys.toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Blur Effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(color: Colors.black.withValues(alpha: 0.4)),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.search,
                                color: Colors.white54,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: CupertinoTextField(
                                  controller: _searchController,
                                  onChanged: _filterApps,
                                  placeholder: "App Library",
                                  placeholderStyle: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 17,
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                  ),
                                  decoration: null,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                              if (_searchController.text.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    _filterApps("");
                                  },
                                  child: const Icon(
                                    CupertinoIcons.xmark_circle_fill,
                                    color: Colors.white54,
                                    size: 18,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          _searchController.clear();
                          _filterApps("");
                        },
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white, fontSize: 17),
                        ),
                      ),
                    ],
                  ),
                ),

                // Grouped List
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 30,
                            bottom: 20,
                          ),
                          itemCount: letters.length,
                          itemBuilder: (context, index) {
                            String letter = letters[index];
                            List<_LibraryApp> apps = groupedApps[letter]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                Text(
                                  letter,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ...apps.expand((app) {
                                  final isLast = app == apps.last;
                                  return [
                                    _AppListItem(app: app),
                                    if (!isLast)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 64),
                                        child: Divider(
                                          height: 1,
                                          color: Colors.white24,
                                        ),
                                      ),
                                  ];
                                }),
                              ],
                            );
                          },
                        ),
                      ),

                      // Index Sidebar (Visual Only for now)
                      if (_searchController.text.isEmpty)
                        Container(
                          width: 20,
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: letters
                                .map(
                                  (l) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 1.0,
                                    ),
                                    child: Text(
                                      l,
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryApp {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _LibraryApp(this.name, this.icon, this.color, this.onTap);
}

class _AppListItem extends StatelessWidget {
  final _LibraryApp app;

  const _AppListItem({required this.app});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: app.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: app.color,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(app.icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Text(
              app.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
