import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: DraggableExample(
                key:
                    UniqueKey(), // Usando UniqueKey para identificar a instância
                dias: 7,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: DraggableExample(
                key:
                    UniqueKey(), // Usando UniqueKey para identificar a instância
                dias: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DraggableExample extends StatefulWidget {
  final int dias;

  const DraggableExample({super.key, required this.dias});

  @override
  _DraggableExampleState createState() => _DraggableExampleState();
}

void reorderBoxes(List<Box> droppedBoxes, int oldIndex, int newIndex) {
  if (oldIndex < newIndex) {
    newIndex -= 1;
  }
  final Box item = droppedBoxes.removeAt(oldIndex);
  droppedBoxes.insert(newIndex, item);
}

class _DraggableExampleState extends State<DraggableExample> {
  late List<List<Box>> droppedBoxesList;
  late Key key;
  List<Box> boxes = [];
  @override
  void initState() {
    super.initState();
    key = widget.key!;
    droppedBoxesList =
        List.generate(widget.dias, (index) => [Box(1, Colors.black, key)]);

    boxes = [
      Box(1, Colors.blue, key),
      Box(2, Colors.red, key),
      Box(3, Colors.green, key),
      Box(4, Colors.amber, key),
      Box(5, Colors.grey, key),
      Box(6, Colors.white, key),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
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
                Text(boxes.length.toString()),
                for (Box box in boxes)
                  DraggableBox(
                    key: UniqueKey(),
                    box: box,
                    allowedDropKey: widget.key,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            for (int dia = 0; dia < widget.dias; dia++)
              myDragTarget(Colors.yellow, droppedBoxesList[dia]),
          ]),
        ],
      ),
    );
  }

  DragTarget<Box> myDragTarget(Color color, List<Box> droppedBoxes) {
    return DragTarget(
      builder: (context, candidateData, rejectedData) {
        return Container(
          height: 180,
          width: 150,
          color: color,
          child: Center(
            child: Column(
              children: [
                Text(droppedBoxes.length.toString()),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (Box droppedBox in droppedBoxes)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              GestureDetector(
                                  child: const Icon(
                                    Icons.arrow_upward,
                                    size: 10,
                                  ),
                                  onTap: () {
                                    int currentIndex =
                                        (droppedBoxes.indexOf(droppedBox));
                                    int newIndex = currentIndex - 1;

                                    if (currentIndex > 0) {
                                      setState(() {
                                        Box movedBox =
                                            droppedBoxes.removeAt(currentIndex);
                                        droppedBoxes.insert(newIndex, movedBox);
                                      });
                                    }
                                  }),
                              const SizedBox(
                                height: 10,
                              ),
                              GestureDetector(
                                child: const Icon(
                                  Icons.arrow_downward,
                                  size: 10,
                                ),
                                onTap: () {
                                  int currentIndex =
                                      (droppedBoxes.indexOf(droppedBox));
                                  int newIndex = currentIndex + 1;

                                  if (currentIndex < droppedBoxes.length - 1) {
                                    setState(() {
                                      Box movedBox =
                                          droppedBoxes.removeAt(currentIndex);
                                      droppedBoxes.insert(newIndex, movedBox);
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                          DraggableBox(
                            box: droppedBox,
                            allowedDropKey: widget.key,
                            onDragStarted: () {
                              setState(() {
                                droppedBoxes.remove(droppedBox);
                                boxes.add(droppedBox);
                              });
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      onWillAccept: (Box? droppedBox) {
        if (droppedBox!.key == key) {
          return true;
        }
        return false;
      },
      onAccept: (Box droppedBox) {
        setState(() {
          droppedBoxes.add(droppedBox);
          boxes.remove(droppedBox);
        });
      },
    );
  }
}

class Box {
  final int id;
  final Color color;
  final key;
  Box(this.id, this.color, this.key);
}

class DraggableBox extends StatelessWidget {
  final Box box;
  final VoidCallback? onDragStarted;
  final Key? allowedDropKey;

  const DraggableBox(
      {super.key, required this.box, this.onDragStarted, this.allowedDropKey});

  @override
  Widget build(BuildContext context) {
    return Draggable(
      key: allowedDropKey,
      data: box,
      feedback: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            width: 50,
            height: 50,
            color: box.color.withOpacity(0.7),
            child: Center(
              child: Text('Box ${box.id}'),
            ),
          ),
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
