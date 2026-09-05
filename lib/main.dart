import 'package:flutter/material.dart';

void main() => runApp(const NotifyTradeApp());

class NotifyTradeApp extends StatefulWidget {
  const NotifyTradeApp({super.key});

  @override
  State<NotifyTradeApp> createState() => _NotifyTradeAppState();
}

class _NotifyTradeAppState extends State<NotifyTradeApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NotifyTrade',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      home: HomePage(
        isDark: _themeMode == ThemeMode.dark,
        onThemeChanged: (dark) => setState(() {
          _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
        }),
      ),
    );
  }

  ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1),
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          dark ? const Color(0xFF0B1020) : const Color(0xFFF5F7FB),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: dark ? const Color(0xFF151B2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor:
            dark ? const Color(0xFF0B1020) : const Color(0xFFF5F7FB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: dark ? const Color(0xFF11172A) : Colors.white,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        ),
      ),
    );
  }
}

class Signal {
  final String time, action, instrument, option, price, confidence, reason;
  const Signal({
    required this.time,
    required this.action,
    required this.instrument,
    required this.option,
    required this.price,
    required this.confidence,
    required this.reason,
  });
}

const allSignals = <Signal>[
  Signal(time: '09:42', action: 'BUY', instrument: 'NIFTY', option: '25,000 CE', price: '₹126.40', confidence: 'High', reason: 'Positive momentum with simulated support holding.'),
  Signal(time: '09:18', action: 'BUY', instrument: 'BANK NIFTY', option: '51,500 PE', price: '₹184.20', confidence: 'Medium', reason: 'Potential reversal setup in the demo engine.'),
  Signal(time: '09:05', action: 'WAIT', instrument: 'SENSEX', option: '81,500 CE', price: '₹142.70', confidence: 'Low', reason: 'Waiting for confirmation before an entry.'),
  Signal(time: '08:56', action: 'BUY', instrument: 'NIFTY', option: '24,900 CE', price: '₹98.60', confidence: 'Medium', reason: 'Price is above the simulated intraday trend line.'),
  Signal(time: '08:41', action: 'WAIT', instrument: 'FINNIFTY', option: '23,800 CE', price: '₹112.10', confidence: 'Low', reason: 'Setup needs confirmation before an entry.'),
  Signal(time: '08:32', action: 'BUY', instrument: 'MIDCAP NIFTY', option: '12,900 CE', price: '₹76.30', confidence: 'Medium', reason: 'Simulated breakout with improving momentum.'),
];

