import 'package:delivery/common/model/cursor_pagination_model.dart';
import 'package:delivery/common/model/model_with_id.dart';
import 'package:delivery/common/provider/pagination_provider.dart';
import 'package:delivery/common/utils/pagination_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef PaginationWidgetBuilder<T extends IModelWithId>
  = Widget Function(BuildContext context, int index, T model);

class PaginationListView<T extends IModelWithId> extends ConsumerStatefulWidget {

  final StateNotifierProvider<PaginationProvider, CursorPaginationBase> provider;
  final PaginationWidgetBuilder<T> itemBuilder;

  const PaginationListView({
    required this.provider,
    required this.itemBuilder,
    super.key,
  });

  @override
  ConsumerState<PaginationListView> createState() => _PaginationListViewState<T>();
}

class _PaginationListViewState<T extends IModelWithId> extends ConsumerState<PaginationListView> {

  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(scrollListener);
  }

  @override
  void dispose() {
    controller.removeListener(scrollListener);
    controller.dispose();
    super.dispose();
  }

  void scrollListener() {
    PaginationUtils.paginate(
      controller: controller,
      provider: ref.read(widget.provider.notifier),
    );
  }

  @override
  Widget build(BuildContext context) {

    final state = ref.watch(widget.provider);

    //완전 처음 로딩
    if(state is CursorPaginationLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    //에러 발생
    if(state is CursorPaginationError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            state.message,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0,),
          ElevatedButton(
            onPressed: () {
              ref.read(widget.provider.notifier).paginate(
                forceReFetch: true,
              );
            },
            child: Text('재시도',),
          )
        ],
      );
    }

    final cursorPagination = state as CursorPagination<T>;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: RefreshIndicator(
        onRefresh: () async {
          ref.read(widget.provider.notifier).paginate(forceReFetch: true,);
        },
        child: ListView.separated(
          //physics: AlwaysScrollableScrollPhysics(),
          controller: controller,
          itemCount: cursorPagination.data.length + 1,
          itemBuilder: (context, index) {
            //추가 요청 시 로딩바
            if(index == cursorPagination.data.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Center(
                  child: cursorPagination is CursorPaginationFetchingMore
                      ? CircularProgressIndicator()
                      : Text('더 이상 데이터가 없습니다.',),
                ),
              );
            }
            final item = cursorPagination.data[index];
            return widget.itemBuilder(context, index, item);
          },
          separatorBuilder: (context, index) {
            return SizedBox(height: 16.0,);
          },
        ),
      ),
    );
  }
}
