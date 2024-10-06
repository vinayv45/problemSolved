import 'package:flutter/material.dart';

class CheckLoaderAnimation extends StatefulWidget {
  @override
  _CheckLoaderAnimationState createState() => _CheckLoaderAnimationState();
}

class _CheckLoaderAnimationState extends State<CheckLoaderAnimation>
    with TickerProviderStateMixin {
  bool _moveLoader = false; // Flag to move the loader
  bool _moveTicket = false; // Flag to move the ticket

  late AnimationController _sizeController;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the size animation controller
    _sizeController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true); // Pulse animation

    // Tween for size animation (small to large pulsing effect)
    _sizeAnimation = Tween<double>(begin: 50.0, end: 100.0).animate(
      CurvedAnimation(
        parent: _sizeController,
        curve: Curves.easeInOut,
      ),
    );

    // Start loader movement after 3 seconds
    Future.delayed(Duration(seconds: 3)).then((_) {
      setState(() {
        _moveLoader = true; // Trigger loader to move to the top
        _moveTicket = true; // Trigger ticket to move slightly
      });

      // Stop the pulsing animation once the loader reaches the top
      _sizeController.stop();
    });
  }

  @override
  void dispose() {
    _sizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Check Loader Animation')),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Loader circle animation (pulsing size)
          AnimatedPositioned(
            duration: Duration(seconds: 2), // Slower movement
            curve: Curves.easeOut, // Ease-out curve for smooth transition
            top: _moveLoader
                ? 100 // Move loader to a fixed position at the top
                : MediaQuery.of(context).size.height / 2 -
                    50, // Initially centered
            child: AnimatedBuilder(
              animation: _sizeController,
              builder: (context, child) {
                return Container(
                  width: _sizeAnimation.value,
                  height: _sizeAnimation.value,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check,
                      size: _sizeAnimation.value /
                          2, // Scale icon with the container
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),

          // Ticket that moves slightly when the loader moves
          AnimatedPositioned(
            duration: Duration(seconds: 2), // Match the loader's duration
            curve: Curves.easeOut, // Ease-out curve for smooth transition
            top: _moveLoader
                ? MediaQuery.of(context).size.height / 2 -
                    70 // Move ticket up slightly more
                : MediaQuery.of(context).size.height / 2, // Center it initially
            child: AnimatedOpacity(
              opacity: _moveTicket ? 1 : 0, // Fade in effect for the ticket
              duration: Duration(seconds: 1), // Fade duration
              child: Container(
                width: 150,
                height: 50,
                color: Colors.orange,
                child: Center(
                  child: Text(
                    'Ticket',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: CheckLoaderAnimation()));
