import 'package:flutter/material.dart';
import '../../shared-enums/shared_enums.dart';
import '/shared/loading/loading_widget.dart';
import 'data_state.dart';

class DataStateWidget<T> extends StatefulWidget {
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
  State<DataStateWidget<T>> createState() => _DataStateWidgetState<T>();
}

class _DataStateWidgetState<T> extends State<DataStateWidget<T>> {
  @override
  void didUpdateWidget(DataStateWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle alert error - show dialog when error state changes
    if (widget.dataState.state == ViewState.error &&
        widget.dataState.errorType == ErrorType.alert &&
        oldWidget.dataState.state != ViewState.error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.dataState.description != null) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(widget.dataState.title ?? 'Error'),
              content: Text(widget.dataState.description!),
              actions: [
                if (widget.dataState.onRetry != null)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.dataState.onRetry?.call();
                    },
                    child: const Text('Retry'),
                  ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.containerHeight != null
        ? SizedBox(
      height: widget.containerHeight,
      child: _buildContent(context),
    )
        : _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    switch (widget.dataState.state) {
      case ViewState.loading:
      // During pull-to-refresh, if we have data and childBuilder, show the child (list)
      // For pullToRefresh without data, return empty scrollable container
        if (widget.dataState.loadingType == LoadingType.pullToRefresh) {
          if (widget.childBuilder != null && widget.dataState.data != null) {
            return widget.childBuilder!(widget.dataState.data as T);
          }
          // No data during pullToRefresh - RefreshIndicator shows loading indicator
          // We return empty scrollable container so RefreshIndicator can detect scroll gesture
          return widget.isInsideScrollable
              ? const SizedBox.shrink()
              : _wrapInScrollView(context, const SizedBox.shrink(), fillHeight: true);
        }
        // For overlayLoading, show content with opacity and loading overlay
        if (widget.dataState.loadingType == LoadingType.overlayLoading) {
          if (widget.childBuilder != null) {
            return Stack(
              children: [
                // Content with reduced opacity
                Opacity(
                  opacity: 0.9,
                  child: widget.childBuilder!(widget.dataState.data as T),
                ),
                // Loading overlay on top
                Container(
                  color: Colors.black.withOpacity(0.1),
                  child: const Center(
                    child: LoadingWidget(),
                  ),
                ),
              ],
            );
          }
          // Fallback to default loading if no childBuilder
          return _wrapInScrollView(context, _buildLoadingWidget(widget.dataState.loadingType, context), fillHeight: true);
        }
        // For other loading types, show loading widget
        final loadingWidget = _buildLoadingWidget(widget.dataState.loadingType, context);
        // If inside a scrollable, don't wrap in another scrollable and don't use Center
        if (widget.isInsideScrollable) {
          // Return loading widget without Center to avoid blocking scroll gestures
          return _buildLoadingWidgetForScrollable(widget.dataState.loadingType, context);
        }
        // Make loading state scrollable for RefreshIndicator while keeping it visible
        return _wrapInScrollView(context, loadingWidget, fillHeight: true);
      case ViewState.success:
        return widget.childBuilder != null
            ? widget.childBuilder!(widget.dataState.data as T)
            : const SizedBox.shrink();
      case ViewState.empty:
        return _buildEmptyOrErrorContent(context, widget.dataState);
      case ViewState.error:
        // For alert errors, show the content (form) instead of error UI
        // The snackbar is handled in didUpdateWidget
        if (widget.dataState.errorType == ErrorType.alert && widget.childBuilder != null) {
          return widget.childBuilder!(widget.dataState.data as T);
        }
        // For emptyState errors, show error UI
        return _buildEmptyOrErrorContent(context, widget.dataState);
    }
  }

  Widget _buildEmptyOrErrorContent(BuildContext context, DataState dataState) {
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (dataState.title != null)
            Text(
              dataState.title!,
              style: widget.titleTextStyle ?? defaultTitleStyle,
              textAlign: TextAlign.center,
            ),
          if (dataState.description != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                dataState.description!,
                style: widget.descriptionTextStyle ?? defaultDescriptionStyle,
                textAlign: TextAlign.center,
              ),
            ),
          if (dataState.onRetry != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ElevatedButton(
                onPressed: dataState.onRetry,
                style: widget.retryButtonStyle ?? defaultButtonStyle,
                child: const Text("Retry"),
              ),
            ),
        ],
      ),
    );
    // If inside a scrollable, center the content horizontally
    if (widget.isInsideScrollable) {
      return Center(
        child: content,
      );
    }
    // Make empty/error states scrollable for RefreshIndicator
    return _wrapInScrollView(context, Center(child: content));
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
            width: double.infinity,
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
          height: widget.placeholderHeight,
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
          height: widget.placeholderHeight,
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
