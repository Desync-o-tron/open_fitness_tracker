import 'package:flutter/widgets.dart';

class PageNotFoundPage extends StatelessWidget {
  const PageNotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Sorry, we couldn't find that page. \n "
          "Submit an issue on GitHub if you think this is a bug."),
    );
  }
}
