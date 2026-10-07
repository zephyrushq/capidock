import '../../instances/domain/server_instance.dart';

const defaultWorkspaceId = 'workspace-default';

class DockWorkspace {
  DockWorkspace({
    required this.id,
    required this.name,
    List<ServerInstance> instances = const [],
  }) : instances = List.unmodifiable(instances);

  final String id;
  final String name;
  final List<ServerInstance> instances;

  DockWorkspace copyWith({String? name, List<ServerInstance>? instances}) =>
      DockWorkspace(
        id: id,
        name: name ?? this.name,
        instances: instances ?? this.instances,
      );

  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'instances': instances.map((i) => i.toJson()).toList(),
  };

  factory DockWorkspace.fromJson(Map<String, dynamic> json) {
    final workspace = DockWorkspace(
      id: json['id'] as String,
      name: json['name'] as String,
      instances: (json['instances'] as List)
          .map((item) => ServerInstance.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
    if (workspace.id.isEmpty || workspace.name.trim().isEmpty) {
      throw const FormatException('Workspace inválido.');
    }
    return workspace;
  }
}
