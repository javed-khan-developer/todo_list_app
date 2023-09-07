part of 'view_exports.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Note>> _noteList;
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  DatabaseHelper databaseHelper = DatabaseHelper.instance;
  Note note = Note();

  _updateNoteList() {
    _noteList = DatabaseHelper.instance.getNoteList();
  }

  @override
  void initState() {
    super.initState();
    _updateNoteList(); // Initialize the note list to get updated notelist
  }

  @override
  Widget build(BuildContext context) {
    Size s = MediaQuery.of(context).size;
    double size = s.height + s.width;
    return Scaffold(
      appBar: const CustomAppBar(title: 'Todo List'),
      body: FutureBuilder(
        future: _noteList,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgressBar();
          }
          final int completeNoteCount = snapshot.data!
              .where((Note note) => note.status == 1)
              .toList()
              .length;

          return ListView.builder(
            itemCount: int.parse(snapshot.data!.length.toString()) + 1,
            padding: const EdgeInsets.symmetric(vertical: 20),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  children: [
                    SizedBox(height: size / 100),
                    Text(
                        '$completeNoteCount of ${snapshot.data!.length}'), // Display note count
                    SizedBox(height: size / 100),
                  ],
                );
              }
              return Dismissible(
                confirmDismiss: (DismissDirection direction) async {
                  final confirm = showDialog<bool>(
                    context: context,
                    builder: (context) => _deleteDialog(
                      context,
                      snapshot,
                      index,
                    ), // Display delete confirmation dialog
                  );
                  return confirm;
                },
                direction: DismissDirection.endToStart,
                key: Key(snapshot.data![index - 1].toString()),
                background: deleteWidget(), // Display delete widget
                child:
                    _buildNotes(snapshot.data![index - 1]), // Build note item
              );
            },
          );
        },
      ),
      floatingActionButton: _addNoteButton(context), // Display add note button
    );
  }

  // Function to create a delete confirmation dialog
  _deleteDialog(
      BuildContext context, AsyncSnapshot<List<Note>> snapshot, int index) {
    return AlertDialog(
      title: const Text('Are you sure you want to delete'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, true);
            _delete(snapshot.data![index - 1].id!); // Delete the selected note
            _updateNoteList(); // Update the note list
          },
          child: const Text('Yes'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('No'),
        ),
      ],
    );
  }

  // Function to create an add note button
  _addNoteButton(BuildContext context) {
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddNoteView(
            updateNoteList: _updateNoteList,
          ),
        ),
      ),
    );
  }

  // Function to build a single note item
  _buildNotes(Note note) {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Icon(
          color: priorityColor(note.priority!),
          Icons.circle,
          size: 20,
        ),
      ),
      title: Text(
        note.title!,
        style: TextStyle(
          decoration: note.status == 0
              ? TextDecoration.none
              : TextDecoration.lineThrough,
        ),
      ),
      subtitle: Text(
        '${_dateFormatter.format(note.date!)}-${note.priority}',
        style: TextStyle(
          decoration: note.status == 0
              ? TextDecoration.none
              : TextDecoration.lineThrough,
        ),
      ),
      trailing: Checkbox(
        value: note.status == 1 ? true : false,
        onChanged: (value) {
          setState(() => note.status = value! ? 1 : 0);
          DatabaseHelper.instance.updateNote(note);
          _updateNoteList(); // Update the note list
        },
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddNoteView(
            updateNoteList: _updateNoteList(),
            note: note,
          ),
        ),
      ),
    );
  }

  // Function to delete a note
  _delete(int id) {
    note.id = id;
    DatabaseHelper.instance.deleteNote(note.id!);
  }
}
