import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../types.dart';

part 'pagination_event.dart';
part 'pagination_state.dart';

class PaginationBloc<T> extends Bloc<PaginationEvent, PaginationState> {
  PaginationBloc(this.query, this.converter, {this.limit = 20})
      : super(PaginationInitial()) {
    _addListener();
  }

  Converter<T> converter;
  int limit;
  Query query;

  StreamSubscription<QuerySnapshot> _listener;

  @override
  Future<void> close() {
    _listener?.cancel();
    return super.close();
  }

  @override
  Stream<PaginationState> mapEventToState(
    PaginationEvent event,
  ) async* {
    final currentState = state;

    if (currentState is PaginationSuccess<T>) {
      if (event is PaginationRefreshEvent) {
        yield PaginationUpdate<T>.fromSuccess(currentState);
      } else if (event is PaginationModified) {
        var converted = await converter(event.document);
        if (event is PaginationAdded) {
          currentState.data.insert(0, converted);
        } else if (event is PaginationRemoved) {
          currentState.data.remove(converted);
        } else {
          var index =
              currentState.data.indexWhere((element) => element == converted);
          if (index >= 0) {
            print(index);
            currentState.data[index] = converted;
          }
        }
        yield PaginationUpdate<T>.fromSuccess(currentState);
      }
    }
    if (event is PaginationFetched && !_hasReachedMax(currentState)) {
      try {
        if (currentState is PaginationInitial) {
          var rawdata = event.documents;
          if (rawdata == null) rawdata = await _fetchPaginations(null, limit);
          final last = rawdata.isNotEmpty ? rawdata.last : null;

          final data = <T>[];
          for (var raw in rawdata) {
            var converted = await converter(raw);
            data.add(converted);
          }
          yield PaginationSuccess<T>(
              data: data,
              hasReachedMax: data.length < limit,
              lastSnapshot: last);
        } else if (currentState is PaginationSuccess<T>) {
          yield* _mapPaginationSuccess(currentState);
        }
      } catch (_) {
        yield PaginationFailure();
      }
    }
  }

  void _addListener() {
    if (_listener != null) return;
    _listener = query.snapshots().listen((event) async {
      // return;
      if (state is PaginationInitial) {
        add(PaginationFetched(
            documents: event.docChanges.map((e) => e.doc).toList()));
      } else {
        for (var change in event.docChanges) {
          if (change.type == DocumentChangeType.added)
            add(PaginationAdded(change.doc));
          else if (change.type == DocumentChangeType.modified) {
            add(PaginationModified(change.doc));
          } else if (change.type == DocumentChangeType.removed) {
            add(PaginationRemoved(change.doc));
          }
        }
      }
    });
  }

  Stream<PaginationSuccess<T>> _mapPaginationSuccess(
      PaginationSuccess<T> currentState) async* {
    final rawdata = await _fetchPaginations(currentState.lastSnapshot, limit);
    final last = rawdata.isNotEmpty ? rawdata.last : currentState.lastSnapshot;

    final data = <T>[];
    for (var raw in rawdata) {
      var converted = await converter(raw);
      data.add(converted);
    }
    if (data.isEmpty) {
      yield currentState.copyWith(hasReachedMax: true, lastSnapshot: last);
    } else
      yield PaginationSuccess<T>(
        data: currentState.data + data,
        lastSnapshot: last,
        hasReachedMax: false,
      );
  }

  bool _hasReachedMax(PaginationState state) =>
      state is PaginationSuccess && state.hasReachedMax;

  Future<List<QueryDocumentSnapshot>> _fetchPaginations(
      DocumentSnapshot startAfter, int limit) async {
    var q = query;
    if (startAfter != null) q = q.startAfterDocument(startAfter);

    var snapshot = await q.limit(limit).get();
    // .catchError(() {
    //   throw Exception('error fetching data');
    // });

    return snapshot.docs;
  }

  // @override
  // Stream<Transition<PaginationEvent, PaginationState>> transformEvents(
  //   Stream<PaginationEvent> events,
  //   TransitionFunction<PaginationEvent, PaginationState> transitionFn,
  // ) {
  //   return super.transformEvents(
  //     events.debounceTime(const Duration(milliseconds: 500)),
  //     transitionFn,
  //   );
  // }

}
