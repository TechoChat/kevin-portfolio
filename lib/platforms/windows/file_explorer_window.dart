import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// ✅ NEW: Windows File Explorer (For Projects & PC)
// -----------------------------------------------------------------------------
class FileExplorerWindow extends StatefulWidget {
  final String title;
  final String path;
  final List<Widget> content; // What icons/folders to show

  const FileExplorerWindow({
    super.key,
    required this.title,
    required this.path,
    required this.content,
  });

  @override
  State<FileExplorerWindow> createState() => _FileExplorerWindowState();
}

class _FileExplorerWindowState extends State<FileExplorerWindow> {
  bool _isMaximized = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: _isMaximized ? size.width : 900,
          height: _isMaximized ? size.height : 600,
          decoration: BoxDecoration(
            color: const Color(0xFF202020), // Dark theme explorer
            borderRadius: _isMaximized ? BorderRadius.zero : BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20)],
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: Column(
            children: [
              // --- 1. Title Bar ---
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFF2B2B2B),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.folder_open, color: Colors.yellowAccent, size: 18),
                    const SizedBox(width: 12),
                    Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 13)),
                    const Spacer(),
                     _WindowControl(icon: Icons.minimize, onTap: () => Navigator.pop(context)),
                    _WindowControl(
                      icon: _isMaximized ? Icons.filter_none : Icons.crop_square, 
                      onTap: () => setState(() => _isMaximized = !_isMaximized)
                    ),
                    _WindowControl(icon: Icons.close, color: Colors.redAccent, onTap: () => Navigator.pop(context)),
                  ],
                ),
              ),

              // --- 2. Address Bar / Toolbar ---
              Container(
                height: 45,
                color: const Color(0xFF1F1F1F),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back, color: Colors.white54, size: 18),
                    const SizedBox(width: 16),
                    const Icon(Icons.arrow_upward, color: Colors.white54, size: 18),
                    const SizedBox(width: 16),
                    // Address Input
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131313),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.computer, color: Colors.white54, size: 14),
                            const SizedBox(width: 8),
                            Text(widget.path, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Search Input
                    Container(
                      width: 200,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131313),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.white54, size: 14),
                          const SizedBox(width: 8),
                          Text("Search ${widget.title}", style: const TextStyle(color: Colors.white30, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- 3. Content Area (Sidebar + Grid) ---
              Expanded(
                child: Row(
                  children: [
                    // Sidebar
                    Container(
                      width: 180,
                      color: const Color(0xFF191919),
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        children: [
                          _SidebarItem(icon: Icons.star, label: "Quick access", isSelected: false),
                          _SidebarItem(icon: Icons.computer, label: "This PC", isSelected: widget.title == "This PC"),
                          _SidebarItem(icon: Icons.folder, label: "Projects", isSelected: widget.title == "Projects"),
                          _SidebarItem(icon: Icons.cloud, label: "Network", isSelected: widget.title == "Network"),
                          const Divider(color: Colors.white10),
                        ],
                      ),
                    ),
                    // Main Grid
                    Expanded(
                      child: Container(
                        color: const Color(0xFF101010),
                        padding: const EdgeInsets.all(16),
                        child: GridView.count(
                          crossAxisCount: 5, // 5 items per row
                          childAspectRatio: 0.8,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          children: widget.content,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // --- 4. Status Bar ---
              Container(
                height: 24,
                color: const Color(0xFF1F1F1F),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.centerLeft,
                child: Text(
                  "${widget.content.length} items", 
                  style: const TextStyle(color: Colors.white54, fontSize: 11)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper Widgets for Explorer
class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  const _SidebarItem({required this.icon, required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isSelected ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
      child: Row(
        children: [
          Icon(icon, color: isSelected ? Colors.blueAccent : Colors.white54, size: 16),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class ExplorerItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subLabel;
  final VoidCallback onTap;

  const ExplorerItem({
    required this.icon, 
    required this.iconColor, 
    required this.label, 
    this.subLabel = "",
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: HoverContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: iconColor),
            const SizedBox(height: 8),
            Text(
              label, 
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 12)
            ),
            if (subLabel.isNotEmpty)
              Text(
                subLabel, 
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 10)
              ),
          ],
        ),
      ),
    );
  }
}

// Simple hover effect wrapper
class HoverContainer extends StatefulWidget {
  final Widget child;
  const HoverContainer({super.key, required this.child});
  @override
  State<HoverContainer> createState() => _HoverContainerState();
}
class _HoverContainerState extends State<HoverContainer> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        decoration: BoxDecoration(
          color: _hover ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: _hover ? Colors.white12 : Colors.transparent),
        ),
        padding: const EdgeInsets.all(8),
        child: widget.child,
      ),
    );
  }
}

// Reuse the WindowControl from your previous code
class _WindowControl extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _WindowControl({required this.icon, this.color = Colors.white70, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Icon(icon, color: color, size: 16)),
    );
  }
}