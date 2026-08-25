// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TripsTableTable extends TripsTable
    with TableInfo<$TripsTableTable, TripsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
      'end_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _distanceMeta =
      const VerificationMeta('distance');
  @override
  late final GeneratedColumn<double> distance = GeneratedColumn<double>(
      'distance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _avgSpeedMeta =
      const VerificationMeta('avgSpeed');
  @override
  late final GeneratedColumn<double> avgSpeed = GeneratedColumn<double>(
      'avg_speed', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _maxSpeedMeta =
      const VerificationMeta('maxSpeed');
  @override
  late final GeneratedColumn<double> maxSpeed = GeneratedColumn<double>(
      'max_speed', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
      'duration_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        startTime,
        endTime,
        distance,
        avgSpeed,
        maxSpeed,
        durationSeconds
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trips';
  @override
  VerificationContext validateIntegrity(Insertable<TripsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    }
    if (data.containsKey('distance')) {
      context.handle(_distanceMeta,
          distance.isAcceptableOrUnknown(data['distance']!, _distanceMeta));
    }
    if (data.containsKey('avg_speed')) {
      context.handle(_avgSpeedMeta,
          avgSpeed.isAcceptableOrUnknown(data['avg_speed']!, _avgSpeedMeta));
    }
    if (data.containsKey('max_speed')) {
      context.handle(_maxSpeedMeta,
          maxSpeed.isAcceptableOrUnknown(data['max_speed']!, _maxSpeedMeta));
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_time']),
      distance: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}distance'])!,
      avgSpeed: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}avg_speed'])!,
      maxSpeed: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}max_speed'])!,
      durationSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_seconds'])!,
    );
  }

  @override
  $TripsTableTable createAlias(String alias) {
    return $TripsTableTable(attachedDatabase, alias);
  }
}

class TripsTableData extends DataClass implements Insertable<TripsTableData> {
  final int id;
  final String? title;
  final DateTime startTime;
  final DateTime? endTime;
  final double distance;
  final double avgSpeed;
  final double maxSpeed;
  final int durationSeconds;
  const TripsTableData(
      {required this.id,
      this.title,
      required this.startTime,
      this.endTime,
      required this.distance,
      required this.avgSpeed,
      required this.maxSpeed,
      required this.durationSeconds});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    map['distance'] = Variable<double>(distance);
    map['avg_speed'] = Variable<double>(avgSpeed);
    map['max_speed'] = Variable<double>(maxSpeed);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    return map;
  }

  TripsTableCompanion toCompanion(bool nullToAbsent) {
    return TripsTableCompanion(
      id: Value(id),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      distance: Value(distance),
      avgSpeed: Value(avgSpeed),
      maxSpeed: Value(maxSpeed),
      durationSeconds: Value(durationSeconds),
    );
  }

  factory TripsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripsTableData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String?>(json['title']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      distance: serializer.fromJson<double>(json['distance']),
      avgSpeed: serializer.fromJson<double>(json['avgSpeed']),
      maxSpeed: serializer.fromJson<double>(json['maxSpeed']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String?>(title),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'distance': serializer.toJson<double>(distance),
      'avgSpeed': serializer.toJson<double>(avgSpeed),
      'maxSpeed': serializer.toJson<double>(maxSpeed),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
    };
  }

  TripsTableData copyWith(
          {int? id,
          Value<String?> title = const Value.absent(),
          DateTime? startTime,
          Value<DateTime?> endTime = const Value.absent(),
          double? distance,
          double? avgSpeed,
          double? maxSpeed,
          int? durationSeconds}) =>
      TripsTableData(
        id: id ?? this.id,
        title: title.present ? title.value : this.title,
        startTime: startTime ?? this.startTime,
        endTime: endTime.present ? endTime.value : this.endTime,
        distance: distance ?? this.distance,
        avgSpeed: avgSpeed ?? this.avgSpeed,
        maxSpeed: maxSpeed ?? this.maxSpeed,
        durationSeconds: durationSeconds ?? this.durationSeconds,
      );
  TripsTableData copyWithCompanion(TripsTableCompanion data) {
    return TripsTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      distance: data.distance.present ? data.distance.value : this.distance,
      avgSpeed: data.avgSpeed.present ? data.avgSpeed.value : this.avgSpeed,
      maxSpeed: data.maxSpeed.present ? data.maxSpeed.value : this.maxSpeed,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripsTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('distance: $distance, ')
          ..write('avgSpeed: $avgSpeed, ')
          ..write('maxSpeed: $maxSpeed, ')
          ..write('durationSeconds: $durationSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, startTime, endTime, distance,
      avgSpeed, maxSpeed, durationSeconds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripsTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.distance == this.distance &&
          other.avgSpeed == this.avgSpeed &&
          other.maxSpeed == this.maxSpeed &&
          other.durationSeconds == this.durationSeconds);
}

