import 'package:firebase_chat/pagination/pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaginationList<T> extends StatefulWidget {
  PaginationList({@required this.arguments, this.paginationBloc});

  final PaginationArgs<T> arguments;
  final PaginationBloc<T> paginationBloc;
  @override
  _PaginationListState<T> createState() {
    return _PaginationListState<T>();
  }
}

class _PaginationListState<T> extends State<PaginationList<T>> {
  PaginationArgs<T> args;
  PaginationBloc<T> paginationBloc;
  ScrollController scrollController;

  @override
  void dispose() {
    paginationBloc.close();
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    args = widget.arguments;
    paginationBloc = widget.paginationBloc ??
        PaginationBloc<T>(
          args.query,
          args.converter,
          limit: args.limit,
        );

    scrollController = args.scrollController ?? ScrollController();
    scrollController.addListener(_onScroll);
    super.initState();
  }

  void _onScroll() {
    if (scrollController.position.atEdge) {
      if (scrollController.position.pixels == 0) {
        // print("Top");
      } else {
        // print("Bottom");
        paginationBloc.add(PaginationFetched());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaginationBloc<T>, PaginationState>(
      bloc: paginationBloc,
      builder: (BuildContext context, PaginationState state) {
        if (args.customBuilder != null)
          return args.customBuilder(context, state);
        if (state is PaginationInitial) {
          if (args.onInitial != null)
            return args.onInitial(context, state);
          else
            return Center(child: Text('implement initial widget'));
        }
        if (state is PaginationFailure) {
          if (args.onFailure != null)
            return args.onFailure(context, state);
          else
            return Center(child: Text('implement failure widget'));
        }
        if (state is PaginationSuccess<T>) {
          var data = state.data;
          if (data.isEmpty) {
            if (args.onEmpty != null)
              return args.onEmpty(context, state);
            else
              return Center(child: Text('implement empty widget'));
          }
          if (args.buildList != null) {
            return args.buildList(context, state);
          } else
            return ListView.builder(
              physics: args.physics,
              shrinkWrap: args.shrinkWrap,
              reverse: args.reverse,
              itemBuilder: (BuildContext context, int index) {
                if (index >= data.length) {
                  if (state.hasReachedMax) {
                    return args.maxReachedWidget ??
                        SizedBox(
                          height: 50,
                        );
                  }
                  return args.loadingWidget ?? CircularProgressIndicator();
                } else {
                  PaginationSuccess<T> success = state;
                  if (args.buildItem != null)
                    return args.buildItem(context, success, index);
                  return Text(data[index].toString());
                }
              },
              itemCount: data.length + 1,
              controller:
                  args.scrollController != null ? null : scrollController,
            );
        }
        return Center(child: Text("unknown state"));
      },
    );
  }
}
