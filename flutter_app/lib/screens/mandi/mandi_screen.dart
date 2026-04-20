import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/mandi_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/mandi_price.dart';
import '../../data/msp_2025.dart';
import 'package:intl/intl.dart';

class MandiScreen extends ConsumerStatefulWidget {
  final String? initialCommodity;
  const MandiScreen({super.key, this.initialCommodity});

  @override
  ConsumerState<MandiScreen> createState() => _MandiScreenState();
}

class _MandiScreenState extends ConsumerState<MandiScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _states = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh', 
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka', 
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram', 
    'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu', 
    'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal', 
    'Andaman and Nicobar', 'Chandigarh', 'Dadra and Nagar Haveli', 'Daman and Diu', 
    'Delhi', 'Jammu and Kashmir', 'Ladakh', 'Lakshadweep', 'Puducherry'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCommodity != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(mandiProvider.notifier).fetchPrices(commodity: widget.initialCommodity);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mandiState = ref.watch(mandiProvider);
    final notifier = ref.read(mandiProvider.notifier);
    final theme = Theme.of(context);

    // Filter results based on search query
    final filteredPrices = mandiState.when(
      data: (prices) => prices.where((p) => 
        p.commodity.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.market.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.district.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList(),
      loading: () => <MandiPrice>[],
      error: (_, __) => <MandiPrice>[],
    );

    final showWarning = filteredPrices.any((p) {
      final msp = msp2025[p.commodity];
      return msp != null && p.modalPrice < msp;
    });

    return Scaffold(
      backgroundColor: MridaColors.surface,
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            color: MridaColors.surface,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterPill(
                        label: notifier.currentState ?? 'Select State',
                        icon: Icons.location_on_outlined,
                        onTap: () => _showStatePicker(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFilterPill(
                        label: notifier.currentCommodity ?? 'All Crops',
                        icon: Icons.eco_outlined,
                        onTap: () => _showCommodityPicker(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Search commodity, market...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: MridaColors.outline.withValues(alpha: 0.1)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: MridaColors.outline.withValues(alpha: 0.1)),
                          ),
                        ),
                      ),
                    ),
                    if (notifier.currentState != null || notifier.currentCommodity != null || _searchQuery.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: TextButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                            ref.read(mandiProvider.notifier).clearFilters();
                          },
                          child: Text(
                            'CLEAR',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Warning Banner
          if (showWarning)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.red.shade50,
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Some prices below MSP — you have the right to sell at MSP via government procurement centers',
                      style: theme.textTheme.labelSmall?.copyWith(color: Colors.red.shade900, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

          // Results List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(mandiProvider.notifier).refresh(),
              child: mandiState.when(
                data: (prices) {
                  if (prices.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredPrices.length,
                    itemBuilder: (context, index) {
                      return MandiPriceCard(price: filteredPrices[index]);
                    },
                  );
                },
                loading: () => _buildShimmerLoading(),
                error: (err, _) => _buildErrorState(err.toString()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill({required String label, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: MridaColors.outline.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: MridaColors.primary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 16),
          ],
        ),
      ),
    );
  }

  void _showStatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Select State', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _states.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_states[index]),
                    onTap: () {
                      ref.read(mandiProvider.notifier).fetchPrices(state: _states[index]);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCommodityPicker(BuildContext context) {
    final commodities = msp2025.keys.toList()..sort();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Select Crop', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: commodities.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(commodities[index]),
                    onTap: () {
                      ref.read(mandiProvider.notifier).fetchPrices(commodity: commodities[index]);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: MridaColors.outline.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text('No price data for this selection.', style: TextStyle(fontWeight: FontWeight.bold)),
          const Text('Try a different commodity or state.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
              ref.read(mandiProvider.notifier).clearFilters();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('CLEAR ALL FILTERS'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Could not load prices. Check connection.', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(mandiProvider.notifier).refresh(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          height: 120,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
          ),
        );
      },
    );
  }
}

class MandiPriceCard extends StatelessWidget {
  final MandiPrice price;
  const MandiPriceCard({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final msp = msp2025[price.commodity];
    
    Color modalColor = Colors.black;
    if (msp != null) {
      if (price.modalPrice > msp * 1.05) {
        modalColor = Colors.green.shade700;
      } else if (price.modalPrice >= msp) {
        modalColor = Colors.orange.shade700;
      } else {
        modalColor = Colors.red.shade700;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: MridaColors.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      price.market.toUpperCase(),
                      style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                    ),
                    Text(
                      '${price.district} · ${price.state}',
                      style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Icon(Icons.more_horiz, color: Colors.grey.shade300),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${price.commodity} (${price.variety})',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildPriceCol('MIN', price.minPrice),
              _buildPriceCol('MODAL', price.modalPrice, color: modalColor),
              _buildPriceCol('MAX', price.maxPrice),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              'Last reported: ${DateFormat('dd MMM yyyy').format(price.reportedDate)}',
              style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey.shade400, fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCol(String label, double val, {Color? color}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.0)),
          const SizedBox(height: 2),
          Text(
            '₹${val.toInt()}',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w900, 
              fontSize: 15,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
