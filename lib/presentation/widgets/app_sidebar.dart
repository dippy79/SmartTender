import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../presentation/providers/auth_provider.dart';

class AppSidebar extends StatelessWidget {
  final String currentRoute;
  final void Function(String)? onNavTap;

  const AppSidebar({
    super.key,
    this.currentRoute = '/dashboard',
    this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isSuperAdmin = auth.isSuperAdmin;

    final navItems = [
      NavItem(Icons.dashboard_rounded, 'Dashboard', '/dashboard'),
      NavItem(Icons.assignment_rounded, 'Tenders', '/tenders'),
      NavItem(Icons.calculate_rounded, 'BOQ Calc', '/boq'),
      NavItem(Icons.inventory_2_rounded, 'Commodities', '/commodities'),
      NavItem(Icons.history_rounded, 'History', '/history'),
      NavItem(Icons.auto_awesome_rounded, 'AI Advisor', '/ai'),
      if (isSuperAdmin) NavItem(Icons.admin_panel_settings_rounded, 'Admin', '/admin'),
    ];

    return Container(
      width: AppTheme.sidebarWidth,
      decoration: BoxDecoration(
        color: AppTheme.sidebarBg,
        border: Border(
          right: BorderSide(color: AppTheme.sidebarBorder, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo Section
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.sidebarBorder)),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.goldPrimary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      'ST',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1000),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'SmartTender',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Nav Items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final item = navItems[index];
                final isActive = currentRoute == item.route;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.goldSubtle : Colors.transparent,
                    border: Border(
                      left: BorderSide(
                        color: isActive ? AppTheme.goldPrimary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    leading: Icon(
                      item.icon,
                      size: 16,
                      color: isActive ? AppTheme.goldPrimary : AppTheme.textMuted,
                    ),
                    title: Text(
                      item.label,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isActive ? AppTheme.goldPrimary : AppTheme.textMuted,
                      ),
                    ),
                    onTap: () {
                      onNavTap?.call(item.route);
                    },
                    dense: true,
                    horizontalTitleGap: 10,
                  ),
                );
              },
            ),
          ),

          // Settings (bottom pinned)
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceSlate.withAlpha(128),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              leading: Icon(
                Icons.settings_rounded,
                size: 16,
                color: AppTheme.textMuted,
              ),
              title: Text(
                'Settings',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textMuted,
                ),
              ),
              dense: true,
              horizontalTitleGap: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;
  final String route;

  const NavItem(this.icon, this.label, this.route);
}
