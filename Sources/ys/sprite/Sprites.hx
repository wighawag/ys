package ys.sprite;

import kha.Loader;
import kha.math.Vector4;

import ys.sprite.TextureAtlas.CutOut;
import ys.sprite.SpriteDataSet;

import khage.g4.Buffer;

class TexturedQuadMesh{

	//TODO public var textureId ?
	public var x1(default,null): Float;
	public var y1(default,null): Float;
	public var x2(default,null): Float;
	public var y2(default,null): Float;
  public var u1(default,null): Float;
  public var v1(default,null): Float;
  public var u2(default,null): Float;
  public var v2(default,null): Float;
	public var refX(default,null): Float;
	public var refY(default,null): Float;

	public function new(meshData : TexturedQuadMeshData){
    x1 = meshData.x1;
    y1 = meshData.y1;
    x2 = meshData.x2;
    y2 = meshData.y2;
		u1 = meshData.u1;
		v1 = meshData.v1;
		u2 = meshData.u2;
		v2 = meshData.v2;
		refX = meshData.refX;
		refY = meshData.refY;
	}
}

class Frame{
	public var index(default, null) : Int;
	public var mesh(default, null) : TexturedQuadMesh; // could use type parameter
	public var scaleX(default, null) : Float;
	public var scaleY(default, null) : Float;

	public function new(index : Int, frameData : FrameData){
		this.index = index;
		//TODO if frameData.meshData == null
		this.mesh = new TexturedQuadMesh(frameData.meshData);
		if (Reflect.hasField(frameData,"scaleX")){
			this.scaleX = frameData.scaleX;
		}else{
			this.scaleX = 1;
		}

		if (Reflect.hasField(frameData,"scaleY")){
			this.scaleY = frameData.scaleY;
		}else{
			this.scaleY = 1;
		}
	}
}


class FrameAnimation{
	public var id(default, null) : String;
  var frames : Array<Frame>;

  public var defaultMsDuration : Int;  // seconds
  public var loopStartFrame : Int;

  private var totalMsDuration : Int;
  private var loopMsDuration : Int;
  private var averageMsDuration : Int;

  public function new(id : String, animationData : AnimationData){
  	this.defaultMsDuration = animationData.defaultMsDuration;
    this.loopStartFrame = animationData.loopStartFrame != null ? animationData.loopStartFrame : 0; //TODO deicde if default to zero?

    var gcd : Int = 0;

    totalMsDuration = 0;
    this.frames = new Array<Frame>();
    for (frame in animationData.frames){
        var frameMsDuration : Int = getFrameDuration(frame);

        if(gcd == 0){
            gcd = frameMsDuration;
        }
        else{
            gcd = computeGCD(gcd, frameMsDuration);
        }
        totalMsDuration += frameMsDuration;
    }

    var counter = 0;
    for (frame in animationData.frames){
        var newFrame = new Frame(counter,frame);
        var frameMsDuration : Int = getFrameDuration(frame);
        var numFrames = Std.int(frameMsDuration / gcd);
        for (i in 0...numFrames){
            this.frames.push(newFrame); // do we want counter or global frame num ?
        }
        counter++;
    }


    // Work as GCD calculated
    averageMsDuration = Std.int(totalMsDuration / this.frames.length);
    loopMsDuration = (this.frames.length - loopStartFrame) * averageMsDuration;
  }

  inline private function getFrameDuration(frame : FrameData) : Int{
    if (frame.overrideMsDuration != null && frame.overrideMsDuration > 0){
        return frame.overrideMsDuration;
    }else{
        return this.defaultMsDuration;
    }
  }

  inline private function computeGCD(a : Int, b : Int) : Int{

    while (a != 0 && b != 0)
    {
        if (a > b){
            a = a % b;
        }else{
            b = b % a;
        }
    }

    if (a == 0){
        return b;
    }else{
        return a;
    }
  }

  public function getFrame(elapsedTime : Float){
  	var frameIndex : Int;
    if(frames.length == 1){
        frameIndex = 0;
    }else{
        var msTimeElapsed = elapsedTime * 1000;
        if (msTimeElapsed >= totalMsDuration){
            if (loopStartFrame >= 0){
                var time = (msTimeElapsed - totalMsDuration) % loopMsDuration;
                frameIndex = Std.int(time / averageMsDuration);
            }else{
                frameIndex = frames.length - 1; // return last frame if not loop (loopStartFrame < 0)
            }
        }else{
            frameIndex = Std.int(msTimeElapsed / averageMsDuration);
        }
    }
    return frames[frameIndex];
  }
}

class Sprite{
	public var id(default, null) : String;
	var animations : Map<String,FrameAnimation>;

