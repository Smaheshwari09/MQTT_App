// TODO Implement this library.
import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:my_app/lib/state/MQTTAppState.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTManager{

  late MQTTAppState _currentState;
  MqttServerClient? _client;
  late String _identifier;
  late String _host;
  late String _topic;

  //constructor
  MQTTManager({
    required String host,
    required String topic,
    required String identifier,
    required MQTTAppState state
    }): _identifier = identifier,
        _host = host,
        _topic = topic,
      _currentState = state;

  DisconnectCallback? get onDiconnected => null;
  void initializeMQTTClient(){
    _client = MqttServerClient(_host, _identifier);
    _client!.port = 1883;
    _client!.keepAlivePeriod = 30;
    _client!.onDisconnected = onDiconnected;
    _client!.logging(on: true);

    //successful callback connection
    _client!.onConnected = onConnected;
    _client!.onSubscribed = onSubscribed;

    final MqttConnectMessage connMess = MqttConnectMessage()
      .withClientIdentifier(_identifier)
      .withWillTopic("willTopic")
      .withWillMessage("MY will Message")
      .startClean()
      .withWillQos(MqttQos.atLeastOnce);
    print("EXAMPLE::Mosquitto client connecting....");
    _client!.connectionMessage = connMess;
  }
    //Connect to the host
    void connect() async{
    //TODO Assert if client is not nil
      assert(_client != null);
      try{
        print('EXAMPLE::Mosquitto start client connecting...');
        _currentState.setAppConnectionState(MQTTAppConnectionState.connecting);
        await _client!.connect("swajahome", "pass@word");
      } on Exception catch(e){
        print('EXAMPLE::client exception - $e');
        disconnect();
      }
    }
    void disconnect(){
    print('Disconnected');
    _client!.disconnect();
    }

    void publish(String message){
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(_topic, MqttQos.exactlyOnce, builder.payload!);
    }

    //The subscribed call back
    void onSubscribed(String topic){
    print('EXAMPLE::Subscription confirmed for topic $topic');
    }
    void onDisconnected(){
      print('EXAMPLE::OnDisconnected client callback -Client disconnection');
      if(_client!.connectionStatus!.returnCode == MqttConnectReturnCode.noneSpecified){
        print('EXAMPLE::OnDisconected call back is solicited, this is correct');
      }
      _currentState.setAppConnectionState(MQTTAppConnectionState.disconnected);
    }

    //The successful connect callback
    void onConnected(){
      _currentState.setAppConnectionState(MQTTAppConnectionState.connected);
      print('EXAMPLE::Mosquitto client connected....');
      _client!.subscribe(_topic, MqttQos.atLeastOnce);
      _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c){
        final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
        final String pt= MqttPublishPayload.bytesToStringAsString(recMess.payload.message!);
        _currentState.setReceivedText(pt);

        print("EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is<-- $pt-->");
        print('');
      });
      print('EXAMPLE::OnConnected client call back - Client connection was successful');
    }

}
