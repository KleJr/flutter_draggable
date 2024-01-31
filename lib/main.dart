import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DraggableExample(),
    );
  }
}

class DraggableExample extends StatefulWidget {
  const DraggableExample({super.key});

  @override
  _DraggableExampleState createState() => _DraggableExampleState();
}

class _DraggableExampleState extends State<DraggableExample> {
  List<Box> boxes = [
    Box(1, Colors.blue),
    Box(2, Colors.red),
    Box(3, Colors.green),
  ];

  List<Box> droppedBoxesYellow = [];
  List<Box> droppedBoxesOrange = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Draggable Example'),
      ),
      body: Column(
        children: [
          Container(
            height: 150,
            width: double.infinity,
            color: Colors.grey[300],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (Box box in boxes)
                  DraggableBox(
                    box: box,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DragTarget(
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    height: 150,
                    width: 150,
                    color: Colors.yellow,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (Box droppedBox in droppedBoxesYellow)
                            DraggableBox(
                              box: droppedBox,
                              onDragStarted: () {
                                setState(() {
                                  droppedBoxesYellow.remove(droppedBox);
                                  boxes.add(droppedBox);
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
                onWillAccept: (Box? droppedBox) {
                  return true;
                },
                onAccept: (Box droppedBox) {
                  setState(() {
                    droppedBoxesYellow.add(droppedBox);
                    boxes.remove(droppedBox);
                  });
                },
              ),
              DragTarget(
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    height: 150,
                    width: 150,
                    color: Colors.orange,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (Box droppedBox in droppedBoxesOrange)
                            DraggableBox(
                              box: droppedBox,
                              onDragStarted: () {
                                setState(() {
                                  droppedBoxesOrange.remove(droppedBox);
                                  boxes.add(droppedBox);
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
                onWillAccept: (Box? droppedBox) {
                  return true;
                },
                onAccept: (Box droppedBox) {
                  setState(() {
                    droppedBoxesOrange.add(droppedBox);
                    boxes.remove(droppedBox);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Box {
  final int id;
  final Color color;

  Box(this.id, this.color);
}

class DraggableBox extends StatelessWidget {
  final Box box;
  final VoidCallback? onDragStarted;

  const DraggableBox({super.key, required this.box, this.onDragStarted});

  @override
  Widget build(BuildContext context) {
    return Draggable(
      data: box,
      feedback: Container(
        width: 50,
        height: 50,
        color: box.color.withOpacity(0.7),
        child: Center(
          child: Text('Box ${box.id}'),
        ),
      ),
      childWhenDragging: Container(),
      onDragStarted: onDragStarted,
      onDragEnd: (details) {
        if (details.wasAccepted) {
          // Não faz nada se o item foi solto na área de recebimento

          return;
        }

        // Se o item foi solto fora da área de recebimento, retorna para a lista inicial
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item ${box.id} devolvido à área inicial.'),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          if (onDragStarted != null) {
            onDragStarted!();
          }
        },
        child: Container(
          width: 50,
          height: 50,
          color: box.color,
          child: Center(
            child: Text('Box ${box.id}'),
          ),
        ),
      ),
    );
  }
}