	public function new(id : String, spriteData : SpriteData){
		this.animations = new Map();
		for (animationId in Reflect.fields(spriteData)){
			this.animations[animationId] = new FrameAnimation(animationId, Reflect.field(spriteData, animationId));
		}
	}

	public function getFrame(animationId : String, elapsedTime : Float){
		var animation = animations[animationId];
		if(animation != null){
			return animation.getFrame(elapsedTime);
		}
		return null;
	}
}

class Sprites{
	var sprites : Map<String,Sprite>;
	public var image(default,null) : kha.Image;
	public var normal(default,null) : kha.Image;

	function new(spritesMap : Map<String,Sprite>, image : kha.Image, normal : kha.Image){
		sprites = spritesMap;
		this.image = image;
		this.normal = normal;
	}

	public static function load(spritePath : String){
    var spritesMap = new Map<String,Sprite>();
    var spriteDataSet : SpriteDataSet = haxe.Json.parse(Loader.the.getBlob(spritePath).toString());
    var spriteSet = spriteDataSet.sprites;
    var textureAtlas : TextureAtlas = haxe.Json.parse(Loader.the.getBlob(spriteDataSet.textureAtlas).toString());
		var imagePath = textureAtlas.bitmapId;
		var image = Loader.the.getImage(imagePath);
		var dotIndex = imagePath.lastIndexOf(".");
		var normalPath = imagePath.substr(0,dotIndex) + "_n" + imagePath.substr(dotIndex);
		trace(normalPath);
		var normal = Loader.the.getImage(normalPath);
		for(spriteId in Reflect.fields(spriteSet)){
			var spriteData : SpriteData = Reflect.field(spriteSet,spriteId);
			for (animationId in Reflect.fields(spriteData)){
				var animationData : AnimationData = Reflect.field(spriteData, animationId);
				for(frameData in animationData.frames){
					var originalCutOut : CutOut = Reflect.field(textureAtlas.cutOuts,frameData.textureCutOut);
		            var uRatio = 1 / textureAtlas.width;
		            var vRatio = 1 / textureAtlas.height;
		            frameData.meshData = {
                        x1: originalCutOut.x1,
                        y1: originalCutOut.y1,
                        x2: originalCutOut.x2,
                        y2: originalCutOut.y2,
		            	u1: originalCutOut.x1 * uRatio,
		            	v1: originalCutOut.y1 * vRatio,
		            	u2: originalCutOut.x2 * uRatio,
		            	v2: originalCutOut.y2 * vRatio,
		            	refX: originalCutOut.refX,
		            	refY: originalCutOut.refY,
		            	//textureId : textureAtlas.bitmapId
		            };
				}
			}
        var sprite = new Sprite(spriteId, spriteData);
        spritesMap[spriteId] = sprite;
    }

		return new Sprites(spritesMap, image, normal);
	}

	public function writeToBuffer(buffer : Buffer<{position:Vec3, alpha:Float, texCoords:Vec2}>, context : ys.g.Context, spriteId : String, animationName : String, elapsedTime : Float, x : Float, y : Float, z : Float, ?width : Float = 0, ?height : Float = 0, ?keepRatio : Bool = true) : Void{
		var placement = getTexturePlacement(context, spriteId, animationName, elapsedTime,x,y,z,width,height,keepRatio);

		var i = buffer.getNumVerticesWritten();
		buffer.writeIndex(i+0);
		buffer.writeIndex(i+2);
		buffer.writeIndex(i+1);
		buffer.writeIndex(i+3);
		buffer.writeIndex(i+1);
		buffer.writeIndex(i+2);

		buffer.write_position(placement.dstX1, placement.dstY1, z);
		buffer.write_position(placement.dstX2, placement.dstY2, z);
		buffer.write_position(placement.dstX3, placement.dstY3, z);
		buffer.write_position(placement.dstX4, placement.dstY4, z);

    buffer.write_alpha(context.alpha);
    buffer.write_alpha(context.alpha);
    buffer.write_alpha(context.alpha);
    buffer.write_alpha(context.alpha);

		buffer.write_texCoords(placement.srcX1, placement.srcY1);
		buffer.write_texCoords(placement.srcX2, placement.srcY1);
		buffer.write_texCoords(placement.srcX1, placement.srcY2);
		buffer.write_texCoords(placement.srcX2, placement.srcY2);
	}

