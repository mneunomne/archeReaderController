class OscController {
  OscP5 oscP5;

  NetAddress remoteBroadcast; 
  NetAddress localBroadcast;

  OscController () {}

  void connect () {
    oscP5 = new OscP5(this,12000);
    remoteBroadcast = new NetAddress(MAX_ADDRESS, MAX_PORT);
  }

  void update () {
    sendOscLiveData();
  }

  /* LIVE Data */
  void sendOscLiveData () {
    OscMessage message = new OscMessage("/camera_data");
    int liveData = decoder.getLiveValue();
    message.add(liveData);
    oscP5.send(message, remoteBroadcast);
    // println("[OscController] send live_data", message);
  }

  void sendLiveDataArray (int [] data) {

  }

  /* Accumulated Data */
  void sendOscAccumulatedData (int [] data, int index) {
    OscMessage message = new OscMessage("/accumulated_data");
    message.add(data);
    OscMessage messageIndex = new OscMessage("/index");
    messageIndex.add(index);
    oscP5.send(message, remoteBroadcast);
    oscP5.send(messageIndex, remoteBroadcast);
    // println("[OscController] send accumulated_data", Arrays.toString(data));
  }
  
  /* Final Audio */
  void sendFinalAudio () {
    OscMessage message = new OscMessage("/final_audio");
    message.add(decoder.getFinalAudio());
    //message.add(sample_rate);
    oscP5.send(message, remoteBroadcast);
    // println("[OscController] send final_audio", Arrays.toString(decoder.getFinalAudio()));
  }
}
