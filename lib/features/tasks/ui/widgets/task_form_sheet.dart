import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/status_alert.dart';
import '../../data/task_model.dart';
import '../../state/tasks_controller.dart';

class TaskFormSheet extends ConsumerStatefulWidget {
  final Task? task;

  const TaskFormSheet({super.key, this.task});

  static Future<bool?> show(BuildContext context, {Task? task}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TaskFormSheet(task: task),
    );
  }

  @override
  ConsumerState<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends ConsumerState<TaskFormSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  DateTime? _selectedDueDate;

  bool _isLoading = false;
  String? _generalError;
  final Map<String, String> _fieldErrors = {};

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');

    if (widget.task != null) {
      _selectedDueDate = widget.task!.dueAt.toLocal();
    } else {
      // Default: 2 hours from now rounded to the next hour
      final now = DateTime.now();
      _selectedDueDate = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour + 2,
        0,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDateTime() async {
    final now = DateTime.now();
    final initialDate = _selectedDueDate ?? now.add(const Duration(hours: 1));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );

    if (pickedDate == null || !mounted) return;

    final initialTime = TimeOfDay.fromDateTime(initialDate);
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime == null || !mounted) return;

    setState(() {
      _selectedDueDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      _fieldErrors.remove('due_at');
    });
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    setState(() {
      _fieldErrors.clear();
      _generalError = null;
    });

    // Client-side validations
    var hasError = false;
    if (title.isEmpty) {
      _fieldErrors['title'] = 'The title field is required.';
      hasError = true;
    } else if (title.length > 255) {
      _fieldErrors['title'] = 'The title may not be greater than 255 characters.';
      hasError = true;
    }

    if (_selectedDueDate == null) {
      _fieldErrors['due_at'] = 'A due date is required.';
      hasError = true;
    } else if (!isEditing && _selectedDueDate!.isBefore(DateTime.now())) {
      // Create validates due date in the future client-side too
      _fieldErrors['due_at'] = 'The due date must be a date in the future.';
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (isEditing) {
        await ref.read(tasksControllerProvider.notifier).updateTask(
              id: widget.task!.id,
              title: title,
              description: description.isEmpty ? null : description,
              dueAt: _selectedDueDate!,
            );
      } else {
        await ref.read(tasksControllerProvider.notifier).createTask(
              title: title,
              description: description.isEmpty ? null : description,
              dueAt: _selectedDueDate!,
            );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on ValidationException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          e.errors.forEach((key, list) {
            _fieldErrors[key] = list.join(' ');
          });
          if (e.message.isNotEmpty && _fieldErrors.isEmpty) {
            _generalError = e.message;
          }
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _generalError = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _generalError = 'An unexpected error occurred. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDue = _selectedDueDate != null
        ? DateFormat('MMM d, y, h:mm a').format(_selectedDueDate!)
        : 'Select due date and time';

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sheet Header with Title and Close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditing ? 'Edit Task' : 'Create a Task',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isEditing
                            ? 'Update your task details and deadline.'
                            : 'Add a new task to your dashboard with a title, optional description, and due date.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.of(context).pop(false),
                  splashRadius: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_generalError != null) ...[
              StatusAlert.error(message: _generalError!),
              const SizedBox(height: 14),
            ],

            // Task Title
            AppTextField(
              label: 'Task title',
              placeholder: 'e.g. Learn Laravel models',
              controller: _titleController,
              textInputAction: TextInputAction.next,
              errorText: _fieldErrors['title'],
              autofocus: !isEditing,
              onChanged: (_) {
                if (_fieldErrors.containsKey('title')) {
                  setState(() => _fieldErrors.remove('title'));
                }
              },
            ),
            const SizedBox(height: 14),

            // Description
            AppTextField(
              label: 'Description (optional)',
              placeholder: 'Add extra details, links, or notes...',
              controller: _descriptionController,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              errorText: _fieldErrors['description'],
              onChanged: (_) {
                if (_fieldErrors.containsKey('description')) {
                  setState(() => _fieldErrors.remove('description'));
                }
              },
            ),
            const SizedBox(height: 14),

            // Due Date Picker
            AppTextField(
              label: 'Due date & time',
              placeholder: 'Select due date',
              controller: TextEditingController(text: formattedDue),
              readOnly: true,
              onTap: _pickDueDateTime,
              errorText: _fieldErrors['due_at'],
              prefixIcon: const Icon(LucideIcons.calendar, size: 18),
              suffixIcon: IconButton(
                icon: const Icon(LucideIcons.clock, size: 18),
                onPressed: _pickDueDateTime,
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Cancel',
                    variant: AppButtonVariant.outline,
                    onPressed: () => Navigator.of(context).pop(false),
                    height: 44,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: _isLoading
                        ? 'Saving...'
                        : (isEditing ? 'Save Changes' : 'Create Task'),
                    isLoading: _isLoading,
                    onPressed: _submit,
                    height: 44,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
