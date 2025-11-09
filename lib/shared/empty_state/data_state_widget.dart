import 'package:flutter/material.dart';
import '../../shared-enums/shared_enums.dart';
import '/shared/loading/loading_widget.dart';
import 'data_state.dart';

class DataStateWidget<T> extends StatelessWidget {
  final DataState<T> dataState;
  final Widget Function(T data)? childBuilder;
  final double placeholderHeight;
  final double? containerHeight;
  final bool isInsideScrollable;

  const DataStateWidget({
    super.key,
    required this.dataState,
    this.childBuilder,
    this.placeholderHeight = 180,
    this.containerHeight,
    this.isInsideScrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    return containerHeight != null
        ? SizedBox(
      height: containerHeight,
      child: _buildContent(context),
    )
        : _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    switch (dataState.state) {
      case ViewState.loading:
      // During pull-to-refresh, if we have data and childBuilder, show the child (list)
      // For pullToRefresh without data, return empty scrollable container
        if (dataState.loadingType == LoadingType.pullToRefresh) {
          if (childBuilder != null && dataState.data != null) {
            return childBuilder!(dataState.data as T);
          }
          // No data during pullToRefresh - RefreshIndicator shows loading indicator
          // We return empty scrollable container so RefreshIndicator can detect scroll gesture
          return isInsideScrollable
              ? const SizedBox.shrink()
              : _wrapInScrollView(context, const SizedBox.shrink(), fillHeight: true);
        }
        // For other loading types, show loading widget
        final loadingWidget = _buildLoadingWidget(dataState.loadingType);
        // If inside a scrollable, don't wrap in another scrollable and don't use Center
        if (isInsideScrollable) {
          // Return loading widget without Center to avoid blocking scroll gestures
          return _buildLoadingWidgetForScrollable(dataState.loadingType);
        }
        // Make loading state scrollable for RefreshIndicator while keeping it visible
        return _wrapInScrollView(context, loadingWidget, fillHeight: true);
      case ViewState.success:
        return childBuilder != null
            ? childBuilder!(dataState.data as T)
            : const SizedBox.shrink();
      case ViewState.empty:
      case ViewState.error:
        final content = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
        );
        // If inside a scrollable, return content directly without Center to avoid blocking scroll
        if (isInsideScrollable) {
          return content;
        }
        // Make empty/error states scrollable for RefreshIndicator
        return _wrapInScrollView(context, Center(child: content));
    }
  }

  Widget _wrapInScrollView(BuildContext context, Widget child, {bool fillHeight = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = MediaQuery.of(context).size.height;
        final availableHeight = constraints.maxHeight > 0
            ? constraints.maxHeight
            : screenHeight;
        final minHeight = fillHeight ? availableHeight : availableHeight * 0.8;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: minHeight,
            child: child,
          ),
        );
      },
    );
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

  // Build loading widget for use inside scrollable (without Center to avoid blocking gestures)
  Widget _buildLoadingWidgetForScrollable(LoadingType? type) {
    switch (type) {
      case LoadingType.defaultLoading:
        return const Padding(
          padding: EdgeInsets.all(40),
          child: LoadingWidget(),
        );

      case LoadingType.placeholder:
        return SizedBox(
          height: placeholderHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
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
          child: LoadingWidget(size: 24),
        );

      default:
        return const Padding(
          padding: EdgeInsets.all(40),
          child: LoadingWidget(),
        );
    }
  }
}
