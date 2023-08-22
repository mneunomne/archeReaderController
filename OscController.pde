class OscController {
  OscP5 oscP5;

  NetAddress remoteBroadcast;
  NetAddress parallelAddress; 
  NetAddress localBroadcast;

  XML xml, px, py;

  SyphonServer syphonServer;

  PApplet parent;

  OscController (PApplet _parent) {
    parent = _parent;
  }

  void connect () {
    oscP5 = new OscP5(this,LOCAL_PORT);
    remoteBroadcast = new NetAddress(MAX_ADDRESS, MAX_PORT);
    parallelAddress = new NetAddress(PARALLEL_ADDRESS, PARALLEL_PORT);
    // syphon server to send camera images
    syphonServer = new SyphonServer(parent, "Processing Syphon");
  }

  // OLD - not used
  void update () {
    sendOscLiveData();
  }

  /* LIVE Data OLD */
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

    float perc_y = (float) current_row_index / (float) PLATE_COLS;
    float perc_x = perc;
    // if inverted, send inverted prop
    if (decoderState == READING_ROW_DATA_INVERTED) {
      perc_x = 1.0 - perc; 
    }

    // set cam to send live feed to parallel window
    // OscMessage messageFeed = new OscMessage("/live_feed");
    // messageFeed.add(perc_x);
    // messageFeed.add(perc_y);
    // oscP5.send(message, parallelAddress);
    cam.sendLiveFeed(perc_x, perc_y);
  }

  void sendLiveDataBits (int [] data, float perc) {
    OscMessage message = new OscMessage("/data_bit");
    message.add(data);
    OscMessage rowProp = new OscMessage("/row_prop");
    rowProp.add(perc);
    oscP5.send(message, remoteBroadcast);
    oscP5.send(rowProp, remoteBroadcast);
  }

  void sendVideoFeed (PGraphics pg, float perc_x, float perc_y) {
    println("[OscController] send video feed", perc_x, perc_y);
    // send video feed to parallel window
    syphonServer.sendImage(pg);
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
    //println("[OscController] send accumulated_data", data.length, Arrays.toString(data));
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