class HomePage extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;
  const HomePage({super.key, required this.isDark, required this.onThemeChanged});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  String market = 'NIFTY';
  bool notifications = true;

  final marketData = const <String, MarketData>{
    'NIFTY': MarketData('25,040.80', '+0.62%', '12,940.20'),
    'BANK NIFTY': MarketData('52,410.30', '+0.81%', '11,610.80'),
    'SENSEX': MarketData('81,920.10', '+0.48%', '9,860.40'),
    'FINNIFTY': MarketData('23,814.10', '+0.41%', '7,320.40'),
    'MIDCAP NIFTY': MarketData('12,905.60', '+0.36%', '5,820.70'),
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        final content = IndexedStack(index: tab, children: [
          _dashboard(wide: wide),
          _signals(),
          _settings(),
        ]);

        if (wide) {
          return Scaffold(
            body: SafeArea(
              child: Row(
                children: [
                  NavigationRail(
                    selectedIndex: tab,
                    onDestinationSelected: (i) => setState(() => tab = i),
                    labelType: NavigationRailLabelType.all,
                    leading: Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 18),
                      child: _brandMark(size: 46),
                    ),
                    destinations: const [
                      NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: Text('Home')),
                      NavigationRailDestination(icon: Icon(Icons.notifications_none_rounded), selectedIcon: Icon(Icons.notifications_active_rounded), label: Text('Signals')),
                      NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: Text('Settings')),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: content),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: SafeArea(child: content),
          bottomNavigationBar: NavigationBar(
            selectedIndex: tab,
            onDestinationSelected: (i) => setState(() => tab = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.notifications_none_rounded), selectedIcon: Icon(Icons.notifications_active_rounded), label: 'Signals'),
              NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: 'Settings'),
            ],
          ),
        );
      },
    );
  }

  Widget _dashboard({bool wide = false}) {
    final data = marketData[market]!;
    return RefreshIndicator(
      onRefresh: () async => Future<void>.delayed(const Duration(milliseconds: 350)),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(wide ? 28 : 16, 12, wide ? 28 : 16, 28),
        children: [
          Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 980), child: _dashboardContent(data, wide))),
        ],
      ),
    );
  }

  Widget _dashboardContent(MarketData data, bool wide) {
    final markets = marketData.keys.toList();
    final alerts = allSignals.take(3).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _header(),
      const SizedBox(height: 16),
      _liveBanner(),
      const SizedBox(height: 16),
      _marketTabs(),
      const SizedBox(height: 16),
      if (wide)
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _marketCard(data)),
          const SizedBox(width: 16),
          Expanded(child: _quickMarketsGrid(markets)),
        ])
      else ...[
        _marketCard(data),
        const SizedBox(height: 22),
        _sectionTitle('Market sections', 'Quick view'),
        const SizedBox(height: 10),
        ...markets.map(_marketSectionCard),
      ],
      const SizedBox(height: 22),
      _sectionTitle('Latest alerts', 'View all', () => setState(() => tab = 1)),
      const SizedBox(height: 10),
      ...alerts.map(_signalCard),
      const SizedBox(height: 8),
      _safetyCard(),
    ]);
  }

  Widget _quickMarketsGrid(List<String> markets) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    _sectionTitle('Market sections', 'Quick view'),
    const SizedBox(height: 10),
    GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: markets.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 94,
      ),
      itemBuilder: (_, i) => _marketSectionCard(markets[i], compact: true),
    ),
  ]);

  Widget _brandMark({double size = 48}) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
      borderRadius: BorderRadius.circular(size * .32),
    ),
    child: Icon(Icons.notifications_active_rounded, color: Colors.white, size: size * .52),
  );

  Widget _header() => Row(children: [
        _brandMark(),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('NotifyTrade', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, letterSpacing: -0.6)),
          Text('Smart market alerts, made simple', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ])),
        _iconButton(Icons.notifications_none_rounded, () => _snack(notifications ? 'Signal notifications are on' : 'Signal notifications are off')),
        const SizedBox(width: 7),
        _iconButton(Icons.tune_rounded, () => setState(() => tab = 2)),
      ]);

  Widget _iconButton(IconData icon, VoidCallback tap) => Material(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(onTap: tap, borderRadius: BorderRadius.circular(15), child: SizedBox(width: 44, height: 44, child: Icon(icon, size: 21))),
      );

  Widget _liveBanner() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xFF16A34A).withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          Container(width: 9, height: 9, decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle)),
          const SizedBox(width: 9),
          const Text('MARKET LIVE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: .8)),
          const Spacer(),
          Text('Demo market data', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      );

  Widget _marketTabs() => SizedBox(
        height: 42,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: marketData.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final name = marketData.keys.elementAt(i);
            final selected = market == name;
            return ChoiceChip(
              label: Text(name), selected: selected,
              onSelected: (_) => setState(() => market = name),
              showCheckmark: false,
              labelStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: selected ? Theme.of(context).colorScheme.onPrimaryContainer : null),
            );
          },
        ),
      );

  Widget _marketCard(MarketData data) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(market, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
              const Spacer(),
              Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: const Color(0xFF16A34A).withValues(alpha: .10), borderRadius: BorderRadius.circular(10)), child: Text(data.change, style: const TextStyle(color: Color(0xFF16A34A), fontSize: 12, fontWeight: FontWeight.w900))),
            ]),
            const SizedBox(height: 7),
            Text(data.value, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -1)),
            const SizedBox(height: 12),
            SizedBox(height: 72, child: CustomPaint(painter: _SparklinePainter(context), child: const SizedBox.expand())),
            const SizedBox(height: 9),
            Row(children: [
              _stat('Day volume', data.volume), const Spacer(), _stat('Status', 'Active'),
            ]),
          ]),
        ),
      );

  Widget _stat(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
      ]);

  Widget _sectionTitle(String title, String action, [VoidCallback? onTap]) => Row(children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -.3))),
        TextButton(onPressed: onTap, child: Text(action, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
      ]);

  Widget _marketSectionCard(String name, {bool compact = false}) {
    final d = marketData[name]!;
    final count = allSignals.where((s) => s.instrument == name).length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () { setState(() => market = name); _snack('$name selected'); },
          child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(14)), child: Icon(_marketIcon(name), size: 21)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text('$count active demo alert${count == 1 ? '' : 's'}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w600)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(d.value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text(d.change, style: const TextStyle(color: Color(0xFF16A34A), fontSize: 11, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded),
          ])),
        ),
      ),
    );
  }

  IconData _marketIcon(String name) {
    if (name == 'BANK NIFTY') return Icons.account_balance_rounded;
    if (name == 'SENSEX') return Icons.public_rounded;
    if (name == 'FINNIFTY') return Icons.pie_chart_rounded;
    if (name == 'MIDCAP NIFTY') return Icons.bar_chart_rounded;
    return Icons.show_chart_rounded;
  }

  Widget _signalCard(Signal s) {
    final buy = s.action == 'BUY';
    final accent = buy ? const Color(0xFF16A34A) : const Color(0xFFF59E0B);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: InkWell(borderRadius: BorderRadius.circular(22), onTap: () => _showSignal(s), child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
          Container(width: 46, height: 46, decoration: BoxDecoration(color: accent.withValues(alpha: .11), borderRadius: BorderRadius.circular(15)), child: Icon(buy ? Icons.arrow_upward_rounded : Icons.pause_rounded, color: accent)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Text(s.action, style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: .7)), const SizedBox(width: 7), Flexible(child: Text(s.instrument, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)))]),
            const SizedBox(height: 4),
            Text('${s.option} • ${s.time}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w600)),
          ])),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(s.price, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)), const SizedBox(height: 3), const Icon(Icons.chevron_right_rounded, size: 19)]),
        ]))),
      ),
    );
  }

  Widget _signals() => ListView(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
    children: [
      Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 980), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _pageTitle('Market Alerts', 'Signals grouped by index.'),
        const SizedBox(height: 18),
        ...marketData.keys.map((name) => _signalSection(name)),
        _safetyCard(),
      ]))),
    ],
  );

  Widget _signalSection(String name) {
    final items = allSignals.where((s) => s.instrument == name).toList();
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(_marketIcon(name), size: 18), const SizedBox(width: 7),
          Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const Spacer(),
          Text('${items.length} alert${items.length == 1 ? '' : 's'}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 8),
        if (items.isEmpty) Card(child: Padding(padding: const EdgeInsets.all(14), child: Text('No active alerts', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)))) else ...items.map(_signalCard),
      ],),
    );
  }

  Widget _settings() => ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 28), children: [
    Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 720), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    _pageTitle('Settings', 'Personalise your NotifyTrade experience.'),
    const SizedBox(height: 18),
    Card(child: Column(children: [
      SwitchListTile(value: notifications, onChanged: (v) => setState(() => notifications = v), secondary: _settingIcon(Icons.notifications_active_outlined), title: const Text('Signal notifications', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('Receive demo market alerts')),
      const Divider(height: 1, indent: 70),
      SwitchListTile(value: widget.isDark, onChanged: widget.onThemeChanged, secondary: _settingIcon(Icons.dark_mode_outlined), title: const Text('Dark mode', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('Comfortable viewing in low light')),
      const Divider(height: 1, indent: 70),
      ListTile(leading: _settingIcon(Icons.info_outline_rounded), title: const Text('About NotifyTrade', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('Version 1.0 • Android + iOS'), trailing: const Icon(Icons.chevron_right_rounded), onTap: () => _snack('NotifyTrade • Version 1.0')),
    ])),
    const SizedBox(height: 16),
    _safetyCard(),
    ])),
  ]);

  Widget _settingIcon(IconData icon) => Container(width: 42, height: 42, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(13)), child: Icon(icon, size: 20));

  Widget _pageTitle(String title, String subtitle) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -.8)),
    const SizedBox(height: 5),
    Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w600)),
  ]);

  Widget _safetyCard() => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: widget.isDark ? .30 : .55), borderRadius: BorderRadius.circular(18)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.shield_outlined, size: 21, color: Theme.of(context).colorScheme.onSecondaryContainer), const SizedBox(width: 10),
      Expanded(child: Text('Demo data only. Alerts are simulated and do not execute trades.', style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer, fontSize: 12, fontWeight: FontWeight.w600, height: 1.35))),
    ]),
  );

  void _showSignal(Signal s) {
    final buy = s.action == 'BUY';
    final accent = buy ? const Color(0xFF16A34A) : const Color(0xFFF59E0B);
    showModalBottomSheet<void>(
      context: context, showDragHandle: true,
      builder: (context) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: accent.withValues(alpha: .11), borderRadius: BorderRadius.circular(15)), child: Icon(buy ? Icons.arrow_upward_rounded : Icons.pause_rounded, color: accent)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${s.action} ${s.instrument}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)), Text('${s.option} • ${s.time}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600))]))]),
        const SizedBox(height: 18),
        _detail('Indicative price', s.price), _detail('Confidence', s.confidence), _detail('Why this alert?', s.reason),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: () { Navigator.pop(context); _snack('Alert saved to your watchlist'); }, child: const Text('Save alert'))),
      ]))),
    );
  }

  Widget _detail(String label, String value) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 118, child: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w700))), Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)))]));

  void _snack(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
}

class MarketData {
  final String value, change, volume;
  const MarketData(this.value, this.change, this.volume);
}

class _SparklinePainter extends CustomPainter {
  final BuildContext context;
  _SparklinePainter(this.context);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Theme.of(context).colorScheme.primary..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final fill = Paint()..color = Theme.of(context).colorScheme.primary.withValues(alpha: .08)..style = PaintingStyle.fill;
    final points = [
      Offset(0, size.height * .72), Offset(size.width*.12, size.height*.58), Offset(size.width*.24, size.height*.64), Offset(size.width*.36, size.height*.40), Offset(size.width*.48, size.height*.47), Offset(size.width*.60, size.height*.25), Offset(size.width*.72, size.height*.36), Offset(size.width*.84, size.height*.18), Offset(size.width, size.height*.27),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i=1; i<points.length; i++) path.lineTo(points[i].dx, points[i].dy);
    final area = Path.from(path)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(area, fill);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => true;
}
