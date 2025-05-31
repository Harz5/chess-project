import 'package:flutter/material.dart';
import '../utils/ui_constants.dart';

/// Wiederverwendbare UI-Komponenten für ein konsistentes Design
class UIComponents {
  // Primäre Schaltfläche
  static Widget primaryButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isFullWidth = false,
  }) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            vertical: UIConstants.smallPadding,
            horizontal: UIConstants.defaultPadding,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(UIConstants.lightTextColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon),
                    const SizedBox(width: UIConstants.smallPadding),
                  ],
                  Text(text),
                ],
              ),
      ),
    );
  }

  // Sekundäre Schaltfläche
  static Widget secondaryButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isFullWidth = false,
  }) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            vertical: UIConstants.smallPadding,
            horizontal: UIConstants.defaultPadding,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon),
                    const SizedBox(width: UIConstants.smallPadding),
                  ],
                  Text(text),
                ],
              ),
      ),
    );
  }

  // Text-Schaltfläche
  static Widget textButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return TextButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon),
            const SizedBox(width: UIConstants.smallPadding),
          ],
          Text(text),
        ],
      ),
    );
  }

  // Eingabefeld
  static Widget textField({
    required String label,
    required TextEditingController controller,
    String? hint,
    String? errorText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixIconPressed,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon),
                onPressed: onSuffixIconPressed,
              )
            : null,
      ),
    );
  }

  // Karte
  static Widget card({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) {
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(UIConstants.defaultPadding),
      child: child,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
      ),
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
              child: content,
            )
          : content,
    );
  }

  // Abschnitt mit Titel
  static Widget section({
    required String title,
    required Widget child,
    VoidCallback? onMorePressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.defaultPadding,
            vertical: UIConstants.smallPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: UIConstants.titleFontFamily,
                  fontSize: UIConstants.mediumFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onMorePressed != null)
                TextButton(
                  onPressed: onMorePressed,
                  child: const Text('Mehr'),
                ),
            ],
          ),
        ),
        child,
      ],
    );
  }

  // Ladeindikator
  static Widget loadingIndicator({String? message}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: UIConstants.defaultPadding),
            Text(message),
          ],
        ],
      ),
    );
  }

  // Leerer Zustand
  static Widget emptyState({
    required String message,
    IconData icon = Icons.info_outline,
    VoidCallback? onActionPressed,
    String? actionText,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.largePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: UIConstants.secondaryTextColor,
            ),
            const SizedBox(height: UIConstants.defaultPadding),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: UIConstants.secondaryTextColor,
              ),
            ),
            if (onActionPressed != null && actionText != null) ...[
              const SizedBox(height: UIConstants.defaultPadding),
              ElevatedButton(
                onPressed: onActionPressed,
                child: Text(actionText),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Fehler-Zustand
  static Widget errorState({
    required String message,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.largePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: UIConstants.errorColor,
            ),
            const SizedBox(height: UIConstants.defaultPadding),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: UIConstants.errorColor,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: UIConstants.defaultPadding),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Erneut versuchen'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Abstandshalter
  static Widget spacer({double height = UIConstants.defaultPadding}) {
    return SizedBox(height: height);
  }

  // Trennlinie
  static Widget divider() {
    return const Divider(
      color: UIConstants.primaryLightColor,
      thickness: 1,
      height: UIConstants.defaultPadding * 2,
    );
  }

  // Badge
  static Widget badge({
    required String text,
    Color backgroundColor = UIConstants.primaryColor,
    Color textColor = UIConstants.lightTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.smallPadding,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: UIConstants.smallFontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Avatar
  static Widget avatar({
    String? imageUrl,
    String? initials,
    double size = 40,
    Color backgroundColor = UIConstants.primaryColor,
  }) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: backgroundColor,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
      child: imageUrl == null && initials != null
          ? Text(
              initials,
              style: TextStyle(
                color: UIConstants.lightTextColor,
                fontSize: size / 2,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  // Schaltfläche mit Icon
  static Widget iconButton({
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
    Color? color,
  }) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      tooltip: tooltip,
      color: color,
    );
  }

  // Schwebende Aktionsschaltfläche
  static Widget floatingActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor ?? UIConstants.primaryColor,
      child: Icon(
        icon,
        color: iconColor ?? UIConstants.lightTextColor,
      ),
    );
  }

  // Snackbar anzeigen
  static void showSnackBar(
    BuildContext context, {
    required String message,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Dialog anzeigen
  static Future<T?> showAppDialog<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: content,
        actions: actions,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        ),
      ),
    );
  }

  // Bottom Sheet anzeigen
  static Future<T?> showAppBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(UIConstants.largeBorderRadius),
        ),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: child,
      ),
    );
  }
}
