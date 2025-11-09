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
  final TextStyle? titleTextStyle;
  final TextStyle? descriptionTextStyle;
  final ButtonStyle? retryButtonStyle;

  const DataStateWidget({
    super.key,
    required this.dataState,
    this.childBuilder,
    this.placeholderHeight = 180,
    this.containerHeight,
    this.isInsideScrollable = false,
    this.titleTextStyle,
    this.descriptionTextStyle,
    this.retryButtonStyle,
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
        final loadingWidget = _buildLoadingWidget(dataState.loadingType, context);
        // If inside a scrollable, don't wrap in another scrollable and don't use Center
        if (isInsideScrollable) {
          // Return loading widget without Center to avoid blocking scroll gestures
          return _buildLoadingWidgetForScrollable(dataState.loadingType, context);
        }
        // Make loading state scrollable for RefreshIndicator while keeping it visible
        return _wrapInScrollView(context, loadingWidget, fillHeight: true);
      case ViewState.success:
        return childBuilder != null
            ? childBuilder!(dataState.data as T)
            : const SizedBox.shrink();
      case ViewState.empty:
      case ViewState.error:
        final theme = Theme.of(context);
        final defaultTitleStyle = theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ) ?? const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        );
        final defaultDescriptionStyle = theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ) ?? TextStyle(
          color: theme.colorScheme.onSurface,
        );
        final defaultButtonStyle = ElevatedButton.styleFrom(
          foregroundColor: theme.colorScheme.surface,
          backgroundColor: theme.colorScheme.primary,
          minimumSize: const Size.fromHeight(48),
        );

        final content = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dataState.title != null)
                Text(
                  dataState.title!,
                  style: titleTextStyle ?? defaultTitleStyle,
                  textAlign: TextAlign.center,
                ),
              if (dataState.description != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    dataState.description!,
                    style: descriptionTextStyle ?? defaultDescriptionStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              if (dataState.onRetry != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ElevatedButton(
                    onPressed: dataState.onRetry,
                    style: retryButtonStyle ?? defaultButtonStyle,
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

  Widget _buildLoadingWidget(LoadingType? type, BuildContext context, {bool horizontal = false}) {
    final theme = Theme.of(context);
    final defaultLoadingTextStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.7),
    ) ?? TextStyle(
      color: theme.colorScheme.onSurface.withOpacity(0.7),
    );

    switch (type) {
      case LoadingType.defaultLoading:
        return const Center(child: LoadingWidget());

      case LoadingType.placeholder:
        return SizedBox(
          height: placeholderHeight,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Loading...", style: defaultLoadingTextStyle),
                const SizedBox(width: 8),
                LoadingWidget(
                  indicatorColor: theme.colorScheme.primary,
                  size: 24,
                ),
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
  Widget _buildLoadingWidgetForScrollable(LoadingType? type, BuildContext context) {
    final theme = Theme.of(context);
    final defaultLoadingTextStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.7),
    ) ?? TextStyle(
      color: theme.colorScheme.onSurface.withOpacity(0.7),
    );

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
              children: [
                Text("Loading...", style: defaultLoadingTextStyle),
                const SizedBox(width: 8),
                LoadingWidget(
                  indicatorColor: theme.colorScheme.primary,
                  size: 24,
                ),
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
