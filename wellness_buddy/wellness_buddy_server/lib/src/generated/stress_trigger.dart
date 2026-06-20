/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

abstract class StressTrigger
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  StressTrigger._({
    required this.trigger,
    required this.category,
    required this.severity,
    required this.evidence,
    required this.explanation,
  });

  factory StressTrigger({
    required String trigger,
    required String category,
    required int severity,
    required String evidence,
    required String explanation,
  }) = _StressTriggerImpl;

  factory StressTrigger.fromJson(Map<String, dynamic> jsonSerialization) {
    return StressTrigger(
      trigger: jsonSerialization['trigger'] as String,
      category: jsonSerialization['category'] as String,
      severity: jsonSerialization['severity'] as int,
      evidence: jsonSerialization['evidence'] as String,
      explanation: jsonSerialization['explanation'] as String,
    );
  }

  String trigger;

  String category;

  int severity;

  String evidence;

  String explanation;

  /// Returns a shallow copy of this [StressTrigger]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  StressTrigger copyWith({
    String? trigger,
    String? category,
    int? severity,
    String? evidence,
    String? explanation,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StressTrigger',
      'trigger': trigger,
      'category': category,
      'severity': severity,
      'evidence': evidence,
      'explanation': explanation,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'StressTrigger',
      'trigger': trigger,
      'category': category,
      'severity': severity,
      'evidence': evidence,
      'explanation': explanation,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _StressTriggerImpl extends StressTrigger {
  _StressTriggerImpl({
    required String trigger,
    required String category,
    required int severity,
    required String evidence,
    required String explanation,
  }) : super._(
         trigger: trigger,
         category: category,
         severity: severity,
         evidence: evidence,
         explanation: explanation,
       );

  /// Returns a shallow copy of this [StressTrigger]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  StressTrigger copyWith({
    String? trigger,
    String? category,
    int? severity,
    String? evidence,
    String? explanation,
  }) {
    return StressTrigger(
      trigger: trigger ?? this.trigger,
      category: category ?? this.category,
      severity: severity ?? this.severity,
      evidence: evidence ?? this.evidence,
      explanation: explanation ?? this.explanation,
    );
  }
}
