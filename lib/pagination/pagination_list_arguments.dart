import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'bloc/pagination_bloc.dart';
import 'types.dart';

class PaginationArgs<T> {
  PaginationArgs({
    @required this.query,
    @required this.converter,
    @required this.loadingWidget,
    this.limit = 20,
    this.maxReachedWidget,
    this.scrollController,
    this.onInitial,
    this.onFailure,
    this.onSuccess,
    this.onEmpty,
    this.buildList,
    this.buildItem,
    this.customBuilder,
    this.reverse,
    this.shrinkWrap,
    this.physics,
  });

  final Converter<T> converter;
  final int limit;
  final Query query;

  final StateChange<PaginationInitial> onInitial;
  final StateChange<PaginationFailure> onFailure;
  final StateChange<PaginationSuccess<T>> onSuccess;
  final StateChange<PaginationSuccess<T>> onEmpty;
  final StateChange<PaginationSuccess<T>> buildList;
  final StateChange<PaginationState> customBuilder;
  final PaginationItemBuilder<T> buildItem;
  final Widget loadingWidget;
  final Widget maxReachedWidget;
  final ScrollController scrollController;
  final bool reverse;
  final bool shrinkWrap;
  final ScrollPhysics physics;

  PaginationArgs<T> copyWith({
    Converter<T> converter,
    int limit,
    Query query,
    StateChange<PaginationInitial> onInitial,
    StateChange<PaginationFailure> onFailure,
    StateChange<PaginationSuccess<T>> onSuccess,
    StateChange<PaginationSuccess<T>> onEmpty,
    StateChange<PaginationSuccess<T>> buildList,
    StateChange<PaginationState> customBuilder,
    PaginationItemBuilder<T> buildItem,
    Widget loadingWidget,
    Widget maxReachedWidget,
    ScrollController scrollController,
    bool reverse,
    bool shrinkWrap,
    ScrollPhysics physics,
  }) {
    return PaginationArgs<T>(
      converter: converter ?? this.converter,
      limit: limit ?? this.limit,
      query: query ?? this.query,
      onInitial: onInitial ?? this.onInitial,
      onFailure: onFailure ?? this.onFailure,
      onSuccess: onSuccess ?? this.onSuccess,
      onEmpty: onEmpty ?? this.onEmpty,
      buildList: buildList ?? this.buildList,
      customBuilder: customBuilder ?? this.customBuilder,
      buildItem: buildItem ?? this.buildItem,
      loadingWidget: loadingWidget ?? this.loadingWidget,
      maxReachedWidget: maxReachedWidget ?? this.maxReachedWidget,
      scrollController: scrollController ?? this.scrollController,
      reverse: reverse ?? this.reverse,
      shrinkWrap: shrinkWrap ?? this.shrinkWrap,
      physics: physics ?? this.physics,
    );
  }
}
