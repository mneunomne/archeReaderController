class OscController {
  OscP5 oscP5;

  NetAddress remoteBroadcast; 
  NetAddress localBroadcast;

  OscController () {}

  void connect () {
    oscP5 = new OscP5(this,LOCAL_PORT);
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

  void sendLiveDataArray (int [] data, float perc) {
    OscMessage message = new OscMessage("/data_brightness");
    message.add(data);
    OscMessage rowProp = new OscMessage("/row_prop");
    rowProp.add(perc);
    oscP5.send(message, remoteBroadcast);
    oscP5.send(rowProp, remoteBroadcast);
  }

  void sendLiveDataBits (int [] data, float perc) {
    OscMessage message = new OscMessage("/data_bit");
    message.add(data);
    OscMessage rowProp = new OscMessage("/row_prop");
    rowProp.add(perc);
    oscP5.send(message, remoteBroadcast);
    oscP5.send(rowProp, remoteBroadcast);
  }

  void sendLiveDataBytes (int [] data) {
    OscMessage message = new OscMessage("/data_byte");
    message.add(data);
    oscP5.send(message, remoteBroadcast);
  }

  void sendRowData (int [] array) {

  }

  /* Accumulated Data */
  void sendOscAccumulatedData (int [] data, int index) {

    OscMessage message = new OscMessage("/accumulated_data");
    message.add(data);
    OscMessage messageIndex = new OscMessage("/accumulated_index");
    messageIndex.add(index);
    oscP5.send(message, remoteBroadcast);
    oscP5.send(messageIndex, remoteBroadcast);
    println("[OscController] send accumulated_data", data.length, Arrays.toString(data));
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
