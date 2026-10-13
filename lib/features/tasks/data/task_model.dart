class Task {
  final int id;
  final String title;
  final String? description;
  final DateTime dueAt;
  final DateTime? completedAt;
  final bool isCompleted;
  final DateTime? createdAt;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.dueAt,
    this.completedAt,
    required this.isCompleted,
    this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    final completedAtStr = json['completed_at'] as String?;
    final isCompletedVal = json['is_completed'] as bool? ?? (completedAtStr != null);

    return Task(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      dueAt: DateTime.parse(json['due_at'] as String),
      completedAt: completedAtStr != null ? DateTime.parse(completedAtStr) : null,
      isCompleted: isCompletedVal,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_at': dueAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'is_completed': isCompleted,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueAt,
    DateTime? completedAt,
    bool? isCompleted,
    DateTime? createdAt,
    bool clearDescription = false,
    bool clearCompletedAt = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      dueAt: dueAt ?? this.dueAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          dueAt == other.dueAt &&
          completedAt == other.completedAt &&
          isCompleted == other.isCompleted;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      dueAt.hashCode ^
      completedAt.hashCode ^
      isCompleted.hashCode;
}
