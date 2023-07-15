import 'dart:io'show Platform;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:my_app/lib/state/MQTTAppState.dart';
import 'package:my_app/lib/state/MQTTManager.dart';

class MQTTView extends StatefulWidget{
  @override
  State<StatefulWidget> createState(){
    return _MQTTViewState();
  }
}


class _MQTTViewState extends State<MQTTView> {
  final TextEditingController _hostTextController = TextEditingController();
  final TextEditingController _messageTextController = TextEditingController();
  final TextEditingController _topicTextController = TextEditingController();
  late MQTTAppState currentAppState;
  late MQTTManager manager;


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _hostTextController.dispose();
    _messageTextController.dispose();
    _topicTextController.dispose();
    super.dispose();
  }

  // _printLatesValue() async {
  //   var _hostTextController;
  //   print("Second text fild: ${_hostTextController.text}");
  //   var _messageTextContriller;
  //   print("Second text field: ${_messageTextContriller.text}");
  //   var _topicTextController;
  //   print("Second text field: ${_topicTextController.text}");
  // }

  @override
  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    //keep a reference to the app state.
    currentAppState = appState;
    final Scaffold scaffold = Scaffold(body: _buildColumn());
    return scaffold;
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('MQTT'),
      backgroundColor: Colors.greenAccent,
    );
  }

  Widget _buildColumn() {

    return Column(
      children: <Widget>[
        _buildConnectionStateText(
            _prepareStateMessageFrom(currentAppState.getAppConnectionState)),
        _buildEditableColumn(),
        _buildScrollableTextWith(currentAppState.getHistoryText)
      ],
    );
  }

  Widget _buildConnectionStateText(String status) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
              color: Colors.deepOrangeAccent,
              child: Text(status, textAlign: TextAlign.center)),
        ),
      ],
    );
  }

  Widget _buildEditableColumn() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          _buildTextFieldWith(_hostTextController, 'Enter broker address',
              currentAppState.getAppConnectionState),
          SizedBox(height: 10),
          _buildTextFieldWith(
              _topicTextController, 'Enter A topic to Subscribe or listen',
              currentAppState.getAppConnectionState),
          SizedBox(height: 10),
          _buildPublishMessageRow(),
          SizedBox(height: 10),
          _buildConnectButtonFrom(currentAppState.getAppConnectionState)
        ],
      ),
    );
  }

  Widget _buildPublishMessageRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
            child: _buildTextFieldWith(
                _messageTextController, 'Enter a message',
                currentAppState.getAppConnectionState),
            ),
              _buildSendButtonFrom(currentAppState.getAppConnectionState)
      ],
    );
  }


  Widget _buildTextFieldWith(TextEditingController controller, String hintText,
      MQTTAppConnectionState state) {
    bool shouldEnable = false;


    if ((controller == _messageTextController &&
        state == MQTTAppConnectionState.connected)) {
      shouldEnable = true;
    } else if ((controller == _hostTextController &&
        state == MQTTAppConnectionState.disconnected) || (controller ==
        _topicTextController && state == MQTTAppConnectionState.disconnected)) {
      shouldEnable = true;
    }
    return TextField(
      enabled: shouldEnable,
      controller: controller,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
        labelText: hintText,
      ),
    );
  }

  Widget _buildScrollableTextWith(String text) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        width: 400,
        height: 200,
        child: SingleChildScrollView(
          child: Text(text),
        ),
      ),
    );
  }

  Widget _buildSendButtonFrom(MQTTAppConnectionState state) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
      ),
      child: Text('Send'),
      onPressed: state == MQTTAppConnectionState.connected ? () {
        _publishMessage(_messageTextController.text);
      }
          : null,
    );
  }

  void _publishMessage(String text) {
    String os_Prefix = "Flutter_ios";
    if (Platform.isAndroid) {
      os_Prefix = "Flutter_Android";
    }
    final message = os_Prefix +"  says:"+ text;
    manager.publish(message);
    _messageTextController.clear();
  }


  Widget _buildConnectButtonFrom(MQTTAppConnectionState state) {
    return Row(
      children: <Widget>[
        Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
              ),
              child: Text('Connect'),
              onPressed: state == MQTTAppConnectionState.disconnected
                  ? _configureAndConnect
                  : null,
            )
        ),
        SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: Text('Disconnect'),
            onPressed: state == MQTTAppConnectionState.connected
                ? _disconnect
                : null,
          ),
        ),
      ],
    );
  }

  void _configureAndConnect() {
    String osPrefix = "Flutter_ios";
    if (Platform.isAndroid) {
      osPrefix = "Flutter_Android";
    }
    manager = MQTTManager(
        host: _hostTextController.text,
        topic: _topicTextController.text,
        state: currentAppState,
        identifier:'osPerfix',
    );
    manager.initializeMQTTClient();
    manager.connect();
  }

  void _disconnect() {
    manager.disconnect();
  }


  String _prepareStateMessageFrom(MQTTAppConnectionState state) {
    switch (state) {
      case MQTTAppConnectionState.connected:
        return "Connected";
      case MQTTAppConnectionState.connecting:
        return "Connecting";
      case MQTTAppConnectionState.disconnected:
        return "Disconnected";
    }
  }


}
