import 'package:flutter/material.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

//todo make sure I can escape out of the dialog on web
class ExerciseDialog extends StatelessWidget {
  final Exercise exercise;
  const ExerciseDialog({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(25), // Outside Padding
      contentPadding: const EdgeInsets.all(10), // Content Padding
      content: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        margin: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                exercise.name,
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headlineLarge?.fontSize!,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.4),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: ListBody(
                  children: [
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 250,
                      child: ImageSwiper(imageRelativeUrls: exercise.images),
                    ),
                    Text('Primary Muscles: ${exercise.primaryMuscles.join(', ')}'),
                    if (exercise.secondaryMuscles != null &&
                        exercise.secondaryMuscles!.isNotEmpty) ...[
                      Text('Secondary Muscles: ${exercise.secondaryMuscles!.join(', ')}'),
                    ],
                    if (exercise.level != null) Text('Level: ${exercise.level}'),
                    const SizedBox(height: 8),
                    if (exercise.instructions != null) ...[
                      const Text('Instructions:'),
                      for (var instruction in exercise.instructions!) Text(instruction),
                    ],
                    const SizedBox(height: 8),
                    if (exercise.mechanic != null) Text('Mechanic: ${exercise.mechanic}'),
                    if (exercise.category != null) Text('Category: ${exercise.category}'),
                    if (exercise.equipment != null)
                      Text('Equipment: ${exercise.equipment}'),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: MyGenericButton(
                label: 'Close',
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageSwiper extends StatefulWidget {
  final List<String>? imageRelativeUrls;
  static final Uri imgBaseUrl = Uri.parse(
      "https://raw.githubusercontent.com/Desync-o-tron/free-exercise-db/main/exercises/");

  const ImageSwiper({super.key, required this.imageRelativeUrls});

  @override
  State<ImageSwiper> createState() => _ImageSwiperState();
}

class _ImageSwiperState extends State<ImageSwiper> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.imageRelativeUrls == null || widget.imageRelativeUrls!.isEmpty) {
      return Container(); // Return an empty container if there are no images
    }

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            scrollBehavior: GenericScrollBehavior(),
            controller: _pageController,
            itemCount: widget.imageRelativeUrls!.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              final imageUrl = ImageSwiper.imgBaseUrl
                  .resolve(widget.imageRelativeUrls![index])
                  .toString();
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/media/bar_loading.gif',
                  image: imageUrl,
                  fit: BoxFit.contain,
                  fadeInDuration: const Duration(milliseconds: 1),
                  fadeOutDuration: const Duration(milliseconds: 1),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                widget.imageRelativeUrls!.length, (index) => buildDot(index, context)),
          ),
        ),
      ],
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: 10,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: _currentPage == index ? Theme.of(context).primaryColor : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}
