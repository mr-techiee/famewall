import 'package:flutter/material.dart';

/// A material design floating action menu button.
///
/// A floating action menu button is a circular icon button that hovers over content
/// to promote a primary action with a expanded menu in the application. Floating action buttons are
/// most commonly used in the [Scaffold.floatingActionButton] field.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=2uaoEDOgk_I}
///
/// Use at most a single floating action menu button per screen. Floating action
/// buttons should be used for positive actions such as "create", "share", or
/// "navigate". (If more than one floating action button is used within a
/// [Route], then make sure that each button has a unique [heroTag], otherwise
/// an exception will be thrown.)
///
/// If the [onPressed] callback is null, then the button will be disabled and
/// will not react to touch. It is highly discouraged to disable a floating
/// action button as there is no indication to the user that the button is
/// disabled. Consider changing the [backgroundColor] if disabling the floating
/// action button.
///
/// {@tool dartpad}
/// This example shows how to display a [FloatingActionButton] in a
/// [Scaffold], with a pink [backgroundColor] and a thumbs up [Icon].
///
/// ![](https://flutter.github.io/assets-for-api-docs/assets/material/floating_action_button.png)
///
/// ** See code in examples/api/lib/material/floating_action_button/floating_action_button.0.dart **
/// {@end-tool}
///
/// {@tool dartpad}
/// This example shows how to make an extended [FloatingActionButton] in a
/// [Scaffold], with a  pink [backgroundColor], a thumbs up [Icon] and a
/// [Text] label that reads "Approve".
///
/// ![](https://flutter.github.io/assets-for-api-docs/assets/material/floating_action_button_label.png)
///
/// ** See code in examples/api/lib/material/floating_action_button/floating_action_button.1.dart **
/// {@end-tool}
///
/// See also:
///
///  * [Scaffold], in which floating action menu buttons typically live.
///  * [ElevatedButton], a filled button whose material elevates when pressed.
///  * <https://material.io/design/components/buttons-floating-action-button.html>

class FloatingActionBubble extends AnimatedWidget {
  const FloatingActionBubble({
    Key? key,
    required this.items,
    required this.onPress,
    required this.iconColor,
    required this.backGroundColor,
    required Animation animation,
    this.herotag,
    this.iconData,
    this.animatedIconData,
  })  : assert((iconData == null && animatedIconData != null) ||
      (iconData != null && animatedIconData == null)),
        super(listenable: animation, key: key);

  final List<Bubble> items;
  final void Function() onPress;
  final AnimatedIconData? animatedIconData;
  final Object? herotag;
  final IconData? iconData;
  final Color iconColor;
  final Color backGroundColor;

  get _animation => listenable;

  Widget buildItem(BuildContext context, int index) {
    final screenWidth = MediaQuery.of(context).size.width;

    TextDirection textDirection = Directionality.of(context);

    double animationDirection = textDirection == TextDirection.ltr ? -1 : 1;

    final transform = Matrix4.translationValues(
      animationDirection *
          (screenWidth - _animation.value * screenWidth) *
          ((items.length - index) / 4),
      0.0,
      0.0,
    );

    return Align(
      alignment: textDirection == TextDirection.ltr
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Transform(
        transform: transform,
        child: Opacity(
          opacity: _animation.value,
          child: BubbleMenu(items[index]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        IgnorePointer(
          ignoring: _animation.value == 0,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => const SizedBox(height: 12.0),
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: items.length,
            itemBuilder: buildItem,
          ),
        ),

        /// Creates a circular floating action button.
        ///
        /// The [mini] and [clipBehavior] arguments must not be null. Additionally,
        /// [elevation], [highlightElevation], and [disabledElevation] (if specified)
        /// must be non-negative.
        FloatingActionButton(
          heroTag: herotag ?? const _DefaultHeroTag(),
          backgroundColor: backGroundColor,
          // iconData is mutually exclusive with animatedIconData
          // only 1 can be null at the time
          child: iconData == null
              ? AnimatedIcon(
            icon: animatedIconData!,
            progress: _animation,
            color: iconColor,
          )
              : Icon(
            iconData,
            color: iconColor,
          ),
          onPressed: onPress,
        ),
      ],
    );
  }
}

/// Creates a bubble item for floating action menu button.
class Bubble {
  const Bubble({
    required IconData icon,
    required Color iconColor,
    required String title,
    required TextStyle titleStyle,
    required Color bubbleColor,
    required this.onPress,
  })  : _icon = icon,
        _iconColor = iconColor,
        _title = title,
        _titleStyle = titleStyle,
        _bubbleColor = bubbleColor;

  final IconData _icon;
  final Color _iconColor;
  final String _title;
  final TextStyle _titleStyle;
  final Color _bubbleColor;
  final void Function() onPress;
}

/// Creates a bubble menu for all the items for floating action menu button.
class BubbleMenu extends StatelessWidget {
  const BubbleMenu(this.item, {Key? key}) : super(key: key);

  final Bubble item;

  @override
  Widget build(BuildContext context) {
    return Container(child: MaterialButton(minWidth: 50,
      shape: const StadiumBorder(),
      padding: const EdgeInsets.only(top: 11, bottom: 13, left: 20, right: 20),
      color: item._bubbleColor,
      splashColor: Colors.grey.withOpacity(0.1),
      highlightColor: Colors.grey.withOpacity(0.1),
      elevation: 2,
      highlightElevation: 2,
      disabledColor: item._bubbleColor,
      onPressed: item.onPress,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(child: Icon(
            item._icon,
            color: item._iconColor,
          )),
          const SizedBox(
            width: 10.0,
          ),
          Text(
            item._title,
            style: item._titleStyle,
          ),
        ],
      ),
    ),width: 120,);
  }
}

/// Creates a Default hero tag for the floating action bubble.
class _DefaultHeroTag {
  const _DefaultHeroTag();
  @override
  String toString() => '<default FloatingActionBubble tag>';
}
