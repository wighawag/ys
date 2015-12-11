package ys;

import kha.System;
import kha.Scheduler;

typedef Framebuffer = kha.Framebuffer;

interface Application{
  function update(now : Float, dt : Float, input : Input) : Void;
  function init(now : Float, input : Input) : Void;
  function render(now : Float, framebuffer : Framebuffer, input : Input) : Void;
}

@:access(ys.Input)
class App {
  public static function start(name : String, app : Application){
    if(_startedApplication == null){
      _startedApplication = app;
      if(_startedApplication != null){
        System.init(name, 640, 480, init); //TODO dimensions    
      }else{
        //TODO error?
      }
    }else{
      //TODO error?
    }
  }

  static var _startedApplication : Application;
  static var _instance : App;

  static function init() {
    _instance = new App(_startedApplication);
    _instance.initialise();
    System.notifyOnRender(_instance.render);
    Scheduler.addTimeTask(_instance.update, 0, 1 / 60); //TODO interval
  }



  var _lastNow : Float;
  var _app : Application;
  var _input : Input;
  
  private function new(app : Application){
    _app = app;
    _input = new Input(kha.input.Keyboard.get(0), kha.input.Mouse.get(0), kha.input.Gamepad.get(0));
  }

  private function initialise(){
    _lastNow = kha.System.time;
    _app.init(_lastNow, _input);
  }


  private function update(){
    var now = kha.System.time;
    var dt = now - _lastNow;
    _lastNow = now;
    _input.preUpdate();
    _app.update(now,dt,_input);
    _input.postUpdate();
  }

  private function render(framebuffer : Framebuffer){
    _app.render(kha.System.time,framebuffer, _input);
  }
}
