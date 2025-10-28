import 'package:flutter/material.dart';
import '../../shared-enums/shared_enums.dart';
import '/shared/loading/loading_widget.dart';
import 'data_state.dart';

class DataStateWidget<T> extends StatelessWidget {
  final DataState<T> dataState;
  final Widget Function(T data)? childBuilder;
  final double placeholderHeight;
  final double? containerHeight;

  const DataStateWidget({
    super.key,
    required this.dataState,
    this.childBuilder,
    this.placeholderHeight = 180,
    this.containerHeight,
  });

  @override
  Widget build(BuildContext context) {
    return containerHeight != null
        ? SizedBox(
      height: containerHeight,
      child: _buildContent(),
    )
        : _buildContent();
  }

  Widget _buildContent() {
    switch (dataState.state) {
      case ViewState.loading:
        return _buildLoadingWidget(dataState.loadingType);
      case ViewState.success:
        return childBuilder != null
            ? childBuilder!(dataState.data as T)
            : const SizedBox.shrink();
      case ViewState.empty:
      case ViewState.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (dataState.title != null)
                  Text(
                    dataState.title!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (dataState.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      dataState.description!,
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (dataState.onRetry != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ElevatedButton(
                      onPressed: dataState.onRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text("Retry"),
                    ),
                  ),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildLoadingWidget(LoadingType? type, {bool horizontal = false}) {
    switch (type) {
      case LoadingType.defaultLoading:
        return const Center(child: LoadingWidget());

      case LoadingType.placeholder:
        return SizedBox(
          height: placeholderHeight,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text("Loading...", style: TextStyle(color: Colors.white70)),
                SizedBox(width: 8),
                LoadingWidget(indicatorColor: Colors.greenAccent, size: 24),
              ],
            ),
          ),
        );

      case LoadingType.pullToRefresh:
        return const SizedBox.shrink();

      case LoadingType.loadMore:
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: LoadingWidget(size: 24)),
        );

      default:
        return const Center(child: LoadingWidget());
    }
  }
}
