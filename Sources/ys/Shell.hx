package ys;

import ys.App;


class Shell implements Application{

  var screens : Array<Screen>;
  var currentIndex : Int = 0;
  var currentScreen : Screen;
  var startTime : Float;

  //updater member
  var _toPause : Bool = false;
  var _paused : Bool = false;
  var _lostTime : Float = 0;
  var _speedScale : Float = 1;
  var _interval : Float = 0.016;
  var _accumulatedTime : Float = 0;

  var _screenToRemoveOnStart : Map<Screen,Bool>;

  public function new (startScreens :Array<Screen>, loopingScreens : Array<Screen>){
    _screenToRemoveOnStart = new Map();
    for(screen in startScreens){
      _screenToRemoveOnStart.set(screen,true);
    }
		this.screens = startScreens.concat(loopingScreens);
	}

  public function init(now : Float, input : Input){
    currentIndex = 0;
    enterScreen(now, input);
  }

  public function update(now : Float, dt : Float, input : Input){

    if(_paused){
      _lostTime += dt;
      return;
    }

    //skip big interval (probably due to debugging)
    if(dt > _interval * 3){
      trace("big lapsed time");
      _lostTime += (dt - _interval);
      dt = _interval;
    }

    now = now - _lostTime;

    var actualDelta = dt * _speedScale;
    _lostTime -= (actualDelta - dt);

    _accumulatedTime += actualDelta;

    var counter = 0;
    while(_accumulatedTime > _interval){
      _accumulatedTime -= _interval;
      now += _interval;
      _update(now,_interval, input);
      counter ++;
      if(counter > 1000){
         break;
      }
    }



    if(_toPause){
      _paused = true;
      _toPause = false;
    }



  }

  inline function _update(now : Float, dt : Float, input : Input){
    var elapsedTime = now - startTime;
    var done = currentScreen.update(elapsedTime, dt, input);
    if (done) {
        currentScreen.exit(elapsedTime);
        currentIndex++;
        if (currentIndex >= screens.length) {
            currentIndex = 0;
            //TODO
        }
        enterScreen(now, input);
    }
  }

  public function render(now : Float, framebuffer : Framebuffer, input : Input){
    currentScreen.render(now - startTime,framebuffer, input);
  }

  function enterScreen(now : Float, input : Input){
    startTime = now;
    currentScreen = screens[currentIndex];
    if(_screenToRemoveOnStart[currentScreen]){
      screens.remove(currentScreen);
      _screenToRemoveOnStart.remove(currentScreen);
      currentIndex --;
    }
    
    currentScreen.enter(input);
  }
}

interface Screen{
  function enter(input : Input):Void;
  function exit(elapsedTime : Float):Void;
  function update(elapsedTime : Float, dt : Float, input : Input):Bool;
  function render(elapsedTime : Float, framebuffer : Framebuffer, input : Input):Void;
}
