
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
      home: AuthGate(
        isDark: _themeMode == ThemeMode.dark,
        onThemeChanged: (dark) => setState(
          () => _themeMode = dark ? ThemeMode.dark : ThemeMode.light,
        ),
      ),
    );
  }

  ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4F46E5),
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          dark ? const Color(0xFF090D18) : const Color(0xFFF7F8FC),
      fontFamily: 'sans',
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: dark ? const Color(0xFF141A2A) : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: dark
                ? Colors.white.withValues(alpha: .06)
                : const Color(0xFFE9EBF2),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF111727) : const Color(0xFFF4F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor:
            dark ? const Color(0xFF090D18) : const Color(0xFFF7F8FC),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: dark ? const Color(0xFF101625) : Colors.white,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        ),
      ),
    );
  }
}

enum AuthMode { login, register }

class AuthGate extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;

  const AuthGate({
    super.key,
    required this.isDark,
    required this.onThemeChanged,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _DemoUser {
  final String name;
  final String mobile;

  const _DemoUser(this.name, this.mobile);
}

class _AuthGateState extends State<AuthGate> {
  static const String demoOtp = '123456';

  // Demo users for testing. No SMS service is used yet.
  final List<_DemoUser> users = [
    const _DemoUser('Amit Sharma', '9876543210'),
    const _DemoUser('Priya Patil', '9876543211'),
    const _DemoUser('Rahul Verma', '9876543212'),
    const _DemoUser('Sneha Joshi', '9876543213'),
    const _DemoUser('Vikas Kumar', '9876543214'),
    const _DemoUser('Neha Singh', '9876543215'),
    const _DemoUser('Rohit Desai', '9876543216'),
    const _DemoUser('Pooja Shah', '9876543217'),
    const _DemoUser('Karan Mehta', '9876543218'),
    const _DemoUser('Anjali Kulkarni', '9876543219'),
    const _DemoUser('Suresh More', '9876543220'),
    const _DemoUser('Kavita Rao', '9876543221'),
    const _DemoUser('Nitin Gupta', '9876543222'),
    const _DemoUser('Meera Iyer', '9876543223'),
    const _DemoUser('Arjun Nair', '9876543224'),
  ];

  AuthMode mode = AuthMode.login;
  bool otpStep = false;
  bool loading = false;
  String name = '';
  String mobile = '';
  String generatedOtp = demoOtp;

  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final otpController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    otpController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    final phone = mobileController.text.replaceAll(RegExp(r'\D'), '');

    if (phone.length != 10) {
      _message('Enter a valid 10-digit mobile number.');
      return;
    }

    final existing = users.where((u) => u.mobile == phone).firstOrNull;

    if (mode == AuthMode.register) {
      if (nameController.text.trim().isEmpty) {
        _message('Please enter your name.');
        return;
      }
      if (existing != null) {
        _message('This mobile number is already registered. Please login.');
        return;
      }
    } else if (existing == null) {
      _message('Mobile number is not registered. Please register first.');
      return;
    }

    setState(() {
      mobile = phone;
      name = mode == AuthMode.register
          ? nameController.text.trim()
          : existing!.name;
      generatedOtp = demoOtp;
      otpStep = true;
      otpController.clear();
    });

    _message('Demo OTP generated: $demoOtp');
  }

  void _verifyOtp() {
    final enteredOtp = otpController.text.trim();

    if (enteredOtp.length != 6) {
      _message('Enter the 6-digit OTP.');
      return;
    }

    if (enteredOtp != generatedOtp) {
      _message('Invalid OTP. For testing, use $demoOtp.');
      return;
    }

    if (mode == AuthMode.register) {
      final alreadyExists = users.any((u) => u.mobile == mobile);
      if (alreadyExists) {
        _message('This mobile number is already registered.');
        return;
      }
      users.add(_DemoUser(name, mobile));
    }

    setState(() => loading = true);
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() => loading = false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomePage(
            userName: name.isEmpty ? 'Trader' : name,
            isDark: widget.isDark,
            onThemeChanged: widget.onThemeChanged,
          ),
        ),
      );
    });
  }

  void _resendOtp() {
    setState(() {
      generatedOtp = demoOtp;
      otpController.clear();
    });
    _message('Demo OTP: $demoOtp');
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  void _switchMode(AuthMode next) {
    setState(() {
      mode = next;
      otpStep = false;
      loading = false;
      name = '';
      mobile = '';
      otpController.clear();
      nameController.clear();
      mobileController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: otpStep ? _otpView() : _phoneView(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _brand() {
    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4F46E5).withValues(alpha: .22),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.notifications_active_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'NotifyTrade',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Smart market alerts, made simple.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _phoneView() {
    final register = mode == AuthMode.register;
    return Column(
      key: ValueKey('$mode-phone'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _brand(),
        const SizedBox(height: 34),
        Text(
          register ? 'Create your account' : 'Welcome back',
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            letterSpacing: -.6,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          register
              ? 'Enter your details to get started.'
              : 'Login securely with your mobile number.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 26),
        if (register) ...[
          const Text(
            'Full name',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Enter your name',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 18),
        ],
        const Text(
          'Mobile number',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: mobileController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          decoration: const InputDecoration(
            hintText: '10-digit mobile number',
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 16, right: 8),
              child: Center(
                widthFactor: 1,
                child: Text(
                  '+91',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            counterText: '',
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 54,
          child: FilledButton.icon(
            onPressed: loading ? null : _sendOtp,
            icon: const Icon(Icons.sms_outlined),
            label: Text(register ? 'Send OTP' : 'Send OTP & Login'),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              register ? 'Already have an account? ' : "Don't have an account? ",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            TextButton(
              onPressed: () =>
                  _switchMode(register ? AuthMode.login : AuthMode.register),
              child: Text(register ? 'Login' : 'Register'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            'Demo mode: use one of the sample users or register a new user. OTP is $demoOtp.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'By continuing, you agree to the NotifyTrade terms and privacy policy.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 11,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _otpView() {
    return Column(
      key: const ValueKey('otp'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _brand(),
        const SizedBox(height: 34),
        Row(
          children: [
            IconButton(
              onPressed: loading ? null : () => setState(() => otpStep = false),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 4),
            const Text(
              'Verify mobile',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Padding(
          padding: const EdgeInsets.only(left: 48),
          child: Text(
            'Enter the 6-digit OTP for +91 $mobile',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.lock_open_rounded,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Demo OTP: $generatedOtp',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            letterSpacing: 12,
          ),
          decoration: const InputDecoration(
            hintText: '••••••',
            counterText: '',
            contentPadding: EdgeInsets.symmetric(vertical: 18),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 54,
          child: FilledButton(
            onPressed: loading ? null : _verifyOtp,
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    mode == AuthMode.register
                        ? 'Verify & create account'
                        : 'Verify & login',
                  ),
          ),
        ),
        const SizedBox(height: 14),
        TextButton.icon(
          onPressed: loading ? null : _resendOtp,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Resend OTP'),
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(
            'Demo testing only — no SMS is sent.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class HomePage extends StatefulWidget {
  final String userName;
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;

  const HomePage({
    super.key,
    required this.userName,
    required this.isDark,
    required this.onThemeChanged,
  });

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
        final content = IndexedStack(
          index: tab,
          children: [
            _dashboard(wide),
            _signals(),
            _settings(),
          ],
        );

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
                      padding: const EdgeInsets.only(top: 12, bottom: 22),
                      child: _brandMark(size: 48),
                    ),
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home_rounded),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.notifications_none_rounded),
                        selectedIcon: Icon(Icons.notifications_active_rounded),
                        label: Text('Signals'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.settings_outlined),
                        selectedIcon: Icon(Icons.settings_rounded),
                        label: Text('Settings'),
                      ),
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
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.notifications_none_rounded),
                selectedIcon: Icon(Icons.notifications_active_rounded),
                label: 'Signals',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dashboard(bool wide) {
    final data = marketData[market]!;
    final alerts = allSignals.take(3).toList();

    return RefreshIndicator(
      onRefresh: () async =>
          Future<void>.delayed(const Duration(milliseconds: 350)),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(wide ? 32 : 18, 18, wide ? 32 : 18, 30),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(),
                  const SizedBox(height: 22),
                  _welcomeCard(),
                  const SizedBox(height: 22),
                  _sectionTitle('Markets', 'View all'),
                  const SizedBox(height: 10),
                  _marketTabs(),
                  const SizedBox(height: 14),
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 6, child: _marketCard(data)),
                        const SizedBox(width: 16),
                        Expanded(flex: 4, child: _marketMiniList()),
                      ],
                    )
                  else
                    _marketCard(data),
                  const SizedBox(height: 24),
                  _sectionTitle(
                    'Latest signals',
                    'See all',
                    () => setState(() => tab = 1),
                  ),
                  const SizedBox(height: 10),
                  ...alerts.map(_signalCard),
                  const SizedBox(height: 6),
                  _safetyCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _welcomeCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good day, ${widget.userName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Stay informed with your latest market signals.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .82),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _brandMark({double size = 48}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(size * .30),
      ),
      child: Icon(
        Icons.notifications_active_rounded,
        color: Colors.white,
        size: size * .52,
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        _brandMark(),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NotifyTrade',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.7,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Market alerts at a glance',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        _iconButton(
          Icons.notifications_none_rounded,
          () => _snack(
            notifications
                ? 'Signal notifications are on'
                : 'Signal notifications are off',
          ),
        ),
        const SizedBox(width: 8),
        _iconButton(
          Icons.tune_rounded,
          () => setState(() => tab = 2),
        ),
      ],
    );
  }

  Widget _iconButton(IconData icon, VoidCallback tap) {
    return Material(
      color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: tap,
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 21),
        ),
      ),
    );
  }

  Widget _marketTabs() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: marketData.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final name = marketData.keys.elementAt(i);
          final selected = market == name;
          return ChoiceChip(
            label: Text(name),
            selected: selected,
            onSelected: (_) => setState(() => market = name),
            showCheckmark: false,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: selected
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _marketCard(MarketData data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  market,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                _gainBadge(data.change),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              data.value,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Today’s market movement',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 90,
              child: CustomPaint(
                painter: _SparklinePainter(context),
                child: const SizedBox.expand(),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _stat('Day volume', data.volume)),
                Expanded(child: _stat('Status', 'Active')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _gainBadge(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF16A34A).withValues(alpha: .10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Color(0xFF16A34A),
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _marketMiniList() {
    final names = marketData.keys.where((n) => n != market).take(4).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Other markets',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        ...names.map((name) {
          final d = marketData[name]!;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => setState(() => market = name),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(_marketIcon(name), size: 20),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            d.value,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            d.change,
                            style: const TextStyle(
                              color: Color(0xFF16A34A),
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, String action, [VoidCallback? onTap]) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -.3,
            ),
          ),
        ),
        if (onTap != null)
          TextButton(
            onPressed: onTap,
            child: Text(
              action,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _signalCard(Signal s) {
    final buy = s.action == 'BUY';
    final accent =
        buy ? const Color(0xFF16A34A) : const Color(0xFFF59E0B);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _showSignal(s),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: .11),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    buy
                        ? Icons.arrow_upward_rounded
                        : Icons.pause_rounded,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            s.action,
                            style: TextStyle(
                              color: accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .7,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Flexible(
                            child: Text(
                              s.instrument,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${s.option} • ${s.time}',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      s.price,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Icon(Icons.chevron_right_rounded, size: 19),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _signals() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _pageTitle(
                  'Market signals',
                  'Clear, focused alerts for each index.',
                ),
                const SizedBox(height: 20),
                ...marketData.keys.map((name) => _signalSection(name)),
                _safetyCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _signalSection(String name) {
    final items =
        allSignals.where((s) => s.instrument == name).toList();
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_marketIcon(name), size: 18),
              const SizedBox(width: 7),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                '${items.length} alert${items.length == 1 ? '' : 's'}',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  'No active alerts',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            ...items.map(_signalCard),
        ],
      ),
    );
  }

  Widget _settings() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _pageTitle(
                  'Settings',
                  'Personalise your NotifyTrade experience.',
                ),
                const SizedBox(height: 20),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: notifications,
                        onChanged: (v) =>
                            setState(() => notifications = v),
                        secondary: _settingIcon(
                          Icons.notifications_active_outlined,
                        ),
                        title: const Text(
                          'Signal notifications',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle:
                            const Text('Receive market alerts'),
                      ),
                      const Divider(height: 1, indent: 70),
                      SwitchListTile(
                        value: widget.isDark,
                        onChanged: widget.onThemeChanged,
                        secondary: _settingIcon(
                          Icons.dark_mode_outlined,
                        ),
                        title: const Text(
                          'Dark mode',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle:
                            const Text('Comfortable viewing in low light'),
                      ),
                      const Divider(height: 1, indent: 70),
                      ListTile(
                        leading: _settingIcon(
                          Icons.info_outline_rounded,
                        ),
                        title: const Text(
                          'About NotifyTrade',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle:
                            const Text('Version 1.0 • Demo application'),
                        trailing:
                            const Icon(Icons.chevron_right_rounded),
                        onTap: () => _snack(
                          'NotifyTrade • Demo market alerts',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _safetyCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _pageTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w900,
            letterSpacing: -.8,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _settingIcon(IconData icon) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, size: 20),
    );
  }

  Widget _safetyCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Demo data only. NotifyTrade does not connect to a broker or execute trades.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 11,
                height: 1.45,
              ),
            ),
          ),
        ],
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

  void _showSignal(Signal s) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${s.action} • ${s.instrument}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                s.reason,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _detail('Option', s.option),
                  _detail('Price', s.price),
                  _detail('Confidence', s.confidence),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class MarketData {
  final String value;
  final String change;
  final String volume;

  const MarketData(this.value, this.change, this.volume);
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
  Signal(
    time: '09:42',
    action: 'BUY',
    instrument: 'NIFTY',
    option: '25,000 CE',
    price: '₹126.40',
    confidence: 'High',
    reason: 'Positive momentum with simulated support holding.',
  ),
  Signal(
    time: '09:18',
    action: 'BUY',
    instrument: 'BANK NIFTY',
    option: '51,500 PE',
    price: '₹184.20',
    confidence: 'Medium',
    reason: 'Potential reversal setup in the demo engine.',
  ),
  Signal(
    time: '09:05',
    action: 'WAIT',
    instrument: 'SENSEX',
    option: '81,500 CE',
    price: '₹142.70',
    confidence: 'Low',
    reason: 'Waiting for confirmation before an entry.',
  ),
  Signal(
    time: '08:56',
    action: 'BUY',
    instrument: 'NIFTY',
    option: '24,900 CE',
    price: '₹98.60',
    confidence: 'Medium',
    reason: 'Price is above the simulated intraday trend line.',
  ),
  Signal(
    time: '08:41',
    action: 'WAIT',
    instrument: 'FINNIFTY',
    option: '23,800 CE',
    price: '₹112.10',
    confidence: 'Low',
    reason: 'Setup needs confirmation before an entry.',
  ),
  Signal(
    time: '08:32',
    action: 'BUY',
    instrument: 'MIDCAP NIFTY',
    option: '12,900 CE',
    price: '₹76.30',
    confidence: 'Medium',
    reason: 'Simulated breakout with improving momentum.',
  ),
];

class _SparklinePainter extends CustomPainter {
  final BuildContext context;

  _SparklinePainter(this.context);

  @override
  void paint(Canvas canvas, Size size) {
    final color = Theme.of(context).colorScheme.primary;
    final line = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fill = Paint()
      ..color = color.withValues(alpha: .08)
      ..style = PaintingStyle.fill;

    final points = [
      Offset(0, size.height * .72),
      Offset(size.width * .12, size.height * .58),
      Offset(size.width * .24, size.height * .64),
      Offset(size.width * .36, size.height * .40),
      Offset(size.width * .48, size.height * .47),
      Offset(size.width * .60, size.height * .25),
      Offset(size.width * .72, size.height * .36),
      Offset(size.width * .84, size.height * .18),
      Offset(size.width, size.height * .27),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final area = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(area, fill);
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => true;
}
