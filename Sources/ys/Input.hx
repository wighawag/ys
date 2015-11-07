package ys;

import kha.input.Keyboard;
import kha.input.Mouse;
import kha.input.Gamepad;
import kha.Key;

class Input{
  inline public function isKeyDown(key : Key):Bool{
    return _keysDown[key];
  }

  inline public function isCharDown(char : String):Bool{
    return _charKeysDown[char];
  }

  inline public function getMouseX() : Int{
    return _lastMouseX;
  }

  inline public function getMouseY() : Int{
    return _lastMouseY;
  }

  inline public function getMouseMovementX() : Int{
    return _lastMouseMovementX;
  }

  inline public function getMouseMovementY() : Int{
    return _lastMouseMovementY;
  }

  inline public function isMouseLeftButtonDown() : Bool{
    return _mouseButtonsDown[1];
  }

  inline public function getMouseWheelDelta() : Int{
    return _lastWheelDelta;
  }

  inline public function getAxisValue(axis : Int) : Float{
    return _axes[axis];
  }

  inline public function getButtonValue(button : Int) : Float{
    return _buttons[button];
  }

  var _mouse : Mouse;
  var _lastMouseX : Int;
  var _lastMouseY : Int;
  var _lastMouseMovementX : Int;
  var _lastMouseMovementY : Int;
  var _mouseButtonsDown : Map<Int, Bool>;
  var _lastWheelDelta : Int;

  var _keyboard : Keyboard;
  var _charKeysDown : Map<String,Bool>;
	var _keysDown : Map<Key,Bool>;

  var _gamepad : Gamepad;
  var _axes : Array<Float>;
  var _buttons : Array<Float>;

	private function new(keyboard : Keyboard, mouse : Mouse, gamepad : Gamepad){
		_keyboard = keyboard;
		_keysDown = new Map();
    _charKeysDown = new Map();
    if(_keyboard != null){
      _keyboard.notify(keyDown,keyUp);  
    }
		

    _mouse = mouse;
    _mouseButtonsDown = new Map();
    if(_mouse != null){
      _mouse.notify(mouseDown, mouseUp, mouseMove, mouseWheel);  
    }
    

    _gamepad = gamepad;
    _axes = new Array();
    for(i in 0...10){
      _axes.push(0);
    }
    _buttons = new Array();
    for(i in 0...10){
      _buttons.push(0);
    }
    if(_gamepad != null){
      _gamepad.notify(gamepadAxis, gamepadButton);  
    }
    
	}

  function preUpdate(){

  }

  function postUpdate(){
    _lastMouseMovementX = 0;
    _lastMouseMovementY = 0;
  }

	function keyDown(k : Key, c : String){
    if(k == CHAR){
      _charKeysDown[c] = true;
    }else{
      _keysDown[k] = true;
    }

	}

	function keyUp(k : Key, c : String){
    if(k == CHAR){
      _charKeysDown[c] = false;
    }else{
      _keysDown[k] = false;
    }
	}

  function mouseDown(button : Int, mouseX : Int, mouseY : Int){
    _mouseButtonsDown[button] = true;
  }

  function mouseUp(button : Int, mouseX : Int, mouseY : Int){
    _mouseButtonsDown[button] = false;
  }

  function mouseMove(mouseX : Int, mouseY : Int, movementX : Int, movementY : Int){
    _lastMouseX = mouseX;
    _lastMouseY = mouseY;
    _lastMouseMovementX = movementX;
    _lastMouseMovementY = movementY; //TODO reset on frane
  }

  function mouseWheel(delta : Int){
    _lastWheelDelta = delta;
  }


  function gamepadAxis(axis : Int, value : Float){
    _axes[axis] = value;
  }

  function gamepadButton(button : Int, value : Float){
    _buttons[button] = value;
  }



}
