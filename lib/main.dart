import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shuffling App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _items = <String>[];
  int _groupCount = 0;
  bool _isShuffled = false;
  final _nameController = TextEditingController();
  final _countController = TextEditingController();
  final _nameNode = FocusNode();
  final _countNode = FocusNode();

  void _reset() {
    setState(() {
      _items.clear();
      _groupCount = 0;
      _isShuffled = false;
    });
    _countNode.requestFocus();
  }

  void _shuffle() {
    setState(() {
      _items.shuffle();
      _isShuffled = true;
    });
  }

  void _addName(String value) {
    if (value.isEmpty) {
      _nameNode.requestFocus();
      return;
    }
    _nameController.clear();
    _nameNode.requestFocus();
    setState(() {
      _items.add(value);
    });
  }

  void _addCount(String value) async {
    final count = int.tryParse(value);
    if (count == null) {
      _countController.clear();
      _countNode.requestFocus();
      return;
    }
    setState(() {
      _groupCount = count;
    });
    _countController.clear();
    await Future.delayed(const Duration(milliseconds: 100));
    _nameNode.requestFocus();
  }

  void _removeItem(String value) {
    setState(() {
      _items.remove(value);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countController.dispose();
    _countNode.dispose();
    _nameNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 32),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 200,
                  child: CupertinoTextField(
                    controller: _countController,
                    onSubmitted: _addCount,
                    keyboardType: const TextInputType.numberWithOptions(),
                    placeholder: 'Enter group count',
                    enabled: _groupCount <= 1,
                    focusNode: _countNode,
                  ),
                ),
                const SizedBox(width: 24),
                FilledButton(
                  onPressed: _groupCount <= 1
                      ? () => _addCount(_countController.text)
                      : null,
                  child: const Text('Submit count'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 200,
                  child: CupertinoTextField(
                    controller: _nameController,
                    onSubmitted: _addName,
                    keyboardType: TextInputType.name,
                    placeholder: 'Enter name',
                    focusNode: _nameNode,
                    enabled: _groupCount > 1 && !_isShuffled,
                  ),
                ),
                const SizedBox(width: 24),
                FilledButton(
                  onPressed: _groupCount > 1 && !_isShuffled
                      ? () => _addName(_nameController.text)
                      : null,
                  child: const Text('Submit Name'),
                ),
              ],
            ),
            const SizedBox(width: 24),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              sizeCurve: Curves.ease,
              firstCurve: Curves.ease,
              secondCurve: Curves.ease,
              crossFadeState: _groupCount > 1
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Container(
                width: 360,
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'Group count: $_groupCount',
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              secondChild: const SizedBox(width: double.infinity),
            ),
            Flexible(
              child: Center(
                child: SizedBox(
                  width: 360,
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                    child: ListView.separated(
                      itemBuilder: (context, index) => _ItemWidget(
                        name: _items[index],
                        onDeleteClick: _isShuffled ? null : _removeItem,
                      ),
                      separatorBuilder: (context, index) => _hasDivider(index)
                          ? const Divider()
                          : const SizedBox(),
                      itemCount: _items.length,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isEnable && !_isShuffled ? _shuffle : null,
              child: const Text('Shuffle'),
            ),
            const SizedBox(height: 32),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              sizeCurve: Curves.ease,
              firstCurve: Curves.ease,
              secondCurve: Curves.ease,
              crossFadeState: _isShuffled
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: FilledButton(
                  onPressed: _reset,
                  child: const Text('Reset'),
                ),
              ),
              secondChild: const SizedBox(width: 100),
            ),
          ],
        ),
      ),
    );
  }

  bool get _isEnable => _groupCount >= 2 && _items.length >= 2;

  bool _hasDivider(int index) {
    if (!_isShuffled) return true;
    if (_groupCount < 2) return true;
    return index == (_items.length / _groupCount).floor() - 1;
  }
}

class _ItemWidget extends StatelessWidget {
  final String name;
  final Function(String name)? onDeleteClick;
  const _ItemWidget({
    required this.name,
    required this.onDeleteClick,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            style: const TextStyle(color: Colors.black),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          sizeCurve: Curves.ease,
          firstCurve: Curves.ease,
          secondCurve: Curves.ease,
          crossFadeState: onDeleteClick == null
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: IconButton(
            icon: const Icon(Icons.delete_rounded),
            onPressed: () => onDeleteClick?.call(name),
          ),
          secondChild: const SizedBox(),
        ),
      ],
    );
  }
}
