import 'package:flutter/material.dart';
import 'package:pokedex/pages/abilities_page.dart';
import '../pages/pokedex_page.dart';
import '../pages/favorites_page.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> cards = [
      {
        'title': 'Pokédex',
        'color': Colors.green,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Pokedex()),
          );
        },
      },
      {
        'title': 'Favorites',
        'color': const Color.fromARGB(255, 239, 99, 99),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FavoritesPage()),
          );
        },
      },
      {
        'title': 'Abilities',
        'color': Colors.blue,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AbilitiesPage()),
          );
        },
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Text(
                'Pokédex Lite',
                style: GoogleFonts.titilliumWeb(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),

            // Content with tilted Poké Ball
            Expanded(
              child: Stack(
                children: [
                  // Tilted grey Poké Ball background
                  CustomPaint(
                    size: Size.infinite,
                    painter: TiltedGreyPokeballPainter(),
                  ),

                  // Centered smaller cards
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var card in cards) ...[
                            _AnimatedCard(
                              title: card['title'],
                              color: card['color'],
                              onTap: card['onTap'],
                              height: 80, // smaller height
                            ),
                            const SizedBox(height: 20), // smaller spacing
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedCard extends StatefulWidget {
  final String title;
  final Color color;
  final VoidCallback onTap;
  final double height;

  const _AnimatedCard({
    required this.title,
    required this.color,
    required this.onTap,
    this.height = 80, // default smaller height
  });

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: _isPressed ? 0.95 : 1.0,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16, // smaller font size
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TiltedGreyPokeballPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // === ADJUST THIS FACTOR TO CHANGE POKÉ BALL SIZE ===
    final double radius = size.width * 0.55; // increased from 0.45
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Colors matching the reference
    const Color outerGrey = Color(0xFFB5BDB3);
    const Color innerGrey = Color(0xFFA7B0A7);
    const Color white = Colors.white;

    // Paints
    final Paint fillPaint = Paint()
      ..color = outerGrey
      ..style = PaintingStyle.fill;

    final Paint whiteLinePaint = Paint()
      ..color = white
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.12
      ..strokeCap = StrokeCap.round;

    final Paint innerFill = Paint()
      ..color = innerGrey
      ..style = PaintingStyle.fill;

    final Paint innerBorder = Paint()
      ..color = white
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.10;

    // === APPLY TILT ===
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(0.32); // precise clockwise rotation
    canvas.translate(-center.dx, -center.dy);

    // Outer circle
    canvas.drawCircle(center, radius, fillPaint);

    // Single horizontal white line
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      whiteLinePaint,
    );

    // Inner circle (middle)
    final double innerRadius = radius * 0.22;
    canvas.drawCircle(center, innerRadius, innerFill);

    // Inner white ring
    canvas.drawCircle(center, innerRadius, innerBorder);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
