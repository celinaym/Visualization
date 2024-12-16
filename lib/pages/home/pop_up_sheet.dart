import 'package:flutter/material.dart';

class PopUpSheet extends StatelessWidget {
  final DraggableScrollableController sheetController;
  final ValueNotifier<double> sheetStateNotifier;
  final String sheetTitle;
  final String sheetDescription;
  final VoidCallback closeSheet;

  const PopUpSheet({
    Key? key,
    required this.sheetController,
    required this.sheetStateNotifier,
    required this.sheetTitle,
    required this.sheetDescription,
    required this.closeSheet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: sheetController,
      initialChildSize: sheetStateNotifier.value > 0.0 ? 0.3 : 0.0,
      minChildSize: sheetStateNotifier.value > 0.0 ? 0.3 : 0.0,
      maxChildSize: 1,
      snap: true,
      snapSizes: [0.3, 1],
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          // Main container for the pop-up sheet
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 16.0), // Increased top padding
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(253, 245, 235, 1), // base color
                Color.fromRGBO(237, 215, 189, 1), // point strong color
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: SingleChildScrollView(
            // Scrollable container for the content
            physics: const ClampingScrollPhysics(),
            controller: scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: AnimatedContainer(
                    // Draggable indicator container
                    duration: const Duration(milliseconds: 300),
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 8.0),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(37, 37, 37, 1),
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
                AnimatedContainer(
                  // Spacer container for smooth animation
                  duration: const Duration(milliseconds: 600),
                  height: sheetStateNotifier.value > 0.95 ? .0 : 0.0, // Further increased top margin
                  curve: Curves.easeOut,
                ),
                Row(
                  // Row container for title and buttons
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AnimatedCrossFade(
                      // Back button container
                      sizeCurve: Curves.easeOut,
                      firstCurve: Curves.easeOut,
                      secondCurve: Curves.easeOut,
                      firstChild: Container(),
                      secondChild: InkWell(
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            sheetController.animateTo(0.3, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                          },
                        ),
                      ),
                      crossFadeState: sheetStateNotifier.value > 0.95 ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 600),
                    ),
                    Text(
                      sheetTitle,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(37, 37, 37, 1)
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color.fromRGBO(37, 37, 37, 0.6)),
                      onPressed: () {
                        sheetController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        closeSheet();
                      },
                    )
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  // Description text container
                  sheetDescription,
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Color.fromRGBO(37, 37, 37, 1),
                  ),
                ),
                const SizedBox(height: 8.0),
                // Additional content can be added here
              ],
            ),
          ),
        );
      },
    );
  }
}
