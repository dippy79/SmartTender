import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/tender.dart';
import '../../../services/tender_repository.dart';
import '../../../presentation/widgets/app_sidebar.dart';
import '../../../presentation/widgets/ai_guide_widget.dart';

class TenderListScreen extends StatefulWidget {
  const TenderListScreen({super.key});

  @override
  State<TenderListScreen> createState() => _TenderListScreenState();
}

class _TenderListScreenState extends State<TenderListScreen> {
  String _currentTab = 'Government';
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';
  List<Tender> _tenders = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 0;
  Timer? _debounce;

  final List<String> _categories = ['All', 'Civil', 'Electrical', 'Mechanical', 'IT & Software', 'Supply Chain'];
  final List<String> _statuses = ['All', 'Open', 'Urgent', 'New', 'Closing', 'Closed'];

  @override
  void initState() {
    super.initState();
    _loadTenders();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadTenders({bool loadMore = false}) async {
    if (loadMore) {
      _isLoadingMore = true;
    } else {
      _isLoading = true;
    }

    try {
      final newTenders = await TenderRepository.fetchTenders(
        type: _currentTab.toLowerCase(),
        searchQuery: _searchQuery,
        category: _selectedCategory,
        status: _selectedStatus,
        page: loadMore ? _page + 1 : 0,
        pageSize: 20,
      );

      setState(() {
        if (loadMore) {
          _tenders.addAll(newTenders);
          _page++;
        } else {
          _tenders = newTenders;
          _page = 0;
        }
        _hasMore = newTenders.length == 20;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _searchQuery = query;
      _loadTenders();
    });
  }

  void _onTabChanged(String tab) {
    setState(() {
      _currentTab = tab;
      _loadTenders();
    });
  }

  void _onFilterChanged({String? category, String? status}) {
    if (category != null) _selectedCategory = category;
    if (status != null) _selectedStatus = status;
    _loadTenders();
  }

  Widget _buildTopSection() {
    return SliverToBoxAdapter(
      child: Container(
        color: AppTheme.surfaceDark,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Tenders',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Live · Updated every 15 min',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['Government', 'Private', 'Bookmarked']
                  .map((tab) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(tab),
                      selected: _currentTab == tab,
                      onSelected: (_) => _onTabChanged(tab),
                      selectedColor: AppTheme.goldSubtle,
                      checkmarkColor: AppTheme.goldPrimary,
                      side: _currentTab == tab
                        ? BorderSide(color: AppTheme.goldPrimary)
                        : BorderSide(color: AppTheme.borderSubtle),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      labelStyle: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ))
                  .toList(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search tenders...',
                prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textMuted),
                suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: AppTheme.textMuted),
                      onPressed: () => _onSearchChanged(''),
                    )
                  : null,
                filled: true,
                fillColor: AppTheme.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppTheme.borderSubtle),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ..._buildFilterRow('Category', _categories, _selectedCategory, (val) => _onFilterChanged(category: val)),
                  const SizedBox(width: 16),
                  ..._buildFilterRow('Status', _statuses, _selectedStatus, (val) => _onFilterChanged(status: val)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFilterRow(String label, List<String> options, String selected, ValueChanged<String> onSelected) {
    return [
      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      ...options.map((option) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(option),
          selected: selected == option,
          onSelected: (_) => onSelected(option),
          selectedColor: AppTheme.goldSubtle,
          labelStyle: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: selected == option ? FontWeight.w600 : FontWeight.w400,
          ),
          backgroundColor: selected == option ? AppTheme.goldSubtle : null,
          side: BorderSide(
            color: selected == option ? AppTheme.goldPrimary : AppTheme.borderSubtle,
          ),
        ),
      )),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(currentRoute: '/tenders'),
          Expanded(
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    _buildTopSection(),
                    _isLoading
                      ? SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator(color: AppTheme.goldPrimary)),
                        )
                      : _tenders.isEmpty
                        ? SliverFillRemaining(
                            child: _buildEmptyState(),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildTenderCard(_tenders[index]),
                              childCount: _tenders.length,
                            ),
                          ),
                    if (_hasMore && !_isLoadingMore)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => _loadTenders(loadMore: true),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.goldPrimary,
                                side: BorderSide(color: AppTheme.goldPrimary, width: 2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text(
                                'Load More Tenders',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (_isLoadingMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                  ],
                ),
                Positioned.fill(
                  child: AiGuideWidget(screenContext: '/tenders'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: AppTheme.textDim),
          const SizedBox(height: 16),
          Text(
            'No tenders found',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            'Try changing filters or search terms',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTenderCard(Tender tender) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      color: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.borderSubtle),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: tender.dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tender.title,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    tender.formattedValue,
                    style: GoogleFonts.dmMono(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.goldPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      '${tender.department} · ${tender.location}',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                  _StatusTag(status: tender.effectiveStatus),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const SizedBox(width: 20),
                  Icon(
                    Icons.schedule_rounded,
                    size: 12,
                    color: tender.isUrgent ? AppTheme.accentRed : AppTheme.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    tender.isExpired
                      ? 'Expired ${tender.deadlineFormatted}'
                      : '${tender.daysLeft}d left · ${tender.deadlineFormatted}',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: tender.isUrgent ? AppTheme.accentRed : AppTheme.textMuted,
                      fontWeight: tender.isUrgent ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  const Spacer(),
                  _QuickActions(tender: tender),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  final String status;

  const _StatusTag({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData? icon;

    switch (status) {
      case 'Open':
        bgColor = AppTheme.accentGreen.withAlpha(38);
        textColor = AppTheme.accentGreen;
        break;
      case 'Urgent':
        bgColor = AppTheme.accentRed.withAlpha(38);
        textColor = AppTheme.accentRed;
        break;
      case 'New':
        bgColor = AppTheme.accentBlue.withAlpha(38);
        textColor = AppTheme.accentBlue;
        break;
      case 'Closing':
        bgColor = AppTheme.goldSubtle;
        textColor = AppTheme.goldPrimary;
        break;
      case 'Closed':
        bgColor = AppTheme.borderSubtle.withAlpha(51);
        textColor = AppTheme.textMuted;
        break;
      case 'Won':
        bgColor = AppTheme.accentGreen.withAlpha(51);
        textColor = AppTheme.accentGreen;
        icon = Icons.check;
        break;
      default:
        bgColor = Colors.transparent;
        textColor = AppTheme.textMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 2),
          Text(
            status,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatefulWidget {
  final Tender tender;

  const _QuickActions({required this.tender});

  @override
  State<_QuickActions> createState() => _QuickActionsState();
}

class _QuickActionsState extends State<_QuickActions> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _hovered ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 180),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => TenderRepository.toggleBookmark(widget.tender.id, widget.tender.isBookmarked),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated.withAlpha(128),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bookmark_border_rounded,
                  size: 16,
                  color: widget.tender.isBookmarked ? AppTheme.goldPrimary : AppTheme.textMuted,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/boq', arguments: widget.tender),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated.withAlpha(128),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.calculate_rounded, size: 16, color: AppTheme.accentBlue),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated.withAlpha(128),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.share_rounded, size: 16, color: AppTheme.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