	public function getTexturePlacement(context : ys.g.Context, spriteId : String, animationName : String, elapsedTime : Float, x : Float, y : Float, z : Float, ?width : Float = 0, ?height : Float = 0, ?keepRatio : Bool = true) : TexturePlacement{
	  var sprite = sprites[spriteId];

    var frame : Frame = null;
    var error = false;
    //TODO always upload an error texture (in debug mode only ?)
    if (sprite == null) {
        trace("no sprite with id : " + spriteId);
        error = true;
    }else{
        frame = sprite.getFrame(animationName, elapsedTime);
        if (frame == null) {
            error = true;
            trace("no frame for animation : " + animationName);
        }
    }


    if(error){
      width = width == 0 ? 100 : width;
      height = height == 0 ? 100 : height;
      return null;
//                {
//                    textureId : "error",
//                    srcX1 : 0,
//                    srcY1 : 0,
//                    srcX2 : 100,
//                    srcY2 : 100,
//                    dstX1 : x,
//                    dstY1 : y,
//                    dstZ : z,
//                    dstX2 : x + 100 * width /100,
//                    dstY2 : y + 100 * height /100
//                };
    }else{
      var mesh = frame.mesh;

      var meshWidth = mesh.x2 - mesh.x1;
      var meshHeight = mesh.y2 - mesh.y1;
      if(width == 0){
        width = meshWidth;
      }
      if(height == 0){
        height = meshHeight;
      }

      var scaleX = width / meshWidth;
      var scaleY = height / meshHeight;

      if(keepRatio){
        scaleX = scaleY = Math.min(scaleX,scaleY);
      }

      var offsetX = mesh.refX * frame.scaleX;
      var offsetY = mesh.refY * frame.scaleY;

      var targetX = - (offsetX * scaleX);
      var targetY = - (offsetY * scaleY);

      var rectX1 = targetX;
      var rectY1 = targetY;
      var rectX2 = targetX + meshWidth * scaleX;
      var rectY2 = targetY + meshHeight * scaleY;

      var vec = new Vector4();
      vec.x = rectX1;
      vec.y = rectY1;
      vec.z = z;
      vec.w = 1;
      context.transform(vec);
      var dstX1 = vec.x;
      var dstY1 = vec.y;

      vec.x = rectX2;
      vec.y = rectY1;
      vec.z = z;
      vec.w = 1;
      context.transform(vec);
      var dstX2 = vec.x;
      var dstY2 = vec.y;

      vec.x = rectX1;
      vec.y = rectY2;
      vec.z = z;
      vec.w = 1;
      context.transform(vec);
      var dstX3 = vec.x;
      var dstY3 = vec.y;

      vec.x = rectX2;
      vec.y = rectY2;
      vec.z = z;
      vec.w = 1;
      context.transform(vec);
      var dstX4 = vec.x;
      var dstY4 = vec.y;

      return {
          //textureId :textureCutOut.textureId,
          srcX1 : mesh.u1,
          srcY1 : mesh.v1,
          srcX2 : mesh.u2,
          srcY2 : mesh.v2,
          dstX1 : dstX1 + x,
          dstY1 : dstY1 + y,
          dstX2 : dstX2 + x,
          dstY2 : dstY2 + y,
          dstX3 : dstX3 + x,
          dstY3 : dstY3 + y,
          dstX4 : dstX4 + x,
          dstY4 : dstY4 + y,
          dstZ : z,
      };
    }
	}

	public function draw(g2 : kha.graphics2.Graphics, spriteId : String, animationName : String, elapsedTime : Float, x : Float, y : Float, ?width : Float = 0, ?height : Float = 0, ?keepRatio : Bool = true) : Void{
		var sprite = sprites[spriteId];

		var frame : Frame = null;
		var error = false;
		//TODO always upload an error texture (in debug mode only ?)
		if (sprite == null) {
				trace("no sprite with id : " + spriteId);
				error = true;
		}else{
				frame = sprite.getFrame(animationName, elapsedTime);
				if (frame == null) {
						error = true;
						trace("no frame for animation : " + animationName);
				}
		}

		if(error){
      width = width == 0 ? 100 : width;
      height = height == 0 ? 100 : height;
      //TODO draw debug placeholder
    }else{
      var mesh = frame.mesh;

      var meshWidth = mesh.x2 - mesh.x1;
      var meshHeight = mesh.y2 - mesh.y1;
      if(width == 0){
        width = meshWidth;
      }
      if(height == 0){
        height = meshHeight;
      }

      var scaleX = width / meshWidth;
      var scaleY = height / meshHeight;

      if(keepRatio){
        scaleX = scaleY = Math.min(scaleX,scaleY);
      }

      var offsetX = mesh.refX * frame.scaleX;
      var offsetY = mesh.refY * frame.scaleY;

      var targetX = - (offsetX * scaleX) + x;
      var targetY = - (offsetY * scaleY) + y;

			g2.drawScaledSubImage(image, mesh.x1, mesh.y1, meshWidth, meshHeight, targetX, targetY, meshWidth * scaleX, meshHeight * scaleY);

		}


	}

}
