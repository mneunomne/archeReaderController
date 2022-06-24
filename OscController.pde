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
    OscMessage message = new OscMessage("/live_data");
    message.add(decoder.getLiveValue());
    oscP5.send(message, remoteBroadcast);
    println("[OscController] send live_data", message);
  }

  /* Accumulated Data */
  void sendOscAccumulatedData (int [] data, int index) {
    OscMessage message = new OscMessage("/accumulated_data");
    message.add(data);
    message.add(index);
    oscP5.send(message, remoteBroadcast);
    println("[OscController] send accumulated_data", message);
  }
  
  /* Final Audio */
  void sendFinalAudio (int [] data, int sample_rate) {
    OscMessage message = new OscMessage("/final_audio");
    message.add(decoder.getFinalAudio());
    //message.add(sample_rate);
    oscP5.send(message, remoteBroadcast);
    println("[OscController] send final_audio", message);
  }
}
