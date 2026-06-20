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
import 'stress_trigger.dart' as _i2;
import 'package:wellness_buddy_server/src/generated/protocol.dart' as _i3;

abstract class JournalAnalysis
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  JournalAnalysis._({required this.triggers});

  factory JournalAnalysis({required List<_i2.StressTrigger> triggers}) =
      _JournalAnalysisImpl;

  factory JournalAnalysis.fromJson(Map<String, dynamic> jsonSerialization) {
    return JournalAnalysis(
      triggers: _i3.Protocol().deserialize<List<_i2.StressTrigger>>(
        jsonSerialization['triggers'],
      ),
    );
  }

  List<_i2.StressTrigger> triggers;

  /// Returns a shallow copy of this [JournalAnalysis]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  JournalAnalysis copyWith({List<_i2.StressTrigger>? triggers});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'JournalAnalysis',
      'triggers': triggers.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'JournalAnalysis',
      'triggers': triggers.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _JournalAnalysisImpl extends JournalAnalysis {
  _JournalAnalysisImpl({required List<_i2.StressTrigger> triggers})
    : super._(triggers: triggers);

  /// Returns a shallow copy of this [JournalAnalysis]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  JournalAnalysis copyWith({List<_i2.StressTrigger>? triggers}) {
    return JournalAnalysis(
      triggers: triggers ?? this.triggers.map((e0) => e0.copyWith()).toList(),
    );
  }
}
