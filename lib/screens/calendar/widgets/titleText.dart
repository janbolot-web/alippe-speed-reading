import 'package:client/screens/calendar/calendar.dart';
import 'package:flutter/material.dart';

class EditableSectionTitle extends StatefulWidget {
  final String initialTitle;
  final Function(String) onSubmit;

  const EditableSectionTitle({
    Key? key,
    required this.initialTitle,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<EditableSectionTitle> createState() => _EditableSectionTitleState();
}

class _EditableSectionTitleState extends State<EditableSectionTitle> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _submitEdit() {
    widget.onSubmit(_controller.text);
    _toggleEdit();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.65,
      constraints: BoxConstraints(minWidth: 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _isEditing
              ? Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: Colors.blue[300]!, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      hintText: 'Введите заголовок раздела',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      isDense: true,
                    ),
                    maxLines: 1,
                  ),
                )
              : Expanded(
                  child: Text(
                    _controller.text,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
          _isEditing
              ? Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.check, color: Colors.white),
                    onPressed: _submitEdit,
                    tooltip: 'Сохранить',
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.edit_outlined, color: Colors.grey[700]),
                  onPressed: _toggleEdit,
                  tooltip: 'Редактировать',
                ),
        ],
      ),
    );
  }
}

// Usage example:
class SectionWidget extends StatelessWidget {
  final Section section;
  final Function(String) onTitleUpdate;

  const SectionWidget({
    Key? key,
    required this.section,
    required this.onTitleUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EditableSectionTitle(
      initialTitle: section.title,
      onSubmit: onTitleUpdate,
    );
  }
}
