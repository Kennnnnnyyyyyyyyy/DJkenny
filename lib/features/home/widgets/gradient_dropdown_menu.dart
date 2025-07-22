import 'package:flutter/material.dart';

class PillDropdownMenu extends StatefulWidget {
  final String value;
  final List<String> items;
  final void Function(String) onChanged;
  final bool gradientActive;
  const PillDropdownMenu({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.gradientActive = true,
  });

  @override
  State<PillDropdownMenu> createState() => _PillDropdownMenuState();
}

class _PillDropdownMenuState extends State<PillDropdownMenu> {
  bool _expanded = false;
  OverlayEntry? _dropdownOverlay;

  @override
  void dispose() {
    _removeDropdown();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_expanded) {
      _removeDropdown();
    } else {
      _showDropdown();
    }
    setState(() {
      _expanded = !_expanded;
    });
  }

  void _showDropdown() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    _dropdownOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx + renderBox.size.width - 180,
        top: position.dy + renderBox.size.height + 4,
        width: 180,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2))],
            ),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: widget.items.map((item) {
                final isSelected = item == widget.value;
                return ListTile(
                  title: Text(
                    item,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.1,
                    ),
                  ),
                  tileColor: isSelected ? Color(0xFF3813C2).withValues(alpha: 0.7) : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onTap: () {
                    widget.onChanged(item);
                    _toggleDropdown();
                  },
                  hoverColor: Color(0xFFFF6FD8).withValues(alpha: 0.2),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_dropdownOverlay!);
  }

  void _removeDropdown() {
    _dropdownOverlay?.remove();
    _dropdownOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(colors: [Color(0xFFFF6FD8), Color(0xFF3813C2)]);
    final pillShape = BorderRadius.circular(40);
    return Align(
      alignment: Alignment.topRight,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: SizedBox(
          width: 180,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.ease,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              gradient: widget.gradientActive ? gradient : null,
              color: widget.gradientActive ? null : Colors.grey.shade900,
              borderRadius: pillShape,
              border: widget.gradientActive ? Border.all(color: Color(0xFFFF6FD8), width: 2) : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.value,
                    style: TextStyle(
                      color: widget.gradientActive ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: widget.gradientActive ? Colors.white : Colors.grey, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PillDropdownItem extends StatefulWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  final double fontSize;
  final double pillRadius;
  final double horizontalPadding;
  final double verticalPadding;
  const _PillDropdownItem({
    required this.text,
    required this.selected,
    required this.onTap,
    required this.fontSize,
    required this.pillRadius,
    required this.horizontalPadding,
    required this.verticalPadding,
  });

  @override
  State<_PillDropdownItem> createState() => _PillDropdownItemState();
}

class _PillDropdownItemState extends State<_PillDropdownItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(colors: [Color(0xFFFF6FD8), Color(0xFF3813C2)]);
    final pillShape = BorderRadius.circular(widget.pillRadius);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.ease,
          margin: EdgeInsets.symmetric(vertical: 7), // revert to original margin
          padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding, vertical: widget.verticalPadding),
          decoration: BoxDecoration(
            gradient: widget.selected || _hovering ? gradient : null,
            color: widget.selected || _hovering ? null : Colors.grey.shade900,
            borderRadius: pillShape,
            border: widget.selected || _hovering ? Border.all(color: Color(0xFFFF6FD8), width: 2) : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: widget.selected || _hovering ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: widget.fontSize,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
