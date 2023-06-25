part of 'pagination_bloc.dart';

abstract class PaginationEvent extends Equatable {
  const PaginationEvent();

  @override
  List<Object> get props => [];
}

class PaginationFetched extends PaginationEvent {
  final List<DocumentSnapshot> documents;

  PaginationFetched({this.documents});
  @override
  List<Object> get props => [documents];
}

class PaginationRefreshEvent extends PaginationEvent {}

class PaginationModified<T> extends PaginationEvent {
  final T document;
  PaginationModified(this.document);

  PaginationModified<T> copyWith({
    T document,
  }) {
    return PaginationModified<T>(
      document ?? this.document,
    );
  }

  @override
  String toString() => 'PaginationModified(document: $document)';
}

class PaginationAdded<T> extends PaginationModified<T> {
  PaginationAdded(T document) : super(document);

  PaginationAdded<T> copyWith({
    T document,
  }) {
    return PaginationAdded<T>(
      document ?? this.document,
    );
  }

  @override
  String toString() => 'PaginationAdded(document: $document)';
}

class PaginationRemoved<T> extends PaginationModified<T> {
  PaginationRemoved(T document) : super(document);

  PaginationRemoved<T> copyWith({
    T document,
  }) {
    return PaginationRemoved<T>(
      document ?? this.document,
    );
  }

  @override
  String toString() => 'PaginationRemoved(document: $document)';
}
