import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //remove the debug banner
      debugShowCheckedModeBanner: false,
     
      title: 'to do demo',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 5, 0, 14)),
      ),
      home: const MyHomePage(title: 'ToDo List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final List<Map<String, dynamic>>_items = [];
 



  void _addItem(String text){
    if (text.trim().isEmpty) return;
    setState(() {
      _items.add({'text': text.trim(), 'done': false});
     _textController.clear();
    });
  }

  


  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {

     final pending = _items.where((item) => item['done']  == false).toList();
     final completed = _items.where((item) => item['done'] == true).toList();
     
    
    return Scaffold(
      appBar: AppBar(
        
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 100,

        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
              // or pick from your theme
            letterSpacing: 2,
          ),
        ),

        iconTheme: IconThemeData(
          color: Colors.blue, // Change the color of the icons
        ),

        actionsIconTheme: IconThemeData(
          color: Colors.blue, // Change the color of the icons
        ),


        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showAddItemDialog(context);
            },

        ),
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('Clear all items?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _items.clear();
                      });
                      Navigator.of(ctx).pop();
                    },
                    child: Text('Confirm'),
                  ),
                ],
              ),
            );
          },
        ),
        ],

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),


        //i want to style appbar
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color.fromARGB(255, 239, 236, 240), const Color.fromARGB(255, 10, 10, 10)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        
        
        
      ),
      body: _items.isEmpty
    ? Center(child: Text('No items yet. Tap + to add.'))
    :
       ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // — Pending Tasks Section —
          Text('Pending tasks',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (pending.isEmpty)
            Text('No pending tasks.')
          else
            ...pending.map((item) {
              final idx = _items.indexOf(item);
              return ListTile(
              title: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (ctx) {
                      bool isRunning = _items[idx]['isRunning'] ?? false;
                      Duration elapsed = _items[idx]['elapsed'] ?? Duration.zero;

                      // Use StatefulBuilder to manage modal state
                      return StatefulBuilder(
                        builder: (context, modalSetState) {
                          // Start timer function
                          void startTimer() {
                            setState(() {
                              isRunning = true;
                              _items[idx]['isRunning'] = true;
                              _items[idx]['timer'] = Timer.periodic(const Duration(seconds: 1), (timer) {
                                setState(() {
                                  elapsed += const Duration(seconds: 1);
                                  _items[idx]['elapsed'] = elapsed;
                                });
                                modalSetState(() {}); // Update modal UI
                              });
                            });
                          }

                          void stopTimer() {
                            setState(() {
                              isRunning = false;
                              _items[idx]['isRunning'] = false;
                              // Cancel the timer if it exists
                              if (_items[idx]['timer'] != null) {
                                (_items[idx]['timer'] as Timer).cancel();
                                _items[idx]['timer'] = null; // Clear the timer reference
                              }
                            });
                            modalSetState(() {}); // Update modal UI
                          }

                          return Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Task Timer',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Elapsed Time: ${elapsed.inMinutes}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: isRunning ? null : startTimer,
                                      child: const Text('Start'),
                                    ),
                                    ElevatedButton(
                                      onPressed: isRunning ? stopTimer : null,
                                      child: const Text('Stop'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        stopTimer();
                                        setState(() {
                                          _items[idx]['done'] = true;
                                        });
                                        Navigator.of(ctx).pop();
                                      },
                                      child: const Text('Mark Done'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                child: Text(item['text']),
              ),
              trailing: Checkbox(
                value: item['done'],
                onChanged: (val) {
                  setState(() => _items[idx]['done'] = val!);
                },
              ),
            );
            }),

          const SizedBox(height: 24),

          // — Completed Tasks Section —
          Text('Completed tasks',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (completed.isEmpty)
            Text('No completed tasks yet.')
          else
            ...completed.map((item) {
              final idx = _items.indexOf(item);
              return CheckboxListTile(
                title: Text(
                  item['text'],
                  style: const TextStyle(decoration: TextDecoration.lineThrough),
                ),
                value: item['done'],
                // Allow un-checking if you like:
                onChanged: (val) {
                  setState(() => _items[idx]['done'] = val!);
                },
              );
            }).toList(),

          // — Clear Completed Button —
          if (completed.isNotEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _items.removeWhere((item) => item['done'] == true);
                });
              },
              icon: const Icon(Icons.delete_forever),
              label: const Text('Clear Completed'),
            ),
          ],
        ],
      ),

    );
  }

  void _showAddItemDialog(BuildContext context) {
  showDialog(context: context,
  builder:
   (ctx) => AlertDialog(
    title: Text('Insert Item'),
    content: TextField(
      controller: _textController,
      decoration: InputDecoration(
        labelText: 'Enter Item',
        hintText: 'Creating New Button',
        border: OutlineInputBorder(),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(ctx).pop(),
        child: Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: () {
          _addItem(_textController.text);
          Navigator.of(ctx).pop();
        },
        child: Text('Add'),
      ),
    ],
   ),
   
   );
  //showDialog(context: context, builder: (context) => builder),
}

}





final TextEditingController _textController = TextEditingController();