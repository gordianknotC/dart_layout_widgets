/*

abstract class DropdownScreenItem{
	Icon icon;
	String name;
	void Function(DropdownScreenItem v) onPress;
}

class DropdownScreen<T extends DropdownScreenItem> extends StatefulWidget {
	final List<T> items;
	
	const DropdownScreen(this.items);
	@override State createState() =>  DropdownScreenState();
}
class DropdownScreenState<T extends DropdownScreenItem> extends State<DropdownScreen<T>> {
	T selected;
	
	@override
	Widget build(BuildContext context) {
		return  DropdownButton<T>(
			hint:  Text("Select T"),
			value: selected,
			onChanged: (T Value) {
				setState(() {
					selected = Value;
				});
			},
			items: widget.items.map((T user) {
				return  DropdownMenuItem<T>(
					value: user,
					child: Row(
						children: <Widget>[
							user.icon,
							SizedBox(width: 10,),
							Text(
								user.name,
								style:  TextStyle(color: Colors.black),
							),
						],
					),
				);
			}).toList(),
		);
	}
}*/
