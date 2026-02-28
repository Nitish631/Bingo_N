// import 'package:flutter/material.dart';
// import 'dart:math';

// import 'package:google_fonts/google_fonts.dart';
// class WaveText extends StatefulWidget {
//   final String text;
//   const WaveText({super.key,required this.text});

//   @override
//   State<WaveText> createState() => _MyWidgetState();
// }

// class _MyWidgetState extends State<WaveText> with SingleTickerProviderStateMixin {
//   late AnimationController waveAnimationController;
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     waveAnimationController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 500),
//     )..repeat();
//     waveAnimationController.forward();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//     animation: waveAnimationController,
//     builder: (context, child) {
//       return Row(
//         mainAxisSize: MainAxisSize.min,
//         children: List.generate(widget.text.length, (index) {
//           // wave calculation
//           double waveOffset =
//               sin((waveAnimationController.value * 2 * pi) + (index * 0.7)) * 10;

//           return Transform.translate(
//             offset: Offset(0, waveOffset),
//             child: Text(
//               widget.text[index],
//               style: GoogleFonts.poppins(
//                 fontSize: animation.value / 8,
//                 fontWeight: FontWeight.w900,
//                 foreground: Paint()
//                   ..shader = LinearGradient(
//                     colors: [
//                       Color.fromRGBO(255, 0, 0, 1),
//                       Color.fromRGBO(255, 150, 0, 1),
//                       Color.fromRGBO(255, 0, 0, 1),
//                       Color.fromRGBO(255, 150, 0, 1),
//                     ],
//                   ).createShader(
//                     Rect.fromLTRB(0, 0, colorValue.value, 100),
//                   ),
//               ),
//             ),
//           );
//         }),
//       );
//     },
//   );
// }
// }