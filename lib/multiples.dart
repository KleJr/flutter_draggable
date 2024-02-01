import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    UniqueKey chave = UniqueKey();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Draggable Tests')),
        body: SingleChildScrollView(
          child: Column(
            children: [
              DraggableExample(
                key: chave,
                dias: 2,
              ),
              DraggableExample(
                key: UniqueKey(),
                dias: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Promotor {
  final String id;
  final List<Box> droppedBoxes;

  Promotor(this.id, this.droppedBoxes);
}

class Estabelecimento {
  final String id;
  final List<Promotor> promotores;

  Estabelecimento(this.id, this.promotores);
}

class DraggableExample extends StatefulWidget {
  final int dias;

  const DraggableExample({
    Key? key,
    required this.dias,
  }) : super(key: key);

  @override
  State<DraggableExample> createState() => _DraggableExampleState();
}

class _DraggableExampleState extends State<DraggableExample> {
  late List<Estabelecimento> estabelecimentos;
  List<Box> boxes = [];
  bool isDraggingOver = false;
  late Key chave;
  final promotor1Id = UniqueKey().toString();
  final promotor2Id = UniqueKey().toString();
  final promotor3Id = UniqueKey().toString();

  @override
  void initState() {
    super.initState();
    estabelecimentos = [];
    chave = widget.key!;
    // Exemplo de estabelecimento com dois promotores

    for (int i = 0; i < 2; i++) {
      final estabelecimentoId = UniqueKey().toString();

      final estabelecimento = Estabelecimento(estabelecimentoId, [
        Promotor(promotor1Id, [Box(1, Colors.black, chave, 0)]),
        Promotor(promotor2Id, [Box(1, Colors.black, chave, 0)]),
        Promotor(promotor3Id, [Box(1, Colors.black, chave, 0)]),
      ]);

      estabelecimentos.add(estabelecimento);
    }

    boxes = [
      Box(1, Colors.blue, chave, 0),
      Box(2, Colors.red, chave, 0),
      Box(3, Colors.green, chave, 0),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50,
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
                  allowedDropKey: chave,
                ),
            ],
          ),
        ),
        for (Estabelecimento estabelecimento in estabelecimentos)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: estabelecimento.promotores.map((e) {
                    return myDragTarget(
                      Colors.yellow,
                      e.droppedBoxes,
                      e.id,
                      estabelecimento.id,
                    );
                  }).toList(),
                )
              ],
            ),
          ),
      ],
    );
  }

  DragTarget<Box> myDragTarget(
    Color color,
    List<Box> droppedBoxes,
    String promotorId,
    String estabelecimentoId,
  ) {
    return DragTarget(
      builder: (context, candidateData, rejectedData) {
        return Container(
          height: 180,
          width: 150,
          color: isDraggingOver ? Colors.green : Colors.yellow,
          child: Center(
            child: Column(
              children: [
                Text(promotorId),
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
                                          droppedBoxes.indexOf(droppedBox);
                                      int newIndex = currentIndex - 1;

                                      if (currentIndex > 0) {
                                        setState(() {
                                          Box movedBox = droppedBoxes
                                              .removeAt(currentIndex);
                                          droppedBoxes.insert(
                                              newIndex, movedBox);
                                        });
                                      }
                                    },
                                  ),
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
                                          droppedBoxes.indexOf(droppedBox);
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
                                  allowedDropKey: chave,
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
      onLeave: (data) {
        // Ação ao sair da área
      },
      onWillAccept: (Box? droppedBox) {
        if (droppedBox!.key == chave) {
          return true;
        }
        return false;
      },
      onAccept: (Box droppedBox) {
        setState(() {
          print('Box: ${droppedBox.id} / key $chave');
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

  const DraggableBox({
    Key? key,
    required this.box,
    this.onDragStarted,
    this.allowedDropKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable(
      key: allowedDropKey,
      data: box,
      feedback: FeedBackBox(box: box),
      childWhenDragging: FeedBackBox(box: box),
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

class FeedBackBox extends StatelessWidget {
  const FeedBackBox({
    Key? key,
    required this.box,
  }) : super(key: key);

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
