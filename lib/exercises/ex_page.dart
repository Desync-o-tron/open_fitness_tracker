// ABOUT

//   "name": "Dumbbell Squat",
//   "images": [
//     "Dumbbell_Squat/0.jpg",
//     "Dumbbell_Squat/1.jpg"
//   ],
//   "level": "beginner",
//   "primaryMuscles": [
//     "quadriceps"
//   ],
//   "secondaryMuscles": [
//     "calves",
//     "glutes",
//     "hamstrings",
//     "lower back"
//   ],
//   "instructions": [
//     "yadda yadda”
//   ],
//   "category": "strength",
//   "mechanic": "compound"
//   "equipment": "dumbbell",

// The ExercisePage
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

class ExerciseDialog extends StatelessWidget {
  final Exercise exercise;
  const ExerciseDialog({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Text(exercise.name,
                      style: TextStyle(
                          fontSize: Theme.of(context).textTheme.headlineLarge?.fontSize!,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.4))),
              const SizedBox(height: 8),
              SizedBox(
                height: 250,
                // width: 400,
                child: ImageSwiper(imageRelativeUrls: exercise.images),
              ),
              Text('Primary Muscles: ${exercise.primaryMuscles.join(', ')}'),
              if (exercise.secondaryMuscles != null && exercise.secondaryMuscles!.isNotEmpty) ...[
                Text('Secondary Muscles: ${exercise.secondaryMuscles!.join(', ')}'),
              ],
              if (exercise.level != null) Text('Level: ${exercise.level}'),
              const SizedBox(height: 8),
              if (exercise.instructions != null) ...[
                Text('Instructions:'),
                for (var instruction in exercise.instructions!) Text(instruction),
              ],
              const SizedBox(height: 8),
              if (exercise.mechanic != null) Text('Mechanic: ${exercise.mechanic}'),
              if (exercise.category != null) Text('Category: ${exercise.category}'),
              if (exercise.equipment != null) Text('Equipment: ${exercise.equipment}'),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageSwiper extends StatefulWidget {
  final List<String>? imageRelativeUrls;
  static final Uri imgBaseUrl =
      Uri.parse("https://raw.githubusercontent.com/Desync-o-tron/free-exercise-db/main/exercises/");

  const ImageSwiper({Key? key, required this.imageRelativeUrls}) : super(key: key);

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
              final imageUrl = ImageSwiper.imgBaseUrl.resolve(widget.imageRelativeUrls![index]).toString();
              return Image.network(imageUrl, fit: BoxFit.contain);
            },
          ),
        ),
        Container(
          padding: EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.imageRelativeUrls!.length, (index) => buildDot(index, context)),
          ),
        ),
      ],
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: 10,
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: _currentPage == index ? Theme.of(context).primaryColor : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}


/*
class ImageSwiper extends StatelessWidget {
  final List<String>? imageRelativeUrls;
  static final Uri imgBaseUrl =
      Uri.parse("https://raw.githubusercontent.com/Desync-o-tron/free-exercise-db/main/exercises/");
  const ImageSwiper({super.key, required this.imageRelativeUrls});

  @override
  Widget build(BuildContext context) {
    if (imageRelativeUrls == null || imageRelativeUrls!.isEmpty) {
      return Container();
    }
    return PageView.builder(
      scrollDirection: Axis.horizontal,
      scrollBehavior: GenericScrollBehavior(),
      itemCount: imageRelativeUrls!.length,
      itemBuilder: (context, index) {
        final imageUrl = imgBaseUrl.resolve(imageRelativeUrls![index]).toString();
        return Image.network(
          imageUrl,
          fit: BoxFit.contain,
          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
            // You might want to display a generic error widget here
            return Text('Error loading image');
          },
        );
        // return FutureBuilder(
        //   future: fetchImage(imgBaseUrl.resolve(imageRelativeUrls![index]).toString()),
        //   builder: (context, snapshot) {
        //     if (snapshot.hasData) {
        //       return snapshot.data!;
        //     } else if (snapshot.hasError) {
        //       // You might want to display a generic placeholder here
        //       return Container();
        //     } else {
        //       return Center(child: CircularProgressIndicator());
        //     }
        //   },
        // );
      },
    );
  }

  Future<Image> fetchImage(String url) async {
    return Image.network(
      url,
      fit: BoxFit.contain,
    );
    // Simulate image fetching delay
    // await Future.delayed(Duration(seconds: 2));
    // In a real scenario, you would fetch the image data from the network or cache here.
  }
}
*/