class TripsTableCompanion extends UpdateCompanion<TripsTableData> {
  final Value<int> id;
  final Value<String?> title;
  final Value<DateTime> startTime;
  final Value<DateTime?> endTime;
  final Value<double> distance;
  final Value<double> avgSpeed;
  final Value<double> maxSpeed;
  final Value<int> durationSeconds;
  const TripsTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.distance = const Value.absent(),
    this.avgSpeed = const Value.absent(),
    this.maxSpeed = const Value.absent(),
    this.durationSeconds = const Value.absent(),
  });
  TripsTableCompanion.insert({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    required DateTime startTime,
    this.endTime = const Value.absent(),
    this.distance = const Value.absent(),
    this.avgSpeed = const Value.absent(),
    this.maxSpeed = const Value.absent(),
    this.durationSeconds = const Value.absent(),
  }) : startTime = Value(startTime);
  static Insertable<TripsTableData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<double>? distance,
    Expression<double>? avgSpeed,
    Expression<double>? maxSpeed,
    Expression<int>? durationSeconds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (distance != null) 'distance': distance,
      if (avgSpeed != null) 'avg_speed': avgSpeed,
      if (maxSpeed != null) 'max_speed': maxSpeed,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
    });
  }

  TripsTableCompanion copyWith(
      {Value<int>? id,
      Value<String?>? title,
      Value<DateTime>? startTime,
      Value<DateTime?>? endTime,
      Value<double>? distance,
      Value<double>? avgSpeed,
      Value<double>? maxSpeed,
      Value<int>? durationSeconds}) {
    return TripsTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      distance: distance ?? this.distance,
      avgSpeed: avgSpeed ?? this.avgSpeed,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (distance.present) {
      map['distance'] = Variable<double>(distance.value);
    }
    if (avgSpeed.present) {
      map['avg_speed'] = Variable<double>(avgSpeed.value);
    }
    if (maxSpeed.present) {
      map['max_speed'] = Variable<double>(maxSpeed.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripsTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('distance: $distance, ')
          ..write('avgSpeed: $avgSpeed, ')
          ..write('maxSpeed: $maxSpeed, ')
          ..write('durationSeconds: $durationSeconds')
          ..write(')'))
        .toString();
  }
}

class $TripPointsTableTable extends TripPointsTable
    with TableInfo<$TripPointsTableTable, TripPointsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripPointsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<int> tripId = GeneratedColumn<int>(
      'trip_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES trips (id) ON DELETE CASCADE'));
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<double> speed = GeneratedColumn<double>(
      'speed', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _accuracyMeta =
      const VerificationMeta('accuracy');
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
      'accuracy', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _altitudeMeta =
      const VerificationMeta('altitude');
  @override
  late final GeneratedColumn<double> altitude = GeneratedColumn<double>(
      'altitude', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, tripId, latitude, longitude, speed, accuracy, altitude, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip_points';
  @override
  VerificationContext validateIntegrity(
      Insertable<TripPointsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('trip_id')) {
      context.handle(_tripIdMeta,
          tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta));
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('speed')) {
      context.handle(
          _speedMeta, speed.isAcceptableOrUnknown(data['speed']!, _speedMeta));
    }
    if (data.containsKey('accuracy')) {
      context.handle(_accuracyMeta,
          accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta));
    }
    if (data.containsKey('altitude')) {
      context.handle(_altitudeMeta,
          altitude.isAcceptableOrUnknown(data['altitude']!, _altitudeMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripPointsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripPointsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      tripId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}trip_id'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude'])!,
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude'])!,
      speed: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}speed'])!,
      accuracy: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}accuracy'])!,
      altitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}altitude'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  $TripPointsTableTable createAlias(String alias) {
    return $TripPointsTableTable(attachedDatabase, alias);
  }
}

