import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommodityTicker extends StatefulWidget {
  const CommodityTicker({super.key});

  @override
  State<CommodityTicker> createState() => _CommodityTickerState();
}

class _CommodityTickerState extends State<CommodityTicker> {
  // Mock data for commodities - Replace with your actual repository data if needed
  final List<Map<String, dynamic>> _commodities = [
    {'name': 'Steel (TMT)', 'price': '₹54,500', 'change': '+1.2%', 'isUp': true},
    {'name': 'Cement (OPC)', 'price': '₹380', 'change': '-0.5%', 'isUp': false},
    {'name': 'Bitumen', 'price': '₹42,000', 'change': '+0.8%', 'isUp': true},
    {'name': 'Copper', 'price': '₹720', 'change': '+2.1%', 'isUp': true},
    {'name': 'Aluminum', 'price': '₹210', 'change': '-1.1%', 'isUp': false},
  ];

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Simple auto-scroll animation logic can be added here if required
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
      ),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _commodities.length,
        itemBuilder: (context, index) {
          final item = _commodities[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${item['name']}: ',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  item['price'],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  item['change'],
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: item['isUp'] ? Colors.green[700] : Colors.red[700],
                  ),
                ),
                const SizedBox(width: 8),
                if (index != _commodities.length - 1)
                  VerticalDivider(
                    color: Colors.grey.withValues(alpha: 0.3),
                    indent: 5,
                    endIndent: 5,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}