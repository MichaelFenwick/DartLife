part of Life;

class PausableTimer {
  Timer timer;
  Duration duration;
  Function callback;

  PausableTimer(Duration this.duration, Function this.callback) {
    start();
  }

  get isActive => timer.isActive;

  void pause() {
    cancel();
  }

  void start() {
    timer = new Timer.periodic(duration, callback);
  }

  void restart() {
    cancel();
    start();
  }

  bool toggle() {
    if (isActive) {
      pause();
    } else {
      start();
    }

    return isActive;
  }

  void setDuration(Duration duration) {
    this.duration = duration;
    if (isActive) {
      restart();
    }
  }

  void setCallback(Function callback) {
    this.callback = callback;
    if (isActive) {
      restart();
    }
  }

  void cancel() {
    timer.cancel();
  }
}