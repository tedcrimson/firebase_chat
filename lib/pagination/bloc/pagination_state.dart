part of 'pagination_bloc.dart';

abstract class PaginationState extends Equatable {
  const PaginationState();

  @override
  List<Object> get props => [];
}

class PaginationNotInitial extends PaginationState {}

class PaginationInitial extends PaginationState {}

class PaginationFailure extends PaginationState {}

class PaginationSuccess<T> extends PaginationState {
  final List<T> data;
  final bool hasReachedMax;
  final DocumentSnapshot lastSnapshot;
  const PaginationSuccess({
    this.data,
    this.lastSnapshot,
    this.hasReachedMax,
  });

  PaginationSuccess<T> copyWith({
    List<T> data,
    bool hasReachedMax,
    DocumentSnapshot lastSnapshot,
  }) {
    return PaginationSuccess<T>(
      data: data ?? this.data,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      lastSnapshot: lastSnapshot ?? this.lastSnapshot,
    );
  }

  @override
  List<Object> get props => [data, hasReachedMax, lastSnapshot];

  @override
  String toString() =>
      'PaginationSuccess { data: ${data.length}, hasReachedMax: $hasReachedMax }';
}

class PaginationUpdate<T> extends PaginationSuccess<T> {
  const PaginationUpdate({
    this.updateTime,
    List<T> data,
    DocumentSnapshot lastSnapshot,
    bool hasReachedMax,
  }) : super(
            data: data,
            lastSnapshot: lastSnapshot,
            hasReachedMax: hasReachedMax);

  factory PaginationUpdate.fromSuccess(PaginationSuccess<T> success) {
    return PaginationUpdate(
      updateTime: DateTime.now(),
      data: success.data,
      lastSnapshot: success.lastSnapshot,
      hasReachedMax: success.hasReachedMax,
    );
  }
  final DateTime updateTime;
  PaginationUpdate<T> copyWith({
    DateTime updateTime,
    List<T> data,
    bool hasReachedMax,
    DocumentSnapshot lastSnapshot,
  }) {
    return PaginationUpdate<T>(
      updateTime: updateTime ?? this.updateTime,
      data: data ?? this.data,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      lastSnapshot: lastSnapshot ?? this.lastSnapshot,
    );
  }

  @override
  List<Object> get props => [updateTime, data, hasReachedMax, lastSnapshot];

  @override
  String toString() => 'PaginationUpdate { data: ${data.length} }';
}
