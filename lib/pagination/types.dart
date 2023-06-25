import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'bloc/pagination_bloc.dart';

typedef Converter<T> = FutureOr<T> Function(DocumentSnapshot snapshot);

typedef StateChange<T extends PaginationState> = Widget Function(
    BuildContext context, T state);
typedef PaginationItemBuilder<T> = Widget Function(
    BuildContext context, PaginationSuccess<T> state, int index);
