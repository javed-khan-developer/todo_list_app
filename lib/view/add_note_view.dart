part of 'view_exports.dart';

class AddNoteView extends StatefulWidget {
  final Note? note; // Note object for editing an existing note
  final Function? updateNoteList; // function to update the note list
  const AddNoteView({super.key, this.note, this.updateNoteList});

  @override
  State<AddNoteView> createState() => _AddNoteViewState();
}

class _AddNoteViewState extends State<AddNoteView> {
  String _title = '';
  String _priority = 'Low';
  String titleText = 'Add Note';
  String btnText = 'Add Note';

  final TextEditingController _dateController = TextEditingController();
  DateTime _date = DateTime.now();
  final DateFormat _dateFormatatter = DateFormat('MMM dd, yyyy');
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      // If editing an existing note, initialize fields with existing data
      _title = widget.note!.title!;
      _date = widget.note!.date!;
      _priority = widget.note!.priority!;
      setState(() {
        btnText = "Update Note".toUpperCase(); // Change button text for editing
        titleText =
            "Update Note".toUpperCase(); // Change app bar title for editing
      });
    } else {
      setState(() {
        btnText = "Add Note".toUpperCase(); // Default button text for adding
        titleText =
            "Add Note".toUpperCase(); // Default app bar title for adding
      });
    }
    _dateController.text =
        _dateFormatatter.format(_date); // Display selected date
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size s = MediaQuery.of(context).size;
    double size = s.height + s.width;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus!
          .unfocus(), // Close keyboard on tap
      child: Scaffold(
        appBar: CustomAppBar(
          title: titleText,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 80),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Display title input field
                  _titleField(),
                  SizedBox(height: size / 30),
                  // Display date input field
                  _dateField(),
                  SizedBox(height: size / 30),
                  // Display priority dropdown
                  _dropdown(),
                  // Display submit button
                  _submitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Function to build the title input field
  _titleField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Title',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onSaved: (newValue) => _title = newValue!, // Save the title value
      initialValue: _title,
      validator: (value) =>
          value!.isEmpty ? 'Please enter title' : null, // Validate title input
    );
  }

  // Function to build the date input field
  _dateField() {
    return TextFormField(
      readOnly: true,
      controller: _dateController,
      onTap: _handleDatePicker, // Show date picker on tap
      decoration: InputDecoration(
        labelText: 'Date',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // Function to build the submit button
  _submitButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 40),
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
      ),
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _submit();
          }
        },
        child: Text(btnText),
      ),
    );
  }

  // Function to build the priority dropdown
  _dropdown() {
    return DropdownButtonFormField(
      icon: const Icon(Icons.arrow_downward),
      items: _priorities.map((String priority) {
        return DropdownMenuItem(
          value: priority,
          child: Text(priority),
        );
      }).toList(),
      onChanged: (value) =>
          _priority = value.toString(), // Update priority value
      decoration: InputDecoration(
          border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      )),
      value: _priority,
    );
  }

  // Function to handle date picker dialog
  _handleDatePicker() async {
    final DateTime? date = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2010),
        lastDate: DateTime(2050));
    if (date != null && date != _date) {
      setState(() => _date = date); // Update selected date
    }
    _dateController.text =
        _dateFormatatter.format(date!); // Update date controller text
  }

  // Function to handle form submission (adding or updating a note)
  _submit() {
    _formKey.currentState!.save(); // Save form data
    Note note = Note(
      title: _title,
      date: _date,
      priority: _priority,
    );
    if (widget.note == null) {
      note.status = 0;
      DatabaseHelper.instance.insertNote(note); // Insert a new note
      _goToHomeView();
    } else {
      note.id = widget.note!.id;
      note.status = widget.note!.status;
      DatabaseHelper.instance.updateNote(note); // Update an existing note
      _goToHomeView();
    }
    widget.updateNoteList!(); // Update the note list using the callback
  }

  // Function to navigate to the home view
  void _goToHomeView() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MyHomePage(),
        ),
      );
}
