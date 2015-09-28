package ys;

import kha.Starter;
import kha.Game;

typedef Framebuffer = kha.Framebuffer;

interface Application{
  function update(now : Float, dt : Float, input : Input) : Void;
  function init(now : Float, input : Input) : Void;
  function render(now : Float, framebuffer : Framebuffer, input : Input) : Void;
}

class App extends Game{
  public static function start(name : String, app : Application){
    var starter = new Starter();
		starter.start(new App(name, app));
  }

  var _lastNow : Float;
  var _app : Application;
  var _input : Input;
  @:access(ys.Input)
  private function new(name : String, app : Application){
    super(name,false);
    _app = app;
    _input = new Input(kha.input.Keyboard.get(0), kha.input.Mouse.get(0), kha.input.Gamepad.get(0));
  }

  override public function init(){
    _lastNow = kha.Sys.getTime();
    _app.init(_lastNow, _input);
  }

  override public function update(){
    var now = kha.Sys.getTime();
    var dt = now - _lastNow;
    _lastNow = now;
    _app.update(now,dt,_input);
  }

  override public function render(framebuffer : Framebuffer){
    _app.render(kha.Sys.getTime(),framebuffer, _input);
  }
}