class TripPointsTableData extends DataClass
    implements Insertable<TripPointsTableData> {
  final int id;
  final int tripId;
  final double latitude;
  final double longitude;
  final double speed;
  final double accuracy;
  final double altitude;
  final DateTime timestamp;
  const TripPointsTableData(
      {required this.id,
      required this.tripId,
      required this.latitude,
      required this.longitude,
      required this.speed,
      required this.accuracy,
      required this.altitude,
      required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['trip_id'] = Variable<int>(tripId);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['speed'] = Variable<double>(speed);
    map['accuracy'] = Variable<double>(accuracy);
    map['altitude'] = Variable<double>(altitude);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  TripPointsTableCompanion toCompanion(bool nullToAbsent) {
    return TripPointsTableCompanion(
      id: Value(id),
      tripId: Value(tripId),
      latitude: Value(latitude),
      longitude: Value(longitude),
      speed: Value(speed),
      accuracy: Value(accuracy),
      altitude: Value(altitude),
      timestamp: Value(timestamp),
    );
  }

  factory TripPointsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripPointsTableData(
      id: serializer.fromJson<int>(json['id']),
      tripId: serializer.fromJson<int>(json['tripId']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      speed: serializer.fromJson<double>(json['speed']),
      accuracy: serializer.fromJson<double>(json['accuracy']),
      altitude: serializer.fromJson<double>(json['altitude']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tripId': serializer.toJson<int>(tripId),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'speed': serializer.toJson<double>(speed),
      'accuracy': serializer.toJson<double>(accuracy),
      'altitude': serializer.toJson<double>(altitude),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  TripPointsTableData copyWith(
          {int? id,
          int? tripId,
          double? latitude,
          double? longitude,
          double? speed,
          double? accuracy,
          double? altitude,
          DateTime? timestamp}) =>
      TripPointsTableData(
        id: id ?? this.id,
        tripId: tripId ?? this.tripId,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        speed: speed ?? this.speed,
        accuracy: accuracy ?? this.accuracy,
        altitude: altitude ?? this.altitude,
        timestamp: timestamp ?? this.timestamp,
      );
  TripPointsTableData copyWithCompanion(TripPointsTableCompanion data) {
    return TripPointsTableData(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      speed: data.speed.present ? data.speed.value : this.speed,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      altitude: data.altitude.present ? data.altitude.value : this.altitude,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripPointsTableData(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('speed: $speed, ')
          ..write('accuracy: $accuracy, ')
          ..write('altitude: $altitude, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, tripId, latitude, longitude, speed, accuracy, altitude, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripPointsTableData &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.speed == this.speed &&
          other.accuracy == this.accuracy &&
          other.altitude == this.altitude &&
          other.timestamp == this.timestamp);
}

class TripPointsTableCompanion extends UpdateCompanion<TripPointsTableData> {
  final Value<int> id;
  final Value<int> tripId;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double> speed;
  final Value<double> accuracy;
  final Value<double> altitude;
  final Value<DateTime> timestamp;
  const TripPointsTableCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.speed = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.altitude = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  TripPointsTableCompanion.insert({
    this.id = const Value.absent(),
    required int tripId,
    required double latitude,
    required double longitude,
    this.speed = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.altitude = const Value.absent(),
    required DateTime timestamp,
  })  : tripId = Value(tripId),
        latitude = Value(latitude),
        longitude = Value(longitude),
        timestamp = Value(timestamp);
  static Insertable<TripPointsTableData> custom({
    Expression<int>? id,
    Expression<int>? tripId,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? speed,
    Expression<double>? accuracy,
    Expression<double>? altitude,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (speed != null) 'speed': speed,
      if (accuracy != null) 'accuracy': accuracy,
      if (altitude != null) 'altitude': altitude,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  TripPointsTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? tripId,
      Value<double>? latitude,
      Value<double>? longitude,
      Value<double>? speed,
      Value<double>? accuracy,
      Value<double>? altitude,
      Value<DateTime>? timestamp}) {
    return TripPointsTableCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      speed: speed ?? this.speed,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<int>(tripId.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (speed.present) {
      map['speed'] = Variable<double>(speed.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (altitude.present) {
      map['altitude'] = Variable<double>(altitude.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripPointsTableCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('speed: $speed, ')
          ..write('accuracy: $accuracy, ')
          ..write('altitude: $altitude, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

class $DashcamClipsTableTable extends DashcamClipsTable
    with TableInfo<$DashcamClipsTableTable, DashcamClipsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DashcamClipsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<int> tripId = GeneratedColumn<int>(
      'trip_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES trips (id) ON DELETE SET NULL'));
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
      'path', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isLockedMeta =
      const VerificationMeta('isLocked');
  @override
  late final GeneratedColumn<bool> isLocked = GeneratedColumn<bool>(
      'is_locked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_locked" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sizeBytesMeta =
      const VerificationMeta('sizeBytes');
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
      'size_bytes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, tripId, path, createdAt, isLocked, sizeBytes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dashcam_clips';
  @override
  VerificationContext validateIntegrity(
      Insertable<DashcamClipsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('trip_id')) {
      context.handle(_tripIdMeta,
          tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta));
    }
    if (data.containsKey('path')) {
      context.handle(
          _pathMeta, path.isAcceptableOrUnknown(data['path']!, _pathMeta));
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_locked')) {
      context.handle(_isLockedMeta,
          isLocked.isAcceptableOrUnknown(data['is_locked']!, _isLockedMeta));
    }
    if (data.containsKey('size_bytes')) {
      context.handle(_sizeBytesMeta,
          sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DashcamClipsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DashcamClipsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      tripId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}trip_id']),
      path: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}path'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      isLocked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_locked'])!,
      sizeBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}size_bytes'])!,
    );
  }

  @override
  $DashcamClipsTableTable createAlias(String alias) {
    return $DashcamClipsTableTable(attachedDatabase, alias);
  }
}

class DashcamClipsTableData extends DataClass
    implements Insertable<DashcamClipsTableData> {
  final int id;
  final int? tripId;
  final String path;
  final DateTime createdAt;
  final bool isLocked;
  final int sizeBytes;
  const DashcamClipsTableData(
      {required this.id,
      this.tripId,
      required this.path,
      required this.createdAt,
      required this.isLocked,
      required this.sizeBytes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || tripId != null) {
      map['trip_id'] = Variable<int>(tripId);
    }
    map['path'] = Variable<String>(path);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_locked'] = Variable<bool>(isLocked);
    map['size_bytes'] = Variable<int>(sizeBytes);
    return map;
  }

  DashcamClipsTableCompanion toCompanion(bool nullToAbsent) {
    return DashcamClipsTableCompanion(
      id: Value(id),
      tripId:
          tripId == null && nullToAbsent ? const Value.absent() : Value(tripId),
      path: Value(path),
      createdAt: Value(createdAt),
      isLocked: Value(isLocked),
      sizeBytes: Value(sizeBytes),
    );
  }

  factory DashcamClipsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DashcamClipsTableData(
      id: serializer.fromJson<int>(json['id']),
      tripId: serializer.fromJson<int?>(json['tripId']),
      path: serializer.fromJson<String>(json['path']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isLocked: serializer.fromJson<bool>(json['isLocked']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tripId': serializer.toJson<int?>(tripId),
      'path': serializer.toJson<String>(path),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isLocked': serializer.toJson<bool>(isLocked),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
    };
  }

  DashcamClipsTableData copyWith(
          {int? id,
          Value<int?> tripId = const Value.absent(),
          String? path,
          DateTime? createdAt,
          bool? isLocked,
          int? sizeBytes}) =>
      DashcamClipsTableData(
        id: id ?? this.id,
        tripId: tripId.present ? tripId.value : this.tripId,
        path: path ?? this.path,
        createdAt: createdAt ?? this.createdAt,
        isLocked: isLocked ?? this.isLocked,
        sizeBytes: sizeBytes ?? this.sizeBytes,
      );
  DashcamClipsTableData copyWithCompanion(DashcamClipsTableCompanion data) {
    return DashcamClipsTableData(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      path: data.path.present ? data.path.value : this.path,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isLocked: data.isLocked.present ? data.isLocked.value : this.isLocked,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DashcamClipsTableData(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('path: $path, ')
          ..write('createdAt: $createdAt, ')
          ..write('isLocked: $isLocked, ')
          ..write('sizeBytes: $sizeBytes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, tripId, path, createdAt, isLocked, sizeBytes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DashcamClipsTableData &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.path == this.path &&
          other.createdAt == this.createdAt &&
          other.isLocked == this.isLocked &&
          other.sizeBytes == this.sizeBytes);
}

class DashcamClipsTableCompanion
    extends UpdateCompanion<DashcamClipsTableData> {
  final Value<int> id;
  final Value<int?> tripId;
  final Value<String> path;
  final Value<DateTime> createdAt;
  final Value<bool> isLocked;
  final Value<int> sizeBytes;
  const DashcamClipsTableCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.path = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.sizeBytes = const Value.absent(),
  });
  DashcamClipsTableCompanion.insert({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    required String path,
    required DateTime createdAt,
    this.isLocked = const Value.absent(),
    this.sizeBytes = const Value.absent(),
  })  : path = Value(path),
        createdAt = Value(createdAt);
  static Insertable<DashcamClipsTableData> custom({
    Expression<int>? id,
    Expression<int>? tripId,
    Expression<String>? path,
    Expression<DateTime>? createdAt,
    Expression<bool>? isLocked,
    Expression<int>? sizeBytes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (path != null) 'path': path,
      if (createdAt != null) 'created_at': createdAt,
      if (isLocked != null) 'is_locked': isLocked,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
    });
  }

  DashcamClipsTableCompanion copyWith(
      {Value<int>? id,
      Value<int?>? tripId,
      Value<String>? path,
      Value<DateTime>? createdAt,
      Value<bool>? isLocked,
      Value<int>? sizeBytes}) {
    return DashcamClipsTableCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      path: path ?? this.path,
      createdAt: createdAt ?? this.createdAt,
      isLocked: isLocked ?? this.isLocked,
      sizeBytes: sizeBytes ?? this.sizeBytes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<int>(tripId.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isLocked.present) {
      map['is_locked'] = Variable<bool>(isLocked.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DashcamClipsTableCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('path: $path, ')
          ..write('createdAt: $createdAt, ')
          ..write('isLocked: $isLocked, ')
          ..write('sizeBytes: $sizeBytes')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TripsTableTable tripsTable = $TripsTableTable(this);
  late final $TripPointsTableTable tripPointsTable =
      $TripPointsTableTable(this);
  late final $DashcamClipsTableTable dashcamClipsTable =
      $DashcamClipsTableTable(this);
  late final TripDao tripDao = TripDao(this as AppDatabase);
  late final TripPointDao tripPointDao = TripPointDao(this as AppDatabase);
  late final DashcamClipDao dashcamClipDao =
      DashcamClipDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [tripsTable, tripPointsTable, dashcamClipsTable];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('trips',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('trip_points', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('trips',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('dashcam_clips', kind: UpdateKind.update),
            ],
          ),
        ],
      );
}

typedef $$TripsTableTableCreateCompanionBuilder = TripsTableCompanion Function({
  Value<int> id,
  Value<String?> title,
  required DateTime startTime,
  Value<DateTime?> endTime,
  Value<double> distance,
  Value<double> avgSpeed,
  Value<double> maxSpeed,
  Value<int> durationSeconds,
});
typedef $$TripsTableTableUpdateCompanionBuilder = TripsTableCompanion Function({
  Value<int> id,
  Value<String?> title,
  Value<DateTime> startTime,
  Value<DateTime?> endTime,
  Value<double> distance,
  Value<double> avgSpeed,
  Value<double> maxSpeed,
  Value<int> durationSeconds,
});

final class $$TripsTableTableReferences
    extends BaseReferences<_$AppDatabase, $TripsTableTable, TripsTableData> {
  $$TripsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TripPointsTableTable, List<TripPointsTableData>>
      _tripPointsTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.tripPointsTable,
              aliasName: $_aliasNameGenerator(
                  db.tripsTable.id, db.tripPointsTable.tripId));

  $$TripPointsTableTableProcessedTableManager get tripPointsTableRefs {
    final manager =
        $$TripPointsTableTableTableManager($_db, $_db.tripPointsTable)
            .filter((f) => f.tripId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_tripPointsTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$DashcamClipsTableTable,
      List<DashcamClipsTableData>> _dashcamClipsTableRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.dashcamClipsTable,
          aliasName: $_aliasNameGenerator(
              db.tripsTable.id, db.dashcamClipsTable.tripId));

  $$DashcamClipsTableTableProcessedTableManager get dashcamClipsTableRefs {
    final manager =
        $$DashcamClipsTableTableTableManager($_db, $_db.dashcamClipsTable)
            .filter((f) => f.tripId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_dashcamClipsTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TripsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TripsTableTable> {
  $$TripsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get distance => $composableBuilder(
      column: $table.distance, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get avgSpeed => $composableBuilder(
      column: $table.avgSpeed, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get maxSpeed => $composableBuilder(
      column: $table.maxSpeed, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnFilters(column));

  Expression<bool> tripPointsTableRefs(
      Expression<bool> Function($$TripPointsTableTableFilterComposer f) f) {
    final $$TripPointsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tripPointsTable,
        getReferencedColumn: (t) => t.tripId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TripPointsTableTableFilterComposer(
              $db: $db,
              $table: $db.tripPointsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> dashcamClipsTableRefs(
      Expression<bool> Function($$DashcamClipsTableTableFilterComposer f) f) {
    final $$DashcamClipsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dashcamClipsTable,
        getReferencedColumn: (t) => t.tripId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DashcamClipsTableTableFilterComposer(
              $db: $db,
              $table: $db.dashcamClipsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TripsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TripsTableTable> {
  $$TripsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get distance => $composableBuilder(
      column: $table.distance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get avgSpeed => $composableBuilder(
      column: $table.avgSpeed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get maxSpeed => $composableBuilder(
      column: $table.maxSpeed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnOrderings(column));
}

class $$TripsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripsTableTable> {
  $$TripsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<double> get distance =>
      $composableBuilder(column: $table.distance, builder: (column) => column);

  GeneratedColumn<double> get avgSpeed =>
      $composableBuilder(column: $table.avgSpeed, builder: (column) => column);

  GeneratedColumn<double> get maxSpeed =>
      $composableBuilder(column: $table.maxSpeed, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds, builder: (column) => column);

  Expression<T> tripPointsTableRefs<T extends Object>(
      Expression<T> Function($$TripPointsTableTableAnnotationComposer a) f) {
    final $$TripPointsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tripPointsTable,
        getReferencedColumn: (t) => t.tripId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TripPointsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.tripPointsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> dashcamClipsTableRefs<T extends Object>(
      Expression<T> Function($$DashcamClipsTableTableAnnotationComposer a) f) {
    final $$DashcamClipsTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.dashcamClipsTable,
            getReferencedColumn: (t) => t.tripId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DashcamClipsTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.dashcamClipsTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$TripsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TripsTableTable,
    TripsTableData,
    $$TripsTableTableFilterComposer,
    $$TripsTableTableOrderingComposer,
    $$TripsTableTableAnnotationComposer,
    $$TripsTableTableCreateCompanionBuilder,
    $$TripsTableTableUpdateCompanionBuilder,
    (TripsTableData, $$TripsTableTableReferences),
    TripsTableData,
    PrefetchHooks Function(
        {bool tripPointsTableRefs, bool dashcamClipsTableRefs})> {
  $$TripsTableTableTableManager(_$AppDatabase db, $TripsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<DateTime> startTime = const Value.absent(),
            Value<DateTime?> endTime = const Value.absent(),
            Value<double> distance = const Value.absent(),
            Value<double> avgSpeed = const Value.absent(),
            Value<double> maxSpeed = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
          }) =>
              TripsTableCompanion(
            id: id,
            title: title,
            startTime: startTime,
            endTime: endTime,
            distance: distance,
            avgSpeed: avgSpeed,
            maxSpeed: maxSpeed,
            durationSeconds: durationSeconds,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> title = const Value.absent(),
            required DateTime startTime,
            Value<DateTime?> endTime = const Value.absent(),
            Value<double> distance = const Value.absent(),
            Value<double> avgSpeed = const Value.absent(),
            Value<double> maxSpeed = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
          }) =>
              TripsTableCompanion.insert(
            id: id,
            title: title,
            startTime: startTime,
            endTime: endTime,
            distance: distance,
            avgSpeed: avgSpeed,
            maxSpeed: maxSpeed,
            durationSeconds: durationSeconds,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TripsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {tripPointsTableRefs = false, dashcamClipsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (tripPointsTableRefs) db.tripPointsTable,
                if (dashcamClipsTableRefs) db.dashcamClipsTable
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tripPointsTableRefs)
                    await $_getPrefetchedData<TripsTableData, $TripsTableTable,
                            TripPointsTableData>(
                        currentTable: table,
                        referencedTable: $$TripsTableTableReferences
                            ._tripPointsTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TripsTableTableReferences(db, table, p0)
                                .tripPointsTableRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.tripId == item.id),
                        typedResults: items),
                  if (dashcamClipsTableRefs)
                    await $_getPrefetchedData<TripsTableData, $TripsTableTable,
                            DashcamClipsTableData>(
                        currentTable: table,
                        referencedTable: $$TripsTableTableReferences
                            ._dashcamClipsTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TripsTableTableReferences(db, table, p0)
                                .dashcamClipsTableRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.tripId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TripsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TripsTableTable,
    TripsTableData,
    $$TripsTableTableFilterComposer,
    $$TripsTableTableOrderingComposer,
    $$TripsTableTableAnnotationComposer,
    $$TripsTableTableCreateCompanionBuilder,
    $$TripsTableTableUpdateCompanionBuilder,
    (TripsTableData, $$TripsTableTableReferences),
    TripsTableData,
    PrefetchHooks Function(
        {bool tripPointsTableRefs, bool dashcamClipsTableRefs})>;
typedef $$TripPointsTableTableCreateCompanionBuilder = TripPointsTableCompanion
    Function({
  Value<int> id,
  required int tripId,
  required double latitude,
  required double longitude,
  Value<double> speed,
  Value<double> accuracy,
  Value<double> altitude,
  required DateTime timestamp,
});
typedef $$TripPointsTableTableUpdateCompanionBuilder = TripPointsTableCompanion
    Function({
  Value<int> id,
  Value<int> tripId,
  Value<double> latitude,
  Value<double> longitude,
  Value<double> speed,
  Value<double> accuracy,
  Value<double> altitude,
  Value<DateTime> timestamp,
});

final class $$TripPointsTableTableReferences extends BaseReferences<
    _$AppDatabase, $TripPointsTableTable, TripPointsTableData> {
  $$TripPointsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TripsTableTable _tripIdTable(_$AppDatabase db) =>
      db.tripsTable.createAlias(
          $_aliasNameGenerator(db.tripPointsTable.tripId, db.tripsTable.id));

  $$TripsTableTableProcessedTableManager get tripId {
    final $_column = $_itemColumn<int>('trip_id')!;

    final manager = $$TripsTableTableTableManager($_db, $_db.tripsTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TripPointsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TripPointsTableTable> {
  $$TripPointsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get speed => $composableBuilder(
      column: $table.speed, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get accuracy => $composableBuilder(
      column: $table.accuracy, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get altitude => $composableBuilder(
      column: $table.altitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  $$TripsTableTableFilterComposer get tripId {
    final $$TripsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tripId,
        referencedTable: $db.tripsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TripsTableTableFilterComposer(
              $db: $db,
              $table: $db.tripsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TripPointsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TripPointsTableTable> {
  $$TripPointsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get speed => $composableBuilder(
      column: $table.speed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get accuracy => $composableBuilder(
      column: $table.accuracy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get altitude => $composableBuilder(
      column: $table.altitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  $$TripsTableTableOrderingComposer get tripId {
    final $$TripsTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tripId,
        referencedTable: $db.tripsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TripsTableTableOrderingComposer(
              $db: $db,
              $table: $db.tripsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TripPointsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripPointsTableTable> {
  $$TripPointsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<double> get altitude =>
      $composableBuilder(column: $table.altitude, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  $$TripsTableTableAnnotationComposer get tripId {
    final $$TripsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tripId,
        referencedTable: $db.tripsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TripsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.tripsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TripPointsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TripPointsTableTable,
    TripPointsTableData,
    $$TripPointsTableTableFilterComposer,
    $$TripPointsTableTableOrderingComposer,
    $$TripPointsTableTableAnnotationComposer,
    $$TripPointsTableTableCreateCompanionBuilder,
    $$TripPointsTableTableUpdateCompanionBuilder,
    (TripPointsTableData, $$TripPointsTableTableReferences),
    TripPointsTableData,
    PrefetchHooks Function({bool tripId})> {
  $$TripPointsTableTableTableManager(
      _$AppDatabase db, $TripPointsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripPointsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripPointsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripPointsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> tripId = const Value.absent(),
            Value<double> latitude = const Value.absent(),
            Value<double> longitude = const Value.absent(),
            Value<double> speed = const Value.absent(),
            Value<double> accuracy = const Value.absent(),
            Value<double> altitude = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
          }) =>
              TripPointsTableCompanion(
            id: id,
            tripId: tripId,
            latitude: latitude,
            longitude: longitude,
            speed: speed,
            accuracy: accuracy,
            altitude: altitude,
            timestamp: timestamp,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int tripId,
            required double latitude,
            required double longitude,
            Value<double> speed = const Value.absent(),
            Value<double> accuracy = const Value.absent(),
            Value<double> altitude = const Value.absent(),
            required DateTime timestamp,
          }) =>
              TripPointsTableCompanion.insert(
            id: id,
            tripId: tripId,
            latitude: latitude,
            longitude: longitude,
            speed: speed,
            accuracy: accuracy,
            altitude: altitude,
            timestamp: timestamp,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TripPointsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({tripId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (tripId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.tripId,
                    referencedTable:
                        $$TripPointsTableTableReferences._tripIdTable(db),
                    referencedColumn:
                        $$TripPointsTableTableReferences._tripIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TripPointsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TripPointsTableTable,
    TripPointsTableData,
    $$TripPointsTableTableFilterComposer,
    $$TripPointsTableTableOrderingComposer,
    $$TripPointsTableTableAnnotationComposer,
    $$TripPointsTableTableCreateCompanionBuilder,
    $$TripPointsTableTableUpdateCompanionBuilder,
    (TripPointsTableData, $$TripPointsTableTableReferences),
    TripPointsTableData,
    PrefetchHooks Function({bool tripId})>;
typedef $$DashcamClipsTableTableCreateCompanionBuilder
    = DashcamClipsTableCompanion Function({
  Value<int> id,
  Value<int?> tripId,
  required String path,
  required DateTime createdAt,
  Value<bool> isLocked,
  Value<int> sizeBytes,
});
typedef $$DashcamClipsTableTableUpdateCompanionBuilder
    = DashcamClipsTableCompanion Function({
  Value<int> id,
  Value<int?> tripId,
  Value<String> path,
  Value<DateTime> createdAt,
  Value<bool> isLocked,
  Value<int> sizeBytes,
});

final class $$DashcamClipsTableTableReferences extends BaseReferences<
    _$AppDatabase, $DashcamClipsTableTable, DashcamClipsTableData> {
  $$DashcamClipsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TripsTableTable _tripIdTable(_$AppDatabase db) =>
      db.tripsTable.createAlias(
          $_aliasNameGenerator(db.dashcamClipsTable.tripId, db.tripsTable.id));

  $$TripsTableTableProcessedTableManager? get tripId {
    final $_column = $_itemColumn<int>('trip_id');
    if ($_column == null) return null;
    final manager = $$TripsTableTableTableManager($_db, $_db.tripsTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DashcamClipsTableTableFilterComposer
    extends Composer<_$AppDatabase, $DashcamClipsTableTable> {
  $$DashcamClipsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isLocked => $composableBuilder(
      column: $table.isLocked, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sizeBytes => $composableBuilder(
      column: $table.sizeBytes, builder: (column) => ColumnFilters(column));

  $$TripsTableTableFilterComposer get tripId {
    final $$TripsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tripId,
        referencedTable: $db.tripsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TripsTableTableFilterComposer(
              $db: $db,
              $table: $db.tripsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DashcamClipsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DashcamClipsTableTable> {
  $$DashcamClipsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isLocked => $composableBuilder(
      column: $table.isLocked, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
      column: $table.sizeBytes, builder: (column) => ColumnOrderings(column));

  $$TripsTableTableOrderingComposer get tripId {
    final $$TripsTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tripId,
        referencedTable: $db.tripsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TripsTableTableOrderingComposer(
              $db: $db,
              $table: $db.tripsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DashcamClipsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DashcamClipsTableTable> {
  $$DashcamClipsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isLocked =>
      $composableBuilder(column: $table.isLocked, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  $$TripsTableTableAnnotationComposer get tripId {
    final $$TripsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tripId,
        referencedTable: $db.tripsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TripsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.tripsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DashcamClipsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DashcamClipsTableTable,
    DashcamClipsTableData,
    $$DashcamClipsTableTableFilterComposer,
    $$DashcamClipsTableTableOrderingComposer,
    $$DashcamClipsTableTableAnnotationComposer,
    $$DashcamClipsTableTableCreateCompanionBuilder,
    $$DashcamClipsTableTableUpdateCompanionBuilder,
    (DashcamClipsTableData, $$DashcamClipsTableTableReferences),
    DashcamClipsTableData,
    PrefetchHooks Function({bool tripId})> {
  $$DashcamClipsTableTableTableManager(
      _$AppDatabase db, $DashcamClipsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DashcamClipsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DashcamClipsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DashcamClipsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> tripId = const Value.absent(),
            Value<String> path = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isLocked = const Value.absent(),
            Value<int> sizeBytes = const Value.absent(),
          }) =>
              DashcamClipsTableCompanion(
            id: id,
            tripId: tripId,
            path: path,
            createdAt: createdAt,
            isLocked: isLocked,
            sizeBytes: sizeBytes,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> tripId = const Value.absent(),
            required String path,
            required DateTime createdAt,
            Value<bool> isLocked = const Value.absent(),
            Value<int> sizeBytes = const Value.absent(),
          }) =>
              DashcamClipsTableCompanion.insert(
            id: id,
            tripId: tripId,
            path: path,
            createdAt: createdAt,
            isLocked: isLocked,
            sizeBytes: sizeBytes,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DashcamClipsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({tripId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (tripId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.tripId,
                    referencedTable:
                        $$DashcamClipsTableTableReferences._tripIdTable(db),
                    referencedColumn:
                        $$DashcamClipsTableTableReferences._tripIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$DashcamClipsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DashcamClipsTableTable,
    DashcamClipsTableData,
    $$DashcamClipsTableTableFilterComposer,
    $$DashcamClipsTableTableOrderingComposer,
    $$DashcamClipsTableTableAnnotationComposer,
    $$DashcamClipsTableTableCreateCompanionBuilder,
    $$DashcamClipsTableTableUpdateCompanionBuilder,
    (DashcamClipsTableData, $$DashcamClipsTableTableReferences),
    DashcamClipsTableData,
    PrefetchHooks Function({bool tripId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TripsTableTableTableManager get tripsTable =>
      $$TripsTableTableTableManager(_db, _db.tripsTable);
  $$TripPointsTableTableTableManager get tripPointsTable =>
      $$TripPointsTableTableTableManager(_db, _db.tripPointsTable);
  $$DashcamClipsTableTableTableManager get dashcamClipsTable =>
      $$DashcamClipsTableTableTableManager(_db, _db.dashcamClipsTable);
}

mixin _$TripDaoMixin on DatabaseAccessor<AppDatabase> {
  $TripsTableTable get tripsTable => attachedDatabase.tripsTable;
  $TripPointsTableTable get tripPointsTable => attachedDatabase.tripPointsTable;
  TripDaoManager get managers => TripDaoManager(this);
}

class TripDaoManager {
  final _$TripDaoMixin _db;
  TripDaoManager(this._db);
  $$TripsTableTableTableManager get tripsTable =>
      $$TripsTableTableTableManager(_db.attachedDatabase, _db.tripsTable);
  $$TripPointsTableTableTableManager get tripPointsTable =>
      $$TripPointsTableTableTableManager(
          _db.attachedDatabase, _db.tripPointsTable);
}

mixin _$TripPointDaoMixin on DatabaseAccessor<AppDatabase> {
  $TripsTableTable get tripsTable => attachedDatabase.tripsTable;
  $TripPointsTableTable get tripPointsTable => attachedDatabase.tripPointsTable;
  TripPointDaoManager get managers => TripPointDaoManager(this);
}

class TripPointDaoManager {
  final _$TripPointDaoMixin _db;
  TripPointDaoManager(this._db);
  $$TripsTableTableTableManager get tripsTable =>
      $$TripsTableTableTableManager(_db.attachedDatabase, _db.tripsTable);
  $$TripPointsTableTableTableManager get tripPointsTable =>
      $$TripPointsTableTableTableManager(
          _db.attachedDatabase, _db.tripPointsTable);
}

mixin _$DashcamClipDaoMixin on DatabaseAccessor<AppDatabase> {
  $TripsTableTable get tripsTable => attachedDatabase.tripsTable;
  $DashcamClipsTableTable get dashcamClipsTable =>
      attachedDatabase.dashcamClipsTable;
  DashcamClipDaoManager get managers => DashcamClipDaoManager(this);
}

class DashcamClipDaoManager {
  final _$DashcamClipDaoMixin _db;
  DashcamClipDaoManager(this._db);
  $$TripsTableTableTableManager get tripsTable =>
      $$TripsTableTableTableManager(_db.attachedDatabase, _db.tripsTable);
  $$DashcamClipsTableTableTableManager get dashcamClipsTable =>
      $$DashcamClipsTableTableTableManager(
          _db.attachedDatabase, _db.dashcamClipsTable);
}
