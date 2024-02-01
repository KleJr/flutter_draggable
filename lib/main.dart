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
    UniqueKey chave = UniqueKey();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Draggable Tests')),
        body: Column(
          children: [
            Expanded(
              child: DraggableExample(
                key:
                    UniqueKey(), // Usando UniqueKey para identificar a instância
                dias: 2,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: DraggableExample(
                  key:
                      UniqueKey(), // Usando UniqueKey para identificar a instância
                  dias: 2),
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
  State<DraggableExample> createState() => _DraggableExampleState();
}

class _DraggableExampleState extends State<DraggableExample> {
  late List<List<Box>> droppedBoxesList;
  late Key key;
  List<Box> boxes = [];
  bool isDraggingOver = false;
  @override
  void initState() {
    super.initState();
    key = widget.key!;
    droppedBoxesList =
        List.generate(widget.dias, (index) => [Box(1, Colors.black, key, 0)]);

    boxes = [
      Box(1, Colors.blue, key, 0),
      Box(2, Colors.red, key, 0),
      Box(3, Colors.green, key, 0),
      // Box(4, Colors.amber, key, 0),
      // Box(5, Colors.grey, key, 0),
      // Box(6, Colors.white, key, 0),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 90,
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
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          for (int dia = 0; dia < widget.dias; dia++)
            myDragTarget(Colors.yellow, droppedBoxesList[dia], dia),
        ]),
      ],
    );
  }

  DragTarget<Box> myDragTarget(Color color, List<Box> droppedBoxes, int dia) {
    return DragTarget(
      builder: (context, candidateData, rejectedData) {
        return Container(
          height: 190,
          width: 150,
          color: isDraggingOver ? Colors.green : Colors.yellow,
          child: Center(
            child: Column(
              children: [
                Text(droppedBoxes.length.toString()),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (Box droppedBox in droppedBoxes)
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                            Box movedBox = droppedBoxes
                                                .removeAt(currentIndex);
                                            droppedBoxes.insert(
                                                newIndex, movedBox);
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

                                      if (currentIndex <
                                          droppedBoxes.length - 1) {
                                        setState(() {
                                          Box movedBox = droppedBoxes
                                              .removeAt(currentIndex);
                                          droppedBoxes.insert(
                                              newIndex, movedBox);
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: DraggableBox(
                                  box: droppedBox,
                                  allowedDropKey: widget.key,
                                  onDragStarted: () {
                                    setState(() {
                                      droppedBoxes.remove(droppedBox);
                                      boxes.add(droppedBox);
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
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
          // setState(() {
          //   isDraggingOver = true;
          // });
          return true;
        }
        return false;
      },
      onLeave: (data) {
        // setState(() {
        //   isDraggingOver = false;
        // });
      },
      onAccept: (Box droppedBox) {
        setState(() {
          print('Box: ${droppedBox.id} / dia $dia / key $key');
          droppedBoxes.add(droppedBox);
          boxes.remove(droppedBox);
          isDraggingOver = false;
        });
      },
    );
  }
}

class Box {
  final int id;
  final Color color;
  final Key key;
  int day;
  Box(this.id, this.color, this.key, this.day);
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
      feedback: feedBackBox(box: box),
      childWhenDragging: feedBackBox(box: box),
      onDragStarted: onDragStarted,
      onDragEnd: (details) {
        print(details.wasAccepted);
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

class feedBackBox extends StatelessWidget {
  const feedBackBox({
    super.key,
    required this.box,
  });

  final Box box;

  @override
  Widget build(BuildContext context) {
    return Material(
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
    );
  }
}
