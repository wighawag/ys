package ys;

import kha.input.Keyboard;
import kha.input.Mouse;
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

  inline public function isMouseLeftButtonDown() : Bool{
    return _mouseButtonsDown[1];
  }

  inline public function getMouseWheelDelta() : Int{
    return _lastWheelDelta;
  }

  var _mouse : Mouse;
  var _lastMouseX : Int;
  var _lastMouseY : Int;
  var _mouseButtonsDown : Map<Int, Bool>;
  var _lastWheelDelta : Int;

  var _keyboard : Keyboard;
  var _charKeysDown : Map<String,Bool>;
	var _keysDown : Map<Key,Bool>;

	private function new(keyboard : Keyboard, mouse : Mouse){
		_keyboard = keyboard;
		_keysDown = new Map();
    _charKeysDown = new Map();
		_keyboard.notify(keyDown,keyUp);

    _mouse = mouse;
    _mouseButtonsDown = new Map();
    _mouse.notify(mouseDown, mouseUp, mouseMove, mouseWheel);
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

  function mouseMove(mouseX : Int, mouseY : Int){
    _lastMouseX = mouseX;
    _lastMouseY = mouseY;
  }

  function mouseWheel(delta : Int){
    _lastWheelDelta = delta;
  }


}
